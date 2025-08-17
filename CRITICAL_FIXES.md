# Критические исправления для запуска системы

## 🚨 Обязательные исправления перед запуском

### 1. Исправление конфликта UUID в models.py
**Проблема**: Task.id использует UUID тип, но остальной код ожидает string

**Файл**: `orchestrator/models.py:146`

```python
# ЗАМЕНИТЬ:
id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

# НА:
id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
```

### 2. Обновление .env.example (удаление реальных креденшиалов)
**Проблема**: .env.example содержит реальные пароли и API ключи

**Файл**: `.env.example`

```bash
# Discord/Midjourney
DISCORD_EMAIL=your_discord_email@example.com
DISCORD_PASSWORD=your_discord_password
MIDJOURNEY_CHANNEL_URL=https://discord.com/channels/YOUR_SERVER_ID/YOUR_CHANNEL_ID

# Claude API
CLAUDE_API_KEY=sk-ant-api03-YOUR_CLAUDE_API_KEY

# Telegram
TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN
TELEGRAM_ADMIN_ID=YOUR_ADMIN_ID
TELEGRAM_CHANNEL_ID=@your_channel

# External Services
RESIDENTIAL_PROXY_URL=http://user:pass@proxy-server:port
CAPTCHA_SERVICE_KEY=your_captcha_service_key

# Social Media Publishing
INSTAGRAM_ACCESS_TOKEN=your_instagram_token
TIKTOK_ACCESS_TOKEN=your_tiktok_token
```

### 3. Добавление переменной окружения для orchestrator URL
**Проблема**: Hardcoded URL в review-bridge

**Файл**: `orchestrator/config.py` (добавить):
```python
orchestrator_url: str = Field(default="http://orchestrator:8000", env="ORCHESTRATOR_URL")
```

**Файл**: `review-bridge/telegram_bot.py:34` (заменить):
```python
# ЗАМЕНИТЬ:
self.orchestrator_url = "http://localhost:8000"

# НА:
self.orchestrator_url = settings.orchestrator_url
```

### 4. Обновление selenium и chrome driver
**Файл**: `requirements.txt`

```python
# ЗАМЕНИТЬ:
selenium==4.10.0
undetected-chromedriver==3.5.0

# НА:
selenium>=4.15.0
undetected-chromedriver>=3.5.0
```

## 📋 Инструкции по применению исправлений

### Шаг 1: Применить исправления
```bash
cd /home/ascode/claude-projects/midjourney-automation-system

# 1. Исправить models.py
# (Выполнить ручное редактирование или применить патч)

# 2. Очистить .env.example
cp .env.example .env.example.backup
# (Заменить содержимое на шаблон выше)

# 3. Обновить зависимости
pip install --upgrade selenium undetected-chromedriver
```

### Шаг 2: Создать рабочий .env файл
```bash
# Скопировать шаблон
cp .env.example .env

# Заполнить реальными данными:
# - Discord креденшиалы
# - Claude API ключ
# - Telegram bot token
# - Прокси настройки
# - Внешние API ключи
```

### Шаг 3: Проверить Docker конфигурацию
```bash
# Проверить синтаксис docker-compose
docker-compose config

# Проверить доступность образов
docker-compose pull postgres redis
```

## 🔧 Дополнительные рекомендации

### Безопасность
1. Добавить `.env` в `.gitignore`
2. Использовать Docker secrets для продакшена
3. Настроить SSL сертификаты для nginx

### Производительность
1. Увеличить memory_limit для Chrome в docker-compose
2. Настроить connection pooling для PostgreSQL
3. Добавить Redis persistence

### Мониторинг
1. Настроить логирование в structured формате
2. Добавить health checks для всех агентов
3. Настроить алерты в Grafana

## ✅ Чек-лист готовности

- [ ] models.py исправлен (UUID → String)
- [ ] .env.example очищен от реальных данных
- [ ] .env создан с реальными креденшиалами
- [ ] requirements.txt обновлен
- [ ] nginx.conf создан
- [ ] prometheus.yml создан
- [ ] Docker images собираются без ошибок
- [ ] PostgreSQL схема применяется корректно
- [ ] Все агенты подключаются к очередям

После выполнения всех пунктов система готова к первому запуску.