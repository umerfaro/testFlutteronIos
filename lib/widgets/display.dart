import 'package:flutter/material.dart';

class Display extends StatelessWidget {
  final String display;
  final String equation;

  const Display({super.key, required this.display, required this.equation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              equation,
              style: const TextStyle(color: Colors.grey, fontSize: 24),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              display,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
