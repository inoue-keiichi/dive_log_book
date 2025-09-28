# Tasks: ダイビング時間統計画面

**Input**: Design documents from `/specs/001-bottom/`
**Prerequisites**: plan.md (✓), research.md (✓), data-model.md (✓), contracts/ (✓)

## Execution Flow (main)
```
1. Load plan.md from feature directory ✓
   → Tech stack: Flutter + Dart, flutter_hooks, sqflite
   → Structure: Single project (lib/ based)
2. Load design documents ✓:
   → data-model.md: StatisticsRepository拡張メソッド
   → contracts/: statistics_repository_methods.dart
   → research.md: 3層パターン、BottomNavigationBar使用
3. Generate tasks by category ✓:
   → Setup: 依存関係確認、lint設定
   → Tests: 契約テスト、統合テスト
   → Core: Repository拡張、統計画面UI
   → Integration: ナビゲーション統合
   → Polish: ユニットテスト、パフォーマンステスト
4. Apply task rules ✓:
   → 異なるファイル = [P]並列実行可能
   → 同一ファイル = 順次実行
   → テスト先行（TDD）
5. Number tasks sequentially ✓
6. Generate dependency graph ✓
7. Create parallel execution examples ✓
8. Validate task completeness ✓
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: 並列実行可能（異なるファイル、依存関係なし）
- 説明文に正確なファイルパスを含める

## Path Conventions
Flutter単一プロジェクト構造：
- **Models**: `lib/models/`
- **Features**: `lib/features/statistics/`
- **Repositories**: `lib/repositories/`
- **Tests**: `test/`

## Phase 3.1: Setup
- [ ] T001 Flutter依存関係確認とlint設定確認
- [ ] T002 [P] 統計機能用ディレクトリ構造作成 `lib/features/statistics/`

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: これらのテストは実装前に作成され、必ず失敗しなければならない**
- [ ] T003 [P] StatisticsRepository契約テスト in `test/repositories/statistics_repository_test.dart`
- [ ] T004 [P] 統計画面ウィジェットテスト in `test/features/statistics/statistics_screen_test.dart`
- [ ] T005 [P] 統計計算フックテスト in `test/features/statistics/use_statistics_test.dart`
- [ ] T006 [P] 底部ナビゲーション統合テスト in `test/integration/bottom_navigation_test.dart`
- [ ] T007 [P] 統計データ表示統合テスト in `test/integration/statistics_display_test.dart`

## Phase 3.3: Core Implementation (テスト失敗後のみ)
- [ ] T008 [P] DiveLogRepository拡張実装 in `lib/repositories/dive_log_repository.dart`
- [ ] T009 [P] 統計計算フック実装 in `lib/features/statistics/use_statistics.dart`
- [ ] T010 [P] 統計画面テンプレート実装 in `lib/features/statistics/statistics_template.dart`
- [ ] T011 統計画面メイン実装 in `lib/features/statistics/statistics_screen.dart`
- [ ] T012 時間フォーマットユーティリティ実装 in `lib/utils/time_format_utils.dart`

## Phase 3.4: Integration
- [ ] T013 main.dartに底部ナビゲーション追加とルーティング設定
- [ ] T014 統計画面をナビゲーションに統合
- [ ] T015 エラーハンドリングとローディング状態管理
- [ ] T016 Material Design 3対応とアクセシビリティ設定

## Phase 3.5: Polish
- [ ] T017 [P] 時間計算ロジックユニットテスト in `test/utils/time_calculation_test.dart`
- [ ] T018 [P] UI表示フォーマットユニットテスト in `test/utils/time_format_utils_test.dart`
- [ ] T019 パフォーマンステスト（<100ms クエリ応答時間）
- [ ] T020 [P] quickstart.md手動テスト実行
- [ ] T021 コード重複除去とリファクタリング
- [ ] T022 `flutter analyze` 実行とwarning修正

## Dependencies
- Setup (T001-T002) → Tests (T003-T007)
- Tests (T003-T007) → Implementation (T008-T012)
- T008 (Repository) → T009 (Hook), T011 (Screen)
- T009, T010, T012 → T011 (Screen main)
- T011 → T013, T014 (Integration)
- Implementation (T008-T012) → Integration (T013-T016)
- Integration → Polish (T017-T022)

## Parallel Example
```bash
# T003-T007を並列実行:
Task: "StatisticsRepository契約テスト in test/repositories/statistics_repository_test.dart"
Task: "統計画面ウィジェットテスト in test/features/statistics/statistics_screen_test.dart"
Task: "統計計算フックテスト in test/features/statistics/use_statistics_test.dart"
Task: "底部ナビゲーション統合テスト in test/integration/bottom_navigation_test.dart"
Task: "統計データ表示統合テスト in test/integration/statistics_display_test.dart"

# T008-T010, T012を並列実行:
Task: "DiveLogRepository拡張実装 in lib/repositories/dive_log_repository.dart"
Task: "統計計算フック実装 in lib/features/statistics/use_statistics.dart"
Task: "統計画面テンプレート実装 in lib/features/statistics/statistics_template.dart"
Task: "時間フォーマットユーティリティ実装 in lib/utils/time_format_utils.dart"
```

## Notes
- [P] タスク = 異なるファイル、依存関係なし
- 実装前にテストが失敗することを確認
- 各タスク後にcommit
- 避けるべき: 曖昧なタスク、同一ファイル競合

## Task Generation Rules
*main() 実行中に適用*

1. **From Contracts**:
   - StatisticsRepository契約 → 契約テストタスク [P]
   - getTotalDivingTimeMinutes, getDiveCountWithTime → 実装タスク

2. **From Data Model**:
   - StatisticsRepository拡張 → Repository実装タスク [P]
   - データフロー → Hook, Template実装タスク [P]

3. **From User Stories**:
   - ナビゲーション遷移 → 統合テスト [P]
   - 統計表示 → 統合テスト [P]
   - quickstart シナリオ → 検証タスク

4. **Ordering**:
   - Setup → Tests → Repository → Hooks/Templates → Screen → Integration → Polish
   - TDD: テスト失敗 → 実装 → テスト成功

## Validation Checklist
*main() 完了前にGATEチェック*

- [x] All contracts have corresponding tests
- [x] Repository拡張にテストあり
- [x] All tests come before implementation
- [x] Parallel tasks truly independent
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task

## 機能固有の詳細

### 実装する主要コンポーネント
1. **DiveLogRepository拡張**: `getTotalDivingTimeMinutes()`, `getDiveCountWithTime()`
2. **統計計算フック**: `useStatistics()` - Repository呼び出しとエラーハンドリング
3. **統計画面UI**: 3層パターン (screen/template/hook)
4. **BottomNavigationBar**: 統計タブ追加
5. **時間フォーマット**: 分数を「XX時間XX分」形式に変換

### テストカバレッジ
- Repository メソッドの契約テスト
- ウィジェット表示テスト
- ナビゲーション遷移テスト
- 時間計算ロジックテスト
- エラーケース（ゼロデータ、無効データ）テスト

### パフォーマンス要件
- SQLite集計クエリ応答時間 <100ms
- UI表示 60fps
- Material Design 3 準拠