# Dockerfile for SEOforge - Rails 8 + React 19 + Sidekiq
# Optimized for Coolify deployment on seoforge.contentforce.ru

ARG RUBY_VERSION=3.4.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base packages including Node.js for asset compilation
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    postgresql-client \
    nodejs \
    npm \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    NODE_ENV="production" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true"

# Build stage - install dependencies and compile assets
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    pkg-config \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install Node.js dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production=false

# Copy application code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Build JavaScript with esbuild
RUN yarn build

# Build CSS with Tailwind
RUN yarn build:css

# Precompile Rails assets (skip javascript:build since we already built it)
RUN SECRET_KEY_BASE_DUMMY=1 SKIP_YARN_BUILD=1 bundle exec rails assets:precompile

# Remove development node_modules AFTER all builds are complete
RUN yarn install --frozen-lockfile --production=true && \
    yarn cache clean

# Final production image
FROM base

# Copy built artifacts
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create rails user and set permissions
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails/tmp /rails/log /rails/storage && \
    chown -R rails:rails /rails

USER rails:rails

# Entrypoint for database preparation
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port 3000 (Coolify will map this)
EXPOSE 3000

# Start Puma web server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
