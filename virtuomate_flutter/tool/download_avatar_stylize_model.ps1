# Optional: TFLite portrait model for stronger on-device cartoon (Layer 1).
# NOT required — without it the app uses ML Kit + CPU cartoon filter (offline).

$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "assets\models"
$outFile = Join-Path $outDir "avatar_cartoon.tflite"

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

if (Test-Path $outFile) {
  $len = (Get-Item $outFile).Length
  if ($len -gt 100000) {
    Write-Host "Already installed: $outFile ($len bytes)"
    exit 0
  }
  Remove-Item $outFile -Force
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$urls = @(
  "https://github.com/nicoaugereau/White-box-Cartoonization-tflite/raw/main/model/whitebox_cartoon.tflite",
  "https://raw.githubusercontent.com/nicoaugereau/White-box-Cartoonization-tflite/main/model/whitebox_cartoon.tflite"
)

function Try-Download($Url) {
  $tmp = "$outFile.download"
  if (Test-Path $tmp) { Remove-Item $tmp -Force }

  for ($attempt = 1; $attempt -le 3; $attempt++) {
    Write-Host "  attempt $attempt : $Url"
    try {
      # curl.exe is often more reliable than Invoke-WebRequest on Windows
      $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
      if ($curl) {
        & curl.exe -fL --connect-timeout 30 --max-time 180 -o $tmp $Url 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0 -and (Test-Path $tmp) -and (Get-Item $tmp).Length -gt 100000) {
          Move-Item -Force $tmp $outFile
          return $true
        }
      }

      Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing -TimeoutSec 180
      if ((Test-Path $tmp) -and (Get-Item $tmp).Length -gt 100000) {
        Move-Item -Force $tmp $outFile
        return $true
      }
    } catch {
      Write-Warning $_.Exception.Message
    }
    Start-Sleep -Seconds 2
  }
  if (Test-Path $tmp) { Remove-Item $tmp -Force }
  return $false
}

Write-Host "Downloading optional TFLite model (not required for the app to work)...`n"

$ok = $false
foreach ($url in $urls) {
  Write-Host "Trying $url"
  if (Try-Download $url) {
    $ok = $true
    break
  }
}

if ($ok) {
  Write-Host "`nSuccess: $outFile ($((Get-Item $outFile).Length) bytes)"
  Write-Host "Rebuild the app: flutter run"
  exit 0
}

Write-Host @"

Download failed (network / GitHub). You can still use the app:

  • Avatar Builder → "Create avatar from photo (free, on-device)"
  • Uses ML Kit face crop + CPU cartoon filter — no .tflite file needed

Optional manual install:
  1. Download any portrait cartoon .tflite from GitHub (search: White-box Cartoonization tflite)
  2. Save as: assets\models\avatar_cartoon.tflite
  3. flutter run

"@

exit 0
