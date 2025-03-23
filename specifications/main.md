# 概要

ダイビングのログブックの iOS アプリを作成する

# タスク

- /dive_log_legacy に Nextjs で実装されたダイビングのログブックの Web アプリがある。それを Flutter で書き直して欲しい。
- ログブックを共有する機能は移植しないでください。
  - dive_log_legacy/pages/share/
  - dive_log_legacy/pages/api/share/
- ログインの機能は移植しないでください。

# ディレクトリ構成

## dive_log_legacy（Nextjs 実装）

```
dive_log_legacy/
├── .env                      # 環境変数設定ファイル
├── .eslintrc.json           # ESLint設定
├── .gitignore               # Gitの除外ファイル設定
├── jest.config.mjs          # Jestテスト設定
├── next.config.js           # Next.js設定
├── package.json             # パッケージ依存関係
├── playwright.config.ts     # Playwrightテスト設定
├── README.md                # プロジェクト説明
├── tsconfig.json            # TypeScript設定
├── yarn.lock                # Yarn依存関係ロックファイル
├── __tests__/               # テストディレクトリ
│   ├── components/          # コンポーネントテスト
│   │   ├── __utils__/       # テスト用ユーティリティ
│   │   └── templates/       # テンプレートコンポーネントテスト
│   ├── pages/               # ページテスト
│   │   └── api/             # APIテスト
│   └── schemas/             # スキーマテスト
├── e2e/                     # E2Eテスト
│   └── __utils__/           # E2Eテスト用ユーティリティ
├── prisma/                  # Prisma ORM
│   ├── schema.prisma        # データベーススキーマ
│   └── migrations/          # データベースマイグレーション
├── public/                  # 静的ファイル
├── src/                     # ソースコード
│   ├── middleware.ts        # ミドルウェア
│   ├── app/                 # Appディレクトリ（Next.js 13+）
│   ├── clients/             # クライアント接続
│   │   ├── prisma.ts        # Prismaクライアント
│   │   └── supabase.ts      # Supabaseクライアント
│   ├── components/          # コンポーネント
│   │   ├── Layout.tsx       # レイアウトコンポーネント
│   │   └── templates/       # テンプレートコンポーネント
│   │       ├── BuddyCommentForm.tsx  # バディコメントフォーム
│   │       ├── BuddyForm.tsx         # バディフォーム
│   │       ├── DiveLogForm.tsx       # ダイブログフォーム
│   │       ├── DiveLogLinkDialog.tsx # ダイブログリンクダイアログ
│   │       └── DiveLogList.tsx       # ダイブログリスト
│   ├── pages/               # ページコンポーネント
│   │   ├── _app.tsx         # アプリケーションラッパー
│   │   ├── _document.tsx    # HTML文書設定
│   │   ├── login.tsx        # ログインページ
│   │   ├── api/             # APIルート
│   │   │   ├── share/       # 共有関連API
│   │   │   │   └── diveLogs/
│   │   │   │       └── [uuid]/
│   │   │   │           ├── index.ts  # ダイブログ詳細取得API
│   │   │   │           └── buddies/
│   │   │   │               ├── new.ts  # バディ作成API
│   │   │   │               └── [buddyId]/
│   │   │   │                   └── comments/
│   │   │   │                       └── new.ts  # コメント作成API
│   │   │   └── users/       # ユーザー関連API
│   │   │       └── [userId]/
│   │   │           ├── diveLogs.ts  # ユーザーのダイブログ一覧API
│   │   │           └── diveLogs/
│   │   │               └── [id]/
│   │   │                   ├── index.ts  # ダイブログ詳細API
│   │   │                   └── buddy/
│   │   │                       └── shareLink/
│   │   │                           └── issue.ts  # 共有リンク発行API
│   │   ├── diveLogs/        # ダイブログページ
│   │   │   ├── [id].tsx     # ダイブログ詳細ページ
│   │   │   ├── index.tsx    # ダイブログ一覧ページ
│   │   │   └── new.tsx      # ダイブログ作成ページ
│   │   └── share/           # 共有ページ
│   │       └── diveLogs/
│   │           └── [uuid]/
│   │               ├── comments.tsx  # コメントページ
│   │               └── index.tsx     # 共有ダイブログ詳細ページ
│   ├── schemas/             # データスキーマ
│   │   ├── buudy.ts         # バディスキーマ
│   │   └── diveLog.ts       # ダイブログスキーマ
│   ├── styles/              # スタイルシート
│   │   ├── globals.css      # グローバルスタイル
│   │   └── Home.module.css  # ホームページスタイル
│   └── utils/               # ユーティリティ関数
│       ├── commons.ts       # 共通ユーティリティ
│       └── type.ts          # 型定義
├── supabase/                # Supabase設定
│   ├── functions/           # Supabase Functions
│   └── migrations/          # Supabase マイグレーション
└── test-results/            # テスト結果
```

# ライブラリ

以下のライブラリを利用すること。無い場合は install すること。

- sqflite: DataBase
- flutter_hooks: ライフサイクルの管理をする
