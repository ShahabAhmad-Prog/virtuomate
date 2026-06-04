# Starts local backend + Flutter (Android emulator friendly)
$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path (Split-Path -Parent $root) "virtuomate_backend_firebase"
if (-not (Test-Path $backend)) {
  $backend = Join-Path $root "..\virtuomate_backend_firebase"
}
Write-Host "Starting backend in new window: $backend" -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$backend'; npm run dev"
Start-Sleep -Seconds 4
Set-Location $root
. (Join-Path $PSScriptRoot 'env-d-drive.ps1')
flutter run `
  --dart-define=USE_FIREBASE=true `
  --dart-define=USE_BACKEND_API=true `
  --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8080 `
  --dart-define=GOOGLE_WEB_CLIENT_ID=671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com
