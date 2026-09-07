@echo off
cd /d "%~dp0"

set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR":~-1%"=="\" set
"PROJECT_DIR=%PROJECT_DIR:~0,-1%"

juliaup default 1.10
echo Installation des dependances en cours...
julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.precompile()"
echo Installation terminee.
pause