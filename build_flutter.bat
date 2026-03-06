@echo off
REM ============================================================
REM Script tự động build Flutter Module và copy vào C# Project
REM Phase 1 POC - SMAPI Launcher
REM ============================================================

echo.
echo ========================================
echo  SMAPI Launcher - Flutter Build Script
echo ========================================
echo.

REM Kiểm tra Flutter có được cài đặt không
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter not found! Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [1/5] Checking Flutter installation...
flutter --version
echo.

echo [2/5] Getting Flutter dependencies...
cd flutter_ui
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to get Flutter dependencies!
    cd ..
    pause
    exit /b 1
)
echo.

echo [3/5] Building Flutter AAR (Release mode)...
call flutter build aar --no-debug --no-profile
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to build Flutter AAR!
    cd ..
    pause
    exit /b 1
)
echo.

echo [4/5] Locating AAR file...
set AAR_PATH=build\host\outputs\repo\com\example\flutter_ui\flutter_release\1.0\flutter_release-1.0.aar
if not exist "%AAR_PATH%" (
    echo [ERROR] AAR file not found at: %AAR_PATH%
    cd ..
    pause
    exit /b 1
)
echo Found: %AAR_PATH%
echo.

echo [5/5] Copying AAR to C# Project...
cd ..
if not exist "SMAPIGameLoader\Libs" mkdir "SMAPIGameLoader\Libs"
copy /Y "flutter_ui\%AAR_PATH%" "SMAPIGameLoader\Libs\flutter_ui.aar"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy AAR file!
    pause
    exit /b 1
)
echo.

echo ========================================
echo  BUILD SUCCESSFUL!
echo ========================================
echo.
echo AAR file copied to: SMAPIGameLoader\Libs\flutter_ui.aar
echo.
echo Next steps:
echo 1. Add AAR reference to SMAPIGameLoader.csproj
echo 2. Update LauncherActivity.cs to use FlutterActivity
echo 3. Implement Method Channel handlers in C#
echo.
pause
