import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';

class CalculatorButtons extends ConsumerWidget {
  const CalculatorButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.watch(calculatorProvider);
    final isScientificMode = calculator.isScientificMode;

    Widget buttonGrid = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isScientificMode) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                context,
                'sin',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
              _buildButton(
                context,
                'cos',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
              _buildButton(
                context,
                'tan',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
              _buildButton(
                context,
                'log',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                context,
                'x²',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
              _buildButton(
                context,
                'x³',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
              _buildButton(
                context,
                '√',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
              _buildButton(
                context,
                'π',
                Colors.blue.withOpacity(0.8),
                ref: ref,
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(
              context,
              'C',
              Colors.redAccent.withOpacity(0.8),
              ref: ref,
            ),
            _buildButton(context, '⌫', Colors.grey.withOpacity(0.8), ref: ref),
            _buildButton(context, '%', Colors.grey.withOpacity(0.8), ref: ref),
            _buildButton(
              context,
              '÷',
              Colors.orange.withOpacity(0.8),
              ref: ref,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(context, '7', Colors.grey[850]!, ref: ref),
            _buildButton(context, '8', Colors.grey[850]!, ref: ref),
            _buildButton(context, '9', Colors.grey[850]!, ref: ref),
            _buildButton(
              context,
              '×',
              Colors.orange.withOpacity(0.8),
              ref: ref,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(context, '4', Colors.grey[850]!, ref: ref),
            _buildButton(context, '5', Colors.grey[850]!, ref: ref),
            _buildButton(context, '6', Colors.grey[850]!, ref: ref),
            _buildButton(
              context,
              '-',
              Colors.orange.withOpacity(0.8),
              ref: ref,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(context, '1', Colors.grey[850]!, ref: ref),
            _buildButton(context, '2', Colors.grey[850]!, ref: ref),
            _buildButton(context, '3', Colors.grey[850]!, ref: ref),
            _buildButton(
              context,
              '+',
              Colors.orange.withOpacity(0.8),
              ref: ref,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(context, '0', Colors.grey[850]!, flex: 2, ref: ref),
            _buildButton(context, '.', Colors.grey[850]!, ref: ref),
            _buildButton(context, '=', Colors.orange, ref: ref),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:
          isScientificMode
              ? SingleChildScrollView(child: buttonGrid)
              : buttonGrid,
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color color, {
    int flex = 1,
    required WidgetRef ref,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          elevation: 2,
          color: color,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => _handleButtonPress(context, ref, text),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.9), color],
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: text.length > 2 ? 18 : 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleButtonPress(BuildContext context, WidgetRef ref, String text) {
    final calculator = ref.read(calculatorProvider.notifier);

    if (text == 'C') {
      calculator.clear();
    } else if (text == '⌫') {
      calculator.handleBackspace();
    } else if (text == '=') {
      calculator.calculate();
    } else if (['+', '-', '×', '÷', '%'].contains(text)) {
      calculator.handleOperation(text);
    } else if ([
      'sin',
      'cos',
      'tan',
      'log',
      'ln',
      'x²',
      'x³',
      '√',
      '1/x',
      'π',
    ].contains(text)) {
      calculator.handleScientificFunction(text);
    } else {
      calculator.handleNumber(text);
    }
  }
}
