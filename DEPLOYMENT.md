# SEOforge Deployment Guide для Coolify

Это руководство описывает процесс развертывания приложения SEOforge на платформе Coolify с использованием Docker.

## Предварительные требования

- Аккаунт и установленный Coolify на вашем сервере
- Домен: `seoforge.contentforce.ru`
- PostgreSQL база данных (предоставляется Coolify)
- Redis (предоставляется Coolify)

## Архитектура деплоя

Приложение состоит из трех компонентов:

1. **Web** - Rails приложение (Puma)
2. **Sidekiq** - Фоновые задачи (генерация статей, публикация)
3. **Redis** - Кэш и очереди для Sidekiq

## Шаг 1: Подготовка репозитория

Убедитесь, что все изменения закоммичены и отправлены в GitHub:

```bash
git add .
git commit -m "feat: Prepare for Coolify deployment"
git push origin develop
```

## Шаг 2: Настройка проекта в Coolify

### 2.1. Создание нового проекта

1. Войдите в панель Coolify
2. Нажмите **"New Resource"** → **"Application"**
3. Выберите **"Public Repository"**
4. Укажите URL репозитория: `https://github.com/mrAr2rD/wp_seo.git`
5. Выберите ветку: `develop`

### 2.2. Настройка Build Pack

1. Build Pack: **Dockerfile**
2. Dockerfile Location: `./Dockerfile`
3. Port: `3000`

### 2.3. Настройка домена

1. В разделе **"Domains"** добавьте: `seoforge.contentforce.ru`
2. Включите **"HTTPS"** (Let's Encrypt)
3. Включите **"Force HTTPS"**

## Шаг 3: Настройка баз данных

### 3.1. PostgreSQL

1. Создайте новый PostgreSQL service в Coolify
2. Скопируйте **Connection String** в формате:
   ```
   postgresql://username:password@host:port/database
   ```

### 3.2. Redis

1. Создайте новый Redis service в Coolify
2. Скопируйте **Connection String** в формате:
   ```
   redis://host:port/0
   ```

## Шаг 4: Переменные окружения

Добавьте следующие переменные окружения в Coolify:

### Обязательные переменные

```env
# Database & Cache
DATABASE_URL=postgresql://user:pass@host:5432/seoforge_prod
REDIS_URL=redis://host:6379/0

# Rails Security
SECRET_KEY_BASE=<generate using: rails secret>
RAILS_MASTER_KEY=<from config/master.key>

# Environment
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true

# Domain
DOMAIN=seoforge.contentforce.ru
PROTOCOL=https

# AI Integration
GEMINI_API_KEY=<your_gemini_key>

# Stripe
STRIPE_PUBLISHABLE_KEY=<your_stripe_public_key>
STRIPE_SECRET_KEY=<your_stripe_secret_key>
STRIPE_WEBHOOK_SECRET=<your_stripe_webhook_secret>

# Google OAuth
GOOGLE_CLIENT_ID=<your_google_client_id>
GOOGLE_CLIENT_SECRET=<your_google_client_secret>
```

### Опциональные переменные

```env
# Performance Tuning
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
SIDEKIQ_CONCURRENCY=10

# Monitoring (optional)
SENTRY_DSN=<your_sentry_dsn>
```

## Шаг 5: Настройка Sidekiq Worker

Coolify поддерживает запуск нескольких контейнеров из одного образа:

1. В настройках приложения найдите **"Add New Container"**
2. Создайте новый контейнер с именем `sidekiq`
3. Command: `bundle exec sidekiq -C config/sidekiq.yml`
4. Используйте те же переменные окружения, что и для web

## Шаг 6: Генерация SECRET_KEY_BASE

На вашей локальной машине выполните:

```bash
rails secret
```

Скопируйте полученное значение и добавьте в переменные окружения Coolify.

## Шаг 7: Настройка RAILS_MASTER_KEY

1. Откройте файл `config/master.key` (он в .gitignore)
2. Скопируйте содержимое
3. Добавьте в переменные окружения Coolify

**Важно:** Если файла нет, создайте его:

```bash
EDITOR="nano" rails credentials:edit
```

## Шаг 8: Первый деплой

1. В Coolify нажмите **"Deploy"**
2. Дождитесь завершения сборки образа (~5-10 минут)
3. После успешного деплоя проверьте логи

### Проверка логов

```bash
# Web logs
Проверьте в Coolify → Logs → Web

# Sidekiq logs
Проверьте в Coolify → Logs → Sidekiq
```

## Шаг 9: Инициализация базы данных

После первого деплоя выполните миграции:

1. Откройте **"Console"** в Coolify для web контейнера
2. Выполните:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

## Шаг 10: Проверка работоспособности

### Проверка Web приложения

```bash
curl https://seoforge.contentforce.ru/up
```

Должен вернуть `200 OK`.

### Проверка Sidekiq

1. Откройте Sidekiq Web UI: `https://seoforge.contentforce.ru/sidekiq` (если настроен маршрут)
2. Или проверьте логи Sidekiq контейнера

### Тестовый пользователь

Создайте первого пользователя через Rails console:

```bash
# В Console Coolify
bundle exec rails console

# Создание пользователя
User.create!(
  email: "admin@seoforge.contentforce.ru",
  password: "SecurePassword123!",
  password_confirmation: "SecurePassword123!",
  name: "Admin"
)
```

## Troubleshooting

### Проблема: Ошибка подключения к базе данных

**Решение:**
1. Проверьте правильность `DATABASE_URL`
2. Убедитесь, что PostgreSQL service запущен
3. Проверьте network connectivity между контейнерами

### Проблема: Assets не загружаются

**Решение:**
1. Убедитесь, что `RAILS_SERVE_STATIC_FILES=true`
2. Проверьте, что assets были прекомпилированы во время сборки
3. Проверьте логи сборки Docker образа

### Проблема: Sidekiq не обрабатывает задачи

**Решение:**
1. Проверьте правильность `REDIS_URL`
2. Убедитесь, что Sidekiq контейнер запущен
3. Проверьте логи Sidekiq контейнера

### Проблема: CORS errors в браузере

**Решение:**
1. Проверьте настройки в `config/initializers/cors.rb`
2. Убедитесь, что домен правильно настроен

## Обновление приложения

Для обновления приложения:

1. Закоммитьте изменения в Git
2. Отправьте в GitHub: `git push origin develop`
3. В Coolify нажмите **"Redeploy"**
4. Coolify автоматически пересоберет образ и перезапустит контейнеры

## Мониторинг

### Health Check

Coolify автоматически проверяет health endpoint:
- URL: `http://localhost:3000/up`
- Interval: 30s
- Timeout: 10s
- Retries: 3

### Логи

Все логи доступны в Coolify:
- Application logs: Rails/Puma output
- Build logs: Docker build process
- System logs: Container events

## Резервное копирование

### Автоматический backup базы данных

Coolify предоставляет встроенные инструменты для backup PostgreSQL:

1. Перейдите в PostgreSQL service
2. Включите **"Automated Backups"**
3. Настройте расписание (рекомендуется: ежедневно)

### Ручной backup

```bash
# Экспорт базы данных
pg_dump -h host -U user -d database > backup.sql

# Импорт базы данных
psql -h host -U user -d database < backup.sql
```

## Масштабирование

### Горизонтальное масштабирование

Coolify поддерживает масштабирование:

1. **Web**: Увеличьте количество реплик в настройках
2. **Sidekiq**: Добавьте дополнительные Sidekiq контейнеры
3. **Database**: Используйте managed PostgreSQL с репликацией

### Вертикальное масштабирование

Увеличьте ресурсы контейнера:
- CPU: 2-4 cores для web, 1-2 для sidekiq
- Memory: 2-4GB для web, 1-2GB для sidekiq

## Безопасность

### Рекомендации

1. ✅ Используйте сильные пароли для базы данных
2. ✅ Включите HTTPS с Let's Encrypt
3. ✅ Регулярно обновляйте зависимости: `bundle update`
4. ✅ Настройте rate limiting в nginx
5. ✅ Используйте environment variables для секретов
6. ✅ Включите Content Security Policy (CSP)

### Обновление зависимостей

```bash
# Обновление Ruby gems
bundle update

# Обновление JavaScript packages
yarn upgrade

# Проверка уязвимостей
bundle audit
yarn audit
```

## Производительность

### Оптимизация

1. **Database Connection Pool**: `RAILS_MAX_THREADS=5`
2. **Web Workers**: `WEB_CONCURRENCY=2`
3. **Sidekiq Concurrency**: `SIDEKIQ_CONCURRENCY=10`
4. **Bootsnap**: Уже включен в Dockerfile
5. **Jemalloc**: Уже включен в entrypoint

### Caching

Rails 8 использует Solid Cache (встроено):
- Cache store: Redis
- Настройка: `config/environments/production.rb`

## Поддержка

При возникновении проблем:

1. Проверьте логи в Coolify
2. Проверьте документацию Rails: https://guides.rubyonrails.org/
3. Проверьте документацию Coolify: https://coolify.io/docs
4. Обратитесь к команде разработки через GitHub Issues

---

**Последнее обновление:** 2026-01-09
**Версия:** 1.0
**Домен:** seoforge.contentforce.ru
