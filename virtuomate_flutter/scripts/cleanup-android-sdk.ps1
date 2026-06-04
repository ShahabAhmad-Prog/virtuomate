# Remove Android SDK components not required for VirtuoMate (Flutter compileSdk 36, NDK 30)
$ErrorActionPreference = 'Continue'
$sdk = 'C:\Users\SHAHAB\AppData\Local\Android\sdk'
if (-not (Test-Path $sdk)) { throw "SDK not found at $sdk" }

function Remove-SdkTree([string]$Path, [string]$Label) {
  if (-not (Test-Path $Path)) { return 0 }
  $bytes = (Get-ChildItem $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum).Sum
  if ($null -eq $bytes) { $bytes = 0 }
  Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
  $mb = [math]::Round($bytes / 1MB, 0)
  Write-Host "Removed $Label (~${mb} MB): $Path"
  return $bytes
}

$total = 0
Write-Host "VirtuoMate needs: platform android-36, build-tools 35.0.0, NDK 30.0.14904198, system-image android-34 (emulator)" -ForegroundColor Cyan
Write-Host ""

# Extra API platforms (compile uses 36)
$total += Remove-SdkTree (Join-Path $sdk 'platforms\android-34') 'platform 34'
$total += Remove-SdkTree (Join-Path $sdk 'platforms\android-35') 'platform 35'

# Old NDK (app pins 30.0.14904198)
$total += Remove-SdkTree (Join-Path $sdk 'ndk\28.2.13676358') 'NDK 28'

# Optional source trees (not needed to build/run)
$total += Remove-SdkTree (Join-Path $sdk 'sources\android-34') 'sources 34'
$total += Remove-SdkTree (Join-Path $sdk 'sources\android-36') 'sources 36'

# Unused emulator images (AVDs use 34 + 37 only — remove 36 / 36.1)
$total += Remove-SdkTree (Join-Path $sdk 'system-images\android-36') 'system-image 36'
$total += Remove-SdkTree (Join-Path $sdk 'system-images\android-36.1') 'system-image 36.1'

# API 37 image + AVD (saves ~3 GB; use Medium_Phone_2 / API 34 for demo)
$total += Remove-SdkTree (Join-Path $sdk 'system-images\android-37.0') 'system-image 37'
$avd37 = Join-Path $env:USERPROFILE '.android\avd\Medium_Phone.avd'
$ini37 = Join-Path $env:USERPROFILE '.android\avd\Medium_Phone.ini'
if (Test-Path $avd37) { $total += Remove-SdkTree $avd37 'AVD Medium_Phone (API 37)' }
if (Test-Path $ini37) { Remove-Item $ini37 -Force -ErrorAction SilentlyContinue; Write-Host "Removed AVD ini: $ini37" }

$gb = [math]::Round($total / 1GB, 2)
Write-Host "`nFreed ~$gb GB on C:" -ForegroundColor Green
Write-Host "Kept: platform-36, build-tools 35.0.0, NDK 30, system-image android-34, emulator binary, cmdline-tools"
