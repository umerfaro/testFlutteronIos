import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Display extends StatelessWidget {
  final String display;
  final String equation;

  const Display({super.key, required this.display, required this.equation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (equation.isNotEmpty)
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: equation));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Equation copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                equation,
                style: const TextStyle(fontSize: 24, color: Colors.grey),
                textAlign: TextAlign.end,
              ),
            ),
          const SizedBox(height: 8),
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: display));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Result copied to clipboard'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              display,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
