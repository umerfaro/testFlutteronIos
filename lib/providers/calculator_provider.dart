import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/calculation.dart';
import 'database_provider.dart';

part 'calculator_provider.g.dart';

class CalculatorState {
  final String display;
  final String equation;
  final double firstNumber;
  final String operation;
  final bool isNewNumber;
  final List<Calculation> history;
  final bool isLoading;
  static const int maxDigits = 16;

  CalculatorState({
    this.display = '0',
    this.equation = '',
    this.firstNumber = 0,
    this.operation = '',
    this.isNewNumber = true,
    List<Calculation>? history,
    this.isLoading = false,
  }) : history = history ?? [];

  CalculatorState copyWith({
    String? display,
    String? equation,
    double? firstNumber,
    String? operation,
    bool? isNewNumber,
    List<Calculation>? history,
    bool? isLoading,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      equation: equation ?? this.equation,
      firstNumber: firstNumber ?? this.firstNumber,
      operation: operation ?? this.operation,
      isNewNumber: isNewNumber ?? this.isNewNumber,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class Calculator extends _$Calculator {
  @override
  CalculatorState build() {
    // Load history asynchronously
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

  Future<void> calculate() async {
    if (state.operation.isEmpty || state.display == 'Error') {
      return;
    }

    final secondNumber = double.parse(state.display);
    final fullEquation =
        '${state.firstNumber} ${state.operation} $secondNumber';
    double result = 0;

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

    String formattedResult = _formatNumber(result.toStringAsFixed(10));

    final newCalculation = Calculation(
      expression: fullEquation,
      result: formattedResult,
      timestamp: DateTime.now(),
    );

    try {
      // Save to database
      await DatabaseHelper.instance.insertCalculation(newCalculation);
      // Update state with new history
      await _loadHistory();
    } catch (e) {
      // If there's an error saving to database, just continue with the calculation
      print('Error saving calculation: $e');
    }

    state = state.copyWith(
      display: formattedResult,
      firstNumber: result,
      operation: '',
      equation: '',
      isNewNumber: true,
    );
  }

  void clear() {
    state = CalculatorState(history: state.history);
  }

  Future<void> clearHistory() async {
    try {
      await DatabaseHelper.instance.clearHistory();
      state = state.copyWith(history: []);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}
