import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/display.dart';
import '../widgets/calculator_buttons.dart';
import '../providers/calculator_provider.dart';
import '../screens/converter_screen.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = ref.watch(calculatorProvider);
    final isScientificMode = calculator.isScientificMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.calculate_outlined),
          tooltip: 'Calculator Mode',
          onSelected: (value) {
            if (value == 'toggle') {
              ref.read(calculatorProvider.notifier).toggleScientificMode();
            } else if (value == 'converter') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConverterScreen(),
                ),
              );
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        calculator.isScientificMode
                            ? Icons.calculate
                            : Icons.science_outlined,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        calculator.isScientificMode
                            ? 'Switch to Basic'
                            : 'Switch to Scientific',
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'converter',
                  child: Row(
                    children: const [
                      Icon(Icons.swap_horiz, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Switch to Converter'),
                    ],
                  ),
                ),
              ],
        ),
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
            if (!isScientificMode) const Spacer(flex: 2),
            Expanded(
              flex: isScientificMode ? 1 : 2,
              child: Display(
                display: calculator.display,
                equation: calculator.equation,
              ),
            ),
            Expanded(
              flex: isScientificMode ? 2 : 4,
              child: const CalculatorButtons(),
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
              final calculator = ref.watch(calculatorProvider);
              if (calculator.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
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
                            onPressed: () async {
                              Navigator.pop(context);
                              await ref
                                  .read(calculatorProvider.notifier)
                                  .clearHistory();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: calculator.history.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          final calculation = calculator.history[index];
                          return GestureDetector(
                            onLongPress: () {
                              final textToCopy =
                                  '${calculation.expression} = ${calculation.result}';
                              Clipboard.setData(
                                ClipboardData(text: textToCopy),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Calculation copied to clipboard',
                                  ),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: ListTile(
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
