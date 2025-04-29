import 'package:flutter/material.dart';

class CalculatorButtons extends StatelessWidget {
  final Function(String) onNumberPressed;
  final Function(String) onOperationPressed;
  final VoidCallback onClear;
  final VoidCallback onCalculate;
  final VoidCallback onBackspace;

  const CalculatorButtons({
    super.key,
    required this.onNumberPressed,
    required this.onOperationPressed,
    required this.onClear,
    required this.onCalculate,
    required this.onBackspace,
  });

  Widget _buildButton(
    BuildContext context,
    dynamic content,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).colorScheme.secondary,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child:
              content is String
                  ? Text(
                    content,
                    style: TextStyle(
                      color: color == null ? Colors.white : Colors.black,
                      fontSize: 24,
                    ),
                  )
                  : content is IconData
                  ? Icon(content, size: 24, color: Colors.black)
                  : content,
        ),
      ),
    );
  }

  Widget _buildZeroButton(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => onNumberPressed('0'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: const Text(
            '0',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildButton(context, 'C', onClear, color: Colors.grey),
                _buildButton(
                  context,
                  Icons.backspace_outlined,
                  onBackspace,
                  color: Colors.grey,
                ),
                _buildButton(context, '%', () {}, color: Colors.grey),
                _buildButton(context, '÷', () => onOperationPressed('÷')),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton(context, '7', () => onNumberPressed('7')),
                _buildButton(context, '8', () => onNumberPressed('8')),
                _buildButton(context, '9', () => onNumberPressed('9')),
                _buildButton(context, '×', () => onOperationPressed('×')),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton(context, '4', () => onNumberPressed('4')),
                _buildButton(context, '5', () => onNumberPressed('5')),
                _buildButton(context, '6', () => onNumberPressed('6')),
                _buildButton(context, '-', () => onOperationPressed('-')),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton(context, '1', () => onNumberPressed('1')),
                _buildButton(context, '2', () => onNumberPressed('2')),
                _buildButton(context, '3', () => onNumberPressed('3')),
                _buildButton(context, '+', () => onOperationPressed('+')),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildZeroButton(context),
                _buildButton(context, '.', () => onNumberPressed('.')),
                _buildButton(context, '=', onCalculate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
