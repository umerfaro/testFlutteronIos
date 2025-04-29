import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/display.dart';
import '../widgets/calculator_buttons.dart';
import '../providers/calculator_provider.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.watch(calculatorProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Display(
                display: calculator.display,
                equation: calculator.equation,
              ),
            ),
            Expanded(
              flex: 2,
              child: CalculatorButtons(
                onNumberPressed:
                    (number) => ref
                        .read(calculatorProvider.notifier)
                        .handleNumber(number),
                onOperationPressed:
                    (operation) => ref
                        .read(calculatorProvider.notifier)
                        .handleOperation(operation),
                onClear: () => ref.read(calculatorProvider.notifier).clear(),
                onCalculate:
                    () => ref.read(calculatorProvider.notifier).calculate(),
                onBackspace:
                    () =>
                        ref.read(calculatorProvider.notifier).handleBackspace(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Consumer(
            builder: (context, ref, child) {
              final history = ref.watch(calculatorProvider).history;
              return Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'History',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              ref
                                  .read(calculatorProvider.notifier)
                                  .clearHistory();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final calculation = history[index];
                          return ListTile(
                            title: Text(
                              calculation.expression,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '= ${calculation.result}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 18,
                              ),
                            ),
                            trailing: Text(
                              '${calculation.timestamp.hour.toString().padLeft(2, '0')}:${calculation.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
