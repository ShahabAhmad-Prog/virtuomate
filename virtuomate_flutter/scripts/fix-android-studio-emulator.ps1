# Fix Android Studio not showing emulators after D: migration
$ErrorActionPreference = 'Stop'
$DevRoot = 'D:\Virtomate\dev-cache'
$Sdk = Join-Path $DevRoot 'Android\Sdk'

if (-not (Test-Path (Join-Path $Sdk 'emulator\emulator.exe'))) {
  Write-Host "ERROR: Emulator not found at $Sdk" -ForegroundColor Red
  Write-Host "Open Android Studio -> SDK Manager -> SDK Tools -> install Android Emulator"
  exit 1
}

# ANDROID_SDK_HOME = folder that CONTAINS .android (not .android itself)
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $Sdk, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', $Sdk, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_SDK_HOME', $DevRoot, 'User')
Set-Item Env:ANDROID_HOME $Sdk
Set-Item Env:ANDROID_SDK_ROOT $Sdk
Set-Item Env:ANDROID_SDK_HOME $DevRoot

Write-Host "Set ANDROID_HOME = $Sdk"
Write-Host "Set ANDROID_SDK_HOME = $DevRoot  (AVDs in $DevRoot\.android\avd)"

$avds = Get-ChildItem (Join-Path $DevRoot '.android\avd') -Filter '*.ini' -EA SilentlyContinue
Write-Host "`nAVDs on D:"
foreach ($ini in $avds) { Write-Host "  - $($ini.BaseName)" }

Write-Host "`n=== Android Studio (do this in the UI) ===" -ForegroundColor Cyan
Write-Host "1. File -> Settings -> Languages & Frameworks -> Android SDK"
Write-Host "   Android SDK Location: $Sdk"
Write-Host "2. SDK Tools tab -> ensure 'Android Emulator' is checked -> Apply"
Write-Host "3. Tools -> Device Manager -> refresh (or create Virtual Device)"
Write-Host "4. Restart Android Studio completely"
Write-Host "`nFlutter local.properties already uses D: SDK if you ran setup-d-drive-build.ps1"
