# Deploy VirtuoMate Intelligence Engine to Google Cloud Run (project: virtuomate)
param(
    [string]$Project = "virtuomate",
    [string]$Region = "us-central1",
    [string]$Service = "virtuomate-intelligence",
    [switch]$AllowPublic
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Resolve-Gcloud {
    $cmd = Get-Command gcloud -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $paths = @(
        "$env:ProgramFiles\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
        "$env:ProgramFiles (x86)\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
        "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$gcloud = Resolve-Gcloud
if (-not $gcloud) {
    Write-Host ""
    Write-Host "gcloud (Google Cloud SDK) is not installed or not on PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "Install it, then open a NEW PowerShell window:" -ForegroundColor Yellow
    Write-Host '  cd "D:\Virtomate Project\virtuomate_ml"'
    Write-Host "  .\scripts\install-gcloud.ps1"
    Write-Host ""
    Write-Host "Or download: https://cloud.google.com/sdk/docs/install#windows" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host "Using gcloud: $gcloud" -ForegroundColor DarkGray
Write-Host "Project: $Project  Region: $Region  Service: $Service" -ForegroundColor Cyan

& $gcloud config set project $Project

Write-Host "Enabling APIs (if needed)..." -ForegroundColor Yellow
& $gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com --quiet

if ($AllowPublic) {
    $authFlag = "--allow-unauthenticated"
} else {
    $authFlag = "--no-allow-unauthenticated"
}

Write-Host "Building and deploying Cloud Run (Dockerfile.cloud)..." -ForegroundColor Yellow
Copy-Item -Path (Join-Path $Root "Dockerfile.cloud") -Destination (Join-Path $Root "Dockerfile") -Force

& $gcloud run deploy $Service `
    --source $Root `
    --region $Region `
    $authFlag `
    --memory 1Gi `
    --cpu 1 `
    --timeout 120 `
    --min-instances 0 `
    --max-instances 10 `
    --set-env-vars "CORS_ORIGIN=*"

$url = & $gcloud run services describe $Service --region $Region --format "value(status.url)"

Write-Host ""
Write-Host "Cloud Run URL:" -ForegroundColor Green
Write-Host $url
Write-Host ""
Write-Host "Test health:" -ForegroundColor Cyan
Write-Host ("  curl " + $url + "/health")
Write-Host ""
Write-Host "Next: wire Firebase Functions" -ForegroundColor Yellow
Write-Host '  cd "D:\Virtomate Project\virtuomate_backend_firebase"'
Write-Host ('  .\scripts\wire-intelligence-engine.ps1 -EngineUrl "' + $url + '"')
Write-Host ""

if (-not $AllowPublic) {
    $sa = $Project + "@appspot.gserviceaccount.com"
    Write-Host "Service requires authentication. Grant Cloud Functions invoker:" -ForegroundColor Yellow
    $iamCmd = "gcloud run services add-iam-policy-binding " + $Service + " --region=" + $Region + " --member=serviceAccount:" + $sa + " --role=roles/run.invoker"
    Write-Host ("  " + $iamCmd)
}
