# Docker 環境使用ガイド

Honest Voice は Docker 環境で実行できます。

- **ローカル開発**: `docker-compose` で簡単起動
- **本番環境**: `Dockerfile` 単体で実行

---

## 📋 前提条件

- Docker & Docker Compose がインストール済み
- Ruby 3.2 / Node.js 18+（ホスト開発時）

---

## 🔧 ローカル開発環境

### 1. Docker イメージビルド・起動

```bash
# docker-compose で起動（最初は --build で初期化）
docker-compose up --build

# 2回目以降は
docker-compose up
```

### 2. フォルダ構成

```
honest-voice/
├── Dockerfile           # マルチステージビルド
├── docker-compose.yml   # ローカル開発用
├── docker-entrypoint.sh # 環境初期化スクリプト
└── .env.example         # 環境変数テンプレート
```

### 3. コンテナ内でコマンド実行

```bash
# Rails コンソール
docker-compose exec app bundle exec rails console

# RSpec テスト実行
docker-compose exec app bundle exec rspec

# Rails ジェネレータ
docker-compose exec app bundle exec rails generate devise:model User

# bash シェル
docker-compose exec app bash
```

### 4. ログ確認

```bash
# リアルタイムログ表示
docker-compose logs -f app

# 過去のログを表示
docker-compose logs app
```

### 5. コンテナを停止・削除

```bash
# 停止
docker-compose down

# ボリュームも削除（DB をリセット）
docker-compose down -v
```

---

## 🚀 本番環境（Docker 単体）

### 1. 本番用イメージビルド

```bash
docker build -t honest-voice:prod --target production .
```

### 2. 環境変数ファイル作成

```bash
cp .env.example .env
# .env を編集して本番設定に変更
```

### 3. 本番サーバー起動

```bash
# 基本実行
docker run -d \
  -p 3000:3000 \
  -e RAILS_ENV=production \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  --name honest-voice-prod \
  honest-voice:prod

# または環境ファイルから読み込み
docker run -d \
  -p 3000:3000 \
  --env-file .env \
  --name honest-voice-prod \
  honest-voice:prod
```

### 4. 本番環境のシェルアクセス

```bash
# コンテナに接続
docker exec -it honest-voice-prod bash

# Rails コンソール
docker exec -it honest-voice-prod bundle exec rails console
```

### 5. ログ確認

```bash
# リアルタイムログ
docker logs -f honest-voice-prod

# コンテナ停止
docker stop honest-voice-prod
```

---

## 📦 Docker イメージの構成

### マルチステージビルド

```
Dockerfile
├── base
│   ├── Ruby 3.2
│   ├── Node.js 18
│   └── 共通システムパッケージ
│
├── development ← docker-compose 用
│   ├── 全 Gem インストール
│   ├── 全 npm モジュール
│   └── ホットリロード対応
│
└── production  ← 本番環境用
    ├── 本番向け Gem のみ
    ├── npm 本番モジュール
    ├── Bootsnap プリコンパイル
    └── アセット事前コンパイル
```

### イメージサイズ

- 開発用: ~1.8 GB（開発ツール含む）
- 本番用: ~600 MB（最適化済み）

---

## 🔍 Dockerfile ステージ解説

### `base` ステージ
- Ruby 3.2 + Node.js 18 基盤
- 共通システムパッケージ
- すべてのステージで継承

### `development` ステージ
- **用途**: ローカル開発（docker-compose）
- Gem + npm フル依存関係
- ボリュームマウント対応
- Rails サーバー
- ポート: `3000` (Rails), `5173` (esbuild)

### `production` ステージ
- **用途**: 本番環境（Docker 単体）
- Gem + npm 本番モードのみ
- Bootsnap プリコンパイル
- アセット事前コンパイル
- 非root ユーザー実行
- ポート: `3000` (Rails)

---

## 🛠️ トラブルシューティング

### ポート 3000 が既に使用されている

```bash
# 使用中のプロセスを確認
lsof -i :3000

# または別ポートで起動
docker-compose run -p 3001:3000 app
```

### データベースロック

```bash
# sqlite3 ロックファイルを削除
rm db/development.sqlite3-journal
docker-compose up
```

### node_modules 問題

```bash
# ボリュームをリセット
docker-compose down -v
docker-compose up --build
```

### コンテナが起動しない

```bash
# ビルドログを確認
docker-compose build --no-cache

# 直接イメージに接続
docker run -it honest-voice:dev bash
```

---

## 📝 環境変数設定

`.env.example` をコピーしてカスタマイズ：

```bash
cp .env.example .env
```

**主要な環境変数:**

| 変数 | 説明 | デフォルト |
|-----|------|-----------|
| `RAILS_ENV` | Rails 環境 | development |
| `NODE_ENV` | Node.js 環境 | development |
| `DATABASE_URL` | DB 接続文字列 | sqlite3:db/development.sqlite3 |
| `RAILS_MASTER_KEY` | Rails マスターキー（本番） | - |

---

## 🔐 セキュリティに関する注意

**本番環境では以下を必ず実施：**

1. **マスターキー管理**
   ```bash
   # config/master.key を暴露しない
   # 環境変数 RAILS_MASTER_KEY で安全に管理
   ```

2. **SECRET_KEY_BASE 設定**
   ```bash
   # 強力なランダム値を生成
   ruby -e "puts SecureRandom.hex(64)"
   ```

3. **HTTPS 有効化**
   - リバースプロキシ（Nginx など）で対応

4. **データベース保護**
   - PostgreSQL など本番向け DB を使用

5. **ログ監視**
   - Docker ログドライバーを JSON ファイル形式に設定

---

質問がありましたら、お気軽にお聞きください！
