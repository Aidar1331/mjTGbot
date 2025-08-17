@echo off
title MJ Automation - Orchestrator
cd /d %~dp0
cd orchestrator
echo Starting Orchestrator...
python -m orchestrator.main
pause