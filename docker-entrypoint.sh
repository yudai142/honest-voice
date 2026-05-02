#!/bin/bash
set -e

# Rails アプリケーション entrypoint
# 開発環境用

cd /rails

echo "🚀 Honest Voice Rails application starting..."
echo "Environment: ${RAILS_ENV:-development}"

# データベースセットアップ
echo "📊 Setting up database..."
bundle exec rails db:create db:migrate 2>/dev/null || true

# PID ファイル削除
if [ -f tmp/pids/server.pid ]; then
  echo "🧹 Cleaning up old PID file..."
  rm tmp/pids/server.pid
fi

echo "✅ Ready for development!"

# コマンド実行
exec "$@"

