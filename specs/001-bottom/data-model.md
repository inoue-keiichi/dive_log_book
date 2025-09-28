# Data Model: ダイビング時間統計画面

## 既存エンティティ使用

### DiveLog（再利用）

**Purpose**: 統計計算のソースデータ
**Fields Used**:

- `divingStartTime`: String (HH:mm format) - 潜水開始時間
- `divingEndTime`: String (HH:mm format) - 潜水終了時間
- `date`: DateTime - ダイビング実施日

**Validation Rules**:

- `divingStartTime` and `divingEndTime`: 有効な HH:mm 形式、時間範囲（00:00-23:59）
- 終了時間 > 開始時間（日をまたがない前提）
- null 値許可（統計計算時は除外）

## 新規リポジトリメソッド

### StatisticsRepository（拡張）

**Purpose**: 統計データ取得・計算ロジック
**New Methods**:

- `Future<int> getTotalDivingTimeMinutes()`: 総潜水時間を分単位で返す
- `Future<int> getDiveCountWithTime()`: 時間記録のあるダイビング数取得

**Return Values**:

- `getTotalDivingTimeMinutes()`: int (>= 0) - 総潜水時間（分）
- `getDiveCountWithTime()`: int (>= 0) - 有効な時間データを持つダイビング数

**State Transitions**: 該当なし（読み取り専用操作）

## データフロー

```
DiveLog (SQLite)
    ↓
StatisticsRepository.getTotalDivingTimeMinutes()
    ↓
useAggrigateDivelogs (repositoryの呼び出し)
    ↓
Statistics Template (フォーマット処理)
    ↓
UI表示 ("XX時間XX分"形式)
```

## 計算ロジック

### 潜水時間計算アルゴリズム

1. 有効な時間データを持つ DiveLog エントリを取得
2. 各エントリで `divingEndTime - divingStartTime` を計算
3. 全エントリの潜水時間を合計
4. 分単位の合計を時間分形式に変換

### SQL 集計クエリ（想定）

```sql
SELECT
  SUM(
    (CAST(substr(diving_end_time, 1, 2) AS INTEGER) * 60 +
     CAST(substr(diving_end_time, 4, 2) AS INTEGER)) -
    (CAST(substr(diving_start_time, 1, 2) AS INTEGER) * 60 +
     CAST(substr(diving_start_time, 4, 2) AS INTEGER))
  ) as total_minutes,
  COUNT(*) as total_dives
FROM dive_logs
WHERE diving_start_time IS NOT NULL
  AND diving_end_time IS NOT NULL;
```

## エラーケース対応

### ゼロデータ

- `getTotalDivingTimeMinutes()` returns 0
- Template formats as "0時間0分"
- UI 表示: "まだダイビング記録がありません"

### 無効時間データ

- 論理エラー（終了 < 開始）: 該当レコードを計算から除外
