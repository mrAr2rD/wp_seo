# ContentFlow - Инструкция по запуску

## Что реализовано

✅ **Фазы 1-6 завершены** (83% общего прогресса)

### Backend (Фазы 1-3, 5)
- ✅ Rails 8 с PostgreSQL
- ✅ Devise + JWT аутентификация
- ✅ API для управления проектами (WordPress сайты)
- ✅ Система подписок с Stripe интеграцией
- ✅ Админ-панель
- ✅ Swagger API документация (`/api-docs`)
- ✅ **AI генерация контента** через Gemini API
- ✅ **Sidekiq workers** для фоновой генерации статей
- ✅ **WordPress интеграция** для публикации статей

### Frontend (Фазы 4, 6)
- ✅ React 19 с React Router
- ✅ Shadcn UI компоненты + Tailwind CSS 3
- ✅ Notion-стиль интерфейс с sidebar навигацией
- ✅ **Лендинг страница** с описанием продукта, тарифами и CTA
- ✅ **Интегрированная авторизация** прямо на лендинге
- ✅ Страницы: Login, Signup, Dashboard, Projects, Subscriptions
- ✅ **UI для генерации статей** с AI
- ✅ **Редактор статей** с HTML preview
- ✅ Публикация в WordPress одним кликом

## Требования

- Ruby 3.4.6
- Node.js 18+ и Yarn
- PostgreSQL
- Redis (для Sidekiq)

## Быстрый старт

### 1. Установка зависимостей

```bash
# Ruby зависимости
bundle install

# JavaScript зависимости
yarn install
```

### 2. Настройка базы данных

```bash
# Создание и миграция БД
bin/rails db:create db:migrate

# (Опционально) Заполнение тестовыми данными
bin/rails db:seed
```

### 3. Переменные окружения

Создайте `.env` файл в корне проекта:

```env
# Gemini API для генерации контента
GEMINI_API_KEY=your_gemini_api_key_here

# Stripe для подписок
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key

# Devise JWT секрет
DEVISE_JWT_SECRET_KEY=your_random_secret_key_here
```

### 4. Сборка assets

```bash
# JavaScript
yarn build

# CSS
yarn build:css
```

### 5. Запуск сервера

**Вариант 1: Все сервисы через Foreman**
```bash
bin/dev
```
Это запустит:
- Rails server (порт 3000)
- JavaScript watcher
- CSS watcher
- Sidekiq worker

**Вариант 2: Запуск отдельно**

```bash
# В разных терминалах:

# Rails server
bin/rails server

# Sidekiq (для фоновых задач)
bundle exec sidekiq

# JS watcher (опционально, для разработки)
yarn build --watch

# CSS watcher (опционально, для разработки)
yarn build:css --watch
```

## Доступ к приложению

- **Главная страница**: http://localhost:3000
- **API документация (Swagger)**: http://localhost:3000/api-docs
- **Админ панель**: http://localhost:3000/admin (требуется admin флаг в БД)

## Структура проекта

```
app/
├── controllers/
│   ├── api/v1/           # API контроллеры
│   │   ├── articles_controller.rb
│   │   ├── projects_controller.rb
│   │   └── subscriptions_controller.rb
│   └── admin/            # Админ панель
├── models/
│   ├── user.rb
│   ├── project.rb
│   ├── generated_article.rb
│   ├── plan.rb
│   └── subscription.rb
├── services/
│   ├── gemini_service.rb         # AI генерация через Gemini
│   └── stripe_subscription_service.rb
├── workers/
│   ├── article_generation_worker.rb   # Фоновая генерация статей
│   └── wordpress_publish_worker.rb    # Публикация в WordPress
└── javascript/
    ├── components/       # React компоненты
    │   ├── App.js
    │   ├── Layout.jsx
    │   └── ui/          # Shadcn UI компоненты
    ├── pages/           # React страницы
    │   ├── Login.jsx
    │   ├── Dashboard.jsx
    │   ├── Projects.jsx
    │   ├── Articles.jsx
    │   └── ArticleEditor.jsx
    ├── contexts/
    │   └── AuthContext.jsx
    └── lib/
        └── api.js       # API клиент
```

## Основные функции

### 1. Управление проектами
- Добавление WordPress сайтов через REST API
- Валидация подключения к WordPress
- Хранение API ключей (Base64 шифрование)

### 2. AI генерация контента
- Создание статьи по теме и ключевым словам
- Генерация через Gemini API с оптимизированными промптами
- HTML контент с правильной структурой (H1, H2, H3, etc.)
- Фоновая обработка через Sidekiq

### 3. Редактирование и публикация
- WYSIWYG редактор с HTML preview
- Редактирование сгенерированного контента
- Публикация в WordPress как draft одним кликом
- Отслеживание статуса публикации

### 4. Подписки
- Интеграция со Stripe
- Тарифные планы с ограничениями
- Webhook обработка для автоматического обновления статусов

## Тестирование

```bash
# Запуск всех тестов
bundle exec rspec

# Запуск конкретного теста
bundle exec rspec spec/models/user_spec.rb
```

## API Endpoints

### Authentication
- `POST /api/v1/users/sign_in` - Вход
- `POST /api/v1/users` - Регистрация
- `DELETE /api/v1/users/sign_out` - Выход
- `GET /api/v1/current_user` - Текущий пользователь

### Projects
- `GET /api/v1/projects` - Список проектов
- `POST /api/v1/projects` - Создать проект
- `PATCH /api/v1/projects/:id` - Обновить проект
- `DELETE /api/v1/projects/:id` - Удалить проект
- `POST /api/v1/projects/:id/validate_wordpress` - Валидация WordPress

### Articles
- `GET /api/v1/projects/:project_id/articles` - Статьи проекта
- `POST /api/v1/projects/:project_id/articles` - Создать статью (запускает AI генерацию)
- `GET /api/v1/articles/:id` - Получить статью
- `PATCH /api/v1/articles/:id` - Обновить статью
- `DELETE /api/v1/articles/:id` - Удалить статью
- `POST /api/v1/articles/:id/publish` - Опубликовать в WordPress

### Subscriptions
- `GET /api/v1/plans` - Доступные тарифы
- `GET /api/v1/subscriptions` - Подписки пользователя
- `POST /api/v1/subscriptions` - Создать подписку
- `PATCH /api/v1/subscriptions/:id` - Обновить подписку
- `DELETE /api/v1/subscriptions/:id` - Отменить подписку

## Что осталось (Фаза 7)

- [ ] E2E тестирование
- [ ] Деплой на продакшн
- [ ] Google Analytics/Search Console интеграция
- [ ] SEO keyword кластеризация
- [ ] Руководства пользователя и разработчика

## Технологии

**Backend:**
- Ruby on Rails 8.0
- PostgreSQL
- Sidekiq + Redis
- Devise + JWT
- Stripe API
- HTTParty

**Frontend:**
- React 19
- React Router
- Tailwind CSS 3
- Shadcn UI
- esbuild

**AI & Integration:**
- Gemini API (для генерации контента)
- WordPress REST API

## Поддержка

См. документацию в `/docs`:
- [ROADMAP.md](docs/ROADMAP.md) - План разработки
- [PRD.md](docs/PRD.md) - Требования к продукту
- [GEMINI.md](docs/GEMINI.md) - Gemini интеграция
- [CLAUDE.md](CLAUDE.md) - Инструкции для Claude Code
