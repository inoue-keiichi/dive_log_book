import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  // ダイブログの追加
  Future<int> insertDiveLog(DiveLog diveLog) async {
    final db = await database;
    return await db.insert(
      'dive_logs',
      buildDiveLogMap(diveLog),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ダイブログの更新
  Future<int> updateDiveLog(DiveLog diveLog) async {
    final db = await database;
    return await db.update(
      'dive_logs',
      buildDiveLogMap(diveLog),
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
      return buildDiveLog(maps[i]);
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
      return buildDiveLog(maps.first);
    }
    return null;
  }
}

Map<String, dynamic> buildDiveLogMap(DiveLog diveLog) {
  return {
    'id': diveLog.id,
    'date': DateFormat("yyyy-MM-dd").format(diveLog.date),
    'place': diveLog.place,
    'point': diveLog.point,
    'divingStartTime': diveLog.divingStartTime,
    'divingEndTime': diveLog.divingEndTime,
    'averageDepth': diveLog.averageDepth,
    'maxDepth': diveLog.maxDepth,
    'tankStartPressure': diveLog.tankStartPressure,
    'tankEndPressure': diveLog.tankEndPressure,
    'tankKind': diveLog.tankKind?.name,
    'suit': diveLog.suit?.name,
    'weight': diveLog.weight,
    'weather': diveLog.weather?.name,
    'temperature': diveLog.temperature,
    'waterTemperature': diveLog.waterTemperature,
    'transparency': diveLog.transparency,
    'memo': diveLog.memo,
  };
}

// データベースから取得したMapからDiveLogオブジェクトを作成
DiveLog buildDiveLog(Map<String, dynamic> map) {
  return DiveLog(
    id: map['id'],
    date: DateTime.parse(map['date']),
    place: map['place'],
    point: map['point'],
    divingStartTime: map['divingStartTime'],
    divingEndTime: map['divingEndTime'],
    averageDepth: map['averageDepth']?.toDouble(),
    maxDepth: map['maxDepth']?.toDouble(),
    tankStartPressure: map['tankStartPressure']?.toDouble(),
    tankEndPressure: map['tankEndPressure']?.toDouble(),
    tankKind:
        map['tankKind'] != null
            ? TankKind.values.firstWhere(
              (e) => e.toString() == 'TankKind.${map['tankKind']}',
              orElse: () => TankKind.STEEL,
            )
            : null,
    suit:
        map['suit'] != null
            ? Suit.values.firstWhere(
              (e) => e.toString() == 'Suit.${map['suit']}',
              orElse: () => Suit.WET,
            )
            : null,
    weight: map['weight']?.toDouble(),
    weather:
        map['weather'] != null
            ? Weather.values.firstWhere(
              (e) => e.toString() == 'Weather.${map['weather']}',
              orElse: () => Weather.SUNNY,
            )
            : null,
    temperature: map['temperature']?.toDouble(),
    waterTemperature: map['waterTemperature']?.toDouble(),
    transparency: map['transparency']?.toDouble(),
    memo: map['memo'],
  );
}
