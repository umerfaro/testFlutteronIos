import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/calculation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use the native implementation
      databaseFactory = databaseFactory;
    } else {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calculator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE calculations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertCalculation(Calculation calculation) async {
    try {
      final db = await instance.database;
      return await db.insert('calculations', {
        'expression': calculation.expression,
        'result': calculation.result,
        'timestamp': calculation.timestamp.toIso8601String(),
      });
    } catch (e) {
      print('Error inserting calculation: $e');
      rethrow;
    }
  }

  Future<List<Calculation>> getAllCalculations() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'calculations',
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) {
        return Calculation(
          expression: maps[i]['expression'],
          result: maps[i]['result'],
          timestamp: DateTime.parse(maps[i]['timestamp']),
        );
      });
    } catch (e) {
      print('Error getting calculations: $e');
      return [];
    }
  }

  Future<void> clearHistory() async {
    try {
      final db = await instance.database;
      await db.delete('calculations');
    } catch (e) {
      print('Error clearing history: $e');
      rethrow;
    }
  }
}
