# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 言語設定

Claude Codeは常に日本語で応答してください。

## プロジェクト概要

このプロジェクトは、ダイビングログを管理するFlutterアプリケーションです。ユーザーはダイビング活動の詳細な記録を作成、編集、管理することができます。記録には潜水場所、水深、器材、天気条件などの関連データが含まれます。

## 開発コマンド

### 基本的なFlutterコマンド
- `flutter run` - デバッグモードでアプリを実行
- `flutter test` - 全てのユニットテストを実行
- `flutter analyze` - コードの問題やlintルール違反を分析
- `flutter build apk` - Android APKをビルド
- `flutter build ios` - iOS向けビルド（macOSとXcodeが必要）
- `flutter clean` - ビルド成果物をクリーン
- `flutter pub get` - 依存関係をインストール
- `flutter pub upgrade` - 依存関係をアップグレード

### テスト
- `flutter test test/screens/dive_log_form_screen_test.dart` - 特定のテストファイルを実行
- テストファイルは`test/`ディレクトリに配置
- ウィジェットテストに`flutter_test`パッケージを使用
- データベーステストはインメモリデータベース用に`sqflite_common_ffi`を使用

## アーキテクチャ

### コア構造
- **`lib/main.dart`** - アプリのエントリーポイント、データベースとMaterialAppを初期化
- **`lib/models/`** - データモデル（バリデーション拡張付きのDiveLog）
- **`lib/services/`** - ビジネスロジック層（SQLite操作のDatabaseService）
- **`lib/features/`** - 機能ベースのUI構成
- **`lib/providers/`** - 状態管理（DatabaseServiceProvider）
- **`lib/utils/`** - ユーティリティ関数（日付フォーマット）
- **`lib/validators/`** - 入力値検証ロジック

### 主要なパターン

#### 機能ベースアーキテクチャ
各機能は`lib/features/[機能名]/`で整理されています：
- `[機能名]_screen.dart` - hooksとビジネスロジックを含むメインウィジェット
- `[機能名]_template.dart` - 純粋なUIテンプレートコンポーネント
- `form_hooks.dart` - フォーム操作用のカスタムフック（作成、更新、削除）

#### データベース層
- **DatabaseService**: SQLite操作のシングルトンパターン
- テスト環境の自動検出（`FLUTTER_TEST`が設定されている場合はインメモリデータベースを使用）
- パス: `/Users/[ユーザー]/Library/Application Support/[アプリ]/dive_log_book.db`（本番環境）

#### 状態管理
- Reactスタイルの状態管理に`flutter_hooks`を使用
- フォーム操作用のカスタムフックパターン：
  - `useLoading()` - ローディング状態管理
  - `useCreateHandler()` - 新規レコード作成
  - `useUpdateHandler()` - レコード更新
  - `useDeleteHandler()` - 確認ダイアログ付きレコード削除

#### フォーム処理
- 複雑なフォーム管理に`flutter_form_builder`を使用
- `DiveLogValidators`拡張での包括的なバリデーション
- 水深、圧力、温度などのフィールド固有のバリデータ
- UIコンポーネントのテンプレート/ロジック分離パターン

### データモデル
コアとなる`DiveLog`モデルには以下が含まれます：
- 基本的なダイブ情報（日付、場所、ダイブサイト）
- 潜水時間データ（`divingStartTime`、`divingEndTime` - HH:mm形式文字列）
- 水深指標（平均/最大水深（メートル））
- 器材データ（タンクの種類/圧力、スーツの種類、ウェイト）
- 環境条件（天気、気温/水温、透明度）
- 自由記述のメモフィールド

全ての数値フィールドは任意で、特定の検証範囲があります。モデルには標準化された選択肢用のenum型が含まれています。

### 統計機能（新規追加）
- ダイビング時間統計画面：全ダイビングログの潜水時間合計を表示
- Repository拡張：`getTotalDivingTimeMinutes()`メソッドでSQLite集計クエリ実行
- 底部ナビゲーション：統計画面へのアクセス

## 依存関係

### 主要なライブラリ
- `sqflite` - データ永続化用のSQLiteデータベース
- `flutter_hooks` - Reactスタイルの状態管理
- `flutter_form_builder` - 高度なフォームコンポーネント
- `form_builder_validators` - フォームバリデーションユーティリティ
- `path_provider` - ファイルシステムパスアクセス
- `intl` - 国際化と日付フォーマット

### 開発用
- `flutter_lints` - Dart/Flutterリンティングルール
- `flutter_test` - テストフレームワーク
- `sqflite_common_ffi` - テスト用インメモリデータベース

## コードスタイルについて

- コードベース全体で日本語のコメントとUIテキストを使用
- Material Design 3を使用（`useMaterial3: true`）
- Reactフックに類似したFlutterフックパターンに従う
- テスタビリティ向上のためのテンプレート/ロジック分離
- ユーザーフレンドリーなエラーメッセージを含む包括的な入力値検証