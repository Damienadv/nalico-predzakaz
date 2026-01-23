@echo off
setlocal EnableDelayedExpansion

cls
echo.
echo ======================================================
echo    Elvira-Koreanka Warehouse - Quick Start
echo ======================================================
echo.

REM Handle UNC path issues by mapping to a temporary drive letter
set "SCRIPT_DIR=%~dp0"
set "UNC_PATH="
set "MAPPED_DRIVE="

REM Check if we're on a UNC path
echo %SCRIPT_DIR% | findstr /B "\\\\" >nul
if %ERRORLEVEL% equ 0 (
    set "UNC_PATH=%SCRIPT_DIR%"
    echo [INFO] UNC path detected, mapping to temporary drive...
    
    REM Find available drive letter
    for %%D in (Z Y X W V U T S R Q P O N M L K) do (
        if not exist %%D:\ (
            set "MAPPED_DRIVE=%%D:"
            net use %%D: "%SCRIPT_DIR%" >nul 2>nul
            if !ERRORLEVEL! equ 0 (
                cd /d %%D:\
                echo [SUCCESS] Mapped to %%D:\
                goto :MAPPED_SUCCESS
            )
        )
    )
    
    echo [ERROR] Failed to map UNC path to drive letter
    echo [INFO] Please copy the project to a local drive (C:\, D:\, etc.)
    pause
    exit /b 1
    
    :MAPPED_SUCCESS
) else (
    REM Not a UNC path, just change to script directory
    cd /d "%SCRIPT_DIR%"
)

echo.

REM Check for Node.js
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not installed!
    echo.
    echo Download and install Node.js from https://nodejs.org/
    echo After installation, run this file again.
    echo.
    pause
    exit /b 1
)

REM Check for node_modules
if not exist "node_modules" (
    echo [INFO] First run: Installing dependencies...
    echo.
    call npm install
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
node convert-to-json.js

if %ERRORLEVEL% equ 0 (
    echo.
    echo ======================================================
    echo    [SUCCESS] Data updated successfully!
    echo ======================================================
    echo.
    
    REM Open in browser
    echo [INFO] Opening dashboard in browser...
    echo.
    
    REM Get full path to index.html
    set "INDEX_PATH=%~dp0index.html"
    
    REM Open in default browser
    start "" "!INDEX_PATH!"
    
    echo [SUCCESS] Dashboard opened in browser
    echo.
    echo Tips:
    echo    - To update data, just run this file again
    echo    - Put new Excel in price_files folder and run update.bat
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

REM Clean up mapped drive if we created one
if not "!MAPPED_DRIVE!"=="" (
    echo.
    echo [INFO] Cleaning up mapped drive...
    net use !MAPPED_DRIVE! /delete >nul 2>nul
)

timeout /t 3 >nul

