import 'package:dive_log_book/features/statistics/use_statistics.dart';
import 'package:dive_log_book/models/dive_log.dart';
import 'package:dive_log_book/providers/database_service_provider.dart';
import 'package:dive_log_book/repositories/divelog.dart';
import 'package:dive_log_book/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DiveLogRepository repository;
  late DatabaseService databaseService;

  setUpAll(() {
    // sqlfiteの初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseService = DatabaseService();
    repository = DiveLogRepository();
    final db = await repository.database;
    await db.delete('dive_logs');
  });

  group('useStatistics Hook Test', () {
    testWidgets('useStatistics - 初期状態でロード中を返す', (WidgetTester tester) async {
      late bool isLoading;

      await tester.pumpWidget(
        MaterialApp(
          home: DatabaseServiceProvider(
            databaseService: databaseService,
            child: HookBuilder(
              builder: (context) {
                final result = useStatistics();
                isLoading = result.isLoading;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // 初回レンダリング時はロード中であることを確認
      expect(isLoading, true);
    });

    testWidgets('useStatistics - データなし状態で0を返す', (WidgetTester tester) async {
      late bool isLoading;
      late int totalMinutes;
      late int diveCount;

      await tester.pumpWidget(
        MaterialApp(
          home: DatabaseServiceProvider(
            databaseService: databaseService,
            child: HookBuilder(
              builder: (context) {
                final result = useStatistics();
                isLoading = result.isLoading;
                totalMinutes = result.totalMinutes;
                diveCount = result.diveCount;

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // フレームを進めて非同期処理完了を待つ
      await tester.pumpAndSettle();

      // データがない場合は0が返される
      expect(isLoading, false);
      expect(totalMinutes, 0);
      expect(diveCount, 0);
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

      for (final diveLog in diveLogs) {
        await repository.insertDiveLog(diveLog);
      }

      late bool isLoading;
      late int totalMinutes;
      late int diveCount;

      await tester.pumpWidget(
        MaterialApp(
          home: DatabaseServiceProvider(
            databaseService: databaseService,
            child: HookBuilder(
              builder: (context) {
                final result = useStatistics();
                isLoading = result.isLoading;
                totalMinutes = result.totalMinutes;
                diveCount = result.diveCount;

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 統計データが正しく計算されることを確認
      expect(isLoading, false);
      expect(totalMinutes, 105); // 45 + 60 = 105分
      expect(diveCount, 2);
    });

    testWidgets('useStatistics - エラー状態の初期値はnull', (WidgetTester tester) async {
      late String? error;

      await tester.pumpWidget(
        MaterialApp(
          home: DatabaseServiceProvider(
            databaseService: databaseService,
            child: HookBuilder(
              builder: (context) {
                final result = useStatistics();
                error = result.error;

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // エラーがない場合はnull
      expect(error, isNull);
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
      await repository.insertDiveLog(diveLog);

      late DiveDuration diveDuration;

      await tester.pumpWidget(
        MaterialApp(
          home: DatabaseServiceProvider(
            databaseService: databaseService,
            child: HookBuilder(
              builder: (context) {
                final result = useStatistics();
                diveDuration = result.diveDuration;

                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 時間が正しくフォーマットされることを確認
      expect(diveDuration.hour, 2);
      expect(diveDuration.minute, 5);
    });
  });
}
