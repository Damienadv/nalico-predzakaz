@echo off
setlocal EnableDelayedExpansion

cls
echo.
echo ======================================================
echo    Auto-Watch: Elvira-Koreanka Warehouse
echo ======================================================
echo.
echo This script will automatically update data.json
echo when Excel files change in price_files folder
echo.
echo Press Ctrl+C to stop
echo.
echo ------------------------------------------------------
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
                echo.
                goto :MAPPED_SUCCESS_WATCH
            )
        )
    )
    
    echo [ERROR] Failed to map UNC path to drive letter
    echo [INFO] Please copy the project to a local drive (C:\, D:\, etc.)
    pause
    exit /b 1
    
    :MAPPED_SUCCESS_WATCH
) else (
    REM Not a UNC path, just change to script directory
    cd /d "%SCRIPT_DIR%"
)


REM Check for Node.js
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not installed!
    pause
    exit /b 1
)

REM Remember last check
set "LAST_CHECK="

:WATCH_LOOP
    REM Find latest modified Excel file
    for /f "delims=" %%i in ('dir /b /o-d /a-d "price_files\*.xlsx" 2^>nul') do (
        set "LATEST_FILE=%%i"
        goto :FOUND_FILE
    )
    
    echo [ERROR] No Excel files in price_files
    timeout /t 10 >nul
    goto :WATCH_LOOP

:FOUND_FILE
    REM Get file modification date
    for %%a in ("price_files\!LATEST_FILE!") do set "FILE_DATE=%%~ta"
    
    REM Check if date changed
    if not "!FILE_DATE!"=="!LAST_CHECK!" (
        if not "!LAST_CHECK!"=="" (
            echo.
            echo [ALERT] Changes detected in !LATEST_FILE!
            echo [TIME] %date% %time%
            echo.
            echo [INFO] Updating data...
            call update-silent.bat
            
            if !ERRORLEVEL! equ 0 (
                echo [SUCCESS] Data updated! Refresh browser page (F5^)
            ) else (
                echo [ERROR] Update failed
            )
            echo.
            echo ------------------------------------------------------
        ) else (
            echo [INFO] Watching: !LATEST_FILE!
            echo [TIME] Last modified: !FILE_DATE!
            echo.
            echo [SUCCESS] Ready. Waiting for changes...
            echo.
        )
        
        set "LAST_CHECK=!FILE_DATE!"
    )
    
    REM Wait 5 seconds before next check
    timeout /t 5 >nul
    
goto :WATCH_LOOP

REM Clean up on exit (Note: This won't be reached if Ctrl+C is used)
:CLEANUP
if not "!MAPPED_DRIVE!"=="" (
    echo.
    echo [INFO] Cleaning up mapped drive...
    net use !MAPPED_DRIVE! /delete >nul 2>nul
)

