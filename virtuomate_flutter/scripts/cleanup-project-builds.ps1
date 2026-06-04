# Remove old VirtuoMate build artifacts (safe — source and .env kept)
$ErrorActionPreference = 'Continue'
$root = 'D:\Virtomate Project'

function Remove-IfExists([string]$Path) {
  if (-not (Test-Path $Path)) { return 0 }
  $item = Get-Item $Path -Force
  $bytes = 0
  if ($item.PSIsContainer) {
    $bytes = (Get-ChildItem $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
      Measure-Object -Property Length -Sum).Sum
    if ($null -eq $bytes) { $bytes = 0 }
    Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
  } else {
    $bytes = $item.Length
    Remove-Item $Path -Force -ErrorAction SilentlyContinue
  }
  Write-Host "Removed: $Path ($([math]::Round($bytes / 1MB, 1)) MB)"
  return $bytes
}

$total = 0
Write-Host "`n=== D: VirtuoMate project ===" -ForegroundColor Cyan

$paths = @(
  "$root\virtuomate_flutter\build",
  "$root\virtuomate_flutter\.dart_tool",
  "$root\virtuomate_flutter\android\.gradle",
  "$root\virtuomate_flutter\android\app\build",
  "$root\virtuomate_flutter\android\build",
  "$root\virtuomate_backend_firebase\.firebase",
  "$root\virtuomate_backend_firebase\firebase-debug.log",
  "$root\virtuomate_backend_firebase\firestore-debug.log",
  "$root\virtuomate_backend_firebase\ui-debug.log",
  "$root\virtuomate_ml\__pycache__",
  "$root\virtuomate_ml\.pytest_cache",
  "$root\virtuomate_ml\data",
  "$root\virtuomate_ml\checkpoints",
  "$root\virtuomate_ml\models",
  "$root\virtuomate_ml\.venv",
  "$root\virtuomate_ml\venv",
  "$root\virtuomate_ml\runs",
  "$root\virtuomate_ml\wandb"
)

foreach ($p in $paths) { $total += Remove-IfExists $p }

# __pycache__ under ML tree
Get-ChildItem "$root\virtuomate_ml" -Recurse -Directory -Filter '__pycache__' -ErrorAction SilentlyContinue |
  ForEach-Object { $total += Remove-IfExists $_.FullName }

Set-Location "$root\virtuomate_flutter"
if (Get-Command flutter -ErrorAction SilentlyContinue) {
  Write-Host "`nflutter clean..." -ForegroundColor Yellow
  flutter clean 2>&1 | Out-Host
}

Set-Location "$root\virtuomate_backend_firebase"
if (Get-Command npm -ErrorAction SilentlyContinue) {
  Write-Host "`nnpm cache clean..." -ForegroundColor Yellow
  npm cache clean --force 2>&1 | Out-Host
}

Write-Host "`n=== C: dev caches (VirtuoMate-related) ===" -ForegroundColor Cyan
$cPaths = @(
  "$env:USERPROFILE\.gradle\caches",
  "$env:USERPROFILE\.gradle\daemon",
  "$env:TEMP"
)
foreach ($p in $cPaths) {
  if ($p -eq $env:TEMP) {
    Get-ChildItem $env:TEMP -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -match 'flutter|gradle|dart|virtuomate' } |
      ForEach-Object { $total += Remove-IfExists $_.FullName }
  } else {
    $total += Remove-IfExists $p
  }
}

$gb = [math]::Round($total / 1GB, 2)
Write-Host "`nEstimated freed: ~$gb GB" -ForegroundColor Green
Write-Host "Kept: source code, .env, node_modules (re-run npm install if needed), Android SDK, emulators."
Write-Host "Next run: cd virtuomate_flutter; flutter pub get; then fyp-demo-step3-run.ps1"
