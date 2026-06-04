# VirtuoMate ML — Windows one-time setup
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Find-Python {
    $pyCmd = Get-Command python -ErrorAction SilentlyContinue
    $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
    $candidates = @(
        $(if ($pyCmd) { $pyCmd.Source }),
        $(if ($pyLauncher) { $pyLauncher.Source }),
        "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
        "C:\Python312\python.exe",
        "C:\Python311\python.exe"
    ) | Where-Object { $_ -and (Test-Path $_) }
    return $candidates | Select-Object -First 1
}

$python = Find-Python
if (-not $python) {
    Write-Host ""
    Write-Host "Python not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Python 3.12 (Admin PowerShell):" -ForegroundColor Yellow
    Write-Host '  winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements'
    Write-Host ""
    Write-Host "Then disable Store aliases: Settings > Apps > App execution aliases > Off python.exe / python3.exe"
    Write-Host "Close PowerShell, open a new window, and run this script again."
    Write-Host ""
    Write-Host "See SETUP_WINDOWS.md for details."
    exit 1
}

Write-Host "Using Python: $python" -ForegroundColor Green
& $python --version

$venv = Join-Path $Root ".venv"
if (-not (Test-Path $venv)) {
    Write-Host "Creating virtual environment..."
    & $python -m venv $venv
}

$venvPython = Join-Path $venv "Scripts\python.exe"
& $venvPython -m pip install --upgrade pip
& $venvPython -m pip install -r (Join-Path $Root "requirements.txt")

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host ""
Write-Host "Activate and start API:" -ForegroundColor Cyan
Write-Host "  .\.venv\Scripts\Activate.ps1"
Write-Host "  python -m ml.api.main"
Write-Host ""
