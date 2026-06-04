# Paste AIza key into .env (PowerShell-friendly)
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiKey
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$envFile = Join-Path $Root ".env"
$key = $ApiKey.Trim()

if ($key -notmatch '^(AIza|AQ\.)') {
    throw "Key must start with AIza or AQ. (from https://aistudio.google.com/apikey)."
}

$lines = @(Get-Content $envFile -ErrorAction SilentlyContinue | Where-Object {
    $_ -notmatch '^GEMINI_API_KEY=' -and $_ -notmatch '^AI_PROVIDER='
})
if (-not ($lines | Where-Object { $_ -match '^INTELLIGENCE_ENGINE_URL=' })) {
    $lines = @("INTELLIGENCE_ENGINE_URL=https://virtuomate-intelligence-do3iebspxq-uc.a.run.app") + $lines
}
$lines += "GEMINI_API_KEY=$key"
$lines += "AI_PROVIDER=gemini"
$lines | Set-Content -Path $envFile -Encoding utf8

Set-Location $Root
node (Join-Path $Root "scripts\test-gemini-key.js")
if ($LASTEXITCODE -ne 0) { throw "Gemini rejected this key. Enable Generative Language API in Cloud Library." }

Write-Host "Key saved and verified. Run: .\scripts\fyp-demo-step2-deploy.ps1" -ForegroundColor Green
