@echo off
echo Checking Midjourney Automation System Status
echo ============================================

echo [1] Docker version:
docker --version
docker-compose --version
echo.

echo [2] Container status:
docker-compose ps
echo.

echo [3] Running containers:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.

echo [4] Health checks:
echo Checking orchestrator health...
curl -s http://localhost:8000/health
echo.

echo [5] Logs (last 10 lines):
echo --- PostgreSQL ---
docker-compose logs --tail=5 postgres
echo.
echo --- Orchestrator ---
docker-compose logs --tail=5 orchestrator
echo.

echo [6] .env file status:
if exist ".env" (
    echo [OK] .env file exists
) else (
    echo [WARNING] .env file missing!
)
echo.

echo [7] Port check:
netstat -an | findstr :8000
netstat -an | findstr :5432
netstat -an | findstr :6379
echo.

pause