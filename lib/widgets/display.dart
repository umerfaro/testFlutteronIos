import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Display extends StatelessWidget {
  final String display;
  final String equation;

  const Display({super.key, required this.display, required this.equation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onLongPress: () {
              if (equation.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: equation));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Equation copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              alignment: Alignment.centerRight,
              child: Text(
                equation,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
              ),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  display,
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
