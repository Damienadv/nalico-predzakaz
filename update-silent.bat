@echo off
setlocal EnableDelayedExpansion

REM Handle UNC path issues by mapping to a temporary drive letter
set "SCRIPT_DIR=%~dp0"
set "UNC_PATH="
set "MAPPED_DRIVE="

REM Check if we're on a UNC path
echo %SCRIPT_DIR% | findstr /B "\\\\" >nul
if %ERRORLEVEL% equ 0 (
    set "UNC_PATH=%SCRIPT_DIR%"
    
    REM Find available drive letter
    for %%D in (Z Y X W V U T S R Q P O N M L K) do (
        if not exist %%D:\ (
            set "MAPPED_DRIVE=%%D:"
            net use %%D: "%SCRIPT_DIR%" >nul 2>nul
            if !ERRORLEVEL! equ 0 (
                cd /d %%D:\
                goto :MAPPED_SUCCESS_SILENT
            )
        )
    )
    
    REM Failed to map
    exit /b 1
    
    :MAPPED_SUCCESS_SILENT
) else (
    REM Not a UNC path, just change to script directory
    cd /d "%SCRIPT_DIR%"
)

REM Silent update without output (for automation)
where node >nul 2>nul
if %ERRORLEVEL% neq 0 exit /b 1

if not exist "node_modules" (
    call npm install --silent >nul 2>nul
)

node convert-to-json.js

REM Store exit code
set "EXIT_CODE=%ERRORLEVEL%"

REM Clean up mapped drive if we created one
if not "!MAPPED_DRIVE!"=="" (
    net use !MAPPED_DRIVE! /delete >nul 2>nul
)

exit /b %EXIT_CODE%

