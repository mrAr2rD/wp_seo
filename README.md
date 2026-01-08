# SEOforge

SEOforge - это microSaaS платформа для автоматизации создания и оптимизации контента для WordPress блогов. Приложение помогает владельцам сайтов, маркетологам и блогерам управлять контент-стратегией, улучшать SEO и автоматизировать публикацию статей.

## Основные возможности

- 🔍 Интеграция с WordPress для анализа семантических ключевых слов
- ✍️ Генерация SEO-оптимизированных статей с использованием LLM (Gemini/OpenAI)
- 📤 Автоматическая публикация в WordPress
- 📊 Аналитика через Google Analytics и Search Console
- 💳 Подписочная модель на базе Stripe

## Технологический стек

### Backend
- **Rails 8.0** с PostgreSQL
- **Sidekiq** для фоновых задач
- **Redis** для кэширования и очередей
- **RSpec** для тестирования

### Frontend
- **React 19** с esbuild
- **Hotwire** (Turbo Rails + Stimulus)
- **Tailwind CSS 3** для стилизации
- **Propshaft** для asset pipeline

## Начало работы

### Требования

- Ruby 3.4.6+
- Node.js 18+
- PostgreSQL 14+
- Redis

### Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/mrAr2rD/wp_seo.git
cd wp_seo
```

2. Установите зависимости:
```bash
bundle install
yarn install
```

3. Настройте базу данных:
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

4. Запустите Redis:
```bash
redis-server --daemonize yes
```

5. Запустите PostgreSQL:
```bash
brew services start postgresql@14
```

6. Запустите приложение:
```bash
bin/dev
```

Приложение будет доступно по адресу http://localhost:3000

### Переменные окружения

Создайте файл `.env` в корне проекта:

```env
GEMINI_API_KEY=your_gemini_api_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
STRIPE_SECRET_KEY=your_stripe_secret_key
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

## Разработка

### Запуск тестов

```bash
bundle exec rspec
```

### Линтинг

```bash
bundle exec rubocop
```

### Анализ безопасности

```bash
bundle exec brakeman
```

## Документация

Подробная документация доступна в директории `docs/`:

- [PRD.md](docs/PRD.md) - Product Requirements Document
- [ROADMAP.md](docs/ROADMAP.md) - Дорожная карта разработки
- [SETUP.md](docs/SETUP.md) - Детальная инструкция по настройке

## API документация

Swagger UI доступен по адресу: http://localhost:3000/api-docs

## Развертывание

Проект использует Kamal для Docker-based развертывания.

```bash
kamal deploy
```

## Лицензия

Copyright © 2024 SEOforge. Все права защищены.
