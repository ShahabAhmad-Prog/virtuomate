# Remove smoke-test / build junk on C: — does NOT delete project source on D:
$ErrorActionPreference = 'Continue'

Write-Host "`n=== Stopping Gradle/Java ===" -ForegroundColor Cyan
$FlutterRoot = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $FlutterRoot 'android')
if (Test-Path '.\gradlew.bat') { .\gradlew.bat --stop 2>&1 | Out-Null }
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

$total = 0
function Remove-Tree([string]$Path, [string]$Label) {
  if (-not (Test-Path $Path)) { return }
  $bytes = (Get-ChildItem $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum).Sum
  if ($null -eq $bytes) { $bytes = 0 }
  Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
  $mb = [math]::Round($bytes / 1MB, 0)
  Write-Host "Removed $Label (~${mb} MB): $Path"
  return $bytes
}

Write-Host "`n=== C: paths (old locations after D: migration) ===" -ForegroundColor Cyan
$total += Remove-Tree "$env:USERPROFILE\.gradle" 'Gradle on C (use D:\Virtomate\dev-cache\.gradle)'
$total += Remove-Tree "$env:LOCALAPPDATA\Pub\Cache" 'Pub cache on C'
$total += Remove-Tree "$env:LOCALAPPDATA\Android\Sdk" 'Android SDK on C (if migrated)'
$total += Remove-Tree "$env:USERPROFILE\.android" '.android on C (if migrated)'

Get-ChildItem $env:TEMP -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -match 'flutter_tools|gradle|dart' } |
  ForEach-Object { $total += Remove-Tree $_.FullName "Temp $($_.Name)" }

Write-Host "`n=== Optional: project build artifacts on D: (safe) ===" -ForegroundColor Cyan
Set-Location $FlutterRoot
if (Get-Command flutter -ErrorAction SilentlyContinue) {
  flutter clean 2>&1 | Out-Null
  Write-Host "flutter clean on project (build/ .dart_tool on D: only)"
}

$gb = [math]::Round($total / 1GB, 2)
Write-Host "`nFreed ~$gb GB from C:" -ForegroundColor Green
Write-Host "Kept: D:\Virtomate Project\*, D:\Virtomate\dev-cache\*, source, .env, node_modules"
Write-Host "Next builds use D: via setup-d-drive-build.ps1 env vars."
