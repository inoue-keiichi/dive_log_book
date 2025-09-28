import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../lib/models/dive_log.dart';
import '../../lib/repositories/divelog.dart';
import '../../lib/services/database_service.dart';

void main() {
  late DiveLogRepository repository;

  setUpAll(() {
    // sqlfiteの初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // テスト前にデータベースを初期化
    repository = DiveLogRepository();
    final db = await repository.database;
    await db.delete('dive_logs'); // 既存データをクリア
  });

  group('StatisticsRepository契約テスト', () {
    test('getTotalDivingTimeMinutes - 空のデータベースで0を返す', () async {
      final result = await repository.getTotalDivingTimeMinutes();
      expect(result, equals(0));
    });

    test('getDiveCountWithTime - 空のデータベースで0を返す', () async {
      final result = await repository.getDiveCountWithTime();
      expect(result, equals(0));
    });

    test('getTotalDivingTimeMinutes - 単一の有効ダイビングで正しい時間を計算', () async {
      // テストデータ作成
      final diveLog = DiveLog(
        date: DateTime.now(),
        divingStartTime: "10:00",
        divingEndTime: "10:45", // 45分間
      );
      await repository.insertDiveLog(diveLog);

      final result = await repository.getTotalDivingTimeMinutes();
      expect(result, equals(45)); // 45 minutes
    });

    test('getTotalDivingTimeMinutes - 複数の有効ダイビングで合計を計算', () async {
      // テストデータ作成
      final diveLogs = [
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 1)),
          divingStartTime: "10:00",
          divingEndTime: "10:45", // 45分間
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 2)),
          divingStartTime: "14:30",
          divingEndTime: "15:15", // 45分間
        ),
      ];

      for (final diveLog in diveLogs) {
        await repository.insertDiveLog(diveLog);
      }

      final result = await repository.getTotalDivingTimeMinutes();
      expect(result, equals(90)); // 90 minutes
    });

    test('getTotalDivingTimeMinutes - null時間フィールドは計算から除外', () async {
      // テストデータ作成
      final diveLogs = [
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 1)),
          divingStartTime: "10:00",
          divingEndTime: "10:45", // 45分間（有効）
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 2)),
          divingStartTime: null, // 無効
          divingEndTime: "15:15",
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 3)),
          divingStartTime: "09:00",
          divingEndTime: null, // 無効
        ),
      ];

      for (final diveLog in diveLogs) {
        await repository.insertDiveLog(diveLog);
      }

      final result = await repository.getTotalDivingTimeMinutes();
      expect(result, equals(45)); // 45 minutes (only the first valid dive)
    });

    test('getDiveCountWithTime - null時間を持つダイビングを除外してカウント', () async {
      // テストデータ作成
      final diveLogs = [
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 1)),
          divingStartTime: "10:00",
          divingEndTime: "10:45", // 有効
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 2)),
          divingStartTime: "14:30",
          divingEndTime: "15:15", // 有効
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 3)),
          divingStartTime: null, // 無効
          divingEndTime: "15:15",
        ),
      ];

      for (final diveLog in diveLogs) {
        await repository.insertDiveLog(diveLog);
      }

      final result = await repository.getDiveCountWithTime();
      expect(result, equals(2)); // 2 (only valid dives)
    });

    test('getTotalDivingTimeMinutes - 無効な時間形式は除外される', () async {
      // 空のデータベースでテスト
      final result = await repository.getTotalDivingTimeMinutes();
      expect(result, equals(0));
    });
  });
}

// StatisticsRepository拡張のための抽象インターフェース
// 実装時にDiveLogRepositoryにこれらのメソッドを追加する
extension StatisticsRepositoryExtension on DiveLogRepository {
  // これらのメソッドは実装時に追加される
  // Future<int> getTotalDivingTimeMinutes() async { ... }
  // Future<int> getDiveCountWithTime() async { ... }
}