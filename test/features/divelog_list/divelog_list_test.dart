import 'package:dive_log_book/features/divelog_list/divelog_list_template.dart';
import 'package:dive_log_book/models/dive_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiveLogListTemplate', () {
    testWidgets('空のリストが正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiveLogListTemplate(
            diveLogs: const [],
            isLoading: false,
            onAddPressed: () {},
            onItemTap: (diveLog) {},
          ),
        ),
      );

      // アプリバーのタイトルが表示される
      expect(find.text('ダイブログ'), findsOneWidget);

      // 空状態のメッセージが表示される
      expect(find.text('ダイブログがありません。新規追加してください。'), findsOneWidget);

      // FloatingActionButtonが表示される
      expect(find.byIcon(Icons.add), findsOneWidget);

      // リストは表示されない
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('ローディング状態が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiveLogListTemplate(
            diveLogs: const [],
            isLoading: true,
            onAddPressed: () {},
            onItemTap: (diveLog) {},
          ),
        ),
      );

      // ローディングインジケーターが表示される
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 空状態のメッセージは表示されない
      expect(find.text('ダイブログがありません。新規追加してください。'), findsNothing);
    });

    testWidgets('ダイブログリストが正しく表示される', (WidgetTester tester) async {
      final testDiveLogs = [
        DiveLog(
          id: 1,
          date: DateTime(2023, 6, 15),
          place: '伊豆',
          point: '大瀬崎',
          averageDepth: 15.5,
          maxDepth: 20.0,
        ),
        DiveLog(
          id: 2,
          date: DateTime(2023, 6, 20),
          place: '沖縄',
          point: '青の洞窟',
          averageDepth: 12.0,
          maxDepth: 18.0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: DiveLogListTemplate(
            diveLogs: testDiveLogs,
            isLoading: false,
            onAddPressed: () {},
            onItemTap: (diveLog) {},
          ),
        ),
      );

      // リストが表示される
      expect(find.byType(ListView), findsOneWidget);

      // カードが2つ表示される
      expect(find.byType(Card), findsNWidgets(2));

      // 各ダイブログの情報が表示される
      expect(find.text('大瀬崎'), findsOneWidget);
      expect(find.text('青の洞窟'), findsOneWidget);
      expect(find.text('2023-06-15'), findsOneWidget);
      expect(find.text('2023-06-20'), findsOneWidget);

      // 空状態のメッセージは表示されない
      expect(find.text('ダイブログがありません。新規追加してください。'), findsNothing);
    });

    testWidgets('FloatingActionButtonをタップできる', (WidgetTester tester) async {
      bool addPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DiveLogListTemplate(
            diveLogs: const [],
            isLoading: false,
            onAddPressed: () {
              addPressed = true;
            },
            onItemTap: (diveLog) {},
          ),
        ),
      );

      // FloatingActionButtonをタップ
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // コールバックが呼ばれたことを確認
      expect(addPressed, true);
    });

    testWidgets('リストアイテムをタップできる', (WidgetTester tester) async {
      final testDiveLog = DiveLog(
        id: 1,
        date: DateTime(2023, 6, 15),
        place: '伊豆',
        point: '大瀬崎',
        averageDepth: 15.5,
        maxDepth: 20.0,
      );

      DiveLog? tappedDiveLog;

      await tester.pumpWidget(
        MaterialApp(
          home: DiveLogListTemplate(
            diveLogs: [testDiveLog],
            isLoading: false,
            onAddPressed: () {},
            onItemTap: (diveLog) {
              tappedDiveLog = diveLog;
            },
          ),
        ),
      );

      // リストアイテムをタップ
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // 正しいダイブログが渡されたことを確認
      expect(tappedDiveLog, testDiveLog);
    });

    testWidgets('pointがnullの場合は空文字が表示される', (WidgetTester tester) async {
      final testDiveLog = DiveLog(
        id: 1,
        date: DateTime(2023, 6, 15),
        place: '伊豆',
        point: null, // nullを設定
        averageDepth: 15.5,
        maxDepth: 20.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DiveLogListTemplate(
            diveLogs: [testDiveLog],
            isLoading: false,
            onAddPressed: () {},
            onItemTap: (diveLog) {},
          ),
        ),
      );

      // リストが表示される
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // 日付は表示される
      expect(find.text('2023-06-15'), findsOneWidget);
    });
  });
}
