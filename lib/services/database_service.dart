import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<String> getDbPath() async {
    final dbDirectory = await getApplicationSupportDirectory();
    final dbFilePath = dbDirectory.path;
    final path = join(dbFilePath, 'sample.db');
    return path;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _onCreate,
      );
    } else {
      String path = join(await getDbPath(), 'dive_log_book.db');
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dive_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        place TEXT,
        point TEXT,
        divingStartTime TEXT,
        divingEndTime TEXT,
        averageDepth REAL,
        maxDepth REAL,
        tankStartPressure REAL,
        tankEndPressure REAL,
        tankKind TEXT,
        suit TEXT,
        weight REAL,
        weather TEXT,
        temperature REAL,
        waterTemperature REAL,
        transparency REAL,
        memo TEXT
      )
    ''');
  }

}
