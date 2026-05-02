# Issue #1 実装計画書

## 概要
Rails 7.xプロジェクトをesbuild / Tailwind CSS / DaisyUI対応で初期化する

## 実装フェーズ

### Phase 1: 基本的なRailsプロジェクト作成
- [ ] `rails new honest-voice --skip-javascript --database=sqlite3 --css=tailwind`
- [ ] プロジェクト確認（Gemfile、config/application.rb、Rakefile etc）

**テスト**: `spec/issue_01_project_initialization_spec.rb` - Project Structure テスト

### Phase 2: esbuild・JavaScript の初期化
- [ ] `rails javascript:install:esbuild`
- [ ] `config/importmap.rb` が削除されたことを確認
- [ ] `package.json` に esbuild スクリプト追加確認
- [ ] `app/javascript/application.js` 存在確認
- [ ] `bin/dev` 実行可能確認

**テスト**: `spec/issue_01_project_initialization_spec.rb` - Project Structure, Build Tools テスト

### Phase 3: Tailwind CSS 確認
- [ ] `app/assets/stylesheets/application.tailwind.css` 存在確認
- [ ] `tailwind.config.js` 存在確認
- [ ] Rails 7 デフォルト Tailwind 設定確認

**テスト**: `spec/issue_01_project_initialization_spec.rb` - Project Structure テスト

### Phase 4: Gemfile 修正・依存関係インストール
Gemfile に以下を追加:
```ruby
# React
gem 'react-rails'

# 認証
gem 'devise'

# 統計・グラフ
gem 'chartkick'
gem 'chart-js-rails'

# 開発補助
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end
```

- [ ] Gemfile 修正
- [ ] `bundle install` 実行
- [ ] `npm install`（必要に応じて）

**テスト**: `spec/issue_01_project_initialization_spec.rb` - Gemfile Configuration テスト

### Phase 5: React-Rails セットアップ
- [ ] `rails generate react:install`
- [ ] `app/javascript/components/` ディレクトリ生成確認
- [ ] `package.json` に React 依存関係追加確認

**テスト**: `spec/issue_01_project_initialization_spec.rb` - React Integration テスト

### Phase 6: DaisyUI セットアップ
- [ ] `npm install daisyui`
- [ ] `tailwind.config.js` 修正（plugins に daisyui 追加）
- [ ] DaisyUI テーマ設定（light）

**テスト**: `spec/issue_01_project_initialization_spec.rb` - DaisyUI Integration テスト

### Phase 7: Devise セットアップ
- [ ] `rails generate devise:install`
- [ ] `rails generate devise user`
- [ ] `rails db:create`
- [ ] `rails db:migrate`

**テスト**: `spec/issue_01_project_initialization_spec.rb` - Devise Authentication テスト

### Phase 8: 動作確認
- [ ] `./bin/dev` でサーバー起動確認
- [ ] ブラウザで http://localhost:3000 確認
- [ ] esbuild ビルド成功確認
- [ ] Tailwind CSS スタイル適用確認

**テスト**: すべてのテストが成功すること

## テスト実行方法

```bash
# 全テスト実行
bundle exec rspec

# Issue #1 テストのみ
bundle exec rspec spec/issue_01_project_initialization_spec.rb

# 詳細表示
bundle exec rspec spec/issue_01_project_initialization_spec.rb -fd
```

## 成功基準

- [ ] すべてのテストが pass
- [ ] `./bin/dev` でアプリケーション起動可
- [ ] Tailwind CSS が有効
- [ ] DaisyUI コンポーネント が認識される
- [ ] Devise User モデル が生成される
- [ ] React コンポーネント ディレクトリ作成される

## ファイル修正リスト

### 追加・修正予定ファイル
- `Gemfile` - gem 追加
- `tailwind.config.js` - DaisyUI plugin 追加
- `config/routes.rb` - (後続issue で修正)
- `app/models/user.rb` - (Devise生成)

## 参照ドキュメント
- [docs/issues/01-project-init.md](../../docs/issues/01-project-init.md)
- [README: 技術スタック](../../README.md#10-技術スタック手段としての技術)

## 注意点
- Rails 7 では `rails javascript:install:esbuild` コマンドが用意されている
- Tailwind CSS は Rails 7 デフォルトで対応（`--css=tailwind`）
- DaisyUI は npm 経由でインストール（Bundler ではなく）
- React-Rails は `rails generate react:install` で初期化

## 推定時間
1～2時間

## PR チェックリスト
- [ ] テストが全て pass している
- [ ] Commit メッセージが明確
- [ ] ドキュメント更新済み
- [ ] 動作確認済み（./bin/dev 実行確認）
