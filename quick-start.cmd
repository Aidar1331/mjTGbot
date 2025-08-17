@echo off
echo Midjourney Automation System - Quick Start
echo ==========================================

REM Check Docker installation
where docker >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker not found. Please install Docker Desktop
    pause
    exit /b 1
)

where docker-compose >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose not found. Please install Docker Desktop with Compose
    pause
    exit /b 1
)

echo [OK] Docker and Docker Compose found

echo [INFO] Current directory: %CD%
echo [INFO] Files in directory:
dir /b *.yml *.env* *.cmd

REM Check .env file
if not exist ".env" (
    echo [WARNING] .env file not found. Creating from .env.example...
    copy ".env.example" ".env" >nul
    echo.
    echo [IMPORTANT] Edit .env file with your real credentials:
    echo    - DISCORD_EMAIL and DISCORD_PASSWORD
    echo    - CLAUDE_API_KEY
    echo    - TELEGRAM_BOT_TOKEN and TELEGRAM_ADMIN_ID
    echo.
    echo Opening .env in notepad...
    notepad .env
    echo.
    echo Press any key after editing .env file...
    pause >nul
)

echo [INFO] Checking Docker Compose configuration...
docker-compose config >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Error in docker-compose.yml
    docker-compose config
    pause
    exit /b 1
)

echo [OK] Configuration is valid

REM Stop existing containers
echo [INFO] Stopping existing containers...
docker-compose down >nul 2>&1

REM Start basic services
echo [INFO] Starting PostgreSQL and Redis...
docker-compose up -d postgres redis

REM Wait for database
echo [INFO] Waiting for PostgreSQL to be ready...
set /a timeout=60
:wait_postgres
docker-compose exec -T postgres pg_isready -U mjuser -d mjsystem >nul 2>&1
if errorlevel 0 (
    echo [OK] PostgreSQL is ready
    goto postgres_ready
)
echo    Waiting... (%timeout% seconds remaining)
timeout /t 2 /nobreak >nul
set /a timeout-=2
if %timeout% gtr 0 goto wait_postgres

echo [ERROR] PostgreSQL not ready. Check logs:
docker-compose logs postgres
pause
exit /b 1

:postgres_ready

REM Start orchestrator
echo [INFO] Starting Orchestrator...
docker-compose up -d orchestrator

REM Wait for API
echo [INFO] Waiting for Orchestrator API...
set /a timeout=60
:wait_api
curl -f http://localhost:8000/health >nul 2>&1
if errorlevel 0 (
    echo [OK] Orchestrator API is ready
    goto api_ready
)
echo    Waiting... (%timeout% seconds remaining)
timeout /t 2 /nobreak >nul
set /a timeout-=2
if %timeout% gtr 0 goto wait_api

echo [ERROR] Orchestrator API not responding. Check logs:
docker-compose logs orchestrator
pause
exit /b 1

:api_ready

REM Start all agents
echo [INFO] Starting all agents...
docker-compose up -d

REM Check status
echo.
echo [INFO] Container status:
docker-compose ps

REM Check health
echo.
echo [INFO] Checking system health...

curl -s http://localhost:8000/health | findstr /C:"ok" >nul 2>&1 || curl -s http://localhost:8000/health | findstr /C:"healthy" >nul 2>&1
if errorlevel 0 (
    echo [OK] Health Check: PASSED
) else (
    echo [ERROR] Health Check: FAILED
)

curl -s -o nul -w "%%{http_code}" http://localhost:8000/docs | findstr "200" >nul
if errorlevel 0 (
    echo [OK] API Docs: AVAILABLE
) else (
    echo [ERROR] API Docs: NOT AVAILABLE
)

echo.
echo ========================================
echo System is running!
echo ========================================
echo.
echo Available URLs:
echo   - API Health: http://localhost:8000/health
echo   - API Docs: http://localhost:8000/docs
echo   - Queue Status: http://localhost:8000/queue/status
echo   - Agent Status: http://localhost:8000/agents/status
echo.
echo Useful commands:
echo   - View logs: docker-compose logs -f
echo   - Stop system: docker-compose down
echo   - Restart: docker-compose restart
echo   - Run tests: python scripts/test-system.py
echo.
echo System is ready to work!
echo.
echo Opening API documentation in browser...
timeout /t 3 /nobreak >nul
start http://localhost:8000/docs
echo.
echo Press any key to exit...
pause >nul