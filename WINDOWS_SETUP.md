# Настройка Midjourney Automation System на Windows

## Системные требования

- Windows 10/11
- Python 3.11 или новее
- Google Chrome (последняя версия)
- PostgreSQL 15+
- Git

## Шаг 1: Установка Python

1. Скачайте Python с официального сайта: https://www.python.org/downloads/
2. При установке убедитесь, что выбрали "Add Python to PATH"
3. Проверьте установку:
   ```cmd
   python --version
   pip --version
   ```

## Шаг 2: Установка PostgreSQL

1. Скачайте PostgreSQL: https://www.postgresql.org/download/windows/
2. Установите с настройками:
   - Пользователь: `postgres`
   - Пароль: запомните его
   - Порт: `5432`
3. Создайте базу данных:
   ```sql
   CREATE DATABASE mjsystem;
   CREATE USER mjuser WITH PASSWORD 'mjpass';
   GRANT ALL PRIVILEGES ON DATABASE mjsystem TO mjuser;
   ```

## Шаг 3: Установка Chrome и ChromeDriver

1. Установите Google Chrome: https://www.google.com/chrome/
2. Узнайте версию Chrome:
   ```cmd
   "C:\Program Files\Google\Chrome\Application\chrome.exe" --version
   ```
3. Скачайте соответствующий ChromeDriver:
   - Перейдите на: https://sites.google.com/chromium.org/driver/
   - Скачайте версию для вашего Chrome
   - Распакуйте `chromedriver.exe` в `C:\chromedriver\`

## Шаг 4: Клонирование проекта

```cmd
cd C:\
git clone https://github.com/your-repo/midjourney-automation-system
cd midjourney-automation-system
```

## Шаг 5: Установка зависимостей

```cmd
pip install -r requirements.txt
```

## Шаг 6: Настройка конфигурации

1. Скопируйте файл конфигурации:
   ```cmd
   copy .env.example .env
   ```

2. Отредактируйте `.env` файл:
   ```env
   # Database
   DATABASE_URL=postgresql+asyncpg://mjuser:mjpass@localhost:5432/mjsystem

   # Discord
   DISCORD_EMAIL=your_discord_email@example.com
   DISCORD_PASSWORD=your_discord_password
   DISCORD_CHANNEL_URL=https://discord.com/channels/SERVER_ID/CHANNEL_ID

   # Claude API
   CLAUDE_API_KEY=your_claude_api_key

   # Telegram
   TELEGRAM_BOT_TOKEN=your_bot_token
   TELEGRAM_CHAT_ID=your_chat_id

   # 2captcha (опционально)
   CAPTCHA_SERVICE_KEY=your_2captcha_key

   # Redis (если используете внешний)
   REDIS_URL=redis://localhost:6379/0
   ```

## Шаг 7: Инициализация базы данных

```cmd
python -c "
import asyncio
from orchestrator.database import init_db
asyncio.run(init_db())
"
```

## Шаг 8: Запуск системы

### Запуск оркестратора
```cmd
cd orchestrator
python -m orchestrator.main
```

### Запуск агента mj-interaction (в новом окне)
```cmd
python -m agents.mj_interaction.agent_windows
```

### Запуск других агентов (в отдельных окнах)
```cmd
python -m agents.trend_parser.agent
python -m agents.prompt_expander.agent
python -m agents.video_compiler.agent
python -m agents.publisher.agent
python -m agents.review_bridge.agent
```

## Альтернативный запуск через batch файлы

Создайте файлы для удобного запуска:

**start_orchestrator.bat**
```batch
@echo off
cd /d %~dp0
cd orchestrator
python -m orchestrator.main
pause
```

**start_mj_interaction.bat**
```batch
@echo off
cd /d %~dp0
python -m agents.mj_interaction.agent_windows
pause
```

**start_all_agents.bat**
```batch
@echo off
cd /d %~dp0

echo Starting Orchestrator...
start cmd /k "cd orchestrator && python -m orchestrator.main"
timeout /t 5

echo Starting MJ Interaction Agent...
start cmd /k "python -m agents.mj_interaction.agent_windows"
timeout /t 3

echo Starting other agents...
start cmd /k "python -m agents.trend_parser.agent"
start cmd /k "python -m agents.prompt_expander.agent"
start cmd /k "python -m agents.video_compiler.agent"
start cmd /k "python -m agents.publisher.agent"
start cmd /k "python -m agents.review_bridge.agent"

echo All services started!
```

## Диагностика проблем

### Проблемы с Chrome
```cmd
# Проверьте версию Chrome
"C:\Program Files\Google\Chrome\Application\chrome.exe" --version

# Проверьте ChromeDriver
C:\chromedriver\chromedriver.exe --version

# Запустите тест
python -c "
import undetected_chromedriver as uc
driver = uc.Chrome(driver_executable_path='C:/chromedriver/chromedriver.exe')
driver.get('https://google.com')
print('Success!')
driver.quit()
"
```

### Проблемы с базой данных
```cmd
# Проверьте подключение к PostgreSQL
python -c "
import asyncio
import asyncpg

async def test():
    conn = await asyncpg.connect('postgresql://mjuser:mjpass@localhost:5432/mjsystem')
    print('Database connection successful!')
    await conn.close()

asyncio.run(test())
"
```

### Логи
Логи сохраняются в папке `logs/`. Проверьте их при возникновении ошибок:
- `logs/orchestrator.log`
- `logs/mj_interaction.log`
- `logs/trend_parser.log`

## API Endpoints

После запуска оркестратора API будет доступно по адресу: http://localhost:8000

- Документация: http://localhost:8000/docs
- Статус здоровья: http://localhost:8000/health
- Метрики: http://localhost:8000/metrics

## Остановка системы

Для корректной остановки нажмите `Ctrl+C` в каждом окне или закройте все cmd окна.