@echo off
echo Starting Midjourney Automation System...

REM Check if .env exists
if not exist ".env" (
    echo Creating .env from template...
    copy ".env.example" ".env"
    echo.
    echo PLEASE EDIT .env FILE WITH YOUR CREDENTIALS!
    notepad .env
    echo.
    pause
)

REM Start services step by step
echo Starting database and cache...
docker-compose up -d postgres redis

echo Waiting 30 seconds for database...
timeout /t 30 /nobreak

echo Starting orchestrator...
docker-compose up -d orchestrator

echo Waiting 20 seconds for API...
timeout /t 20 /nobreak

echo Starting all agents...
docker-compose up -d

echo.
echo System starting... Check status:
docker-compose ps

echo.
echo Open in browser: http://localhost:8000/docs
echo.
pause