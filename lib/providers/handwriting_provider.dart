import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/handwriting_expression.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

class HandwritingState {
  final List<List<Offset>> symbols;
  final String recognizedText;
  final String result;
  final bool isProcessing;
  final List<HandwritingExpression> history;

  HandwritingState({
    List<List<Offset>>? symbols,
    this.recognizedText = '',
    this.result = '',
    this.isProcessing = false,
    this.history = const [],
  }) : symbols = symbols ?? const [];

  HandwritingState copyWith({
    List<List<Offset>>? symbols,
    String? recognizedText,
    String? result,
    bool? isProcessing,
    List<HandwritingExpression>? history,
  }) {
    return HandwritingState(
      symbols: symbols ?? this.symbols,
      recognizedText: recognizedText ?? this.recognizedText,
      result: result ?? this.result,
      isProcessing: isProcessing ?? this.isProcessing,
      history: history ?? this.history,
    );
  }
}

class HandwritingNotifier extends StateNotifier<HandwritingState> {
  final Ref ref;
  List<List<Offset>> _symbols = [[]];
  List<Offset> _currentStroke = [];

  HandwritingNotifier(this.ref) : super(HandwritingState(symbols: [[]]));

  void startStroke(Offset point) {
    _currentStroke = [point];
    state = state.copyWith(symbols: allSymbols);
  }

  void continueStroke(Offset point) {
    _currentStroke.add(point);
    state = state.copyWith(symbols: allSymbols);
  }

  void endStroke() {
    if (_currentStroke.isNotEmpty) {
      _symbols.last.addAll(_currentStroke);
      _currentStroke = [];
      state = state.copyWith(symbols: List.from(_symbols));
      // Automatically start a new symbol after each stroke
      _symbols.add([]);
    }
  }

  void nextSymbol() {
    _symbols.add([]);
    state = state.copyWith(symbols: List.from(_symbols));
  }

  void clearCanvas() {
    _symbols = [[]];
    _currentStroke = [];
    state = state.copyWith(
      symbols: List.from(_symbols),
      recognizedText: '',
      result: '',
    );
  }

  Future<void> recognizeExpression() async {
    if (_symbols.every((s) => s.isEmpty)) return;
    state = state.copyWith(isProcessing: true);
    final textRecognizer = TextRecognizer();
    try {
      List<String> recognizedSymbols = [];
      for (final symbol in _symbols.where((s) => s.isNotEmpty)) {
        final imagePath = await _renderSymbolToImage(symbol);
        print('Processing image at $imagePath');
        final inputImage = InputImage.fromFilePath(imagePath);
        final recognized = await textRecognizer.processImage(inputImage);
        final text = recognized.text.trim();
        print('Recognized symbol: "$text"');
        // fallback to placeholder if empty
        recognizedSymbols.add(text.isNotEmpty ? text : '?');
      }
      final rawExpr = recognizedSymbols.join('');
      print('Raw expression: "$rawExpr"');
      // Sanitize for math evaluation
      final expr = rawExpr.replaceAll(RegExp(r'[^0-9\+\-\*\/,\(\)\.]'), '');
      print('Sanitized expression for parsing: "$expr"');

      String resultText;
      if (expr.isEmpty) {
        resultText = 'Could not compute';
      } else {
        try {
          final value = _evaluateMathExpression(expr);
          resultText = value.toString();
          print('Evaluated result: "$resultText"');
        } catch (e) {
          print('Evaluation error: $e');
          resultText = 'Error';
        }
      }
      state = state.copyWith(
        recognizedText: rawExpr,
        result: resultText,
        isProcessing: false,
      );
    } catch (e) {
      print('Recognition outer error: $e');
      state = state.copyWith(
        isProcessing: false,
        recognizedText: 'Error',
        result: '',
      );
    } finally {
      await textRecognizer.close();
    }
  }

  Future<String> _renderSymbolToImage(List<Offset> symbol) async {
    const canvasSize = 256.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasSize, canvasSize),
    );
    // white bg
    final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize, canvasSize), bgPaint);
    double minX = symbol.map((p) => p.dx).reduce(min);
    double minY = symbol.map((p) => p.dy).reduce(min);
    double maxX = symbol.map((p) => p.dx).reduce(max);
    double maxY = symbol.map((p) => p.dy).reduce(max);
    double width = maxX - minX;
    double height = maxY - minY;
    double scale = 0.8 * canvasSize / (max(width, height));
    double offsetX = (canvasSize - width * scale) / 2 - minX * scale;
    double offsetY = (canvasSize - height * scale) / 2 - minY * scale;
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 8.0
          ..strokeCap = StrokeCap.round;
    for (int i = 0; i < symbol.length - 1; i++) {
      final p1 = Offset(
        symbol[i].dx * scale + offsetX,
        symbol[i].dy * scale + offsetY,
      );
      final p2 = Offset(
        symbol[i + 1].dx * scale + offsetX,
        symbol[i + 1].dy * scale + offsetY,
      );
      canvas.drawLine(p1, p2, paint);
    }
    final picture = recorder.endRecording();
    final imgBytes = await (await picture.toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    )).toByteData(format: ui.ImageByteFormat.png);
    final buffer = imgBytes!.buffer;
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/symbol_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(filePath).writeAsBytes(buffer.asUint8List());
    // Basic preprocessing removed to avoid undefined functions
    return filePath;
  }

  num _evaluateMathExpression(String expr) {
    final parser = ShuntingYardParser();
    final parsedExp = parser.parse(expr.replaceAll(',', '/'));
    return parsedExp.evaluate(EvaluationType.REAL, ContextModel());
  }

  List<List<Offset>> get allSymbols {
    final symbols = List<List<Offset>>.from(_symbols);
    if (_currentStroke.isNotEmpty) {
      if (symbols.isEmpty) symbols.add([]);
      symbols.last = List<Offset>.from(_currentStroke);
    }
    return symbols;
  }
}

final handwritingProvider =
    StateNotifierProvider<HandwritingNotifier, HandwritingState>((ref) {
      return HandwritingNotifier(ref);
    });
