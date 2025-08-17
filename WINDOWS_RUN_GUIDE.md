# 🪟 Запуск в Windows - Пошаговое руководство

## 📋 Подготовка

### 1. Скопируйте проект в Windows директорию
```cmd
# Например, на рабочий стол
C:\Users\AS\Desktop\midjourney-automation-system
```

### 2. Убедитесь что установлен Docker Desktop
- Скачайте с https://docker.com/products/docker-desktop
- Запустите и включите WSL 2 backend (если предложит)
- Проверьте: `docker --version` и `docker-compose --version`

## 🚀 Автоматический запуск (Рекомендуется)

### Вариант A: Двойной клик
1. Найдите файл `quick-start.cmd` в папке проекта
2. Кликните правой кнопкой → "Запуск от имени администратора"
3. Следуйте инструкциям на экране

### Вариант B: Через командную строку
```cmd
cd C:\Users\AS\Desktop\midjourney-automation-system
quick-start.cmd
```

## 🔧 Ручная настройка

### 1. Создание .env файла
```cmd
cd C:\Users\AS\Desktop\midjourney-automation-system
copy .env.example .env
notepad .env
```

### 2. Заполните обязательные поля в .env:
```env
DISCORD_EMAIL=ваш_email@gmail.com
DISCORD_PASSWORD=ваш_пароль
CLAUDE_API_KEY=sk-ant-api03-ВАШ_КЛЮЧ
TELEGRAM_BOT_TOKEN=1234567890:ВАШТОКЕН
TELEGRAM_ADMIN_ID=123456789
```

### 3. Запуск контейнеров
```cmd
# Проверка конфигурации
docker-compose config

# Запуск базовых сервисов
docker-compose up -d postgres redis

# Ожидание 1-2 минуты, затем
docker-compose up -d orchestrator

# Ожидание еще минуту, затем все остальное
docker-compose up -d
```

## ✅ Проверка работы

### Откройте в браузере:
- **API документация**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health
- **Статус очередей**: http://localhost:8000/queue/status

### Команды проверки:
```cmd
# Статус контейнеров
docker-compose ps

# Логи всех сервисов
docker-compose logs -f

# Логи конкретного сервиса
docker-compose logs orchestrator
docker-compose logs mj-interaction
```

## 🐛 Решение проблем

### Проблема: "no matching manifest for windows/amd64"
**Решение**: Включите экспериментальные фичи в Docker Desktop:
- Settings → Docker Engine → добавьте `"experimental": true`
- Restart Docker Desktop

### Проблема: Chrome не запускается в контейнере
**Решение**: Увеличьте память Docker:
- Docker Desktop → Settings → Resources → Memory: 4GB+
- Apply & Restart

### Проблема: PostgreSQL долго стартует
**Решение**: Дайте больше времени:
```cmd
# Проверяйте готовность БД
docker-compose exec postgres pg_isready -U mjuser -d mjsystem
```

### Проблема: Порты заняты
**Решение**: Остановите конфликтующие процессы или измените порты:
```cmd
# Остановить все контейнеры
docker-compose down

# Проверить занятые порты
netstat -an | findstr :8000
netstat -an | findstr :5432
```

## 📱 Тестирование Telegram бота

1. Найдите своего бота в Telegram (@your_bot_name)
2. Отправьте `/start`
3. Бот должен ответить приветствием
4. Проверьте логи: `docker-compose logs review-bridge`

## 🎯 Полезные команды

```cmd
# Полная остановка системы
docker-compose down

# Перезапуск с очисткой
docker-compose down -v
docker-compose up -d

# Просмотр использования ресурсов
docker stats

# Подключение к базе данных
docker-compose exec postgres psql -U mjuser -d mjsystem

# Запуск тестов
python scripts/test-system.py
```

## 🔄 Регулярное использование

### Каждый день:
```cmd
cd C:\Users\AS\Desktop\midjourney-automation-system
docker-compose up -d
```

### Для остановки:
```cmd
docker-compose down
```

### Для обновления:
```cmd
docker-compose pull
docker-compose up -d --force-recreate
```

## 🎉 Готово!

После успешного запуска:
- Система будет автоматически парсить тренды Midjourney
- Отправлять контент на модерацию в Telegram  
- Генерировать новые изображения через MJ
- Публиковать одобренный контент в соцсети

**Все работает в фоне!** 🚀