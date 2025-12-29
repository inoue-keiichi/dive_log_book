import 'package:dive_log_book/features/divelog_list/divelog_list.dart';
import 'package:dive_log_book/features/statistics/statistics_screen.dart';
import 'package:dive_log_book/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Widget app;

  setUpAll(() {
    // sqfliteの初期化
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    app = const ProviderScope(child: MyApp());
  });

  group('Bottom Navigation Integration Test', () {
    testWidgets('底部ナビゲーションで画面が適切に切り替わり、選択状態が正しく更新される', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // 初期状態：ログ画面が表示され、選択インデックスが0であることを確認
      expect(find.byType(DivelogList), findsOneWidget);
      expect(find.byType(StatisticsScreen), findsNothing);

      var bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 0);

      // 統計タブをタップ
      await tester.tap(find.text('統計'));
      await tester.pumpAndSettle();

      // 統計画面が表示され、ログ画面が非表示になり、選択インデックスが更新されることを確認
      expect(find.byType(StatisticsScreen), findsOneWidget);
      expect(find.text('総潜水時間'), findsOneWidget);
      expect(find.byType(DivelogList), findsNothing);

      bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 1);

      // ログタブをタップ
      await tester.tap(find.text('ログ'));
      await tester.pumpAndSettle();

      // ログ画面が表示され、統計画面が非表示になり、選択インデックスが戻ることを確認
      expect(find.byType(DivelogList), findsOneWidget);
      expect(find.byType(StatisticsScreen), findsNothing);

      bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNav.currentIndex, 0);
    });

    testWidgets('アクセシビリティ対応が適切に設定されている', (WidgetTester tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // BottomNavigationBarItemにtooltipが設定されていることを確認
      final bottomNav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      // tooltipが設定されていることを確認
      expect(bottomNav.items[0].tooltip, 'ダイビング記録画面を開く');
      expect(bottomNav.items[1].tooltip, '統計画面を開く');

      // タブラベルが正しく表示されていることを確認
      expect(find.text('ログ'), findsOneWidget);
      expect(find.text('統計'), findsOneWidget);
    });
  });
}
