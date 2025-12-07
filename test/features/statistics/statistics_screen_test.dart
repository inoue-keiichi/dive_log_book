import 'package:dive_log_book/features/statistics/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StatisticsScreen Widget Test', () {
    testWidgets('統計画面が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: StatisticsScreen())),
      );

      // 非同期処理の完了を待つ（pumpAndSettleの代わりにpumpを使用）
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // AppBarのタイトルが表示される
      expect(find.text('統計'), findsOneWidget);
    });

    testWidgets('データなし状態で初期表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: StatisticsScreen())),
      );

      // 非同期処理の完了を待つ
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 初期表示（データなし）の確認
      expect(find.text('0時間0分'), findsOneWidget);
      expect(find.text('0回'), findsOneWidget);
    });

    testWidgets('ウィジェットが正常にレンダリングされる', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: StatisticsScreen())),
      );

      // 非同期処理の完了を待つ
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 基本的なウィジェットが表示されることを確認
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('初期ローディング状態が処理される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: StatisticsScreen())),
      );

      // 最初のフレームではローディングの可能性がある
      await tester.pump();

      // ローディングまたはコンテンツのいずれかが表示される
      expect(
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
            find.text('0時間0分').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Material Design 3のスタイルが適用されている', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: const StatisticsScreen(),
          ),
        ),
      );

      // 非同期処理の完了を待つ（Cardが表示されるまで十分待つ）
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Material Design 3のコンポーネントが使用されていることを確認
      expect(find.byType(Card), findsWidgets);
    });
  });
}
