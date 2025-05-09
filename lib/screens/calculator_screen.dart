import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/display.dart';
import '../widgets/calculator_buttons.dart';
import '../providers/calculator_provider.dart';
import '../screens/converter_screen.dart';
import '../screens/handwriting_screen.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  void _navigateToConverter(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const ConverterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToHandwriting(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const HandwritingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _navigateToConverter(context);
            } else if (value == 'handwriting') {
              _navigateToHandwriting(context);
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
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'handwriting',
                  child: Row(
                    children: const [
                      Icon(Icons.draw_outlined, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Switch to Handwriting'),
                    ],
                  ),
                ),
              ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => Consumer(
                      builder: (context, ref, child) {
                        final calculator = ref.watch(calculatorProvider);
                        if (calculator.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
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
                                    final calculation =
                                        calculator.history[index];
                                    return GestureDetector(
                                      onLongPress: () {
                                        final textToCopy =
                                            '${calculation.expression} = ${calculation.result}';
                                        Clipboard.setData(
                                          ClipboardData(text: textToCopy),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
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
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
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
            },
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
}
