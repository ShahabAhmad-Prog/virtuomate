# Optional Rive coach overlay — place a .riv you author in Rive Editor, or try a sample URL.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "assets\rive"
$outFile = Join-Path $outDir "coach_avatar.riv"

New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Write-Host @"
VirtuoMate expects a custom Rive file:
  assets\rive\coach_avatar.riv
  State machine name: Coach
  Inputs: mouthOpen (number), happy, thinking, speaking (booleans)

Layer 2 sprite animations work WITHOUT this file.
Create your coach in https://rive.app and export here.

"@

if (Test-Path $outFile) {
  Write-Host "Already exists: $outFile"
  exit 0
}

Write-Host "No automatic download configured — add your .riv manually."
exit 1
