# Step 1 - Add Gemini API key to .env (FYP demo)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$envFile = Join-Path $Root ".env"

if (-not (Test-Path $envFile)) {
    Copy-Item (Join-Path $Root ".env.example") $envFile
    Write-Host "Created .env from .env.example" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== STEP 1: Gemini API key ===" -ForegroundColor Cyan
Write-Host "Get key from: https://aistudio.google.com/apikey" -ForegroundColor White
Write-Host "Valid keys: AIza... or AQ.... (new Google AI Studio format)" -ForegroundColor Yellow
Write-Host ""
$key = Read-Host "Paste your GEMINI_API_KEY"
$key = $key.Trim()
if (-not $key) { throw "No key entered." }
if ($key -notmatch '^(AIza|AQ\.)') {
    throw "Invalid key. Create one at https://aistudio.google.com/apikey (AIza or AQ. prefix)."
}

$lines = @(Get-Content $envFile | Where-Object {
    $_ -notmatch '^GEMINI_API_KEY=' -and $_ -notmatch '^AI_PROVIDER='
})
$lines += "GEMINI_API_KEY=$key"
$lines += "AI_PROVIDER=gemini"
$lines | Set-Content -Path $envFile -Encoding utf8

Write-Host "Testing key against Gemini API..." -ForegroundColor Cyan
Set-Location $Root
node (Join-Path $Root "scripts\test-gemini-key.js")
if ($LASTEXITCODE -ne 0) {
    throw "Gemini rejected this key. Create a new one at Google AI Studio."
}

Write-Host "Saved .env successfully." -ForegroundColor Green
Write-Host "Next run: .\scripts\fyp-demo-step2-deploy.ps1" -ForegroundColor Green
