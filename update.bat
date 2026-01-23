@echo off
setlocal EnableDelayedExpansion

echo.
echo ======================================================
echo    Update Elvira-Koreanka Warehouse
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
    echo.
    pause
    exit /b 1
)

REM Check for node_modules
if not exist "node_modules" (
    echo [INFO] Installing dependencies...
    echo.
    call npm install
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
node convert-to-json.js

if %ERRORLEVEL% equ 0 (
    echo.
    echo ======================================================
    echo    [SUCCESS] Update completed!
    echo ======================================================
    echo.
    echo Open or refresh index.html in your browser
    echo Press F5 to refresh the page
    echo.
) else (
    echo.
    echo ======================================================
    echo    [ERROR] Conversion failed
    echo ======================================================
    echo.
)

REM Clean up mapped drive if we created one
if not "!MAPPED_DRIVE!"=="" (
    echo.
    echo [INFO] Cleaning up mapped drive...
    net use !MAPPED_DRIVE! /delete >nul 2>nul
)

pause

