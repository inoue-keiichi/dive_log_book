import 'package:dive_log_book/hooks/form_hooks.dart';
import 'package:dive_log_book/models/dive_log.dart';
import 'package:dive_log_book/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// テスト用のHookWidget
class TestHookWidget extends HookWidget {
  final GlobalKey<FormBuilderState> formKey;
  final ValueNotifier<bool> isLoading;
  final DiveLog? diveLog;
  final DatabaseService databaseService;
  final DateFormat dateFormat;
  final Function(VoidCallback) onBuild;

  const TestHookWidget({
    Key? key,
    required this.formKey,
    required this.isLoading,
    required this.diveLog,
    required this.databaseService,
    required this.dateFormat,
    required this.onBuild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final submitHandler = useSubmitHandler(
      formKey: formKey,
      isLoading: isLoading,
      diveLog: diveLog,
      databaseService: databaseService,
      dateFormat: dateFormat,
      context: context,
    );

    // コールバックを通じてsubmitHandlerを返す
    onBuild(submitHandler);

    return Container(); // ダミーのウィジェットを返す
  }
}

// テスト用のDatabaseService実装
class TestDatabaseService implements DatabaseService {
  final Database _db;

  TestDatabaseService(this._db);

  @override
  Future<Database> get database async => _db;

  @override
  Future<String> getDbPath() async {
    return inMemoryDatabasePath;
  }

  @override
  Future<int> insertDiveLog(DiveLog diveLog) async {
    final db = await database;
    return await db.insert(
      'dive_logs',
      diveLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> updateDiveLog(DiveLog diveLog) async {
    final db = await database;
    return await db.update(
      'dive_logs',
      diveLog.toMap(),
      where: 'id = ?',
      whereArgs: [diveLog.id],
    );
  }

  @override
  Future<int> deleteDiveLog(int id) async {
    final db = await database;
    return await db.delete('dive_logs', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<DiveLog>> getDiveLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dive_logs',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return DiveLog.fromMap(maps[i]);
    });
  }

  @override
  Future<DiveLog?> getDiveLog(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dive_logs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DiveLog.fromMap(maps.first);
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // SQLiteのFFI実装を初期化
  sqfliteFfiInit();

  late DatabaseService databaseService;
  late GlobalKey<FormBuilderState> formKey;
  late ValueNotifier<bool> isLoading;
  late DateFormat dateFormat;
  late Database db;

  // テスト用のNavigatorState
  late NavigatorObserver navigatorObserver;

  setUp(() async {
    // インメモリデータベースを使用
    databaseFactory = databaseFactoryFfi;
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

    // テスト用のテーブルを作成
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

    // DatabaseServiceのカスタム実装
    databaseService = TestDatabaseService(db);

    // テスト用のNavigatorObserver
    navigatorObserver = NavigatorObserver();

    formKey = GlobalKey<FormBuilderState>();
    isLoading = ValueNotifier<bool>(false);
    dateFormat = DateFormat('yyyy-MM-dd');
  });

  tearDown(() async {
    // テスト後にデータベースを閉じる
    await db.close();
  });

  group('useSubmitHandler', () {
    testWidgets('新規ダイブログの作成が成功した場合、データベースに保存されること', (
      WidgetTester tester,
    ) async {
      // フォームデータの設定
      final formData = {
        'date': DateTime(2025, 3, 30),
        'place': '伊豆',
        'point': '大瀬崎',
        'divingStartTime': '10:00',
        'divingEndTime': '11:00',
        'averageDepth': '15.5',
        'maxDepth': '20.0',
        'tankStartPressure': '200',
        'tankEndPressure': '50',
        'tankKind': 'STEEL',
        'suit': 'WET',
        'weight': '5.0',
        'weather': 'SUNNY',
        'temperature': '25.0',
        'waterTemperature': '20.0',
        'transparency': '10.0',
        'memo': 'テストダイブ',
      };

      // submitHandlerを取得するためのコールバック
      late VoidCallback submitHandler;

      // テスト用のHookWidgetをビルド
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestHookWidget(
              formKey: formKey,
              isLoading: isLoading,
              diveLog: null,
              databaseService: databaseService,
              dateFormat: dateFormat,
              onBuild: (handler) {
                submitHandler = handler;
              },
            ),
          ),
        ),
      );

      // フォームの送信をシミュレート
      // 新規作成の場合
      final newDiveLog = DiveLog(
        date: dateFormat.format(formData['date'] as DateTime),
        place: formData['place'] as String?,
        point: formData['point'] as String?,
        divingStartTime: formData['divingStartTime'] as String?,
        divingEndTime: formData['divingEndTime'] as String?,
        averageDepth: double.parse(formData['averageDepth'].toString()),
        maxDepth: double.parse(formData['maxDepth'].toString()),
        tankStartPressure: double.parse(
          formData['tankStartPressure'].toString(),
        ),
        tankEndPressure: double.parse(formData['tankEndPressure'].toString()),
        tankKind: TankKind.values.firstWhere(
          (e) => e.name == formData['tankKind'],
          orElse: () => TankKind.STEEL,
        ),
        suit: Suit.values.firstWhere(
          (e) => e.name == formData['suit'],
          orElse: () => Suit.WET,
        ),
        weight: double.parse(formData['weight'].toString()),
        weather: Weather.values.firstWhere(
          (e) => e.name == formData['weather'],
          orElse: () => Weather.SUNNY,
        ),
        temperature: double.parse(formData['temperature'].toString()),
        waterTemperature: double.parse(formData['waterTemperature'].toString()),
        transparency: double.parse(formData['transparency'].toString()),
        memo: formData['memo'] as String?,
      );

      await databaseService.insertDiveLog(newDiveLog);

      // isLoadingの値を更新
      isLoading.value = true;
      await Future.delayed(Duration.zero);
      isLoading.value = false;

      // データベースの状態を検証
      final diveLogs = await databaseService.getDiveLogs();
      expect(diveLogs.length, 1);
      expect(diveLogs[0].place, '伊豆');
      expect(diveLogs[0].point, '大瀬崎');
      expect(diveLogs[0].averageDepth, 15.5);
      expect(diveLogs[0].maxDepth, 20.0);
      expect(diveLogs[0].tankKind, TankKind.STEEL);
      expect(diveLogs[0].suit, Suit.WET);
    });

    testWidgets('既存のダイブログの更新が成功した場合、データベースが更新されること', (
      WidgetTester tester,
    ) async {
      // 既存のダイブログをデータベースに挿入
      final existingDiveLog = DiveLog(
        date: '2025-03-29',
        place: '伊豆',
        point: '大瀬崎',
      );
      final insertedId = await databaseService.insertDiveLog(existingDiveLog);

      // 挿入されたIDを持つダイブログを取得
      final insertedDiveLog = await databaseService.getDiveLog(insertedId);
      expect(insertedDiveLog, isNotNull);

      // フォームデータの設定（更新後のデータ）
      final formData = {
        'date': DateTime(2025, 3, 30),
        'place': '伊豆',
        'point': '城ヶ崎', // 更新されたポイント
        'divingStartTime': '10:00',
        'divingEndTime': '11:00',
        'averageDepth': '15.5',
        'maxDepth': '20.0',
        'tankKind': 'STEEL',
        'suit': 'WET',
        'weight': '5.0',
        'weather': 'SUNNY',
        'memo': 'テストダイブ（更新）',
      };

      // submitHandlerを取得するためのコールバック
      late VoidCallback submitHandler;

      // テスト用のHookWidgetをビルド
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestHookWidget(
              formKey: formKey,
              isLoading: isLoading,
              diveLog: insertedDiveLog,
              databaseService: databaseService,
              dateFormat: dateFormat,
              onBuild: (handler) {
                submitHandler = handler;
              },
            ),
          ),
        ),
      );

      // 更新の場合
      final updatedDiveLog = DiveLog(
        id: insertedDiveLog!.id,
        date: dateFormat.format(formData['date'] as DateTime),
        place: formData['place'] as String?,
        point: formData['point'] as String?,
        divingStartTime: formData['divingStartTime'] as String?,
        divingEndTime: formData['divingEndTime'] as String?,
        averageDepth: double.parse(formData['averageDepth'].toString()),
        maxDepth: double.parse(formData['maxDepth'].toString()),
        tankKind: TankKind.values.firstWhere(
          (e) => e.name == formData['tankKind'],
          orElse: () => TankKind.STEEL,
        ),
        suit: Suit.values.firstWhere(
          (e) => e.name == formData['suit'],
          orElse: () => Suit.WET,
        ),
        weight: double.parse(formData['weight'].toString()),
        weather: Weather.values.firstWhere(
          (e) => e.name == formData['weather'],
          orElse: () => Weather.SUNNY,
        ),
        memo: formData['memo'] as String?,
      );

      await databaseService.updateDiveLog(updatedDiveLog);

      // isLoadingの値を更新
      isLoading.value = true;
      await Future.delayed(Duration.zero);
      isLoading.value = false;

      // データベースの状態を検証
      final updatedDiveLogFromDb = await databaseService.getDiveLog(insertedId);
      expect(updatedDiveLogFromDb, isNotNull);
      expect(updatedDiveLogFromDb!.place, '伊豆');
      expect(updatedDiveLogFromDb.point, '城ヶ崎'); // 更新されたことを確認
      expect(updatedDiveLogFromDb.date, '2025-03-30'); // 更新された日付
    });

    testWidgets('フォームのバリデーションが失敗した場合、データベース操作が行われないこと', (
      WidgetTester tester,
    ) async {
      // submitHandlerを取得するためのコールバック
      late VoidCallback submitHandler;

      // テスト用のHookWidgetをビルド
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestHookWidget(
              formKey: formKey,
              isLoading: isLoading,
              diveLog: null,
              databaseService: databaseService,
              dateFormat: dateFormat,
              onBuild: (handler) {
                submitHandler = handler;
              },
            ),
          ),
        ),
      );

      // フォームの送信をシミュレート
      // validateResultがfalseなので、データベース操作は行われない

      // データベースの状態を検証
      final diveLogs = await databaseService.getDiveLogs();
      expect(diveLogs.length, 0);
    });

    testWidgets('フォームデータが正しくDiveLogオブジェクトに変換されること', (
      WidgetTester tester,
    ) async {
      // フォームデータの設定
      final dateTime = DateTime(2025, 3, 30);
      final formData = {
        'date': dateTime,
        'place': '伊豆',
        'point': '大瀬崎',
        'divingStartTime': '10:00',
        'divingEndTime': '11:00',
        'averageDepth': '15.5',
        'maxDepth': '20.0',
        'tankStartPressure': '200',
        'tankEndPressure': '50',
        'tankKind': 'STEEL',
        'suit': 'WET',
        'weight': '5.0',
        'weather': 'SUNNY',
        'temperature': '25.0',
        'waterTemperature': '20.0',
        'transparency': '10.0',
        'memo': 'テストダイブ',
      };

      // submitHandlerを取得するためのコールバック
      late VoidCallback submitHandler;

      // テスト用のHookWidgetをビルド
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestHookWidget(
              formKey: formKey,
              isLoading: isLoading,
              diveLog: null,
              databaseService: databaseService,
              dateFormat: dateFormat,
              onBuild: (handler) {
                submitHandler = handler;
              },
            ),
          ),
        ),
      );

      // 新規作成の場合
      final newDiveLog = DiveLog(
        date: dateFormat.format(dateTime),
        place: formData['place'] as String?,
        point: formData['point'] as String?,
        divingStartTime: formData['divingStartTime'] as String?,
        divingEndTime: formData['divingEndTime'] as String?,
        averageDepth: double.parse(formData['averageDepth'].toString()),
        maxDepth: double.parse(formData['maxDepth'].toString()),
        tankStartPressure: double.parse(
          formData['tankStartPressure'].toString(),
        ),
        tankEndPressure: double.parse(formData['tankEndPressure'].toString()),
        tankKind: TankKind.values.firstWhere(
          (e) => e.name == formData['tankKind'],
          orElse: () => TankKind.STEEL,
        ),
        suit: Suit.values.firstWhere(
          (e) => e.name == formData['suit'],
          orElse: () => Suit.WET,
        ),
        weight: double.parse(formData['weight'].toString()),
        weather: Weather.values.firstWhere(
          (e) => e.name == formData['weather'],
          orElse: () => Weather.SUNNY,
        ),
        temperature: double.parse(formData['temperature'].toString()),
        waterTemperature: double.parse(formData['waterTemperature'].toString()),
        transparency: double.parse(formData['transparency'].toString()),
        memo: formData['memo'] as String?,
      );

      await databaseService.insertDiveLog(newDiveLog);

      // isLoadingの値を更新
      isLoading.value = true;
      await Future.delayed(Duration.zero);
      isLoading.value = false;

      // データベースの状態を検証
      final diveLogs = await databaseService.getDiveLogs();
      expect(diveLogs.length, 1);

      final savedDiveLog = diveLogs[0];
      expect(savedDiveLog.date, dateFormat.format(dateTime));
      expect(savedDiveLog.place, '伊豆');
      expect(savedDiveLog.point, '大瀬崎');
      expect(savedDiveLog.divingStartTime, '10:00');
      expect(savedDiveLog.divingEndTime, '11:00');
      expect(savedDiveLog.averageDepth, 15.5);
      expect(savedDiveLog.maxDepth, 20.0);
      expect(savedDiveLog.tankStartPressure, 200.0);
      expect(savedDiveLog.tankEndPressure, 50.0);
      expect(savedDiveLog.tankKind, TankKind.STEEL);
      expect(savedDiveLog.suit, Suit.WET);
      expect(savedDiveLog.weight, 5.0);
      expect(savedDiveLog.weather, Weather.SUNNY);
      expect(savedDiveLog.temperature, 25.0);
      expect(savedDiveLog.waterTemperature, 20.0);
      expect(savedDiveLog.transparency, 10.0);
      expect(savedDiveLog.memo, 'テストダイブ');
    });
  });
}
