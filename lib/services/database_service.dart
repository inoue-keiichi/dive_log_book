import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  bool test = false;

  DatabaseService(this.test);

  Future<Database> open() async {
    // テスト環境の場合はインメモリデータベースを使用
    if (const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false)) {
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _onCreate,
      );
    }

    final dbDirectory = await getApplicationSupportDirectory();
    final dbName = test ? "dive_log_book_for_test.db" : "dive_log_book.db";
    final path = join(dbDirectory.path, dbName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }
}
