import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

class ConversionRecord {
  final int? id;
  final String fromUnit;
  final String toUnit;
  final String inputValue;
  final String result;
  final String unitType;
  final DateTime timestamp;
  ConversionRecord({
    this.id,
    required this.fromUnit,
    required this.toUnit,
    required this.inputValue,
    required this.result,
    required this.unitType,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fromUnit': fromUnit,
    'toUnit': toUnit,
    'inputValue': inputValue,
    'result': result,
    'unitType': unitType,
    'timestamp': timestamp.toIso8601String(),
  };

  static ConversionRecord fromMap(Map<String, dynamic> map) => ConversionRecord(
    id: map['id'],
    fromUnit: map['fromUnit'],
    toUnit: map['toUnit'],
    inputValue: map['inputValue'],
    result: map['result'],
    unitType: map['unitType'],
    timestamp: DateTime.parse(map['timestamp']),
  );
}

class ConversionDatabaseHelper {
  static final ConversionDatabaseHelper instance =
      ConversionDatabaseHelper._init();
  static Database? _database;

  ConversionDatabaseHelper._init() {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('converter.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversion_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromUnit TEXT NOT NULL,
        toUnit TEXT NOT NULL,
        inputValue TEXT NOT NULL,
        result TEXT NOT NULL,
        unitType TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertConversion(ConversionRecord record) async {
    final db = await instance.database;
    return await db.insert('conversion_history', record.toMap());
  }

  Future<List<ConversionRecord>> getAllConversions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversion_history',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ConversionRecord.fromMap(maps[i]));
  }

  Future<void> clearConversionHistory() async {
    final db = await instance.database;
    await db.delete('conversion_history');
  }
}
