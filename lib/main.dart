import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'screens/calculator_screen.dart';

void main() {
  // Initialize FFI for non-mobile platforms
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
  }

  runApp(const ProviderScope(child: CalculatorApp()));
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.grey[800]!,
          surface: Colors.black,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}
