import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/dive_log.dart';

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
    String path = join(await getDbPath(), 'dive_log_book.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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

  // ダイブログの追加
  Future<int> insertDiveLog(DiveLog diveLog) async {
    final db = await database;
    return await db.insert(
      'dive_logs',
      diveLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ダイブログの更新
  Future<int> updateDiveLog(DiveLog diveLog) async {
    final db = await database;
    return await db.update(
      'dive_logs',
      diveLog.toMap(),
      where: 'id = ?',
      whereArgs: [diveLog.id],
    );
  }

  // ダイブログの削除
  Future<int> deleteDiveLog(int id) async {
    final db = await database;
    return await db.delete('dive_logs', where: 'id = ?', whereArgs: [id]);
  }

  // 全てのダイブログを取得
  Future<List<DiveLog>> getDiveLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dive_logs',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return DiveLog.fromMap(maps[i]);
    });
  }

  // 特定のダイブログを取得
  Future<DiveLog?> getDiveLog(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dive_logs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DiveLog.fromMap(maps.first);
    }
    return null;
  }
}
