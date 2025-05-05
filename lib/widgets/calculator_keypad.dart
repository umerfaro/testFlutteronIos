import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';

class CalculatorKeypad extends ConsumerWidget {
  const CalculatorKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 4,
      children: [
        _buildButton('7', ref),
        _buildButton('8', ref),
        _buildButton('9', ref),
        _buildOperationButton('÷', ref),
        _buildButton('4', ref),
        _buildButton('5', ref),
        _buildButton('6', ref),
        _buildOperationButton('×', ref),
        _buildButton('1', ref),
        _buildButton('2', ref),
        _buildButton('3', ref),
        _buildOperationButton('-', ref),
        _buildButton('0', ref),
        _buildButton('.', ref),
        _buildEqualsButton(ref),
        _buildOperationButton('+', ref),
      ],
    );
  }

  Widget _buildButton(String text, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => ref.read(calculatorProvider.notifier).handleNumber(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 24)),
    );
  }

  Widget _buildOperationButton(String text, WidgetRef ref) {
    return ElevatedButton(
      onPressed:
          () => ref.read(calculatorProvider.notifier).handleOperation(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 24)),
    );
  }

  Widget _buildEqualsButton(WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => ref.read(calculatorProvider.notifier).calculate(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('=', style: TextStyle(fontSize: 24)),
    );
  }
}
