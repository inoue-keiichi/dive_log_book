# Integration Tests

このディレクトリには、Flutter標準の`integration_test`パッケージを使用したインテグレーションテストが含まれています。

## 概要

インテグレーションテストは、アプリ全体の動作を実際のデバイスやシミュレータ/エミュレータ上で検証するためのテストです。ユニットテストやウィジェットテストと異なり、実際の環境に近い状態でアプリの動作を確認できます。

## テストファイル

- `bottom_navigation_test.dart` - 底部ナビゲーションのインテグレーションテスト
- `statistics_display_test.dart` - 統計表示機能のインテグレーションテスト

## 実行方法

### 基本的な実行方法

```bash
# すべてのインテグレーションテストを実行
flutter test integration_test

# 特定のテストファイルのみを実行
flutter test integration_test/bottom_navigation_test.dart
flutter test integration_test/statistics_display_test.dart
```

### デバイス/シミュレータで実行

インテグレーションテストは、実際のデバイスやシミュレータ/エミュレータで実行することもできます：

```bash
# デバイス/シミュレータで実行（テストドライバーを使用）
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/bottom_navigation_test.dart

# または
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/statistics_display_test.dart
```

### プロファイルモードでの実行

パフォーマンステストなどでより正確な測定を行う場合は、プロファイルモードで実行します：

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/statistics_display_test.dart \
  --profile
```

### デバイスを指定して実行

複数のデバイスがある場合、特定のデバイスを指定できます：

```bash
# 接続されているデバイスを確認
flutter devices

# デバイスを指定して実行
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/bottom_navigation_test.dart \
  -d <device_id>
```

## テスト構造

各テストファイルは以下の構造になっています：

1. **IntegrationTestWidgetsFlutterBinding の初期化**
   ```dart
   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
   ```

2. **セットアップ**
   - `setUpAll`: すべてのテスト実行前に一度だけ実行
   - `setUp`: 各テスト実行前に毎回実行

3. **テストケース**
   - `testWidgets`: 個々のテストケースを定義

## 旧テストディレクトリとの違い

以前の`test/integration`ディレクトリにあったテストは、通常の`flutter_test`パッケージを使用していましたが、現在は標準の`integration_test`パッケージに移行しました。

主な違い：
- **実行環境**: `flutter_test`はテスト環境で実行、`integration_test`は実際のデバイス/シミュレータで実行
- **テストバインディング**: `IntegrationTestWidgetsFlutterBinding`を使用
- **実行コマンド**: `flutter test`または`flutter drive`で実行可能

## トラブルシューティング

### テストがタイムアウトする場合

長時間かかるテストの場合、タイムアウトを延長できます：

```dart
testWidgets('長時間テスト', (WidgetTester tester) async {
  // ...
}, timeout: const Timeout(Duration(minutes: 5)));
```

### sqflite関連のエラー

テスト環境でsqfliteを使用する場合、`sqflite_common_ffi`の初期化が必要です：

```dart
setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});
```

## 参考リンク

- [Flutter Integration Testing 公式ドキュメント](https://docs.flutter.dev/testing/integration-tests)
- [integration_test パッケージ](https://github.com/flutter/flutter/tree/main/packages/integration_test)
