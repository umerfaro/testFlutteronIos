import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math' as math;

part 'scientific_operations.g.dart';

@riverpod
class ScientificOperations extends _$ScientificOperations {
  @override
  ScientificOperations build() {
    return this;
  }

  double _calculateScientificFunction(String function, double number) {
    switch (function) {
      case 'sin':
        return math.sin(number * math.pi / 180);
      case 'cos':
        return math.cos(number * math.pi / 180);
      case 'tan':
        return math.tan(number * math.pi / 180);
      case 'log':
        if (number <= 0) throw Exception('Invalid input for log');
        return math.log(number) / math.ln10;
      case 'ln':
        if (number <= 0) throw Exception('Invalid input for ln');
        return math.log(number);
      case '√':
        if (number < 0) throw Exception('Invalid input for square root');
        return math.sqrt(number);
      case 'x²':
        return number * number;
      case 'x³':
        return number * number * number;
      case '1/x':
        if (number == 0) throw Exception('Division by zero');
        return 1 / number;
      case 'π':
        return math.pi;
      case 'e':
        return math.e;
      case '±':
        return -number;
      default:
        throw Exception('Unknown scientific function');
    }
  }

  String _getExpression(String function, double number) {
    switch (function) {
      case 'sin':
        return 'sin($number)';
      case 'cos':
        return 'cos($number)';
      case 'tan':
        return 'tan($number)';
      case 'log':
        return 'log($number)';
      case 'ln':
        return 'ln($number)';
      case '√':
        return '√($number)';
      case 'x²':
        return '($number)²';
      case 'x³':
        return '($number)³';
      case '1/x':
        return '1/($number)';
      case 'π':
        return 'π';
      case 'e':
        return 'e';
      case '±':
        return '-($number)';
      default:
        return '';
    }
  }

  (double, String) calculate(String function, double number) {
    try {
      final result = _calculateScientificFunction(function, number);
      final expression = _getExpression(function, number);
      return (result, expression);
    } catch (e) {
      rethrow;
    }
  }
}
