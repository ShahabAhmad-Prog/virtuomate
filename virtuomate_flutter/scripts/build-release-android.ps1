# Build Android APK (and optional App Bundle for Play Store)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot 'env-d-drive.ps1')

$defines = @(
  '--dart-define=USE_FIREBASE=true',
  '--dart-define=USE_BACKEND_API=true',
  '--dart-define=GOOGLE_WEB_CLIENT_ID=671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com'
)

if (-not (Test-Path (Join-Path $PWD 'assets\images\virtuomate_logo.png'))) {
  Write-Host "Applying branding (logo + launcher icons)..." -ForegroundColor Yellow
  & (Join-Path $PSScriptRoot 'apply-branding.ps1')
}

Write-Host "`n=== Validating logo PNG for Android ===" -ForegroundColor Cyan
node (Join-Path $PWD 'tool\copy_logo_assets.js')

Write-Host "`n=== Building release APK ===" -ForegroundColor Cyan
flutter build apk --release @defines

$apk = Join-Path $PWD 'build\app\outputs\flutter-apk\app-release.apk'
if (Test-Path $apk) {
  $mb = [math]::Round((Get-Item $apk).Length / 1MB, 1)
  Write-Host "`nAPK ready ($mb MB):" -ForegroundColor Green
  Write-Host $apk
  Write-Host "`nInstall on phone: copy APK to device and open, or:"
  Write-Host "  adb install -r `"$apk`""
}

Write-Host "`nFor Google Play, build AAB instead:" -ForegroundColor Yellow
Write-Host "  flutter build appbundle --release @defines"
