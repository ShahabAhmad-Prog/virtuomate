# Step 2 - Deploy Cloud Functions + Firestore rules (chat + Gemini)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$envFile = Join-Path $Root ".env"
if (-not (Test-Path $envFile)) {
    throw "Run step 1 first: .\scripts\fyp-demo-step1-gemini.ps1"
}
$envContent = Get-Content $envFile -Raw
if ($envContent -notmatch 'GEMINI_API_KEY=(AIza|AQ\.)') {
    throw "GEMINI_API_KEY missing or invalid in .env - run step 1 with AI Studio key (AIza or AQ.)."
}

Write-Host ""
Write-Host "=== STEP 2: Install + deploy ===" -ForegroundColor Cyan

if (-not (Test-Path ".\node_modules")) {
    Write-Host "Running npm install..." -ForegroundColor Yellow
    npm install
}

Write-Host "Deploying functions + Firestore rules (2-5 min)..." -ForegroundColor Yellow
firebase deploy --only functions,firestore:rules

Write-Host ""
Write-Host "Verifying /health ..." -ForegroundColor Cyan
Start-Sleep -Seconds 5
try {
    $health = Invoke-RestMethod -Uri "https://us-central1-virtuomate.cloudfunctions.net/api/health" -TimeoutSec 45
    Write-Host "ok: $($health.ok)" -ForegroundColor Green
    Write-Host "geminiConfigured: $($health.geminiConfigured)" -ForegroundColor Green
    Write-Host "aiProvider: $($health.aiProvider)" -ForegroundColor White
} catch {
    Write-Host "Health check failed (wait 30s and retry): $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next: cd to virtuomate_flutter and run .\scripts\fyp-demo-step3-run.ps1" -ForegroundColor Green
