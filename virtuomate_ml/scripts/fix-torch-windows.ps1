# Fix PyTorch WinError 1114 (c10.dll) on Windows — use stable CPU wheels
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$py = Join-Path $Root ".venv\Scripts\python.exe"
if (-not (Test-Path $py)) {
    throw "No .venv found. Run: python -m venv .venv; .\.venv\Scripts\pip install -r requirements.txt"
}

function Invoke-Pip {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Args)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & $py -m pip @Args 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            Write-Host $_.Exception.Message
        } else {
            Write-Host $_
        }
    }
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0) {
        throw "pip failed (exit $code): pip $($Args -join ' ')"
    }
}

Write-Host "Removing old torch packages (if any)..." -ForegroundColor Yellow
$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& $py -m pip uninstall -y torch torchvision torchaudio 2>&1 | Out-Host
$ErrorActionPreference = $prev

Write-Host "Installing PyTorch 2.5.1 (CPU, Windows)..." -ForegroundColor Cyan
Invoke-Pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 `
    --index-url https://download.pytorch.org/whl/cpu

Write-Host "Verifying import..." -ForegroundColor Cyan
& $py -c "import torch; print('torch', torch.__version__, 'cuda', torch.cuda.is_available())"
if ($LASTEXITCODE -ne 0) {
    throw "PyTorch still fails to import. Install VC++ Redistributable (x64) and retry."
}

Write-Host "OK. Run training:" -ForegroundColor Green
Write-Host "  .\.venv\Scripts\python.exe -m ml.training.train_multitask --epochs 3 --batch-size 8" -ForegroundColor White
