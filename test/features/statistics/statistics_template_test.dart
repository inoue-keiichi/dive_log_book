import 'package:dive_log_book/features/statistics/statistics_template.dart';
import 'package:dive_log_book/features/statistics/use_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsTemplate Widget Test', () {
    testWidgets('ローディング状態でCircularProgressIndicatorが表示される',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsTemplate(
              isLoading: true,
              diveDuration: DiveDuration(hour: 0, minute: 0),
              diveCount: 0,
            ),
          ),
        ),
      );

      // ローディングインジケーターが表示される
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // 統計カードは表示されない
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('エラー状態でエラーメッセージとアイコンが表示される',
        (WidgetTester tester) async {
      const errorMessage = 'データの読み込みに失敗しました';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsTemplate(
              isLoading: false,
              diveDuration: DiveDuration(hour: 0, minute: 0),
              diveCount: 0,
              error: errorMessage,
            ),
          ),
        ),
      );

      // エラーメッセージが表示される
      expect(find.text(errorMessage), findsOneWidget);
      // エラーアイコンが表示される
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      // 統計カードは表示されない
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('データなし状態で0時間0分と0回が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsTemplate(
              isLoading: false,
              diveDuration: DiveDuration(hour: 0, minute: 0),
              diveCount: 0,
            ),
          ),
        ),
      );

      // 統計カードが表示される
      expect(find.byType(Card), findsOneWidget);
      // データなし状態の表示
      expect(find.text('0時間0分'), findsOneWidget);
      expect(find.text('0回'), findsOneWidget);
      // 空状態メッセージが表示される
      expect(find.text('まだダイビング記録がありません'), findsOneWidget);
      expect(find.byIcon(Icons.insights), findsOneWidget);
    });

    testWidgets('データあり状態で正しい時間と回数が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsTemplate(
              isLoading: false,
              diveDuration: DiveDuration(hour: 5, minute: 30),
              diveCount: 10,
            ),
          ),
        ),
      );

      // 統計カードが表示される
      expect(find.byType(Card), findsOneWidget);
      // 正しいデータが表示される
      expect(find.text('5時間30分'), findsOneWidget);
      expect(find.text('10回'), findsOneWidget);
      // 空状態メッセージは表示されない
      expect(find.text('まだダイビング記録がありません'), findsNothing);
    });

    testWidgets('統計カードに必要なアイコンとラベルが表示される',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsTemplate(
              isLoading: false,
              diveDuration: DiveDuration(hour: 3, minute: 45),
              diveCount: 5,
            ),
          ),
        ),
      );

      // タイトルが表示される
      expect(find.text('ダイビング統計'), findsOneWidget);
      // アイコンが表示される
      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.byIcon(Icons.water), findsOneWidget);
      // ラベルが表示される
      expect(find.text('総潜水時間'), findsOneWidget);
      expect(find.text('ダイビング記録数'), findsOneWidget);
    });

    testWidgets('60分以上の場合に正しく時間表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsTemplate(
              isLoading: false,
              diveDuration: DiveDuration(hour: 12, minute: 5),
              diveCount: 20,
            ),
          ),
        ),
      );

      // 正しい時間表示
      expect(find.text('12時間5分'), findsOneWidget);
      expect(find.text('20回'), findsOneWidget);
    });

    testWidgets('Material Design 3のスタイルが適用されている',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: StatisticsTemplate(
              isLoading: false,
              diveDuration: DiveDuration(hour: 1, minute: 30),
              diveCount: 3,
            ),
          ),
        ),
      );

      // Cardウィジェットが使用されている
      expect(find.byType(Card), findsOneWidget);

      // Cardのプロパティを確認
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 0);
      expect(card.shape, isA<RoundedRectangleBorder>());
    });
  });
}
