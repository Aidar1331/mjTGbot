@echo off
title MJ Automation - Launcher
cd /d %~dp0

echo ============================================
echo  Midjourney Automation System - Windows
echo ============================================
echo.

echo Starting Orchestrator...
start "Orchestrator" cmd /k "cd orchestrator && python -m orchestrator.main"
timeout /t 10

echo Starting MJ Interaction Agent (Windows)...
start "MJ Interaction" cmd /k "python -m agents.mj_interaction.agent_windows"
timeout /t 5

echo Starting Trend Parser Agent...
start "Trend Parser" cmd /k "python -m agents.trend_parser.agent"
timeout /t 3

echo Starting Prompt Expander Agent...
start "Prompt Expander" cmd /k "python -m agents.prompt_expander.agent"
timeout /t 3

echo Starting Video Compiler Agent...
start "Video Compiler" cmd /k "python -m agents.video_compiler.agent"
timeout /t 3

echo Starting Publisher Agent...
start "Publisher" cmd /k "python -m agents.publisher.agent"
timeout /t 3

echo Starting Review Bridge (Telegram Bot)...
start "Review Bridge" cmd /k "python -m agents.review_bridge.agent"

echo.
echo ============================================
echo  All services started!
echo ============================================
echo.
echo Services:
echo - Orchestrator API: http://localhost:8000
echo - API Documentation: http://localhost:8000/docs
echo.
echo Press any key to exit launcher...
pause > nul