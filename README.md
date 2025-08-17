# 🎨 Midjourney Automation System

Автоматизированная система для курирования и публикации трендового контента из Midjourney через микросервисную архитектуру.

## 🏗️ Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                    Внешние сервисы                          │
├─────────────────────────────────────────────────────────────┤
│ Discord/MJ │ Claude API │ Прокси │ CAPTCHA │ Соцсети       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                  Центральная система                        │
├─────────────────────────────────────────────────────────────┤
│           Оркестратор (FastAPI)                            │
│              │                    │                        │
│         PostgreSQL            Redis Queue                  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    Агенты (Claude субагенты)                │
├─────────────────────────────────────────────────────────────┤
│ Trend      │ MJ         │ Prompt     │ Video    │ Publisher │
│ Parser     │ Interaction│ Expander   │ Compiler │           │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                Review Bridge (Telegram)                     │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Компоненты

### Центральный оркестратор
- **FastAPI** сервер для управления задачами
- **PostgreSQL** для хранения состояния
- **Redis** для очереди задач

### Агенты (Claude субагенты)
- **Trend Parser** - парсинг трендов Midjourney
- **MJ Interaction** - генерация через Selenium/Discord  
- **Prompt Expander** - создание вариаций промптов
- **Video Compiler** - сборка финальных роликов
- **Publisher** - публикация в соцсети

### Review Bridge
- **Telegram бот** для модерации
- **Callback система** для принятия решений

## 🚀 Установка и запуск

```bash
# Клонировать проект
git clone <repository-url>
cd midjourney-automation-system

# Запуск через Docker
docker-compose up -d

# Или локально
pip install -r requirements.txt
python -m orchestrator.main
```

## ⚙️ Конфигурация

Создайте `.env` файл:
```env
# Database
DATABASE_URL=postgresql://user:pass@localhost/mjsystem

# Redis
REDIS_URL=redis://localhost:6379

# External Services
DISCORD_EMAIL=your@email.com
DISCORD_PASSWORD=your_password
MIDJOURNEY_CHANNEL_URL=https://discord.com/channels/@me/...

CLAUDE_API_KEY=your_claude_key
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_ADMIN_ID=your_admin_id

# Proxies & CAPTCHA
RESIDENTIAL_PROXY_URL=http://proxy:port
CAPTCHA_SERVICE_KEY=your_2captcha_key
```

## 📊 Workflow

1. **Trend Parser** находит популярный контент
2. **Оркестратор** отправляет на модерацию через Telegram
3. **При одобрении** создает задачи для генерации вариаций
4. **MJ Interaction** генерирует контент через Discord
5. **Video Compiler** собирает финальные ролики
6. **Publisher** публикует в соцсети

## 🔧 Мониторинг

- API endpoints: `http://localhost:8000/docs`
- Queue status: `http://localhost:8000/queue/status`  
- Agent status: `http://localhost:8000/agents/status`