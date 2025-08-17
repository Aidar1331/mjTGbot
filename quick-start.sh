#!/bin/bash

echo "🚀 Midjourney Automation System - Quick Start"
echo "============================================="

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker и Docker Compose"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не найден. Установите Docker Compose"
    exit 1
fi

echo "✅ Docker и Docker Compose найдены"

# Проверка .env файла
if [ ! -f ".env" ]; then
    echo "⚠️  Файл .env не найден. Создаю из .env.example..."
    cp .env.example .env
    echo "📝 ВАЖНО: Отредактируйте файл .env с реальными креденшиалами:"
    echo "   - DISCORD_EMAIL и DISCORD_PASSWORD"
    echo "   - CLAUDE_API_KEY" 
    echo "   - TELEGRAM_BOT_TOKEN и TELEGRAM_ADMIN_ID"
    echo ""
    read -p "Нажмите Enter после редактирования .env или Ctrl+C для выхода..."
fi

echo "🔧 Проверка конфигурации Docker Compose..."
if ! docker-compose config > /dev/null 2>&1; then
    echo "❌ Ошибка в docker-compose.yml"
    docker-compose config
    exit 1
fi

echo "✅ Конфигурация корректна"

# Остановка существующих контейнеров
echo "🛑 Остановка существующих контейнеров..."
docker-compose down > /dev/null 2>&1

# Запуск базовых сервисов
echo "🗄️  Запуск PostgreSQL и Redis..."
docker-compose up -d postgres redis

# Ожидание готовности БД
echo "⏳ Ожидание готовности PostgreSQL..."
timeout=60
while [ $timeout -gt 0 ]; do
    if docker-compose exec -T postgres pg_isready -U mjuser -d mjsystem > /dev/null 2>&1; then
        echo "✅ PostgreSQL готов"
        break
    fi
    echo "   Ожидание... ($timeout сек)"
    sleep 2
    timeout=$((timeout-2))
done

if [ $timeout -le 0 ]; then
    echo "❌ PostgreSQL не готов. Проверьте логи:"
    docker-compose logs postgres
    exit 1
fi

# Запуск оркестратора
echo "🎯 Запуск Orchestrator..."
docker-compose up -d orchestrator

# Ожидание готовности API
echo "⏳ Ожидание готовности Orchestrator API..."
timeout=60
while [ $timeout -gt 0 ]; do
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Orchestrator API готов"
        break
    fi
    echo "   Ожидание... ($timeout сек)"
    sleep 2
    timeout=$((timeout-2))
done

if [ $timeout -le 0 ]; then
    echo "❌ Orchestrator API не отвечает. Проверьте логи:"
    docker-compose logs orchestrator
    exit 1
fi

# Запуск всех агентов
echo "🤖 Запуск всех агентов..."
docker-compose up -d

# Проверка статуса
echo ""
echo "📊 Статус контейнеров:"
docker-compose ps

# Проверка работоспособности
echo ""
echo "🔍 Проверка работоспособности..."

# Health check
if curl -s http://localhost:8000/health | grep -q "ok\|healthy"; then
    echo "✅ Health Check: OK"
else
    echo "❌ Health Check: FAIL"
fi

# API docs
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs | grep -q "200"; then
    echo "✅ API Docs: OK"
else
    echo "❌ API Docs: FAIL" 
fi

echo ""
echo "🎉 Система запущена!"
echo ""
echo "🔗 Доступные URL:"
echo "   • API Health: http://localhost:8000/health"
echo "   • API Docs: http://localhost:8000/docs"
echo "   • Queue Status: http://localhost:8000/queue/status"
echo "   • Agent Status: http://localhost:8000/agents/status"
echo ""
echo "📋 Полезные команды:"
echo "   • Просмотр логов: docker-compose logs -f"
echo "   • Остановка: docker-compose down"
echo "   • Перезапуск: docker-compose restart"
echo "   • Тест системы: python scripts/test-system.py"
echo ""
echo "🎯 Система готова к работе!"