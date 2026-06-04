# Set INTELLIGENCE_ENGINE_URL on Firebase Cloud Function + optional OpenAI for Whisper
param(
    [Parameter(Mandatory = $true)]
    [string]$EngineUrl,
    [string]$OpenAiKey = "",
    [string]$Project = "virtuomate",
    [string]$Region = "us-central1"
)

$ErrorActionPreference = "Stop"
$EngineUrl = $EngineUrl.TrimEnd("/")
$backendRoot = Split-Path -Parent $PSScriptRoot
Set-Location $backendRoot

Write-Host "Writing .env for deploy (INTELLIGENCE_ENGINE_URL)..." -ForegroundColor Cyan
$envLines = @(
    "INTELLIGENCE_ENGINE_URL=$EngineUrl"
)
$envPath = Join-Path $backendRoot ".env"
if (Test-Path $envPath) {
    $existing = Get-Content $envPath | Where-Object { $_ -notmatch '^INTELLIGENCE_ENGINE_URL=' }
    $envLines = $existing + $envLines
}
$envLines | Set-Content -Path $envPath -Encoding utf8

Write-Host "Setting Firebase Functions runtime config (gen1)..." -ForegroundColor Cyan
firebase use $Project
firebase functions:config:set intelligence.engine_url="$EngineUrl"

if ($OpenAiKey) {
    Write-Host "Setting OpenAI key in Functions config (for coach + optional Whisper on ML service)..." -ForegroundColor Cyan
    firebase functions:config:set openai.key="$OpenAiKey"
}

Write-Host ""
Write-Host "Deploying functions (.env + runtime config)..." -ForegroundColor Yellow
firebase deploy --only functions

Write-Host ""
Write-Host "Done. Engine URL: $EngineUrl" -ForegroundColor Green
Write-Host "Verify Firebase API (replace TOKEN with Firebase ID token):" -ForegroundColor Cyan
Write-Host "  curl https://us-central1-virtuomate.cloudfunctions.net/api/health"
Write-Host ""
Write-Host "After login, test assessment:" -ForegroundColor Cyan
Write-Host '  POST https://us-central1-virtuomate.cloudfunctions.net/api/ai/analyze-text'
Write-Host '  Authorization: Bearer <firebase-id-token>'
Write-Host '  Body: {"text":"I led a team and increased revenue by 20 percent.","sessionType":"Interview"}'
