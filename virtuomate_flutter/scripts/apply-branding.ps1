# Applies VirtuoMate logo assets, launcher icons, and native splash.
# Run from repo root: .\scripts\apply-branding.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

$logoSrc = Join-Path $env:USERPROFILE '.cursor\projects\d-Virtomate-Project-virtuomate-flutter\assets\c__Users_SHAHAB_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_image-73742e94-793e-436c-a984-47c43b92e2aa.png'
$assetsLogo = Join-Path $root 'assets\images\virtuomate_logo.png'

if (-not (Test-Path $assetsLogo)) {
  if (-not (Test-Path $logoSrc)) {
    throw "Logo not found. Place virtuomate_logo.png in assets\images\"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path $assetsLogo) | Out-Null
  Copy-Item $logoSrc $assetsLogo -Force
}

node (Join-Path $root 'tool\copy_logo_assets.js')

flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create

Write-Host 'Branding applied. Rebuild APK with .\scripts\build-release-android.ps1'
