@echo off
echo Starting Midjourney System WITHOUT Chrome Agent
echo =================================================
echo This version excludes MJ Interaction to test other components

REM Stop all
docker-compose -f docker-compose.yml -f docker-compose.windows.yml down

REM Start core services
echo [INFO] Starting core services...
docker-compose -f docker-compose.yml -f docker-compose.windows.yml up -d postgres redis orchestrator

echo [INFO] Waiting for core services...
timeout /t 20 /nobreak

REM Start other agents (without mj-interaction)
echo [INFO] Starting other agents...
docker-compose -f docker-compose.yml -f docker-compose.windows.yml up -d trend-parser prompt-expander video-compiler publisher review-bridge

echo.
echo [INFO] System status (without Chrome agent):
docker-compose -f docker-compose.yml -f docker-compose.windows.yml ps

echo.
echo ================================
echo Core system running!
echo ================================
echo.
echo Test these URLs:
echo - API Docs: http://localhost:8000/docs
echo - Health: http://localhost:8000/health
echo - Queue Status: http://localhost:8000/queue/status
echo.
echo Chrome agent disabled due to Windows compatibility issues
echo Other agents should work fine
echo.
pause
start http://localhost:8000/docs