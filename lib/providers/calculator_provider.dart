import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calculation.dart';

part 'calculator_provider.g.dart';

class CalculatorState {
  final String display;
  final String equation;
  final double firstNumber;
  final String operation;
  final bool isNewNumber;
  final List<Calculation> history;
  static const int maxDigits = 16;

  CalculatorState({
    this.display = '0',
    this.equation = '',
    this.firstNumber = 0,
    this.operation = '',
    this.isNewNumber = true,
    List<Calculation>? history,
  }) : history = history ?? [];

  CalculatorState copyWith({
    String? display,
    String? equation,
    double? firstNumber,
    String? operation,
    bool? isNewNumber,
    List<Calculation>? history,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      equation: equation ?? this.equation,
      firstNumber: firstNumber ?? this.firstNumber,
      operation: operation ?? this.operation,
      isNewNumber: isNewNumber ?? this.isNewNumber,
      history: history ?? this.history,
    );
  }
}

@riverpod
class Calculator extends _$Calculator {
  @override
  CalculatorState build() {
    return CalculatorState();
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
    if (state.isNewNumber || state.display == '0' || state.display == 'Error') {
      return;
    }

    final currentDisplay = state.display;
    if (currentDisplay.length == 1) {
      state = state.copyWith(display: '0');
    } else {
      state = state.copyWith(
        display: currentDisplay.substring(0, currentDisplay.length - 1),
      );
    }
  }

  void handleNumber(String number) {
    if (state.display.length >= CalculatorState.maxDigits &&
        !state.isNewNumber) {
      return; // Prevent adding more digits if max length reached
    }

    if (state.isNewNumber) {
      state = state.copyWith(display: number, isNewNumber: false);
    } else {
      // Don't allow multiple decimal points
      if (number == '.' && state.display.contains('.')) {
        return;
      }

      state = state.copyWith(
        display:
            state.display == '0' && number != '.'
                ? number
                : state.display + number,
      );
    }
  }

  void handleOperation(String operation) {
    if (state.operation.isEmpty) {
      state = state.copyWith(
        firstNumber: double.parse(state.display),
        operation: operation,
        equation: '${_formatNumber(state.display)} $operation',
        isNewNumber: true,
      );
    } else {
      calculate();
      state = state.copyWith(
        operation: operation,
        equation: '${_formatNumber(state.firstNumber.toString())} $operation',
      );
    }
  }

  void calculate() {
    if (state.operation.isEmpty) return;

    double secondNumber = double.parse(state.display);
    double result = 0;
    String fullEquation =
        '${_formatNumber(state.firstNumber.toString())} ${state.operation} ${_formatNumber(secondNumber.toString())}';

    switch (state.operation) {
      case '+':
        result = state.firstNumber + secondNumber;
        break;
      case '-':
        result = state.firstNumber - secondNumber;
        break;
      case '×':
        result = state.firstNumber * secondNumber;
        break;
      case '÷':
        if (secondNumber == 0) {
          state = state.copyWith(
            display: 'Error',
            equation: '',
            operation: '',
            isNewNumber: true,
          );
          return;
        }
        result = state.firstNumber / secondNumber;
        break;
    }

    // Format the result to prevent scientific notation and limit decimal places
    String formattedResult = _formatNumber(result.toStringAsFixed(10));

    final newCalculation = Calculation(
      expression: fullEquation,
      result: formattedResult,
      timestamp: DateTime.now(),
    );

    final updatedHistory = List<Calculation>.from(state.history)
      ..add(newCalculation);

    state = state.copyWith(
      display: formattedResult,
      firstNumber: result,
      operation: '',
      equation: '',
      isNewNumber: true,
      history: updatedHistory,
    );
  }

  void clear() {
    final currentHistory = state.history;
    state = CalculatorState(history: currentHistory);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }
}
