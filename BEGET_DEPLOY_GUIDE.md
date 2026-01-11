# 🚀 Полная Инструкция по Деплою на Beget VPS через Coolify

## 📋 Что вам понадобится

- Доступ к Coolify на вашем VPS
- GitHub репозиторий с вашим проектом
- 10-15 минут времени

## 🔧 Предварительная Подготовка

### Шаг 0: Генерация SECRET_KEY_BASE (на локальной машине)

Перед началом деплоя сгенерируйте секретный ключ:

```bash
cd /Users/avdemkin/ai_ssh
bundle exec rails secret
```

Скопируйте полученный ключ — он понадобится позже.

---

## 🚀 Процесс Деплоя

### Шаг 1: Создание PostgreSQL Database в Coolify

1. Войдите в панель Coolify
2. Нажмите **"+ New Resource"** → **"Database"**
3. Выберите **"PostgreSQL 16"**
4. Настройки:
   - **Name:** `seoforge-db` (любое имя)
   - **Database Name:** `seoforge_production`
   - **Username:** `postgres` (по умолчанию)
   - **Password:** (будет сгенерирован автоматически)
5. Нажмите **"Create"**
6. **ВАЖНО:** После создания найдите и скопируйте **Connection String**
   - Он выглядит так: `postgresql://postgres:password@hostname:5432/seoforge_production`
   - Сохраните его — понадобится в Шаге 4

### Шаг 2: Создание Redis Service в Coolify

1. Нажмите **"+ New Resource"** → **"Database"**
2. Выберите **"Redis 7"**
3. Настройки:
   - **Name:** `seoforge-redis` (любое имя)
   - Остальное оставьте по умолчанию
4. Нажмите **"Create"**
5. **ВАЖНО:** Скопируйте **Connection String**
   - Он выглядит так: `redis://hostname:6379/0`
   - Сохраните его — понадобится в Шаге 4

### Шаг 3: Создание Application в Coolify

1. Нажмите **"+ New Resource"** → **"Application"**
2. Настройки:
   - **Source Type:** `Public Repository` или `Private Repository`
   - **Git URL:** URL вашего репозитория (например: `https://github.com/username/your-repo.git`)
   - **Branch:** `main` или `master` (или ваша ветка для продакшена)
   - **Build Pack:** `Dockerfile`
3. Нажмите **"Continue"**
4. Настройки deployment:
   - **Port:** `3000` (обязательно!)
   - **Domain:** Ваш домен (например: `seoforge.contentforce.ru`)
   - **Automatic Deployment:** включите, если хотите автодеплой при пуше в GitHub
5. Нажмите **"Save"** (пока НЕ деплойте!)

### Шаг 4: Настройка Environment Variables

1. В настройках созданного приложения перейдите в раздел **"Environment Variables"**
2. Добавьте следующие переменные:

#### Обязательные переменные (без них приложение не запустится):

```env
# === База данных ===
DATABASE_URL=postgresql://postgres:password@hostname:5432/seoforge_production
# ☝️ Вставьте Connection String из Шага 1

# === Redis ===
REDIS_URL=redis://hostname:6379/0
# ☝️ Вставьте Connection String из Шага 2

# === Rails Configuration ===
SECRET_KEY_BASE=your_generated_secret_from_step_0
# ☝️ Вставьте ключ, сгенерированный в Шаге 0

RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2

# === Домен ===
DOMAIN=your-domain.com
# ☝️ Замените на ваш реальный домен

PROTOCOL=https

# === CORS (если нужен фронтенд отдельно) ===
CORS_ORIGINS=https://your-domain.com
# ☝️ Замените на ваш домен или добавьте несколько через запятую
```

#### Опциональные переменные (можно добавить позже):

```env
# === AI Integration (для генерации контента) ===
GEMINI_API_KEY=your_gemini_api_key
# Получить на: https://aistudio.google.com/app/apikey

# === Stripe Payment (для подписок) ===
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_secret
# Получить на: https://dashboard.stripe.com/

# === Google OAuth (для аналитики) ===
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
# Получить на: https://console.cloud.google.com/

# === Sidekiq ===
SIDEKIQ_CONCURRENCY=10
```

3. Нажмите **"Save"**

### Шаг 5: Первый Deploy

1. В настройках приложения нажмите **"Deploy"**
2. Дождитесь завершения сборки (обычно 5-10 минут)
3. Следите за логами — если что-то пойдет не так, вы увидите ошибку

**Что происходит во время деплоя:**
- Клонирование репозитория
- Установка Ruby gems
- Установка Node.js зависимостей
- Компиляция JavaScript (esbuild)
- Компиляция CSS (Tailwind)
- Precompile Rails assets
- Запуск контейнера

### Шаг 6: Инициализация Базы Данных

После успешного деплоя:

1. В Coolify откройте **"Console"** (Terminal) для вашего приложения
2. Выполните команды:

```bash
# Создать структуру БД
bundle exec rails db:migrate

# Загрузить начальные данные (планы подписок)
bundle exec rails db:seed
```

**Примечание:** Команда `db:create` не нужна, так как база уже создана в Шаге 1.

### Шаг 7: Создание Администратора

1. В той же консоли откройте Rails console:

```bash
bundle exec rails console
```

2. Создайте пользователя-администратора:

```ruby
User.create!(
  email: "admin@yourdomain.com",
  password: "SecurePassword123!",
  password_confirmation: "SecurePassword123!",
  name: "Admin",
  admin: true
)
```

3. Выйдите из консоли: нажмите `Ctrl+D` или введите `exit`

### Шаг 8: Настройка Sidekiq Worker (для фоновых задач)

**Зачем это нужно:** Sidekiq обрабатывает фоновые задачи (генерация статей AI, публикация в WordPress)

1. В настройках приложения найдите раздел **"Processes"** или **"Workers"**
2. Нажмите **"Add Process"**
3. Настройки:
   - **Name:** `sidekiq`
   - **Command:** `bundle exec sidekiq`
   - **Environment Variables:** (автоматически наследуются от основного приложения)
4. Нажмите **"Save"** и **"Start"**

**Альтернатива:** Если Coolify не поддерживает отдельные процессы, можете использовать встроенный режим:
- Добавьте переменную: `SOLID_QUEUE_IN_PUMA=true`
- Это запустит Sidekiq внутри Puma (подходит для небольших нагрузок)

---

## ✅ Проверка Работоспособности

### 1. Проверьте доступность сайта

Откройте в браузере: `https://your-domain.com`

Вы должны увидеть Landing page вашего приложения.

### 2. Проверьте API

Откройте: `https://your-domain.com/up`

Должен вернуться статус `200 OK` и текст `"OK"`

### 3. Проверьте Swagger документацию

Откройте: `https://your-domain.com/api-docs`

Должна открыться интерактивная документация API.

### 4. Войдите в систему

1. Откройте: `https://your-domain.com/login`
2. Введите email и пароль администратора из Шага 7
3. После входа вы должны попасть в Dashboard

---

## 🔧 Настройка SSL (HTTPS)

Coolify автоматически настраивает Let's Encrypt SSL сертификат, если:

1. Ваш домен правильно настроен (A-запись указывает на IP сервера)
2. Порт 80 и 443 открыты на сервере
3. В настройках приложения включен **"Enable SSL"**

Если SSL не работает:
- Проверьте DNS записи домена
- Убедитесь, что домен доступен по HTTP
- Попробуйте переиздать сертификат в настройках Coolify

---

## 🔄 Обновление Приложения

### Автоматический деплой

Если вы включили **"Automatic Deployment"** в Шаге 3:
- Каждый push в выбранную ветку GitHub автоматически запустит деплой

### Ручной деплой

1. Откройте приложение в Coolify
2. Нажмите **"Redeploy"**
3. Дождитесь завершения

### Откат к предыдущей версии

1. В Coolify перейдите в **"Deployments"**
2. Найдите нужную версию
3. Нажмите **"Rollback"**

---

## 🐛 Решение Проблем

### Ошибка при деплое: "Failed to build"

**Причины:**
- Отсутствуют зависимости в Gemfile или package.json
- Ошибки в Dockerfile

**Решение:**
- Проверьте логи сборки в Coolify
- Убедитесь, что проект собирается локально: `docker build -t test .`

### Приложение не запускается: "Error 502 Bad Gateway"

**Причины:**
- Не настроены переменные окружения
- База данных недоступна
- Порт 3000 не прослушивается

**Решение:**
1. Откройте логи приложения в Coolify
2. Проверьте переменные `DATABASE_URL` и `SECRET_KEY_BASE`
3. Убедитесь, что PostgreSQL и Redis запущены

### База данных пустая после деплоя

**Решение:**
```bash
bundle exec rails db:migrate
bundle exec rails db:seed
```

### Ошибка "PG::ConnectionBad"

**Причина:** Неправильный `DATABASE_URL`

**Решение:**
- Проверьте Connection String из PostgreSQL service
- Убедитесь, что hostname, port, username, password правильные
- Попробуйте подключиться вручную:
  ```bash
  psql "postgresql://postgres:password@hostname:5432/seoforge_production"
  ```

### CSS и JavaScript не загружаются

**Причина:** Не скомпилированы assets

**Решение:**
- Убедитесь, что в Dockerfile есть шаги:
  ```dockerfile
  RUN yarn build
  RUN yarn build:css
  RUN bundle exec rails assets:precompile
  ```
- Переменная `RAILS_SERVE_STATIC_FILES=true` должна быть установлена

### Sidekiq не обрабатывает задачи

**Решение:**
1. Проверьте, что Sidekiq процесс запущен
2. Проверьте `REDIS_URL`
3. Посмотрите логи Sidekiq:
   ```bash
   tail -f log/sidekiq.log
   ```

---

## 📊 Мониторинг

### Просмотр логов

В Coolify:
1. Откройте приложение
2. Перейдите в **"Logs"**
3. Выберите контейнер (web или sidekiq)

### Проверка состояния

```bash
# В консоли приложения

# Проверить подключение к БД
bundle exec rails db:version

# Проверить Redis
bundle exec rails console
> Redis.current.ping
# Должен вернуться "PONG"

# Проверить Sidekiq
> Sidekiq.redis(&:info)
```

---

## 🔐 Безопасность

### После деплоя обязательно:

1. **Смените пароль администратора** на более сложный
2. **Не храните секреты в коде** — только в Environment Variables
3. **Настройте бэкапы базы данных** в Coolify
4. **Включите SSL** (HTTPS)
5. **Ограничьте доступ к консоли Coolify** (используйте 2FA)

---

## 📝 Чеклист Финальной Проверки

- [ ] PostgreSQL создан и доступен
- [ ] Redis создан и доступен
- [ ] Все обязательные переменные окружения настроены
- [ ] Приложение успешно задеплоено
- [ ] База данных мигрирована (`db:migrate`)
- [ ] Начальные данные загружены (`db:seed`)
- [ ] Создан администратор
- [ ] Sidekiq запущен
- [ ] Сайт доступен по домену
- [ ] SSL сертификат работает (HTTPS)
- [ ] API отвечает (`/up` возвращает 200)
- [ ] Можно войти в систему
- [ ] Swagger документация доступна

---

## 🎯 Минимальный Набор Переменных для Старта

Если хотите максимально быстро запустить проект (без Stripe, Google, AI):

```env
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
SECRET_KEY_BASE=...
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
DOMAIN=your-domain.com
PROTOCOL=https
CORS_ORIGINS=https://your-domain.com
```

Остальные API ключи можно добавить позже, когда они понадобятся.

---

## 🚀 Готово!

Ваше приложение развернуто и готово к использованию. 

Для расширенных настроек см. [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 📚 Важные Файлы Проекта

### Проверены и готовы к деплою:

✅ **Dockerfile** - оптимизирован для Coolify:
- Multi-stage build
- Ruby 3.4.6
- Node.js + Yarn для сборки assets
- Puma web server на порту 3000
- Автоматическая миграция БД через docker-entrypoint

✅ **Gemfile** - все необходимые гемы:
- Rails 8.0
- PostgreSQL (pg)
- Redis + Sidekiq
- Devise + JWT (аутентификация)
- Stripe (платежи)
- HTTParty (API запросы)
- Solid Cache/Queue/Cable

✅ **package.json** - фронтенд зависимости:
- React 19
- esbuild (сборка JS)
- Tailwind CSS
- React Router

✅ **config/database.yml** - настроен для production:
- Использует ENV['DATABASE_URL']

✅ **config/environments/production.rb** - оптимизирован:
- Логи в STDOUT
- SSL включен
- Кэширование настроено
- Solid Cache/Queue

⚠️ **ВАЖНО**: В production.rb используется `solid_queue`, но в application.rb стоит `:sidekiq`. Нужно согласовать!

### Рекомендация:

Выберите один адаптер для фоновых задач:

**Вариант 1: Использовать Sidekiq (рекомендуется)**
```ruby
# config/application.rb
config.active_job.queue_adapter = :sidekiq

# config/environments/production.rb
# Закомментируйте эти строки:
# config.active_job.queue_adapter = :solid_queue
# config.solid_queue.connects_to = { database: { writing: :queue } }
```

**Вариант 2: Использовать Solid Queue**
```ruby
# config/application.rb
config.active_job.queue_adapter = :solid_queue

# config/environments/production.rb
# Оставить как есть
```

Я рекомендую **Sidekiq**, так как у вас уже есть Redis и Sidekiq workers настроены.
