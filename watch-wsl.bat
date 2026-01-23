@echo off
setlocal EnableDelayedExpansion

cls
echo.
echo ======================================================
echo    Auto-Watch: Elvira-Koreanka Warehouse (WSL)
echo ======================================================
echo.
echo This script will automatically update data.json
echo when Excel files change in price_files folder
echo.
echo Press Ctrl+C to stop
echo.
echo ------------------------------------------------------
echo.

REM WSL path in Linux format
set "WSL_PATH=/home/damien/projects/predzakaz_dashboard"

REM Check if WSL is available
wsl --list --quiet >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] WSL is not installed or not running!
    pause
    exit /b 1
)

REM Check for Node.js in WSL
wsl bash -c "which node" >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not installed in WSL!
    pause
    exit /b 1
)

echo [INFO] Starting file watcher in WSL...
echo.

REM Run watch script in WSL
wsl bash -c "cd %WSL_PATH% && bash update.sh watch"

