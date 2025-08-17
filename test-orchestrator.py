#!/usr/bin/env python3
"""
Простой тест для проверки оркестратора
"""
import sys
import os

try:
    # Тестируем импорты
    print("Testing imports...")
    
    print("- fastapi:", end=" ")
    import fastapi
    print("✅")
    
    print("- pydantic:", end=" ")
    import pydantic
    print("✅")
    
    print("- sqlalchemy:", end=" ")
    import sqlalchemy
    print("✅")
    
    print("- asyncpg:", end=" ")
    import asyncpg
    print("✅")
    
    print("- redis:", end=" ")
    import redis
    print("✅")
    
    print("\nAll imports successful!")
    
    # Тестируем создание FastAPI приложения
    print("\nTesting FastAPI app creation...")
    from fastapi import FastAPI
    app = FastAPI(title="Test App")
    print("✅ FastAPI app created successfully")
    
    print("\n🎉 Orchestrator dependencies test PASSED!")
    
except ImportError as e:
    print(f"❌ Import error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)