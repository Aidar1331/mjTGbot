# 🚀 Инструкции по запуску Midjourney Automation System

## Предварительная подготовка

### 1. Применение критических исправлений
```bash
# Убедитесь, что применены исправления из CRITICAL_FIXES.md
# UUID конфликт в models.py уже исправлен ✅
```

### 2. Настройка окружения
```bash
cd /home/ascode/claude-projects/midjourney-automation-system

# Создание рабочего .env файла
cp .env.example .env

# ⚠️ ВАЖНО: Заполните .env реальными креденшиалами:
# - DISCORD_EMAIL и DISCORD_PASSWORD
# - CLAUDE_API_KEY
# - TELEGRAM_BOT_TOKEN и TELEGRAM_ADMIN_ID
# - RESIDENTIAL_PROXY_URL (если используется)
# - CAPTCHA_SERVICE_KEY
```

## Вариант 1: Запуск через Docker Compose (Рекомендуется)

### Этап 1: Подготовка инфраструктуры
```bash
# Проверка Docker
docker --version
docker-compose --version

# Проверка конфигурации
docker-compose config

# Загрузка базовых образов
docker-compose pull postgres redis
```

### Этап 2: Запуск базовых сервисов
```bash
# Запуск БД и очередей
docker-compose up -d postgres redis

# Ожидание готовности БД (30-60 секунд)
echo "Waiting for PostgreSQL to be ready..."
while ! docker-compose exec postgres pg_isready -U mjuser -d mjsystem; do
  echo "PostgreSQL not ready, waiting..."
  sleep 5
done
echo "PostgreSQL is ready!"

# Проверка логов
docker-compose logs postgres redis
```

### Этап 3: Запуск оркестратора
```bash
# Сборка и запуск оркестратора
docker-compose up -d orchestrator

# Ожидание готовности API
echo "Waiting for orchestrator API..."
timeout 60 bash -c 'while ! curl -f http://localhost:8000/health >/dev/null 2>&1; do sleep 2; done'
echo "Orchestrator API is ready!"

# Проверка API
curl http://localhost:8000/health
curl http://localhost:8000/docs
```

### Этап 4: Запуск всех агентов
```bash
# Запуск всех остальных сервисов
docker-compose up -d

# Проверка статуса всех контейнеров
docker-compose ps

# Просмотр логов в реальном времени
docker-compose logs -f --tail=50
```

## Вариант 2: Локальный запуск (для разработки)

### Подготовка Python окружения
```bash
# Создание виртуального окружения
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# или venv\Scripts\activate  # Windows

# Обновление pip
pip install --upgrade pip

# Установка зависимостей
pip install -r requirements.txt

# Обновление selenium (если требуется)
pip install --upgrade selenium undetected-chromedriver
```

### Запуск компонентов по отдельности

#### Терминал 1: PostgreSQL + Redis
```bash
docker-compose up postgres redis
```

#### Терминал 2: Orchestrator
```bash
cd orchestrator
python main.py
```

#### Терминал 3: MJ Interaction Agent
```bash
cd agents/mj_interaction
python -m agents.mj_interaction
```

#### Терминал 4: Review Bridge
```bash
cd review-bridge
python telegram_bot.py
```

## Windows: Готовые bat-файлы

### Вариант A: Полный запуск
```cmd
start_all_windows.bat
```

### Вариант B: Только оркестратор
```cmd
start_orchestrator.bat
```

### Вариант C: Только MJ Interaction
```cmd
start_mj_interaction_windows.bat
```

## ✅ Проверка работоспособности

### 1. Проверка API
```bash
# Health check
curl http://localhost:8000/health

# API документация
curl http://localhost:8000/docs

# Статус очередей
curl http://localhost:8000/queue/status

# Статус агентов
curl http://localhost:8000/agents/status
```

### 2. Проверка базы данных
```bash
# Подключение к PostgreSQL
docker-compose exec postgres psql -U mjuser -d mjsystem

# Проверка таблиц
\dt

# Проверка данных
SELECT * FROM originals LIMIT 5;
SELECT * FROM tasks LIMIT 5;
```

### 3. Проверка Redis
```bash
# Подключение к Redis
docker-compose exec redis redis-cli

# Проверка очередей
KEYS *
LLEN trend-parser
LLEN mj-interaction
```

### 4. Тестовые запросы
```bash
# Запуск парсинга трендов
curl -X POST http://localhost:8000/tasks/trend-parsing

# Проверка задач в БД
docker-compose exec postgres psql -U mjuser -d mjsystem -c "SELECT * FROM tasks ORDER BY created_at DESC LIMIT 5;"
```

## 🐛 Устранение проблем

### Проблема: PostgreSQL не запускается
```bash
# Очистка volumes
docker-compose down -v
docker volume prune

# Перезапуск
docker-compose up -d postgres
```

### Проблема: Chrome не работает в Docker
```bash
# Увеличение shared memory
# В docker-compose.yml для mj-interaction:
shm_size: "2g"
```

### Проблема: Telegram бот не отвечает
```bash
# Проверка токена
# Отправить GET запрос: https://api.telegram.org/bot<YOUR_TOKEN>/getMe

# Проверка логов
docker-compose logs review-bridge
```

### Проблема: MJ Interaction падает
```bash
# Проверка Chrome установки
docker-compose exec mj-interaction google-chrome --version

# Проверка прокси
docker-compose exec mj-interaction curl -x $RESIDENTIAL_PROXY_URL http://httpbin.org/ip

# Отладочный режим
docker-compose exec mj-interaction python debug-mj-interaction.py
```

## 📊 Мониторинг

### Просмотр логов
```bash
# Все сервисы
docker-compose logs -f

# Конкретный сервис
docker-compose logs -f orchestrator
docker-compose logs -f mj-interaction
```

### Метрики (опционально)
```bash
# Запуск monitoring stack
docker-compose --profile monitoring up -d

# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin123)
```

## 🎯 После успешного запуска

1. **API доступно**: http://localhost:8000
2. **Документация**: http://localhost:8000/docs
3. **Telegram бот**: Готов принимать команды модерации
4. **MJ Automation**: Готов выполнять задачи генерации
5. **Очереди**: Активны и обрабатывают задачи

Система полностью готова к работе! 🎉