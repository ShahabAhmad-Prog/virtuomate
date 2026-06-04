# Step 3 — Run Flutter app (Firebase + API)
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

Write-Host ""
Write-Host "=== STEP 3: Flutter run ===" -ForegroundColor Cyan
Write-Host "Device: connect phone USB or start Android emulator first." -ForegroundColor White
Write-Host ""

flutter pub get
& "$PSScriptRoot\run_dev.ps1"
