# Full VirtuoMate DeBERTa training pipeline (Option A)
param(
    [int]$MaxRows = 50000,
    [int]$Epochs = 3,
    [int]$BatchSize = 16
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$py = Join-Path $Root ".venv\Scripts\python.exe"
if (-not (Test-Path $py)) {
    Write-Host "Creating venv and installing requirements..." -ForegroundColor Yellow
    python -m venv .venv
    $py = Join-Path $Root ".venv\Scripts\python.exe"
    & $py -m pip install -r requirements.txt
}

$env:PYTHONIOENCODING = "utf-8"

Write-Host "Checking PyTorch..." -ForegroundColor Cyan
& $py -c "import torch; print('torch', torch.__version__)" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "PyTorch failed to load (WinError 1114). Running fix-torch-windows.ps1 ..." -ForegroundColor Yellow
    & (Join-Path $Root "scripts\fix-torch-windows.ps1")
}

Write-Host "Step 1/3: Download GoEmotions ($MaxRows rows)..." -ForegroundColor Cyan
& $py -m ml.datasets.download_goemotions --max-rows $MaxRows

Write-Host "Step 2/3: Prepare coaching labels..." -ForegroundColor Cyan
& $py -m ml.datasets.prepare_coaching_labels

$data = Join-Path $Root "datasets\processed\coaching_train.jsonl"
if (-not (Test-Path $data)) {
    throw "Missing training data: $data"
}

Write-Host "Step 3/3: Train DeBERTa multi-task ($Epochs epochs)..." -ForegroundColor Cyan
& $py -m ml.training.train_multitask --epochs $Epochs --batch-size $BatchSize

$ckpt = Join-Path $Root "models\checkpoints\best\config.json"
if (-not (Test-Path $ckpt)) {
    throw "Training finished but checkpoint not found at models\checkpoints\best"
}

Write-Host ""
Write-Host "Training complete. Checkpoint: models\checkpoints\best" -ForegroundColor Green
Write-Host "Deploy with: .\scripts\deploy-with-checkpoint.ps1" -ForegroundColor Yellow
