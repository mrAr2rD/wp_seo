# Coolify Quick Start для SEOforge

Быстрая инструкция для деплоя на **seoforge.contentforce.ru**

## 1. Создать Application в Coolify

```
Resource Type: Application
Source: Public Repository
Git URL: https://github.com/mrAr2rD/wp_seo.git
Branch: develop
Build Pack: Dockerfile
Port: 3000
Domain: seoforge.contentforce.ru
```

## 2. Создать PostgreSQL Database

```
Service: PostgreSQL 16
Database Name: seoforge_production
Save Connection String
```

## 3. Создать Redis Service

```
Service: Redis 7
Save Connection String
```

## 4. Добавить Environment Variables

**Минимально необходимые:**

```env
# Database & Cache
DATABASE_URL=postgresql://...    # из PostgreSQL service
REDIS_URL=redis://...            # из Redis service

# Rails
SECRET_KEY_BASE=                 # rails secret
RAILS_MASTER_KEY=                # из config/master.key
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true

# Domain
DOMAIN=seoforge.contentforce.ru
PROTOCOL=https

# API Keys (получить позже)
GEMINI_API_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
```

## 5. Добавить Sidekiq Worker

В настройках приложения:
```
Name: sidekiq
Command: bundle exec sidekiq -C config/sidekiq.yml
Environment: [копировать все переменные из web]
```

## 6. Deploy

Нажмите **"Deploy"** и дождитесь завершения (~5-10 минут)

## 7. Инициализация БД

После деплоя откройте Console:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

## 8. Создать первого пользователя

```bash
bundle exec rails console

User.create!(
  email: "admin@seoforge.contentforce.ru",
  password: "YourSecurePassword123!",
  password_confirmation: "YourSecurePassword123!",
  name: "Admin"
)
```

## 9. Проверка

Откройте: https://seoforge.contentforce.ru

## Полная документация

См. [DEPLOYMENT.md](./DEPLOYMENT.md)
