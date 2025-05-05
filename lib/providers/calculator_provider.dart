import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calculation.dart';
import 'database_provider.dart';
import 'scientific_operations.dart';

part 'calculator_provider.g.dart';

class CalculatorState {
  final String display;
  final String equation;
  final String currentExpression;
  final bool isNewNumber;
  final List<Calculation> history;
  final bool isLoading;
  final bool isScientificMode;
  static const int maxDigits = 40;

  CalculatorState({
    this.display = '0',
    this.equation = '',
    this.currentExpression = '',
    this.isNewNumber = true,
    List<Calculation>? history,
    this.isLoading = false,
    this.isScientificMode = false,
  }) : history = history ?? [];

  CalculatorState copyWith({
    String? display,
    String? equation,
    String? currentExpression,
    bool? isNewNumber,
    List<Calculation>? history,
    bool? isLoading,
    bool? isScientificMode,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      equation: equation ?? this.equation,
      currentExpression: currentExpression ?? this.currentExpression,
      isNewNumber: isNewNumber ?? this.isNewNumber,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isScientificMode: isScientificMode ?? this.isScientificMode,
    );
  }
}

@riverpod
class Calculator extends _$Calculator {
  @override
  CalculatorState build() {
    _loadHistory();
    return CalculatorState(isLoading: true);
  }

  Future<void> _loadHistory() async {
    try {
      final history = await DatabaseHelper.instance.getAllCalculations();
      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      // If there's an error, just continue with empty history
      state = state.copyWith(history: [], isLoading: false);
    }
  }

  String _formatNumber(String number) {
    if (number.contains('.')) {
      // Remove trailing zeros after decimal point
      while (number.endsWith('0')) {
        number = number.substring(0, number.length - 1);
      }
      // Remove decimal point if it's the last character
      if (number.endsWith('.')) {
        number = number.substring(0, number.length - 1);
      }
    }
    return number;
  }

  void handleBackspace() {
    if (state.currentExpression.isEmpty) {
      state = state.copyWith(display: '0', isNewNumber: true);
      return;
    }

    final newExpression = state.currentExpression.substring(
      0,
      state.currentExpression.length - 1,
    );
    state = state.copyWith(
      currentExpression: newExpression,
      display: newExpression.isEmpty ? '0' : newExpression,
      isNewNumber: newExpression.isEmpty,
    );
  }

  void handleNumber(String number) {
    if (state.currentExpression.length >= CalculatorState.maxDigits) {
      return;
    }

    String newExpression = state.currentExpression;

    // If expression is empty, just add the number
    if (newExpression.isEmpty) {
      newExpression = number;
    } else if (state.isNewNumber) {
      // If it's a new number and the last character is an operator, just add the number
      if (_isOperator(newExpression[newExpression.length - 1])) {
        newExpression += number;
      } else {
        // If it's a new number and no operator, replace the current number
        newExpression = number;
      }
    } else {
      // Don't allow multiple decimal points in a number
      if (number == '.' && _lastNumberHasDecimal(newExpression)) {
        return;
      }
      newExpression += number;
    }

    state = state.copyWith(
      display: newExpression,
      currentExpression: newExpression,
      isNewNumber: false,
    );
  }

  bool _lastNumberHasDecimal(String expression) {
    if (expression.isEmpty) return false;

    final parts = expression.split(RegExp(r'[+\-×÷]'));
    if (parts.isEmpty) return false;

    return parts.last.contains('.');
  }

  void handleOperation(String operation) {
    // Don't allow operations on empty expression
    if (state.currentExpression.isEmpty) {
      return;
    }

    // Don't allow operations if the last character is a decimal point
    if (state.currentExpression.endsWith('.')) {
      return;
    }

    // Don't allow consecutive operators
    if (_isOperator(
      state.currentExpression[state.currentExpression.length - 1],
    )) {
      return;
    }

    state = state.copyWith(
      currentExpression: state.currentExpression + operation,
      display: state.currentExpression + operation,
      isNewNumber: true,
    );
  }

  bool _isOperator(String char) {
    return ['+', '-', '×', '÷'].contains(char);
  }

  Future<void> calculate() async {
    if (state.currentExpression.isEmpty) {
      return;
    }

    try {
      // Remove trailing operators before evaluation
      String expressionToEvaluate = state.currentExpression;
      while (_isOperator(
        expressionToEvaluate[expressionToEvaluate.length - 1],
      )) {
        expressionToEvaluate = expressionToEvaluate.substring(
          0,
          expressionToEvaluate.length - 1,
        );
      }

      if (expressionToEvaluate.isEmpty) {
        state = state.copyWith(
          display: '0',
          currentExpression: '0',
          isNewNumber: true,
        );
        return;
      }

      final result = _evaluateExpression(expressionToEvaluate);
      final formattedResult = _formatNumber(result.toStringAsFixed(10));

      final newCalculation = Calculation(
        expression: expressionToEvaluate,
        result: formattedResult,
        timestamp: DateTime.now(),
      );

      try {
        await DatabaseHelper.instance.insertCalculation(newCalculation);
        await _loadHistory();
      } catch (e) {
        print('Error saving calculation: $e');
      }

      state = state.copyWith(
        display: formattedResult,
        currentExpression: formattedResult,
        isNewNumber: true,
      );
    } catch (e) {
      state = state.copyWith(
        display: 'Error',
        currentExpression: '',
        isNewNumber: true,
      );
    }
  }

  double _evaluateExpression(String expression) {
    // Convert expression to postfix notation (Reverse Polish Notation)
    final postfix = _infixToPostfix(expression);
    return _evaluatePostfix(postfix);
  }

  List<String> _infixToPostfix(String expression) {
    final List<String> output = [];
    final List<String> operators = [];

    final tokens = _tokenizeExpression(expression);

    for (final token in tokens) {
      if (_isNumber(token)) {
        output.add(token);
      } else if (_isOperator(token)) {
        while (operators.isNotEmpty &&
            _getPrecedence(operators.last) >= _getPrecedence(token)) {
          output.add(operators.removeLast());
        }
        operators.add(token);
      }
    }

    while (operators.isNotEmpty) {
      output.add(operators.removeLast());
    }

    return output;
  }

  List<String> _tokenizeExpression(String expression) {
    final List<String> tokens = [];
    String currentNumber = '';

    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];

      if (_isOperator(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      } else {
        currentNumber += char;
      }
    }

    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    return tokens;
  }

  bool _isNumber(String token) {
    return double.tryParse(token) != null;
  }

  int _getPrecedence(String operator) {
    switch (operator) {
      case '×':
      case '÷':
        return 2;
      case '+':
      case '-':
        return 1;
      default:
        return 0;
    }
  }

  double _evaluatePostfix(List<String> postfix) {
    final List<double> stack = [];

    for (final token in postfix) {
      if (_isNumber(token)) {
        stack.add(double.parse(token));
      } else {
        final b = stack.removeLast();
        final a = stack.removeLast();

        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '×':
            stack.add(a * b);
            break;
          case '÷':
            if (b == 0) throw Exception('Division by zero');
            stack.add(a / b);
            break;
        }
      }
    }

    return stack.last;
  }

  void clear() {
    state = CalculatorState(
      history: state.history,
      isScientificMode: state.isScientificMode,
    );
  }

  Future<void> clearHistory() async {
    try {
      await DatabaseHelper.instance.clearHistory();
      state = state.copyWith(history: []);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  void toggleScientificMode() {
    state = state.copyWith(isScientificMode: !state.isScientificMode);
  }

  Future<void> handleScientificFunction(String function) async {
    if (state.display == 'Error') return;

    try {
      final number = double.parse(state.display);
      final scientificOperations = ref.read(scientificOperationsProvider);
      final (result, expression) = scientificOperations.calculate(
        function,
        number,
      );

      final newCalculation = Calculation(
        expression: expression,
        result: _formatNumber(result.toStringAsFixed(10)),
        timestamp: DateTime.now(),
      );

      try {
        await DatabaseHelper.instance.insertCalculation(newCalculation);
        await _loadHistory();
      } catch (e) {
        print('Error saving calculation: $e');
      }

      state = state.copyWith(
        display: _formatNumber(result.toStringAsFixed(10)),
        equation: '',
        isNewNumber: true,
      );
    } catch (e) {
      state = state.copyWith(display: 'Error', equation: '', isNewNumber: true);
    }
  }

  void updateDisplay(String value) {
    state = state.copyWith(
      display: value,
      currentExpression: value,
      isNewNumber: true,
    );
  }
}
