import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calculator_provider.dart';

class HistoryPanel extends ConsumerWidget {
  const HistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(calculatorProvider).history;

    return Container(
      color: Colors.grey[900],
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
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed:
                      () =>
                          ref.read(calculatorProvider.notifier).clearHistory(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final calculation = history[index];
                return ListTile(
                  title: Text(
                    calculation.expression,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  subtitle: Text(
                    calculation.result,
                    style: const TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                  trailing: Text(
                    _formatTimestamp(calculation.timestamp),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () {
                    ref
                        .read(calculatorProvider.notifier)
                        .updateDisplay(calculation.result);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
