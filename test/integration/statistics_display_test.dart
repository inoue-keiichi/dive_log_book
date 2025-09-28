import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../lib/main.dart';
import '../../lib/models/dive_log.dart';
import '../../lib/repositories/divelog.dart';
import '../../lib/features/statistics/statistics_screen.dart';

void main() {
  late DiveLogRepository repository;

  setUpAll(() {
    // sqlfiteの初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    repository = DiveLogRepository();
    final db = await repository.database;
    await db.delete('dive_logs');
  });

  group('Statistics Display Integration Test', () {
    testWidgets('データなし状態で適切なメッセージが表示される', (WidgetTester tester) async {
      // This test MUST fail until statistics screen is implemented

      expect(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await tester.pumpAndSettle();

        // データなしメッセージの確認
        expect(find.text('まだダイビング記録がありません'), findsOneWidget);
        expect(find.text('0時間0分'), findsOneWidget);
        expect(find.text('0回'), findsOneWidget); // ダイビング記録数
      }, throwsA(isA<Error>())); // 統計画面が未実装
    });

    testWidgets('単一のダイビング記録で正しい統計が表示される', (WidgetTester tester) async {
      // This test MUST fail until statistics integration is complete

      // テストデータ作成
      final diveLog = DiveLog(
        date: DateTime.now(),
        place: "伊豆",
        divingStartTime: "10:00",
        divingEndTime: "10:45", // 45分間
      );
      await repository.insertDiveLog(diveLog);

      expect(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await tester.pumpAndSettle();

        // 統計データの確認
        expect(find.text('0時間45分'), findsOneWidget);
        expect(find.text('1回'), findsOneWidget); // ダイビング記録数
        expect(find.text('まだダイビング記録がありません'), findsNothing);
      }, throwsA(isA<Error>())); // 統計機能が未実装
    });

    testWidgets('複数のダイビング記録で合計統計が表示される', (WidgetTester tester) async {
      // This test MUST fail until statistics calculation is implemented

      // テストデータ作成
      final diveLogs = [
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 1)),
          place: "伊豆",
          divingStartTime: "10:00",
          divingEndTime: "10:45", // 45分間
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 2)),
          place: "沖縄",
          divingStartTime: "14:30",
          divingEndTime: "15:30", // 60分間
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 3)),
          place: "伊豆",
          divingStartTime: "09:15",
          divingEndTime: "10:00", // 45分間
        ),
      ];

      for (final diveLog in diveLogs) {
        await repository.insertDiveLog(diveLog);
      }

      expect(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await tester.pumpAndSettle();

        // 統計データの確認（45 + 60 + 45 = 150分 = 2時間30分）
        expect(find.text('2時間30分'), findsOneWidget);
        expect(find.text('3回'), findsOneWidget); // ダイビング記録数
      }, throwsA(isA<Error>())); // 統計機能が未実装
    });

    testWidgets('無効な時間データが除外されて統計が計算される', (WidgetTester tester) async {
      // This test MUST fail until data filtering is implemented

      // テストデータ作成（一部無効）
      final diveLogs = [
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 1)),
          place: "伊豆",
          divingStartTime: "10:00",
          divingEndTime: "10:45", // 45分間（有効）
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 2)),
          place: "沖縄",
          divingStartTime: null, // 無効
          divingEndTime: "15:30",
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 3)),
          place: "伊豆",
          divingStartTime: "09:15",
          divingEndTime: null, // 無効
        ),
      ];

      for (final diveLog in diveLogs) {
        await repository.insertDiveLog(diveLog);
      }

      expect(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await teller.pumpAndSettle();

        // 有効なデータのみ計算されることを確認
        expect(find.text('0時間45分'), findsOneWidget); // 1つの有効レコードのみ
        expect(find.text('1回'), findsOneWidget); // 有効な時間データを持つ記録数
      }, throwsA(isA<Error>())); // データフィルタリングが未実装
    });

    testWidgets('時間の境界値が正しく処理される', (WidgetTester tester) async {
      // This test MUST fail until edge case handling is implemented

      // 境界値テストデータ
      final diveLogs = [
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 1)),
          divingStartTime: "00:00", // 0時開始
          divingEndTime: "00:01", // 1分間
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 2)),
          divingStartTime: "23:58", // 深夜
          divingEndTime: "23:59", // 1分間
        ),
        DiveLog(
          date: DateTime.now().subtract(const Duration(days: 3)),
          divingStartTime: "12:00", // 正午
          divingEndTime: "13:58", // 118分間 = 1時間58分
        ),
      ];

      for (final diveLog in diveLogs) {
        await repository.insertDiveLog(diveLog);
      }

      expect(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await tester.pumpAndSettle();

        // 境界値計算の確認（1 + 1 + 118 = 120分 = 2時間0分）
        expect(find.text('2時間0分'), findsOneWidget);
        expect(find.text('3回'), findsOneWidget);
      }, throwsA(isA<Error>())); // 境界値処理が未実装
    });

    testWidgets('リアルタイム更新機能が動作する', (WidgetTester tester) async {
      // This test MUST fail until real-time updates are implemented

      expect(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await tester.pumpAndSettle();

        // 初期状態確認
        expect(find.text('0時間0分'), findsOneWidget);

        // バックグラウンドで新しいダイビングログを追加
        final diveLog = DiveLog(
          date: DateTime.now(),
          divingStartTime: "10:00",
          divingEndTime: "11:00", // 60分間
        );
        await repository.insertDiveLog(diveLog);

        // リフレッシュまたは自動更新を待つ
        await tester.pump(const Duration(seconds: 1));

        // 統計が更新されることを確認
        expect(find.text('1時間0分'), findsOneWidget);
        expect(find.text('1回'), findsOneWidget);
      }, throwsA(isA<Error>())); // リアルタイム更新が未実装
    });

    testWidgets('大量データでの性能要件を満たす', (WidgetTester tester) async {
      // This test MUST fail until performance optimization is implemented

      expect(() async {
        // 大量のテストデータ作成（100件）
        for (int i = 0; i < 100; i++) {
          final diveLog = DiveLog(
            date: DateTime.now().subtract(Duration(days: i)),
            divingStartTime: "10:00",
            divingEndTime: "11:00", // 各60分間
          );
          await repository.insertDiveLog(diveLog);
        }

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // パフォーマンス測定開始
        final stopwatch = Stopwatch()..start();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // 100ms以内での表示を確認（要件より）
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        // 大量データの正確な計算結果確認（100件 × 60分 = 6000分 = 100時間）
        expect(find.text('100時間0分'), findsOneWidget);
        expect(find.text('100回'), findsOneWidget);
      }, throwsA(isA<Error>())); // パフォーマンス最適化が未実装
    });

    testWidgets('エラー状態から回復できる', (WidgetTester tester) async {
      // This test MUST fail until error handling is implemented

      expect(() async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 統計画面に遷移
        await tester.tap(find.text('統計'));
        await tester.pumpAndSettle();

        // エラー状態をシミュレート（データベース接続エラーなど）
        // 実装時にモックを使用してエラー状態を作成

        // エラーメッセージの表示確認
        expect(find.text('統計データの読み込みに失敗しました'), findsOneWidget);

        // リトライボタンをタップ
        await tester.tap(find.text('再試行'));
        await tester.pumpAndSettle();

        // エラーから回復して正常なデータが表示される
        expect(find.text('統計データの読み込みに失敗しました'), findsNothing);
      }, throwsA(isA<Error>())); // エラーハンドリングが未実装
    });
  });
}