import 'package:sqflite/sqflite.dart';

import '../models/dive_log.dart';
import '../services/database_service.dart';
import '../utils/date_formatter.dart';

class DiveLogRepository {
  static final DiveLogRepository _instance = DiveLogRepository._internal();
  final DatabaseService _databaseService = DatabaseService();

  factory DiveLogRepository() {
    return _instance;
  }

  DiveLogRepository._internal();

  // テスト用のデータベースアクセス
  Future<Database> get database => _databaseService.database;

  Future<int> insertDiveLog(DiveLog diveLog) async {
    final db = await _databaseService.database;
    return await db.insert(
      'dive_logs',
      _buildDiveLogMap(diveLog),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateDiveLog(DiveLog diveLog) async {
    final db = await _databaseService.database;
    return await db.update(
      'dive_logs',
      _buildDiveLogMap(diveLog),
      where: 'id = ?',
      whereArgs: [diveLog.id],
    );
  }

  Future<int> deleteDiveLog(int id) async {
    final db = await _databaseService.database;
    return await db.delete('dive_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DiveLog>> getDiveLogs() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dive_logs',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return _buildDiveLog(maps[i]);
    });
  }

  Future<DiveLog?> getDiveLog(int id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dive_logs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _buildDiveLog(maps.first);
    }
    return null;
  }

  Map<String, dynamic> _buildDiveLogMap(DiveLog diveLog) {
    return {
      'id': diveLog.id,
      'date': DateFormatter.formatDate(diveLog.date),
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

  DiveLog _buildDiveLog(Map<String, dynamic> map) {
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

  // 統計機能拡張メソッド
  Future<int> getTotalDivingTimeMinutes() async {
    final db = await _databaseService.database;

    final result = await db.rawQuery('''
      SELECT SUM(
        (CAST(substr(divingEndTime, 1, 2) AS INTEGER) * 60 +
         CAST(substr(divingEndTime, 4, 2) AS INTEGER)) -
        (CAST(substr(divingStartTime, 1, 2) AS INTEGER) * 60 +
         CAST(substr(divingStartTime, 4, 2) AS INTEGER))
      ) as total_minutes
      FROM dive_logs
      WHERE divingStartTime IS NOT NULL
        AND divingEndTime IS NOT NULL
        AND divingStartTime LIKE '__:__'
        AND divingEndTime LIKE '__:__'
        AND LENGTH(divingStartTime) = 5
        AND LENGTH(divingEndTime) = 5
    ''');

    if (result.isNotEmpty && result.first['total_minutes'] != null) {
      return result.first['total_minutes'] as int;
    }
    return 0;
  }

  Future<int> getDiveCountWithTime() async {
    final db = await _databaseService.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM dive_logs
      WHERE divingStartTime IS NOT NULL
        AND divingEndTime IS NOT NULL
        AND divingStartTime LIKE '__:__'
        AND divingEndTime LIKE '__:__'
        AND LENGTH(divingStartTime) = 5
        AND LENGTH(divingEndTime) = 5
    ''');

    if (result.isNotEmpty && result.first['count'] != null) {
      return result.first['count'] as int;
    }
    return 0;
  }
}
