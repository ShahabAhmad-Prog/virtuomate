# VirtuoMate ML — Windows setup

PowerShell errors like **`pip` is not recognized** and **`Python was not found`** mean Python is not installed (or not on PATH).

## Option A — Install with winget (recommended)

Run **PowerShell as Administrator**:

```powershell
winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements
```

Close and reopen PowerShell, then verify:

```powershell
python --version
pip --version
```

## Option B — Install from python.org

1. Download **Python 3.12** from https://www.python.org/downloads/windows/
2. Run the installer.
3. Check **“Add python.exe to PATH”** at the bottom of the first screen.
4. Choose **“Install Now”**.

## Disable Microsoft Store aliases (important)

Windows can hijack `python` and send you to the Store:

1. **Settings** → **Apps** → **Advanced app settings** → **App execution aliases**
2. Turn **Off** both **python.exe** and **python3.exe**

Then open a **new** PowerShell window.

## Project setup (after Python works)

```powershell
cd "D:\Virtomate Project\virtuomate_ml"
.\scripts\setup_windows.ps1
```

Or manually:

```powershell
cd "D:\Virtomate Project\virtuomate_ml"
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
python -m ml.api.main
```

Open http://localhost:8090/health

## Training (optional — needs Python + time + disk)

```powershell
.\.venv\Scripts\Activate.ps1
python -m ml.datasets.download_goemotions --max-rows 50000
python -m ml.datasets.prepare_coaching_labels
python -m ml.training.train_multitask
```

## You do not need Python for the Flutter app

The Firebase backend already includes a **linguistic coaching assessor** in Node.js. Python is only for:

- Running the standalone Intelligence API locally
- Training the DeBERTa model

Deploy backend functions as usual; set `INTELLIGENCE_ENGINE_URL` only when Cloud Run ML is running.
