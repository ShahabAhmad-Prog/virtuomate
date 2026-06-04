# Install Google Cloud SDK on Windows (required for Cloud Run deploy)
$ErrorActionPreference = "Stop"

function Find-Gcloud {
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

$existing = Find-Gcloud
if ($existing) {
    Write-Host "gcloud already installed: $existing" -ForegroundColor Green
    & $existing --version
    exit 0
}

Write-Host "Installing Google Cloud SDK via winget..." -ForegroundColor Cyan
Write-Host "If prompted, accept the installer and check 'Add to PATH'." -ForegroundColor Yellow
winget install Google.CloudSDK --accept-package-agreements --accept-source-agreements

Write-Host ""
Write-Host "Close this PowerShell window and open a NEW one, then run:" -ForegroundColor Green
Write-Host '  gcloud --version'
Write-Host '  gcloud auth login'
Write-Host '  gcloud config set project virtuomate'
Write-Host ""
Write-Host '  cd "D:\Virtomate Project\virtuomate_ml"'
Write-Host '  .\scripts\deploy-cloud-run.ps1 -AllowPublic'
