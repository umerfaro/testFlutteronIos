import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/handwriting_provider.dart';
import 'package:path_provider/path_provider.dart';

class HandwritingCanvas extends ConsumerStatefulWidget {
  const HandwritingCanvas({super.key});

  @override
  ConsumerState<HandwritingCanvas> createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends ConsumerState<HandwritingCanvas> {
  @override
  Widget build(BuildContext context) {
    final handwriting = ref.watch(handwritingProvider);
    final notifier = ref.read(handwritingProvider.notifier);
    final allSymbols = notifier.allSymbols;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onPanStart: (details) {
              notifier.startStroke(details.localPosition);
            },
            onPanUpdate: (details) {
              notifier.continueStroke(details.localPosition);
            },
            onPanEnd: (_) {
              notifier.endStroke(); // Always add stroke to current symbol
            },
            child: CustomPaint(
              painter: HandwritingPainter(symbols: allSymbols),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        if (handwriting.isProcessing)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        if (handwriting.recognizedText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              handwriting.recognizedText,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      notifier.clearCanvas();
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Clear', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await notifier.recognizeExpression();
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text(
                      'Recognize',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> symbols;

  HandwritingPainter({required this.symbols});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    for (final symbol in symbols) {
      for (int i = 0; i < symbol.length - 1; i++) {
        canvas.drawLine(symbol[i], symbol[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(HandwritingPainter oldDelegate) {
    return oldDelegate.symbols != symbols;
  }
}
