import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/handwriting_canvas.dart';
import '../providers/calculator_provider.dart';

class HandwritingScreen extends ConsumerWidget {
  const HandwritingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.draw_outlined),
          tooltip: 'Calculator Mode',
          onSelected: (value) {
            if (value == 'calculator') {
              Navigator.pop(context);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'calculator',
                  child: Row(
                    children: [
                      Icon(Icons.calculate_outlined, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Switch to Calculator'),
                    ],
                  ),
                ),
              ],
        ),
        title: const Text('Handwriting', style: TextStyle(color: Colors.white)),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: HandwritingCanvas(),
        ),
      ),
    );
  }
}
