@echo off
echo Starting Midjourney Automation System for Windows
echo ==================================================

REM Check .env
if not exist ".env" (
    echo Creating .env file...
    copy ".env.example" ".env"
    echo.
    echo PLEASE EDIT .env WITH YOUR CREDENTIALS!
    echo Opening .env in notepad...
    notepad .env
    pause
)

echo [INFO] Using Windows-compatible configuration...

REM Stop any existing containers
docker-compose -f docker-compose.yml -f docker-compose.windows.yml down

REM Start database and cache
echo [INFO] Starting PostgreSQL and Redis...
docker-compose -f docker-compose.yml -f docker-compose.windows.yml up -d postgres redis

echo [INFO] Waiting 30 seconds for database...
timeout /t 30 /nobreak

REM Check database
docker-compose -f docker-compose.yml -f docker-compose.windows.yml exec postgres pg_isready -U mjuser -d mjsystem
if errorlevel 1 (
    echo [WARNING] Database not ready, waiting more...
    timeout /t 30 /nobreak
)

REM Start orchestrator
echo [INFO] Starting Orchestrator...
docker-compose -f docker-compose.yml -f docker-compose.windows.yml up -d orchestrator

echo [INFO] Waiting 20 seconds for API...
timeout /t 20 /nobreak

REM Start agents
echo [INFO] Starting all agents...
docker-compose -f docker-compose.yml -f docker-compose.windows.yml up -d

echo.
echo [INFO] Checking system status...
docker-compose -f docker-compose.yml -f docker-compose.windows.yml ps

echo.
echo ================================
echo System should be running!
echo ================================
echo.
echo Check these URLs:
echo - API Docs: http://localhost:8000/docs  
echo - Health: http://localhost:8000/health
echo.
echo If problems, check logs:
echo   docker-compose -f docker-compose.yml -f docker-compose.windows.yml logs
echo.
pause
start http://localhost:8000/docs