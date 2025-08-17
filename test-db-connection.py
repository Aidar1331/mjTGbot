#!/usr/bin/env python3
"""
Простой тест подключения к базе данных с правильным asyncpg драйвером
"""
import asyncio
import sys
import os

# Добавляем корневую директорию проекта в Python path
project_root = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, project_root)

# Переменные окружения
os.environ['DATABASE_URL'] = 'postgresql+asyncpg://mjuser:mjpass@localhost:5432/mjsystem'

async def test_db_connection():
    try:
        print("Testing asyncpg database connection...")
        
        # Простое подключение к базе
        import asyncpg
        
        # Извлекаем параметры из URL 
        conn = await asyncpg.connect(
            host='localhost',
            port=5432,
            user='mjuser', 
            password='mjpass',
            database='mjsystem'
        )
        
        print("✅ Successfully connected to PostgreSQL with asyncpg")
        
        # Простой запрос
        result = await conn.fetchval('SELECT 1')
        print(f"✅ Query test successful: {result}")
        
        await conn.close()
        print("✅ Connection closed successfully")
        
        print("\n🎉 Database connection test PASSED!")
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        print("Install asyncpg: pip install asyncpg")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Connection error: {e}")
        print("Make sure PostgreSQL is running and accessible")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(test_db_connection())