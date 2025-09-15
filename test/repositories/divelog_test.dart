import 'package:dive_log_book/models/dive_log.dart';
import 'package:dive_log_book/repositories/divelog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('DiveLogRepository', () {
    late DiveLogRepository diveLogRepository;

    setUpAll(() {
      // テスト環境でFFIを初期化
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      diveLogRepository = DiveLogRepository();
    });

    tearDown(() async {
      // 各テスト後にテストデータをクリア
      final db = await diveLogRepository.database;
      await db.delete('dive_logs');
    });

    test('データベースが正しく初期化される', () async {
      final db = await diveLogRepository.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('テーブルが正しく作成される', () async {
      final db = await diveLogRepository.database;

      // テーブルの存在確認
      final tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='dive_logs'",
      );
      expect(tableExists.isNotEmpty, true);

      // テーブル構造の確認
      final tableInfo = await db.rawQuery('PRAGMA table_info(dive_logs)');
      final columnNames = tableInfo.map((row) => row['name']).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('date'));
      expect(columnNames, contains('place'));
      expect(columnNames, contains('point'));
      expect(columnNames, contains('averageDepth'));
      expect(columnNames, contains('maxDepth'));
    });

    group('ダイブログのCRUD操作', () {
      late DiveLog testDiveLog;

      setUp(() {
        testDiveLog = DiveLog(
          date: DateTime(2023, 6, 15),
          place: 'テスト海岸',
          point: 'テストポイント',
          divingStartTime: '10:30',
          divingEndTime: '11:15',
          averageDepth: 15.5,
          maxDepth: 20.0,
          tankStartPressure: 200.0,
          tankEndPressure: 50.0,
          tankKind: TankKind.STEEL,
          suit: Suit.WET,
          weight: 4.0,
          weather: Weather.SUNNY,
          temperature: 25.0,
          waterTemperature: 18.0,
          transparency: 15.0,
          memo: 'テストダイビング',
        );
      });

      test('ダイブログを正しく挿入できる', () async {
        final id = await diveLogRepository.insertDiveLog(testDiveLog);

        expect(id, greaterThan(0));

        // 挿入されたデータを確認
        final retrievedLog = await diveLogRepository.getDiveLog(id);
        expect(retrievedLog, isNotNull);
        expect(retrievedLog!.place, equals('テスト海岸'));
        expect(retrievedLog.point, equals('テストポイント'));
        expect(retrievedLog.averageDepth, equals(15.5));
        expect(retrievedLog.maxDepth, equals(20.0));
        expect(retrievedLog.tankKind, equals(TankKind.STEEL));
        expect(retrievedLog.suit, equals(Suit.WET));
        expect(retrievedLog.weather, equals(Weather.SUNNY));
      });

      test('ダイブログを正しく更新できる', () async {
        // まず挿入
        final id = await diveLogRepository.insertDiveLog(testDiveLog);

        // 更新用のダイブログ作成
        final updatedLog = testDiveLog.copyWith(
          id: id,
          place: '更新されたテスト海岸',
          averageDepth: 18.0,
          weather: Weather.CLOUDY,
        );

        // 更新実行
        final updateCount = await diveLogRepository.updateDiveLog(updatedLog);
        expect(updateCount, equals(1));

        // 更新されたデータを確認
        final retrievedLog = await diveLogRepository.getDiveLog(id);
        expect(retrievedLog!.place, equals('更新されたテスト海岸'));
        expect(retrievedLog.averageDepth, equals(18.0));
        expect(retrievedLog.weather, equals(Weather.CLOUDY));
        expect(retrievedLog.point, equals('テストポイント')); // 変更していない項目は保持
      });

      test('ダイブログを正しく削除できる', () async {
        // まず挿入
        final id = await diveLogRepository.insertDiveLog(testDiveLog);

        // 削除実行
        final deleteCount = await diveLogRepository.deleteDiveLog(id);
        expect(deleteCount, equals(1));

        // 削除されたことを確認
        final retrievedLog = await diveLogRepository.getDiveLog(id);
        expect(retrievedLog, isNull);
      });

      test('全てのダイブログを日付降順で取得できる', () async {
        // 複数のダイブログを挿入
        final log1 = testDiveLog.copyWith(date: DateTime(2023, 6, 10));
        final log2 = testDiveLog.copyWith(date: DateTime(2023, 6, 15));
        final log3 = testDiveLog.copyWith(date: DateTime(2023, 6, 5));

        await diveLogRepository.insertDiveLog(log1);
        await diveLogRepository.insertDiveLog(log2);
        await diveLogRepository.insertDiveLog(log3);

        // 全ログを取得
        final allLogs = await diveLogRepository.getDiveLogs();

        expect(allLogs.length, equals(3));
        // 日付降順で並んでいることを確認
        expect(allLogs[0].date, equals(DateTime(2023, 6, 15)));
        expect(allLogs[1].date, equals(DateTime(2023, 6, 10)));
        expect(allLogs[2].date, equals(DateTime(2023, 6, 5)));
      });

      test('存在しないIDでダイブログを取得した場合nullが返る', () async {
        final retrievedLog = await diveLogRepository.getDiveLog(999);
        expect(retrievedLog, isNull);
      });
    });

    group('エラーハンドリング', () {
      test('存在しないIDで更新を試みた場合、0が返る', () async {
        final nonExistentLog = DiveLog(
          id: 999,
          date: DateTime(2023, 6, 15),
          place: 'テスト場所',
        );

        final updateCount = await diveLogRepository.updateDiveLog(nonExistentLog);
        expect(updateCount, equals(0));
      });

      test('存在しないIDで削除を試みた場合、0が返る', () async {
        final deleteCount = await diveLogRepository.deleteDiveLog(999);
        expect(deleteCount, equals(0));
      });
    });
  });
}