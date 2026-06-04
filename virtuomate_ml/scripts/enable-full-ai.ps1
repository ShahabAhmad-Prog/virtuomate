# Deploy Cloud Run with neural_checkpoint:true + whisper:true
param(
    [string]$Project = "virtuomate",
    [string]$Region = "us-central1",
    [string]$Service = "virtuomate-intelligence",
    [Parameter(Mandatory = $false)]
    [string]$OpenAiKey = "",
    [string]$BackendEnv = "D:\Virtomate Project\virtuomate_backend_firebase\.env"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Resolve-Gcloud {
    $cmd = Get-Command gcloud -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $p = "$env:ProgramFiles\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
    if (Test-Path $p) { return $p }
    throw "gcloud not found. Run scripts/install-gcloud.ps1"
}

if (-not $OpenAiKey -and (Test-Path $BackendEnv)) {
    Get-Content $BackendEnv | ForEach-Object {
        if ($_ -match '^OPENAI_API_KEY=(.+)$') {
            $script:OpenAiKey = $matches[1].Trim()
        }
    }
}
if (-not $OpenAiKey) {
    $secure = Read-Host "Enter OPENAI_API_KEY (required for whisper:true)" -AsSecureString
    $OpenAiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    )
}
if (-not $OpenAiKey) {
    throw "OPENAI_API_KEY is required."
}

Write-Host "Deploying with Dockerfile.neural (trains checkpoint in Cloud Build, 15-25 min)..." -ForegroundColor Yellow
Write-Host "whisper:true requires OPENAI_API_KEY on the service." -ForegroundColor Cyan

$gcloud = Resolve-Gcloud
& $gcloud config set project $Project

Copy-Item -Path (Join-Path $Root "Dockerfile.neural") -Destination (Join-Path $Root "Dockerfile") -Force

$envVars = "CORS_ORIGIN=*,OPENAI_API_KEY=$OpenAiKey"
& $gcloud run deploy $Service `
    --source $Root `
    --region $Region `
    --allow-unauthenticated `
    --memory 2Gi `
    --cpu 2 `
    --timeout 300 `
    --set-env-vars $envVars

$url = & $gcloud run services describe $Service --region $Region --format "value(status.url)"
Write-Host ""
Write-Host "Cloud Run URL: $url" -ForegroundColor Green
Write-Host "Verify:" -ForegroundColor Cyan
Write-Host ("  curl " + $url + "/health")
Write-Host ""
Write-Host 'Expected: "neural_checkpoint": true, "whisper": true' -ForegroundColor Green
Write-Host ""
Write-Host "Update Firebase if needed:" -ForegroundColor Yellow
Write-Host ('  cd "D:\Virtomate Project\virtuomate_backend_firebase"')
Write-Host ('  .\scripts\wire-intelligence-engine.ps1 -EngineUrl "' + $url + '"')
