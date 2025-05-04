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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('C', onClear, color: Colors.grey[800]),
                _buildButton('⌫', onBackspace, color: Colors.grey[800]),
                _buildButton(
                  '%',
                  () => onOperationPressed('%'),
                  color: Colors.grey[800],
                ),
                _buildButton(
                  '÷',
                  () => onOperationPressed('÷'),
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('7', () => onNumberPressed('7')),
                _buildButton('8', () => onNumberPressed('8')),
                _buildButton('9', () => onNumberPressed('9')),
                _buildButton(
                  '×',
                  () => onOperationPressed('×'),
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('4', () => onNumberPressed('4')),
                _buildButton('5', () => onNumberPressed('5')),
                _buildButton('6', () => onNumberPressed('6')),
                _buildButton(
                  '-',
                  () => onOperationPressed('-'),
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('1', () => onNumberPressed('1')),
                _buildButton('2', () => onNumberPressed('2')),
                _buildButton('3', () => onNumberPressed('3')),
                _buildButton(
                  '+',
                  () => onOperationPressed('+'),
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton('0', () => onNumberPressed('0'), flex: 2),
                _buildButton('.', () => onNumberPressed('.')),
                _buildButton('=', onCalculate, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    Color? color,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: color ?? Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: color == Colors.orange ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
