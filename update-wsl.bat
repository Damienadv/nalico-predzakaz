@echo off
setlocal EnableDelayedExpansion

echo.
echo ======================================================
echo    Update Elvira-Koreanka Warehouse (WSL)
echo ======================================================
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

REM Check for node_modules
wsl bash -c "cd %WSL_PATH% && test -d node_modules"
if %ERRORLEVEL% neq 0 (
    echo [INFO] Installing dependencies...
    echo.
    wsl bash -c "cd %WSL_PATH% && npm install"
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
    echo.
)

REM Convert Excel to JSON
echo [INFO] Converting Excel to JSON...
echo.
wsl bash -c "cd %WSL_PATH% && node convert-to-json.js"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ======================================================
    echo    [SUCCESS] Update completed!
    echo ======================================================
    echo.
    echo Refresh index.html in your browser (F5)
    echo.
) else (
    echo.
    echo ======================================================
    echo    [ERROR] Conversion failed
    echo ======================================================
    echo.
)

pause

