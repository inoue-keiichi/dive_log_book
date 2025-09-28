# Feature Specification: ダイビング時間統計画面

**Feature Branch**: `001-bottom`
**Created**: 2025-09-15
**Status**: Draft
**Input**: User description: "ダイビングログの潜水時間の合計を表示する画面を追加してください。bottom ナビゲーションで遷移できるようにして欲しい"

## Execution Flow (main)

```
1. Parse user description from Input
   → Feature is to add dive time statistics screen with bottom navigation
2. Extract key concepts from description
   → Actors: ダイビングユーザー
   → Actions: 潜水時間統計の表示、画面遷移
   → Data: 既存のダイビングログデータの潜水時間
   → Constraints: bottomナビゲーションからアクセス可能
3. For each unclear aspect:
   → 潜水時間の単位は時間分単位
   → 統計の期間は全期間
4. Fill User Scenarios & Testing section
   → ユーザーは統計画面で自分の総潜水時間を確認できる
5. Generate Functional Requirements
   → 各要件はテスト可能
6. Identify Key Entities
   → DiveLog（既存）の潜水時間データを使用
7. Run Review Checklist
   → WARN "Spec has uncertainties"（時間単位と期間選択について）
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines

- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

---

## User Scenarios & Testing _(mandatory)_

### Primary User Story

ダイビングユーザーとして、自分がこれまでに潜水した時間の合計を簡単に確認したい。アプリの底部ナビゲーションから統計画面にアクセスし、総潜水時間を一目で把握できるようにしたい。

### Acceptance Scenarios

1. **Given** ユーザーがアプリを開いている、**When** 底部ナビゲーションの統計タブをタップする、**Then** 統計画面が表示される
2. **Given** ユーザーが統計画面を開いている、**When** 画面を確認する、**Then** 総潜水時間が明確に表示される
3. **Given** ダイビングログが複数登録されている、**When** 統計画面を表示する、**Then** 全てのログの潜水時間の合計が計算されて表示される

### Edge Cases

- ダイビングログが 0 件の場合、統計画面に「データがありません」のような適切なメッセージが表示されるか？
- 潜水時間が未入力のログがある場合、計算から除外されるか？
- 非常に大きな時間数（例：1000 時間超）でも正しく表示されるか？

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: システムは底部ナビゲーションに統計画面へのタブを追加しなければならない
- **FR-002**: システムは統計画面で全ダイビングログの潜水時間の合計を計算して表示しなければならない
- **FR-003**: システムは潜水時間が未入力のログを合計計算から除外しなければならない
- **FR-004**: システムはダイビングログが 0 件の場合に適切なメッセージを表示しなければならない
- **FR-005**: システムは潜水時間を時間分単位で表示しなければならない
- **FR-006**: システムは統計の表示期間を全期間固定で提供しなければならない

### Key Entities _(include if feature involves data)_

- **DiveLog**: 既存のダイビングログエンティティ、潜水時間フィールドを統計計算に使用
- **NavigationTab**: 底部ナビゲーションの新しいタブ、統計画面への遷移を管理

---

## Review & Acceptance Checklist

_GATE: Automated checks run during main() execution_

### Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status

_Updated by main() during processing_

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [ ] Review checklist passed

---
