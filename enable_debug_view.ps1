# PowerShell script to enable Firebase Analytics DebugView
Write-Host "Enabling Firebase Analytics DebugView for Android..." -ForegroundColor Cyan
Write-Host ""

# Try to find ADB in common locations
$adbPath = $null

if (Test-Path "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe") {
    $adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
} elseif (Test-Path "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe") {
    $adbPath = "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
} elseif ($env:ANDROID_HOME) {
    $adbPath = "$env:ANDROID_HOME\platform-tools\adb.exe"
    if (-not (Test-Path $adbPath)) {
        $adbPath = $null
    }
}

if ($null -eq $adbPath) {
    # Try to find adb in PATH
    $adbInPath = Get-Command adb -ErrorAction SilentlyContinue
    if ($adbInPath) {
        $adbPath = "adb"
    }
}

if ($null -eq $adbPath) {
    Write-Host "ERROR: ADB not found!" -ForegroundColor Red
    Write-Host "Please install Android SDK Platform Tools or add ADB to your PATH." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common locations:" -ForegroundColor Yellow
    Write-Host "  - $env:LOCALAPPDATA\Android\Sdk\platform-tools\" -ForegroundColor Gray
    Write-Host "  - $env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\" -ForegroundColor Gray
    pause
    exit 1
}

Write-Host "Using ADB at: $adbPath" -ForegroundColor Green
Write-Host ""
Write-Host "Make sure your Android device is connected via USB or ADB over Wi-Fi" -ForegroundColor Yellow
Write-Host ""

# Execute the command
& $adbPath shell setprop debug.firebase.analytics.app com.example.shopping_list_app

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Debug mode enabled successfully!" -ForegroundColor Green
    Write-Host "Restart your app to see events in Firebase DebugView." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "ERROR: Failed to enable debug mode." -ForegroundColor Red
    Write-Host "Make sure your device is connected and USB debugging is enabled." -ForegroundColor Yellow
}

Write-Host ""
pause


