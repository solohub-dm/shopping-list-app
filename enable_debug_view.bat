@echo off
echo Enabling Firebase Analytics DebugView for Android...
echo.

REM Try to find ADB in common locations
set ADB_PATH=
if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set ADB_PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
) else if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" (
    set ADB_PATH=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe
) else if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
    set ADB_PATH=%ANDROID_HOME%\platform-tools\adb.exe
) else (
    echo ADB not found in common locations. Trying system PATH...
    where adb >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set ADB_PATH=adb
    ) else (
        echo ERROR: ADB not found!
        echo Please install Android SDK Platform Tools or add ADB to your PATH.
        pause
        exit /b 1
    )
)

echo Using ADB at: %ADB_PATH%
echo.
echo Make sure your Android device is connected via USB or ADB over Wi-Fi
echo.

%ADB_PATH% shell setprop debug.firebase.analytics.app com.example.shopping_list_app

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Debug mode enabled successfully!
    echo Restart your app to see events in Firebase DebugView.
) else (
    echo.
    echo ERROR: Failed to enable debug mode.
    echo Make sure your device is connected and USB debugging is enabled.
)

echo.
pause

