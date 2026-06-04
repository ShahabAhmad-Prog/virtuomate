# Device smoke test — build with Firebase, install, run integration_test on emulator
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
. (Join-Path $PSScriptRoot 'env-d-drive.ps1')

$defines = @(
  '--dart-define=USE_FIREBASE=true',
  '--dart-define=USE_BACKEND_API=true',
  '--dart-define=GOOGLE_WEB_CLIENT_ID=671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com'
)

Write-Host "`n=== API health ===" -ForegroundColor Cyan
& "$PSScriptRoot\fyp-demo-step4-smoke.ps1"

Write-Host "`n=== Flutter unit tests ===" -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) { throw 'Unit tests failed' }

$device = 'emulator-5554'
Write-Host "`n=== Device: $device ===" -ForegroundColor Cyan
flutter devices | Select-String $device
if ($LASTEXITCODE -ne 0) { Write-Host 'Warning: emulator-5554 not found; using default device' -ForegroundColor Yellow }

Write-Host "`n=== Integration smoke on device (2-5 min) ===" -ForegroundColor Cyan
flutter test integration_test/smoke_test.dart -d $device @defines
if ($LASTEXITCODE -ne 0) { throw 'Device smoke test failed' }

Write-Host "`nDEVICE SMOKE: PASS" -ForegroundColor Green
