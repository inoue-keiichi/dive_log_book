import 'package:dive_log_book/features/statistics/use_statistics.dart';
import 'package:dive_log_book/models/dive_log.dart';
import 'package:dive_log_book/providers/database_service_provider.dart';
import 'package:dive_log_book/repositories/divelog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DiveLogRepository repository;
  late DataAccessProvider dataAccess;

  setUpAll(() {
    // sqlfiteの初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dataAccess = DataAccessProvider();
    repository = await dataAccess.createDiveLogRepository();
    final db = repository.db;
    await db.delete('dive_logs');
  });

  group('useStatistics Hook Test', () {
    testWidgets('useStatistics - データなし状態で0を返す', (WidgetTester tester) async {
      late StatisticsResult result;
      await tester.pumpWidget(
        HookBuilder(
          builder: (context) {
            result = useStatistics(dataAccess);
            return GestureDetector();
          },
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });

      // データがない場合は0が返される
      expect(result.isLoading.value, false);
      expect(result.error.value, null);
      expect(result.diveDuration.value.hour, 0);
      expect(result.diveDuration.value.minute, 0);
      expect(result.diveCount.value, 0);
    });

    testWidgets('useStatistics - 有効なダイビングデータで正しい統計を返す', (
      WidgetTester tester,
    ) async {
      // テストデータを事前に挿入
      final diveLogs = [
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 1)),
          divingStartTime: "10:00",
          divingEndTime: "10:45", // 45分
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 2)),
          divingStartTime: "14:30",
          divingEndTime: "15:30", // 60分
        ),
      ];

      await tester.runAsync(() async {
        for (final diveLog in diveLogs) {
          await repository.insertDiveLog(diveLog);
        }
      });

      late StatisticsResult result;
      await tester.pumpWidget(
        HookBuilder(
          builder: (context) {
            result = useStatistics(dataAccess);
            return GestureDetector();
          },
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });

      // 統計データが正しく計算されることを確認
      expect(result.isLoading.value, false);
      expect(result.error.value, null);
      expect(result.diveDuration.value.hour, 1);
      expect(result.diveDuration.value.minute, 45);
      expect(result.diveCount.value, 2);
    });

    testWidgets('useStatistics - フォーマットされた時間文字列を返す', (
      WidgetTester tester,
    ) async {
      // 125分のテストデータ (2時間5分)
      final diveLog = DiveLog(
        date: DateTime.now(),
        divingStartTime: "10:00",
        divingEndTime: "12:05", // 125分
      );
      await tester.runAsync(() async {
        await repository.insertDiveLog(diveLog);
      });

      late StatisticsResult result;
      await tester.pumpWidget(
        HookBuilder(
          builder: (context) {
            result = useStatistics(dataAccess);

            return const SizedBox();
          },
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 500));
      });

      // 時間が正しくフォーマットされることを確認
      expect(result.diveDuration.value.hour, 2);
      expect(result.diveDuration.value.minute, 5);
    });
  });
}
