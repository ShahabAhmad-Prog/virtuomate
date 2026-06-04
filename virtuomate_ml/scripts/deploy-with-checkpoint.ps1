# Deploy Cloud Run with a fully trained local checkpoint (after train-full.ps1)
param(
    [string]$Project = "virtuomate",
    [string]$Region = "us-central1",
    [string]$Service = "virtuomate-intelligence",
    [string]$OpenAiKey = "",
    [string]$BackendEnv = "D:\Virtomate Project\virtuomate_backend_firebase\.env"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$ckpt = Join-Path $Root "models\checkpoints\best\config.json"
if (-not (Test-Path $ckpt)) {
    throw "No checkpoint at models\checkpoints\best. Run .\scripts\train-full.ps1 first."
}

function Resolve-Gcloud {
    $cmd = Get-Command gcloud -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $p = "$env:ProgramFiles\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
    if (Test-Path $p) { return $p }
    throw "gcloud not found."
}

if (-not $OpenAiKey -and (Test-Path $BackendEnv)) {
    Get-Content $BackendEnv | ForEach-Object {
        if ($_ -match '^OPENAI_API_KEY=(.+)$') { $script:OpenAiKey = $matches[1].Trim() }
    }
}

$gcloud = Resolve-Gcloud
& $gcloud config set project $Project

Copy-Item -Path (Join-Path $Root "Dockerfile.checkpoint") -Destination (Join-Path $Root "Dockerfile") -Force

$envVars = "CORS_ORIGIN=*"
if ($OpenAiKey) { $envVars += ",OPENAI_API_KEY=$OpenAiKey" }

Write-Host "Deploying $Service with trained checkpoint..." -ForegroundColor Cyan
& $gcloud run deploy $Service `
    --source $Root `
    --region $Region `
    --allow-unauthenticated `
    --memory 2Gi `
    --cpu 2 `
    --timeout 300 `
    --set-env-vars $envVars

$url = & $gcloud run services describe $Service --region $Region --format "value(status.url)"
Write-Host "Cloud Run URL: $url" -ForegroundColor Green
Write-Host "Verify: curl $url/health" -ForegroundColor Yellow
