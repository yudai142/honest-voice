# syntax = docker/dockerfile:1

# Honest Voice Rails アプリケーション
# マルチステージビルド: development / production

ARG RUBY_VERSION=3.2.11
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

# システムパッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libvips \
      sqlite3 \
      libsqlite3-dev \
      libpq-dev \
      build-essential \
      git \
      libyaml-dev \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Node.js インストール
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install --no-install-recommends -y nodejs && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# =====================================
# 開発環境ステージ
# =====================================
FROM base AS development

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    NODE_ENV="development" \
    RAILS_LOG_TO_STDOUT=1

# Gem インストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# npm インストール
COPY package.json package-lock.json ./
RUN npm ci || npm install

# アプリケーションコード
COPY . .

# 開発用ポート公開
EXPOSE 3000 5173

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# =====================================
# 本番環境ステージ
# =====================================
FROM base AS production

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    NODE_ENV="production" \
    RAILS_LOG_TO_STDOUT=1

# Gem インストール（本番向け）
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# npm インストール（本番向け）
COPY package.json package-lock.json ./
RUN npm ci --omit=dev || npm install --production

# アプリケーションコード
COPY . .

# Bootsnap + アセットプリコンパイル
RUN bundle exec bootsnap precompile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# 非root ユーザー
RUN useradd -m -u 1000 rails && \
    chown -R rails:rails /rails
USER rails

# 本番用ポート公開
EXPOSE 3000

# entrypoint スクリプト
COPY --chown=rails:rails docker-entrypoint.sh /rails/docker-entrypoint.sh
RUN chmod +x /rails/docker-entrypoint.sh
ENTRYPOINT ["/rails/docker-entrypoint.sh"]

# Puma サーバー起動
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]

