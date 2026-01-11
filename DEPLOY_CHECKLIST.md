# ✅ DEPLOY CHECKLIST - Beget VPS через Coolify

## 📋 ПРЕД-ДЕПЛОЙ ПРОВЕРКА

### 🔧 Конфигурационные файлы
- [x] **Dockerfile** - готов к деплою (порт 3000, multi-stage)
- [x] **Gemfile** - все зависимости указаны
- [x] **package.json** - фронтенд зависимости готовы
- [x] **config/database.yml** - использует DATABASE_URL
- [x] **config/puma.rb** - слушает порт из ENV
- [x] **config/application.rb** - queue_adapter = :sidekiq
- [x] **config/environments/production.rb** - исправлен конфликт адаптеров
- [x] **bin/docker-entrypoint** - автоматические миграции при старте

### 🔑 Секреты и Ключи
- [x] **SECRET_KEY_BASE** - сгенерирован (см. инструкцию)
- [x] **RAILS_MASTER_KEY** - есть в config/master.key
- [ ] **GEMINI_API_KEY** - получить на https://aistudio.google.com/app/apikey
- [ ] **STRIPE_KEYS** - получить на https://dashboard.stripe.com/
- [ ] **GOOGLE_OAUTH** - получить на https://console.cloud.google.com/

---

## 🚀 ПОРЯДОК ДЕПЛОЯ

### Этап 1: Подготовка в Coolify
- [ ] Создать PostgreSQL 16 базу данных
- [ ] Создать Redis 7 сервис
- [ ] Скопировать Connection Strings

### Этап 2: Настройка Application
- [ ] Создать Application с Dockerfile build pack
- [ ] Указать порт 3000
- [ ] Добавить домен

### Этап 3: Environment Variables
Обязательные:
- [ ] `DATABASE_URL` (из PostgreSQL)
- [ ] `REDIS_URL` (из Redis)
- [ ] `SECRET_KEY_BASE` (сгенерированный)
- [ ] `RAILS_ENV=production`
- [ ] `RAILS_LOG_TO_STDOUT=true`
- [ ] `RAILS_SERVE_STATIC_FILES=true`
- [ ] `DOMAIN=your-domain.com`
- [ ] `PROTOCOL=https`

### Этап 4: Deploy
- [ ] Нажать Deploy
- [ ] Дождаться успешной сборки (~5-10 мин)
- [ ] Проверить логи на ошибки

### Этап 5: Инициализация
- [ ] `bundle exec rails db:migrate`
- [ ] `bundle exec rails db:seed`
- [ ] Создать администратора через console

### Этап 6: Sidekiq
- [ ] Добавить Sidekiq worker process
- [ ] Или установить `SOLID_QUEUE_IN_PUMA=true`

---

## 🔍 ПОСЛЕ-ДЕПЛОЙ ПРОВЕРКА

### Доступность
- [ ] Сайт открывается по домену
- [ ] `/up` возвращает 200 OK
- [ ] Swagger документация доступна (`/api-docs`)
- [ ] Можно залогиниться

### Функциональность
- [ ] Регистрация новых пользователей
- [ ] Создание проектов
- [ ] Генерация статей (если API ключи есть)
- [ ] Публикация в WordPress (если настроено)

### Фоновые задачи
- [ ] Sidekiq/Solid Queue запущен
- [ ] Задачи обрабатываются
- [ ] Нет ошибок в логах очередей

---

## ⚠️ ИЗВЕСТНЫЕ ПРОБЛЕМЫ И РЕШЕНИЯ

### 1. Конфликт Queue Adapters
**Исправлено:** В production.rb закомментирован solid_queue, используется sidekiq из application.rb

### 2. Assets не загружаются
**Решение:** Убедиться что:
- `RAILS_SERVE_STATIC_FILES=true`
- В Dockerfile есть шаги компиляции assets
- Файлы собраны в `app/assets/builds/`

### 3. База данных не мигрируется
**Решение:** 
- Проверить `DATABASE_URL`
- Запустить вручную: `bundle exec rails db:migrate`

### 4. Sidekiq не запускается
**Решение:**
- Проверить `REDIS_URL`
- Убедиться что Redis сервис запущен
- Проверить логи Sidekiq

---

## 🛠️ ПОЛЕЗНЫЕ КОМАНДЫ

### В консоли Coolify:
```bash
# Проверка миграций
bundle exec rails db:migrate:status

# Сброс базы (осторожно!)
bundle exec rails db:drop db:create db:migrate db:seed

# Проверка Redis
bundle exec rails console
> Redis.current.ping

# Проверка Sidekiq
> Sidekiq.redis(&:info)

# Создание админа
> User.create!(email: "admin@example.com", password: "pass", admin: true)
```

### Локальная проверка Docker:
```bash
# Сборка образа
docker build -t seoforge-test .

# Запуск с docker-compose (для тестирования)
docker-compose up --build
```

---

## 📦 ТЕХНИЧЕСКИЙ СТЕК

**Backend:**
- Ruby 3.4.6
- Rails 8.0
- PostgreSQL 16
- Redis 7
- Sidekiq (фоновые задачи)
- Puma (web server)

**Frontend:**
- React 19
- esbuild (bundler)
- Tailwind CSS
- React Router

**Deployment:**
- Docker (multi-stage)
- Coolify (на Beget VPS)
- Let's Encrypt SSL

---

## 📞 ПОДДЕРЖКА

Если возникнут проблемы:
1. Проверьте логи в Coolify
2. Сверьтесь с этой инструкцией
3. Проверьте DEPLOYMENT.md для деталей
4. Убедитесь что все переменные окружения установлены

---

🎯 **Готово к деплою!** Следуйте инструкции в BEGET_DEPLOY_GUIDE.md пошагово.
