# 🚀 Deployment Guide - Midjourney Automation System

Полное руководство по развертыванию и настройке системы автоматизации Midjourney.

## 📋 Предварительные требования

### Системные требования
- **ОС**: Linux (Ubuntu 20.04+), macOS, Windows (с WSL2)
- **RAM**: минимум 8GB, рекомендуется 16GB+
- **Диск**: минимум 20GB свободного места
- **CPU**: минимум 4 ядра

### Необходимое ПО
- [Docker](https://docs.docker.com/get-docker/) версия 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) версия 2.0+
- Git
- Текстовый редактор

### Внешние сервисы
- **Discord аккаунт** с доступом к Midjourney
- **Telegram Bot Token** (@BotFather)
- **Claude API ключ** (Anthropic)
- **Резидентные прокси** (рекомендуется)
- **CAPTCHA сервис** (2captcha/anticaptcha)

## 🔧 Быстрая установка

### 1. Клонирование проекта
```bash
git clone <repository-url>
cd midjourney-automation-system
```

### 2. Конфигурация
```bash
# Создаем файл конфигурации
cp .env.example .env

# Редактируем конфигурацию
nano .env
```

### 3. Заполнение .env файла
```env
# Database
DATABASE_URL=postgresql://mjuser:mjpass@localhost:5432/mjsystem
REDIS_URL=redis://localhost:6379/0

# Discord/Midjourney - КРИТИЧНО!
DISCORD_EMAIL=ваш_discord_email@example.com
DISCORD_PASSWORD=ваш_discord_пароль
MIDJOURNEY_CHANNEL_URL=https://discord.com/channels/@me/ID_КАНАЛА

# Claude API
CLAUDE_API_KEY=ваш_claude_api_ключ

# Telegram
TELEGRAM_BOT_TOKEN=1234567890:ваш_bot_token
TELEGRAM_ADMIN_ID=ваш_chat_id_админа
TELEGRAM_CHANNEL_ID=@ваш_канал

# Внешние сервисы
RESIDENTIAL_PROXY_URL=http://user:pass@proxy.provider.com:port
CAPTCHA_SERVICE_KEY=ваш_2captcha_ключ

# Соцсети (опционально)
INSTAGRAM_ACCESS_TOKEN=ваш_instagram_токен
TIKTOK_ACCESS_TOKEN=ваш_tiktok_токен
```

### 4. Запуск системы
```bash
# Запуск через скрипт (рекомендуется)
./scripts/start.sh

# Или вручную
docker-compose up -d
```

### 5. Проверка системы
```bash
# Тестирование всех компонентов
python3 scripts/test-system.py

# Проверка статуса сервисов
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

## ⚙️ Детальная настройка

### Discord/Midjourney Setup

1. **Получение URL канала:**
   ```
   1. Откройте Discord в браузере
   2. Перейдите в канал с Midjourney
   3. Скопируйте URL из адресной строки
   4. Вставьте в MIDJOURNEY_CHANNEL_URL
   ```

2. **Настройка прав:**
   - Убедитесь что у вас есть доступ к Midjourney
   - Рекомендуется Midjourney Relax режим ($60/месяц)

### Telegram Bot Setup

1. **Создание бота:**
   ```
   1. Напишите @BotFather в Telegram
   2. Отправьте /newbot
   3. Следуйте инструкциям
   4. Скопируйте токен в TELEGRAM_BOT_TOKEN
   ```

2. **Получение Admin Chat ID:**
   ```
   1. Напишите @userinfobot в Telegram
   2. Отправьте /start
   3. Скопируйте ваш ID в TELEGRAM_ADMIN_ID
   ```

### Настройка прокси

1. **Резидентные прокси (рекомендуется):**
   ```env
   # Формат: http://username:password@proxy.com:port
   RESIDENTIAL_PROXY_URL=http://user:pass@proxy.provider.com:8000
   ```

2. **Список проверенных провайдеров:**
   - Bright Data (Luminati)
   - Smartproxy
   - ProxyMesh
   - IPRoyal

### CAPTCHA сервис

1. **2captcha setup:**
   ```
   1. Регистрируйтесь на 2captcha.com
   2. Пополните баланс ($5 минимум)
   3. Скопируйте API ключ в CAPTCHA_SERVICE_KEY
   ```

## 🎛️ Управление системой

### Основные команды

```bash
# Запуск системы
./scripts/start.sh

# Остановка системы
docker-compose down

# Перезапуск конкретного сервиса
docker-compose restart orchestrator

# Просмотр логов
docker-compose logs -f [service_name]

# Проверка статуса
docker-compose ps

# Очистка системы
docker-compose down -v --remove-orphans
docker system prune -f
```

### API Endpoints

После запуска доступны по адресу `http://localhost:8000`:

- **Документация API**: `/docs`
- **Статус системы**: `/health`
- **Статус очередей**: `/queue/status`
- **Статус агентов**: `/agents/status`
- **Статистика**: `/stats/dashboard`

### Мониторинг

```bash
# Статус очередей
curl http://localhost:8000/queue/status

# Статус агентов
curl http://localhost:8000/agents/status

# Запуск парсинга трендов вручную
curl -X POST http://localhost:8000/tasks/trend-parsing
```

## 🔄 Workflow системы

### Автоматический режим:
1. **Trend Parser** находит трендовый контент
2. **Система** отправляет контент на модерацию в Telegram
3. **Администратор** одобряет/отклоняет через кнопки
4. **Prompt Expander** создает 5 вариаций промптов
5. **MJ Interaction** генерирует изображения через Discord
6. **Система** отправляет результаты на модерацию
7. **Video Compiler** создает финальные ролики
8. **Publisher** публикует в социальные сети

### Ручное управление:
```bash
# Запуск парсинга трендов
curl -X POST http://localhost:8000/tasks/trend-parsing

# Принудительная генерация для контента
curl -X POST http://localhost:8000/tasks/generate-content \
  -H "Content-Type: application/json" \
  -d '{"original_id": "uuid-here"}'
```

## 🐛 Устранение неполадок

### Частые проблемы

1. **Selenium не может запустить Chrome:**
   ```bash
   # Проверьте права доступа
   docker-compose logs mj-interaction
   
   # Перезапустите с правами
   docker-compose restart mj-interaction
   ```

2. **База данных не подключается:**
   ```bash
   # Проверьте статус PostgreSQL
   docker-compose ps postgres
   
   # Проверьте логи
   docker-compose logs postgres
   
   # Пересоздайте с чистой БД
   docker-compose down -v
   docker-compose up -d postgres
   ```

3. **Telegram бот не отвечает:**
   ```bash
   # Проверьте токен бота
   curl "https://api.telegram.org/bot<TOKEN>/getMe"
   
   # Проверьте логи
   docker-compose logs review-bridge
   ```

4. **Прокси не работает:**
   ```bash
   # Тестируйте прокси вручную
   curl --proxy "http://user:pass@proxy:port" https://httpbin.org/ip
   ```

### Диагностика

```bash
# Полная диагностика системы
python3 scripts/test-system.py

# Проверка доступности сервисов
curl http://localhost:8000/health
curl http://localhost:6379  # Redis
nc -z localhost 5432        # PostgreSQL

# Мониторинг ресурсов
docker stats

# Логи в реальном времени
docker-compose logs -f --tail=100
```

### Сброс системы

```bash
# Полный сброс с удалением данных
docker-compose down -v --remove-orphans
docker system prune -f
rm -rf logs/*

# Перезапуск
./scripts/start.sh
```

## 🔒 Безопасность

### Рекомендации:

1. **Никогда не коммитьте .env файл**
2. **Используйте сложные пароли для БД**
3. **Ограничьте доступ к API (nginx + auth)**
4. **Регулярно обновляйте Docker образы**
5. **Мониторьте логи на подозрительную активность**

### Production setup:

```bash
# Запуск с nginx и SSL
docker-compose --profile production up -d

# Настройка мониторинга
docker-compose --profile monitoring up -d
```

## 📈 Масштабирование

### Горизонтальное масштабирование:

```yaml
# В docker-compose.yml
mj-interaction:
  deploy:
    replicas: 3  # Запуск 3 экземпляров агента
```

### Вертикальное масштабирование:

```yaml
# Увеличение ресурсов
services:
  orchestrator:
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2'
```

## 🎯 Оптимизация производительности

### Настройки для высокой нагрузки:

```env
# В .env файле
WORKER_CONCURRENCY=5         # Параллельные задачи
MAX_RETRIES=3               # Повторы при ошибках
TASK_TIMEOUT=300            # Таймаут задач (сек)
```

### PostgreSQL оптимизация:

```sql
-- В database/init.sql добавить
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
```

## 📞 Поддержка

При возникновении проблем:

1. **Проверьте логи**: `docker-compose logs -f`
2. **Запустите тесты**: `python3 scripts/test-system.py`
3. **Изучите документацию API**: `http://localhost:8000/docs`
4. **Проверьте GitHub Issues** проекта

---

**🎉 Система готова к работе! Начните с запуска `./scripts/start.sh` и тестирования через Telegram бота.**