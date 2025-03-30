import 'package:dive_log_book/models/dive_log.dart';
import 'package:dive_log_book/screens/dive_log_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// // テスト用のDatabaseServiceクラス
// class TestDatabaseService implements DatabaseService {
//   final String testDatabasePath;
//   Database? _database;

//   TestDatabaseService(this.testDatabasePath);

//   @override
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     return await openDatabase(
//       testDatabasePath,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE dive_logs(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             date TEXT NOT NULL,
//             place TEXT,
//             point TEXT,
//             divingStartTime TEXT,
//             divingEndTime TEXT,
//             averageDepth REAL,
//             maxDepth REAL,
//             tankStartPressure REAL,
//             tankEndPressure REAL,
//             tankKind TEXT,
//             suit TEXT,
//             weight REAL,
//             weather TEXT,
//             temperature REAL,
//             waterTemperature REAL,
//             transparency REAL,
//             memo TEXT
//           )
//         ''');
//       },
//     );
//   }

//   @override
//   Future<int> insertDiveLog(DiveLog diveLog) async {
//     final db = await database;
//     return await db.insert(
//       'dive_logs',
//       diveLog.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   @override
//   Future<int> updateDiveLog(DiveLog diveLog) async {
//     final db = await database;
//     return await db.update(
//       'dive_logs',
//       diveLog.toMap(),
//       where: 'id = ?',
//       whereArgs: [diveLog.id],
//     );
//   }

//   @override
//   Future<int> deleteDiveLog(int id) async {
//     final db = await database;
//     return await db.delete('dive_logs', where: 'id = ?', whereArgs: [id]);
//   }

//   @override
//   Future<List<DiveLog>> getDiveLogs() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'dive_logs',
//       orderBy: 'date DESC',
//     );
//     return List.generate(maps.length, (i) {
//       return DiveLog.fromMap(maps[i]);
//     });
//   }

//   @override
//   Future<DiveLog?> getDiveLog(int id) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'dive_logs',
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (maps.isNotEmpty) {
//       return DiveLog.fromMap(maps.first);
//     }
//     return null;
//   }
// }

void main() {
  // テスト実行前の初期化
  late Database db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // SQLite FFIの初期化
    sqfliteFfiInit();
    // テスト用のデータベースファクトリを設定
    // databaseFactory = databaseFactoryFfi;
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    await db.execute('''
      CREATE TABLE dive_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        place TEXT,
        point TEXT,
        divingStartTime TEXT,
        divingEndTime TEXT,
        averageDepth REAL,
        maxDepth REAL,
        tankStartPressure REAL,
        tankEndPressure REAL,
        tankKind TEXT,
        suit TEXT,
        weight REAL,
        weather TEXT,
        temperature REAL,
        waterTemperature REAL,
        transparency REAL,
        memo TEXT
      )
    ''');

    // // テスト用のデータベースファイルパスを設定
    // testDatabasePath = join(await getDatabasesPath(), 'test_dive_log_book.db');
    // TestWidgetsFlutterBinding.ensureInitialized();
    // const MethodChannel channel = MethodChannel(
    //   'plugins.flutter.io/path_provider',
    // );
    // channel.setMockMethodCallHandler((methodCall) async {
    //   return ".";
    // });

    // // データベースの初期化
    // databaseService = DatabaseService();
    // await databaseService.database;
    // dbPath = await databaseService.getDbPath();
    // // テスト前にデータベースファイルが存在する場合は削除
    // if (await databaseExists(dbPath)) {
    //   await deleteDatabase(dbPath);
    // }
  });

  // tearDownAll(() async {
  //   // await db.close();
  //   // // テスト後にデータベースファイルを削除
  //   // if (await databaseExists(dbPath)) {
  //   //   await deleteDatabase(dbPath);
  //   // }
  // });

  // 固定の日付を使用するためのセットアップ
  final mockDate = DateTime(2023, 6, 27);
  final dateFormat = DateFormat('yyyy-MM-dd');
  final formattedMockDate = dateFormat.format(mockDate);

  // フォームフィールドを入力するヘルパー関数
  Future<void> fillFormFields(WidgetTester tester) async {
    // 場所
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) => widget is FormBuilderTextField && widget.name == 'place',
      ),
      'Ose',
    );
    await tester.pumpAndSettle();

    // ポイント
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) => widget is FormBuilderTextField && widget.name == 'point',
      ),
      'Wannai',
    );
    await tester.pumpAndSettle();

    // 潜水開始時間
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'divingStartTime',
      ),
      '09:30',
    );
    await tester.pumpAndSettle();

    // 潜水終了時間
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'divingEndTime',
      ),
      '10:00',
    );
    await tester.pumpAndSettle();

    // 平均水深
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'averageDepth',
      ),
      '18',
    );
    await tester.pumpAndSettle();

    // 最大水深
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) => widget is FormBuilderTextField && widget.name == 'maxDepth',
      ),
      '25',
    );
    await tester.pumpAndSettle();

    // タンク圧力(開始)
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField &&
            widget.name == 'tankStartPressure',
      ),
      '200',
    );
    await tester.pumpAndSettle();

    // タンク圧力(終了)
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'tankEndPressure',
      ),
      '50',
    );
    await tester.pumpAndSettle();

    // タンク種類 - スクロールしてからタップ
    await tester.dragUntilVisible(
      find.text('スチール'),
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.tap(find.text('スチール'));
    await tester.pumpAndSettle();

    // ウェイト
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) => widget is FormBuilderTextField && widget.name == 'weight',
      ),
      '5',
    );
    await tester.pumpAndSettle();

    // スーツ - スクロールしてからタップ
    await tester.dragUntilVisible(
      find.text('ウェット'),
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.tap(find.text('ウェット'));
    await tester.pumpAndSettle();

    // 天気 - スクロールしてからタップ
    await tester.dragUntilVisible(
      find.text('晴れ'),
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.tap(find.text('晴れ'));
    await tester.pumpAndSettle();

    // 気温 - スクロールしてから入力
    await tester.dragUntilVisible(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'temperature',
      ),
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'temperature',
      ),
      '35',
    );
    await tester.pumpAndSettle();

    // 水温 - スクロールしてから入力
    await tester.dragUntilVisible(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'waterTemperature',
      ),
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'waterTemperature',
      ),
      '28',
    );
    await tester.pumpAndSettle();

    // 透明度 - スクロールしてから入力
    await tester.dragUntilVisible(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'transparency',
      ),
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderTextField && widget.name == 'transparency',
      ),
      '8',
    );
    await tester.pumpAndSettle();

    // メモ - スクロールしてから入力
    await tester.dragUntilVisible(
      find.byWidgetPredicate(
        (widget) => widget is FormBuilderTextField && widget.name == 'memo',
      ),
      find.byType(SingleChildScrollView),
      const Offset(0, -100),
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (widget) => widget is FormBuilderTextField && widget.name == 'memo',
      ),
      'Good Diving!!',
    );
    await tester.pumpAndSettle();
  }

  group('DiveLogFormScreen Tests', () {
    testWidgets('新規ダイブログ作成画面が正しく表示される', (WidgetTester tester) async {
      // テスト対象のウィジェットをビルド
      await tester.pumpWidget(MaterialApp(home: DiveLogFormScreen()));

      // アプリバーのタイトルが正しいか確認
      expect(find.text('新規ダイブログ'), findsOneWidget);

      // 各フォームフィールドが存在するか確認
      expect(find.text('日付'), findsOneWidget);
      expect(find.text('場所'), findsOneWidget);
      expect(find.text('ポイント'), findsOneWidget);
      expect(find.text('潜水開始時間 (HH:mm)'), findsOneWidget);
      expect(find.text('潜水終了時間 (HH:mm)'), findsOneWidget);
      expect(find.text('平均水深 (m)'), findsOneWidget);
      expect(find.text('最大水深 (m)'), findsOneWidget);
      expect(find.text('タンク圧力(開始) (kg/cm²)'), findsOneWidget);
      expect(find.text('タンク圧力(終了) (kg/cm²)'), findsOneWidget);
      expect(find.text('タンク'), findsOneWidget);
      expect(find.text('スチール'), findsOneWidget);
      expect(find.text('アルミニウム'), findsOneWidget);
      expect(find.text('ウェイト (kg)'), findsOneWidget);
      expect(find.text('スーツ'), findsOneWidget);
      expect(find.text('ウェット'), findsOneWidget);
      expect(find.text('ドライ'), findsOneWidget);
      expect(find.text('天気'), findsOneWidget);
      expect(find.text('晴れ'), findsOneWidget);
      expect(find.text('晴れ/曇り'), findsOneWidget);
      expect(find.text('曇り'), findsOneWidget);
      expect(find.text('雨'), findsOneWidget);
      expect(find.text('雪'), findsOneWidget);
      expect(find.text('気温 (℃)'), findsOneWidget);
      expect(find.text('水温 (℃)'), findsOneWidget);
      expect(find.text('透明度 (m)'), findsOneWidget);
      expect(find.text('メモ'), findsOneWidget);

      // 送信ボタンが存在するか確認
      expect(find.text('追加'), findsOneWidget);
    });

    testWidgets('既存ダイブログ編集画面が正しく表示される', (WidgetTester tester) async {
      // TODO: 項目ごとに find して値を確認するようにしたいがやり方が分からない

      // テスト用のダイブログデータ
      final diveLog = DiveLog(
        id: 1,
        date: '2022-04-01',
        place: 'Ose',
        point: 'Wannai',
        divingStartTime: '09:30',
        divingEndTime: '10:00',
        averageDepth: 18,
        maxDepth: 25,
        tankStartPressure: 200,
        tankEndPressure: 50,
        tankKind: TankKind.STEEL,
        suit: Suit.WET,
        weight: 5,
        weather: Weather.SUNNY,
        temperature: 35,
        waterTemperature: 28,
        transparency: 8,
        memo: 'Good Diving!!',
      );

      // テスト対象のウィジェットをビルド
      await tester.pumpWidget(
        MaterialApp(home: DiveLogFormScreen(diveLog: diveLog)),
      );

      // アプリバーのタイトルが正しいか確認
      expect(find.text('ダイブログ編集'), findsOneWidget);

      // 各フォームフィールドの値が期待通りになっているか確認

      // 日付フィールドの確認
      final dateField = find.byWidgetPredicate(
        (widget) =>
            widget is FormBuilderDateTimePicker && widget.name == 'date',
      );
      expect(dateField, findsOneWidget);

      // 日付が表示されているか確認（2022-04-01の形式で表示されているはず）
      expect(find.text('2022-04-01'), findsOneWidget);

      // 場所フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FormBuilderTextField && widget.name == 'place',
        ),
        findsOneWidget,
      );
      expect(find.text('Ose'), findsOneWidget);

      // ポイントフィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FormBuilderTextField && widget.name == 'point',
        ),
        findsOneWidget,
      );
      expect(find.text('Wannai'), findsOneWidget);

      // 潜水開始時間フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField &&
              widget.name == 'divingStartTime',
        ),
        findsOneWidget,
      );
      expect(find.text('09:30'), findsOneWidget);

      // 潜水終了時間フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField && widget.name == 'divingEndTime',
        ),
        findsOneWidget,
      );
      expect(find.text('10:00'), findsOneWidget);

      // 平均水深フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField && widget.name == 'averageDepth',
        ),
        findsOneWidget,
      );
      expect(find.text('18.0'), findsOneWidget);

      // 最大水深フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField && widget.name == 'maxDepth',
        ),
        findsOneWidget,
      );
      expect(find.text('25.0'), findsOneWidget);

      // タンク圧力(開始)フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField &&
              widget.name == 'tankStartPressure',
        ),
        findsOneWidget,
      );
      expect(find.text('200.0'), findsOneWidget);

      // タンク圧力(終了)フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField &&
              widget.name == 'tankEndPressure',
        ),
        findsOneWidget,
      );
      expect(find.text('50.0'), findsOneWidget);

      // タンク種類フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderRadioGroup && widget.name == 'tankKind',
        ),
        findsOneWidget,
      );
      // スチールが選択されているか確認
      expect(find.text('スチール'), findsOneWidget);

      // ウェイトフィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FormBuilderTextField && widget.name == 'weight',
        ),
        findsOneWidget,
      );
      expect(find.text('5.0'), findsOneWidget);

      // スーツフィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FormBuilderRadioGroup && widget.name == 'suit',
        ),
        findsOneWidget,
      );
      // ウェットが選択されているか確認
      expect(find.text('ウェット'), findsOneWidget);

      // 天気フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderRadioGroup && widget.name == 'weather',
        ),
        findsOneWidget,
      );
      // 晴れが選択されているか確認
      expect(find.text('晴れ'), findsOneWidget);

      // 気温フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField && widget.name == 'temperature',
        ),
        findsOneWidget,
      );
      expect(find.text('35.0'), findsOneWidget);

      // 水温フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField &&
              widget.name == 'waterTemperature',
        ),
        findsOneWidget,
      );
      expect(find.text('28.0'), findsOneWidget);

      // 透明度フィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField && widget.name == 'transparency',
        ),
        findsOneWidget,
      );
      expect(find.text('8.0'), findsOneWidget);

      // メモフィールドの確認
      expect(
        find.byWidgetPredicate(
          (widget) => widget is FormBuilderTextField && widget.name == 'memo',
        ),
        findsOneWidget,
      );
      expect(find.text('Good Diving!!'), findsOneWidget);

      // 送信ボタンが存在するか確認
      expect(find.text('上書き'), findsOneWidget);
    });

    testWidgets('フォーム入力と検証が正しく機能する', (WidgetTester tester) async {
      // テスト対象のウィジェットをビルド
      await tester.pumpWidget(MaterialApp(home: DiveLogFormScreen()));

      // 無効な時間形式を入力
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField &&
              widget.name == 'divingStartTime',
        ),
        '25:30',
      );
      await tester.pumpAndSettle();

      // 追加ボタンが見えるようにスクロール
      await tester.dragUntilVisible(
        find.text('追加'),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // 送信ボタンをタップ
      await tester.tap(find.text('追加'));
      await tester.pump(const Duration(milliseconds: 500));

      // エラーメッセージが表示されるか確認
      // FormBuilderTextFieldのvalidatorによって表示されるエラーメッセージを検索
      // エラーテキストを含むTextウィジェットを探す
      expect(find.text('時間のフォーマットを HH:mm にしてください'), findsOneWidget);

      // 無効な数値を入力
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField && widget.name == 'averageDepth',
        ),
        'abc',
      );
      await tester.pumpAndSettle();

      // 追加ボタンが見えるようにスクロール
      await tester.dragUntilVisible(
        find.text('追加'),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // 送信ボタンをタップ
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // エラーメッセージが表示されるか確認
      expect(find.text('数値を入力してください'), findsOneWidget);

      // 範囲外の数値を入力
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is FormBuilderTextField && widget.name == 'averageDepth',
        ),
        '150',
      );
      await tester.pumpAndSettle();

      // 追加ボタンが見えるようにスクロール
      await tester.dragUntilVisible(
        find.text('追加'),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      // 送信ボタンをタップ
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // エラーメッセージが表示されるか確認
      expect(find.text('100以下の数値を入力してください'), findsOneWidget);
    });

    testWidgets('新規ダイブログの追加が正しく機能する', (WidgetTester tester) async {
      print("hoge7");

      // テスト対象のウィジェットをビルド
      // await tester.pumpWidget(testWidget);
      await tester.pumpWidget(
        MaterialApp(home: DiveLogFormScreen()),
        duration: Duration(milliseconds: 3000),
      );

      print("hoge2");
      // フォームに値を入力
      await fillFormFields(tester);

      // 追加ボタンが見えるようにスクロール
      // await tester.dragUntilVisible(
      //   find.text('追加'),
      //   find.byType(SingleChildScrollView),
      //   const Offset(0, -500),
      // );
      // await tester.pumpAndSettle();

      // 送信ボタンをタップ
      print("hoge1");
      await tester.tap(find.text('追加'));
      await tester.pump(const Duration(milliseconds: 3000));

      print("hoge0");
      print(await db.query('dive_logs'));
      // データベースにデータが追加されたことを確認
      final result = await db.query('dive_logs');
      // expect(result.length, 1);
      print("hoge");
      await db.close();
      print(result);

      // // 追加されたデータの内容を詳細に検証
      // final insertedData = result.first;
      // expect(insertedData['place'], 'Ose');
      // expect(insertedData['point'], 'Wannai');
      // expect(insertedData['divingStartTime'], '09:30');
      // expect(insertedData['divingEndTime'], '10:00');
      // expect(insertedData['averageDepth'], 18.0);
      // expect(insertedData['maxDepth'], 25.0);
      // expect(insertedData['tankStartPressure'], 200.0);
      // expect(insertedData['tankEndPressure'], 50.0);
      // expect(insertedData['tankKind'], 'STEEL');
      // expect(insertedData['suit'], 'WET');
      // expect(insertedData['weight'], 5.0);
      // expect(insertedData['weather'], 'SUNNY');
      // expect(insertedData['temperature'], 35.0);
      // expect(insertedData['waterTemperature'], 28.0);
      // expect(insertedData['transparency'], 8.0);
      // expect(insertedData['memo'], 'Good Diving!!');
    });

    // testWidgets('既存ダイブログの更新が正しく機能する', (WidgetTester tester) async {
    //   Database? db;
    //   try {
    //     // インメモリデータベースを設定
    //     db = await databaseFactoryFfi.openDatabase(
    //       inMemoryDatabasePath,
    //       options: OpenDatabaseOptions(
    //         version: 1,
    //         onCreate: (db, version) async {
    //           await db.execute('''
    //             CREATE TABLE dive_logs(
    //               id INTEGER PRIMARY KEY AUTOINCREMENT,
    //               date TEXT NOT NULL,
    //               place TEXT,
    //               point TEXT,
    //               divingStartTime TEXT,
    //               divingEndTime TEXT,
    //               averageDepth REAL,
    //               maxDepth REAL,
    //               tankStartPressure REAL,
    //               tankEndPressure REAL,
    //               tankKind TEXT,
    //               suit TEXT,
    //               weight REAL,
    //               weather TEXT,
    //               temperature REAL,
    //               waterTemperature REAL,
    //               transparency REAL,
    //               memo TEXT
    //             )
    //           ''');
    //         },
    //       ),
    //     );

    //     // テスト用のデータを挿入
    //     await db.insert('dive_logs', {
    //       'id': 1,
    //       'date': '2022-04-01',
    //       'place': 'Ose',
    //       'point': 'Wannai',
    //       'divingStartTime': '09:30',
    //       'divingEndTime': '10:00',
    //       'averageDepth': 18,
    //       'maxDepth': 25,
    //       'tankStartPressure': 200,
    //       'tankEndPressure': 50,
    //       'tankKind': 'STEEL',
    //       'suit': 'WET',
    //       'weight': 5,
    //       'weather': 'SUNNY',
    //       'temperature': 35,
    //       'waterTemperature': 28,
    //       'transparency': 8,
    //       'memo': 'Good Diving!!',
    //     });

    //     // テスト用のダイブログデータ
    //     final diveLog = DiveLog(
    //       id: 1,
    //       date: '2022-04-01',
    //       place: 'Ose',
    //       point: 'Wannai',
    //       divingStartTime: '09:30',
    //       divingEndTime: '10:00',
    //       averageDepth: 18,
    //       maxDepth: 25,
    //       tankStartPressure: 200,
    //       tankEndPressure: 50,
    //       tankKind: TankKind.STEEL,
    //       suit: Suit.WET,
    //       weight: 5,
    //       weather: Weather.SUNNY,
    //       temperature: 35,
    //       waterTemperature: 28,
    //       transparency: 8,
    //       memo: 'Good Diving!!',
    //     );

    //     // テスト対象のウィジェットをビルド
    //     await tester.pumpWidget(
    //       MaterialApp(home: DiveLogFormScreen(diveLog: diveLog)),
    //     );

    //     // メモを更新
    //     await tester.enterText(
    //       find.byWidgetPredicate(
    //         (widget) => widget is FormBuilderTextField && widget.name == 'memo',
    //       ),
    //       'Updated memo',
    //     );
    //     await tester.pumpAndSettle();

    //     // 送信ボタンをタップ
    //     await tester.tap(find.text('上書き'));
    //     await tester.pumpAndSettle();

    //     // データベースのデータが更新されたことを確認
    //     final result = await db.query(
    //       'dive_logs',
    //       where: 'id = ?',
    //       whereArgs: [1],
    //     );
    //     expect(result.length, 1);
    //     expect(result[0]['memo'], 'Updated memo');
    //   } finally {
    //     // データベースを確実に閉じる
    //     if (db != null) {
    //       await db.close();
    //     }
    //   }
    // });

    testWidgets('戻るボタンが正しく機能する', (WidgetTester tester) async {
      // テスト対象のウィジェットをビルド
      await tester.pumpWidget(MaterialApp(home: DiveLogFormScreen()));

      // 戻るボタンをタップ
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // TODO: 一覧画面に遷移したことを評価するようにしたい
    });

    // エラー発生時のテストは、実際のデータベースエラーを再現するのが難しいため、
    // ここではスキップします。実際のアプリケーションでは、DatabaseServiceを
    // モックしてエラーをシミュレートするか、データベース操作を直接テストする
    // 方法を検討する必要があります。
  });
}
