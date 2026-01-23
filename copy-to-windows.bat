@echo off
setlocal EnableDelayedExpansion

echo.
echo ======================================================
echo    Copy Project from WSL to Windows
echo ======================================================
echo.

REM Ask for destination
set /p "DEST=Enter destination path (e.g., C:\Users\YourName\Desktop\warehouse): "

if "%DEST%"=="" (
    echo [ERROR] No destination specified
    pause
    exit /b 1
)

echo.
echo [INFO] Creating directory: %DEST%
mkdir "%DEST%" 2>nul

echo [INFO] Copying files...
echo.

REM Copy essential files
xcopy /Y /Q "index.html" "%DEST%\"
xcopy /Y /Q "data.json" "%DEST%\"
xcopy /Y /Q "convert-to-json.js" "%DEST%\"
xcopy /Y /Q "package.json" "%DEST%\"
xcopy /Y /Q "*.bat" "%DEST%\"
xcopy /Y /Q "*.md" "%DEST%\"

REM Copy price_files directory
echo [INFO] Copying price_files...
xcopy /E /Y /Q "price_files" "%DEST%\price_files\"

REM Copy node_modules if exists
if exist "node_modules" (
    echo [INFO] Copying node_modules (this may take a while)...
    xcopy /E /Y /Q "node_modules" "%DEST%\node_modules\"
)

echo.
echo ======================================================
echo    [SUCCESS] Project copied successfully!
echo ======================================================
echo.
echo Destination: %DEST%
echo.
echo Next steps:
echo   1. Navigate to: %DEST%
echo   2. Double-click start.bat
echo   3. Dashboard will open in browser
echo.

pause
