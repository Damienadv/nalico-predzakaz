@echo off
setlocal EnableDelayedExpansion

cls
echo.
echo ======================================================
echo    Elvira-Koreanka Warehouse - WSL Launcher
echo ======================================================
echo.

REM WSL path in Linux format
set "WSL_PATH=/home/damien/projects/predzakaz_dashboard"

REM Check if WSL is available
wsl --list --quiet >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] WSL is not installed or not running!
    echo.
    echo Please install WSL: https://aka.ms/wsl
    echo.
    pause
    exit /b 1
)

echo [INFO] Running from WSL: %WSL_PATH%
echo.

REM Check for Node.js in WSL
wsl bash -c "which node" >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not installed in WSL!
    echo.
    echo Install it with:
    echo   wsl bash -c "curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
    echo   wsl bash -c "sudo apt-get install -y nodejs"
    echo.
    pause
    exit /b 1
)

echo [INFO] Node.js found in WSL
echo.

REM Check for node_modules
wsl bash -c "cd %WSL_PATH% && test -d node_modules"
if %ERRORLEVEL% neq 0 (
    echo [INFO] First run: Installing dependencies...
    echo.
    wsl bash -c "cd %WSL_PATH% && npm install"
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Failed to install dependencies
        pause
        exit /b 1
    )
    echo [SUCCESS] Dependencies installed
    echo.
)

REM Convert Excel to JSON
echo [INFO] Finding and converting latest Excel file...
echo.
wsl bash -c "cd %WSL_PATH% && node convert-to-json.js"

if %ERRORLEVEL% equ 0 (
    echo.
    echo ======================================================
    echo    [SUCCESS] Data updated successfully!
    echo ======================================================
    echo.
    
    REM Open in browser (Windows path)
    echo [INFO] Opening dashboard in browser...
    echo.
    
    REM Get Windows path to index.html
    set "WIN_PATH=\\wsl.localhost\Ubuntu-24.04\home\damien\projects\predzakaz_dashboard\index.html"
    
    REM Open in default browser
    start "" "!WIN_PATH!"
    
    echo [SUCCESS] Dashboard opened in browser
    echo.
    echo Tips:
    echo    - To update data, run this file again
    echo    - Or use update-wsl.bat for quick updates
    echo    - Put new Excel in price_files folder
    echo.
) else (
    echo.
    echo ======================================================
    echo    [ERROR] Conversion failed
    echo ======================================================
    echo.
    echo Check:
    echo    1. Are there Excel files in price_files folder?
    echo    2. Is the file format correct (.xlsx)?
    echo.
)

timeout /t 3 >nul

