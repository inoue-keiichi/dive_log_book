// Contract: StatisticsRepository拡張メソッド
// Purpose: 統計データ取得・計算ロジックの契約定義

abstract class StatisticsRepositoryExtension {
  /// 総潜水時間を分単位で取得
  ///
  /// Returns:
  ///   - int: 総潜水時間（分単位、>= 0）
  ///
  /// Calculation:
  ///   - divingStartTime, divingEndTime両方がnull以外のレコードのみ対象
  ///   - 各レコードで (終了時間 - 開始時間) を分で計算
  ///   - 全レコードの潜水時間を合計
  ///   - 無効データ（フォーマット不正、終了<開始）は除外
  ///
  /// Throws:
  ///   - DatabaseException: DB接続・クエリエラー
  Future<int> getTotalDivingTimeMinutes();

  /// 有効な時間記録を持つダイビング数を取得
  ///
  /// Returns:
  ///   - int: 時間データありのダイビング数 (>= 0)
  ///
  /// Conditions:
  ///   - divingStartTime IS NOT NULL
  ///   - divingEndTime IS NOT NULL
  ///   - HH:mm形式として解析可能
  ///   - 終了時間 >= 開始時間
  Future<int> getDiveCountWithTime();
}

// Test Scenarios (契約テスト用)
const statisticsRepositoryTestScenarios = [
  'Empty database: getTotalDivingTimeMinutes() returns 0',
  'Empty database: getDiveCountWithTime() returns 0',
  'Single valid dive: correct time calculation',
  'Multiple valid dives: sum calculation',
  'Null time fields: excluded from calculation',
  'Invalid time format: excluded from calculation',
  'End time before start time: excluded from calculation',
  'Mixed valid/invalid data: only valid included',
];