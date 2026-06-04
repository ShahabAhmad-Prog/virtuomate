# Fix "Could not read workspace metadata from ... metadata.bin" (corrupt Gradle cache)
$ErrorActionPreference = 'Continue'
Write-Host "Stopping Gradle daemons..." -ForegroundColor Cyan
Set-Location (Join-Path (Split-Path -Parent $PSScriptRoot) 'android')
if (Test-Path '.\gradlew.bat') { .\gradlew.bat --stop 2>&1 | Out-Null }
Start-Sleep -Seconds 2
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$root = Split-Path -Parent $PSScriptRoot
$wipe = @(
  "$env:USERPROFILE\.gradle\caches\8.14\transforms",
  "$env:USERPROFILE\.gradle\caches\8.14\transforms-3",
  "$env:USERPROFILE\.gradle\daemon",
  (Join-Path $root 'android\.gradle')
)
foreach ($p in $wipe) {
  if (Test-Path $p) {
    Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Removed $p"
  }
}

Set-Location $root
flutter clean 2>&1 | Out-Null
flutter pub get 2>&1 | Out-Null
Write-Host "`nDone. Run: .\scripts\fyp-demo-step3-run.ps1" -ForegroundColor Green
