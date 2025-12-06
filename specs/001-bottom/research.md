# Research: ダイビング時間統計画面

## 時間計算ロジック

**Decision**: `divingStartTime`と`divingEndTime`（HH:mm形式文字列）から潜水時間を分単位で計算
**Rationale**: 既存のDiveLogモデルでは時間をHH:mm文字列で保存。Duration計算で分単位の差分を取得
**Alternatives considered**:
- 秒単位計算 → 精度過剰、ユーザーには分単位で十分
- 時間単位計算 → 精度不足、短時間ダイビングで0時間表示のリスク

## 底部ナビゲーション実装

**Decision**: Flutter標準の`BottomNavigationBar`を使用
**Rationale**: Material Design 3準拠、既存アプリのデザイン言語と整合、シンプルな実装
**Alternatives considered**:
- Custom bottom bar → 過剰な複雑性
- Tab view → ナビゲーション意図と不整合

## 統計データ集計方法

**Decision**: SQLiteクエリで直接集計（SUM演算）
**Rationale**: パフォーマンス効率、SQLiteの集計機能活用、メモリ使用量最小化
**Alternatives considered**:
- Dartコードでループ集計 → パフォーマンス劣化、メモリ使用量増大
- キャッシュ機能 → 過剰な複雑性、データ整合性リスク

## データ形式とUI表示

**Decision**: 統計結果を「XX時間XX分」形式で表示
**Rationale**: ユーザーフレンドリー、直感的理解、既存アプリの時間表示パターンと整合
**Alternatives considered**:
- 分のみ表示 → 大きな数値（例：1440分）の理解困難
- 小数点付き時間 → 日常的でない表現

## アーキテクチャパターン

**Decision**: 既存の3層パターンを踏襲（screen/template/hook）
**Rationale**: コードベース一貫性、保守性、既存パターンとの整合性
**Alternatives considered**:
- 単一ファイル実装 → アーキテクチャ一貫性欠如
- 新しいパターン → 不要な複雑性導入

## 状態管理

**Decision**: `flutter_hooks`の`useState`と`useEffect`を使用
**Rationale**: 既存コードベースとの整合性、リアクティブパターン、シンプルな状態管理
**Alternatives considered**:
- Provider → 過剰な複雑性、シンプルな統計画面には不要
- StatefulWidget → フックパターンとの不整合

## エラーハンドリング

**Decision**: データベースエラーとゼロデータケースの明示的処理
**Rationale**: ユーザーエクスペリエンス向上、障害時の適切なフィードバック
**Alternatives considered**:
- 無視 → ユーザビリティ問題
- 例外スロー → アプリクラッシュリスク