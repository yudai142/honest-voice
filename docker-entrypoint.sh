#!/bin/bash
set -e

# Rails アプリケーション entrypoint

cd /rails

echo "🚀 Honest Voice Rails application starting..."
echo "Environment: ${RAILS_ENV:-development}"

# データベースセットアップ
echo "📊 Setting up database..."
if [ "${RAILS_ENV}" = "production" ]; then
  bundle exec rails db:migrate
else
  bundle exec rails db:create db:migrate 2>/dev/null || true
fi

# PID ファイル削除
if [ -f tmp/pids/server.pid ]; then
  echo "🧹 Cleaning up old PID file..."
  rm tmp/pids/server.pid
fi

echo "✅ Ready for development!"

# コマンド実行
exec "$@"

