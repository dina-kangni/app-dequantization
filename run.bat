@echo off
cd /d "%~dp0"
set SCRIPT_DIR=%~dp0
julia --project=. -e "include(\"src/L2F2_Dequantification_App.jl\"); L2F2_Dequantification_App.lancer()"
pause