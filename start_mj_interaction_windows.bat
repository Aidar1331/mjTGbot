@echo off
title MJ Automation - MJ Interaction Agent (Windows)
cd /d %~dp0
echo Starting MJ Interaction Agent for Windows...
python -m agents.mj_interaction.agent_windows
pause