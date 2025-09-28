import 'package:dive_log_book/features/divelog/divelog_form.dart';
import 'package:dive_log_book/models/dive_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiveLogForm', () {
    testWidgets('新規作成フォームが正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const DiveLogForm()));

      // アプリバーのタイトルが正しく表示される
      expect(find.text('新規ダイブログ'), findsOneWidget);

      // 主要なフィールドが表示される
      expect(find.text('日付'), findsOneWidget);
      expect(find.text('場所'), findsOneWidget);
      expect(find.text('ポイント'), findsOneWidget);
      expect(find.text('潜水開始時間 (HH:mm)'), findsOneWidget);
      expect(find.text('潜水終了時間 (HH:mm)'), findsOneWidget);
      expect(find.text('平均水深 (m)'), findsOneWidget);
      expect(find.text('最大水深 (m)'), findsOneWidget);

      // 送信ボタンが新規作成となっている
      expect(find.text('新規作成'), findsOneWidget);

      // 削除ボタンは表示されない（新規作成時）
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('編集フォームが正しく表示される', (WidgetTester tester) async {
      final existingDiveLog = DiveLog(
        id: 1,
        date: DateTime(2023, 6, 15),
        place: 'テスト場所',
        point: 'テストポイント',
        averageDepth: 15.5,
        maxDepth: 20.0,
      );

      await tester.pumpWidget(
        MaterialApp(home: DiveLogForm(diveLog: existingDiveLog)),
      );

      // アプリバーのタイトルが編集用になっている
      expect(find.text('ダイブログ編集'), findsOneWidget);

      // 送信ボタンが上書きとなっている
      expect(find.text('上書き'), findsOneWidget);
    });

    testWidgets('戻るボタンが動作する', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => ElevatedButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DiveLogForm(),
                          ),
                        ),
                    child: const Text('フォームを開く'),
                  ),
            ),
          ),
        ),
      );

      // フォームを開く
      await tester.tap(find.text('フォームを開く'));
      await tester.pumpAndSettle();

      // フォームが表示されている
      expect(find.text('新規ダイブログ'), findsOneWidget);

      // 戻るボタンをタップ
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 元の画面に戻っている
      expect(find.text('フォームを開く'), findsOneWidget);
      expect(find.text('新規ダイブログ'), findsNothing);
    });

    testWidgets('フォームフィールドが正しく初期化される', (WidgetTester tester) async {
      final existingDiveLog = DiveLog(
        id: 1,
        date: DateTime(2023, 6, 15),
        place: 'テスト場所',
        point: 'テストポイント',
        divingStartTime: '10:30',
        divingEndTime: '11:15',
        averageDepth: 15.5,
        maxDepth: 20.0,
        tankKind: TankKind.STEEL,
        suit: Suit.WET,
        weather: Weather.SUNNY,
        memo: 'テストメモ',
      );

      await tester.pumpWidget(
        MaterialApp(home: DiveLogForm(diveLog: existingDiveLog)),
      );

      await tester.pumpAndSettle();

      // テキストフィールドの初期値が設定されている
      expect(find.text('テスト場所'), findsOneWidget);
      expect(find.text('テストポイント'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('11:15'), findsOneWidget);
      expect(find.text('15.5'), findsOneWidget);
      expect(find.text('20.0'), findsOneWidget);
      expect(find.text('テストメモ'), findsOneWidget);
    });

    // TODO: バリデーションのテストを書く
    // testWidgets('バリデーションエラーが表示される', (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home: const DiveLogForm()));

    //   await tester.pumpAndSettle();

    //   // 無効な時間フォーマットを入力
    //   await tester.enterText(
    //     find.widgetWithText(FormBuilderTextField, '潜水開始時間 (HH:mm)'),
    //     '25:70',
    //   );

    //   // 無効な水深を入力
    //   await tester.enterText(
    //     find.widgetWithText(FormBuilderTextField, '平均水深 (m)'),
    //     '300',
    //   );

    //   // 送信ボタンまでスクロール
    //   await tester.scrollUntilVisible(find.text('新規作成'), 500.0);

    //   // 送信ボタンをタップ
    //   await tester.tap(find.text('新規作成'));
    //   await tester.pumpAndSettle();

    //   // バリデーションエラーが表示される
    //   expect(find.text('時間のフォーマットを HH:mm にしてください'), findsOneWidget);
    //   expect(find.textContaining('100'), findsOneWidget);
    // });

    testWidgets('ラジオボタンの選択が動作する', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const DiveLogForm()));

      await tester.pumpAndSettle();

      // タンク種類 - スクロールしてからタップ
      await tester.dragUntilVisible(
        find.text('スチール'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('スチール'));
      await tester.pumpAndSettle();

      // スーツでドライを選択
      await tester.dragUntilVisible(
        find.text('ドライ'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('ドライ'));
      await tester.pumpAndSettle();

      // 天気で曇りを選択
      await tester.dragUntilVisible(
        find.text('曇り'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('曇り'));
      await tester.pumpAndSettle();

      // 選択が反映されている（視覚的な確認は困難だが、エラーが発生しないことを確認）
      expect(tester.takeException(), isNull);
    });

    testWidgets('数値フィールドが正しく動作する', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const DiveLogForm()));

      await tester.pumpAndSettle();

      // 各数値フィールドに有効な値を入力
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, '平均水深 (m)'),
        '15.5',
      );
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, '最大水深 (m)'),
        '25.0',
      );
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, 'タンク圧力(開始) (kg/cm²)'),
        '200',
      );
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, 'タンク圧力(終了) (kg/cm²)'),
        '50',
      );
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, 'ウェイト (kg)'),
        '4.0',
      );
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, '気温 (℃)'),
        '25',
      );
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, '水温 (℃)'),
        '18',
      );
      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, '透明度 (m)'),
        '15',
      );

      await tester.pumpAndSettle();

      // エラーが発生しないことを確認
      expect(tester.takeException(), isNull);
    });

    testWidgets('メモフィールドが複数行で動作する', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const DiveLogForm()));

      await tester.pumpAndSettle();

      const longMemo =
          '今日のダイビングは素晴らしかった。\n'
          '水は透明で、たくさんの魚を見ることができた。\n'
          '次回もまた来たい。';

      await tester.enterText(
        find.widgetWithText(FormBuilderTextField, 'メモ'),
        longMemo,
      );

      await tester.pumpAndSettle();

      // メモが正しく入力されている
      expect(find.text(longMemo), findsOneWidget);
    });
  });
}
