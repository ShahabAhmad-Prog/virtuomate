# One-time: route Gradle, Pub, Android SDK, and AVDs to D:\Virtomate\dev-cache
$ErrorActionPreference = 'Stop'

$DevRoot = 'D:\Virtomate\dev-cache'
$GradleHome = Join-Path $DevRoot '.gradle'
$PubCache = Join-Path $DevRoot 'pub-cache'
$AndroidSdk = Join-Path $DevRoot 'Android\Sdk'
# Parent folder for .android\avd (ANDROID_SDK_HOME must NOT be .android itself)
$AndroidSdkHome = $DevRoot
$AndroidDotFolder = Join-Path $DevRoot '.android'
$TempDir = Join-Path $DevRoot 'temp'

@($DevRoot, $GradleHome, $PubCache, $AndroidSdk, $AndroidDotFolder, $TempDir) | ForEach-Object {
  New-Item -ItemType Directory -Force -Path $_ | Out-Null
}

function Set-UserEnv([string]$Name, [string]$Value) {
  [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
  Set-Item -Path "Env:$Name" -Value $Value
  Write-Host "  $Name = $Value"
}

Write-Host "`n=== User environment (permanent) ===" -ForegroundColor Cyan
Set-UserEnv 'GRADLE_USER_HOME' $GradleHome
Set-UserEnv 'PUB_CACHE' $PubCache
Set-UserEnv 'ANDROID_HOME' $AndroidSdk
Set-UserEnv 'ANDROID_SDK_ROOT' $AndroidSdk
Set-UserEnv 'ANDROID_SDK_HOME' $AndroidSdkHome

$OldSdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$OldGradle = Join-Path $env:USERPROFILE '.gradle'
$OldPub = Join-Path $env:LOCALAPPDATA 'Pub\Cache'
$OldAndroid = Join-Path $env:USERPROFILE '.android'

# Migrate Android SDK from C if D is empty (close Android Emulator first for a full MOVE)
if ((Test-Path $OldSdk) -and -not (Test-Path (Join-Path $AndroidSdk 'platforms'))) {
  Write-Host "`n=== Copying Android SDK to D: (close emulator first to free C: later) ===" -ForegroundColor Yellow
  & robocopy $OldSdk $AndroidSdk /E /COPY:DAT /NFL /NDL /NJH /NJS /nc /ns /np
  if ($LASTEXITCODE -ge 8) { throw "SDK copy failed (robocopy exit $LASTEXITCODE)" }
  Write-Host "SDK copied to $AndroidSdk (run cleanup-c-drive-smoke.ps1 after closing emulator)"
}

# Migrate AVD folder
if ((Test-Path $OldAndroid) -and -not (Test-Path (Join-Path $AndroidDotFolder 'avd'))) {
  Write-Host "`n=== Migrating .android (AVDs) to D: ===" -ForegroundColor Yellow
  & robocopy $OldAndroid $AndroidDotFolder /E /MOVE /NFL /NDL /NJH /NJS /nc /ns /np
  if ($LASTEXITCODE -ge 8) { Write-Host "AVD migration warning: robocopy $LASTEXITCODE" -ForegroundColor Yellow }
}

# Migrate existing Gradle cache to D (optional merge)
if ((Test-Path $OldGradle) -and (Test-Path (Join-Path $OldGradle 'caches'))) {
  Write-Host "`n=== Copying Gradle cache to D: (then C copy removed by cleanup script) ===" -ForegroundColor Yellow
  & robocopy (Join-Path $OldGradle 'caches') (Join-Path $GradleHome 'caches') /E /NFL /NDL /NJH /NJS /nc /ns /np
}

# Point Flutter android/local.properties at D SDK
$FlutterRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$LocalProps = Join-Path $FlutterRoot 'android\local.properties'
$sdkDir = $AndroidSdk -replace '\\', '\\'
if (Test-Path $LocalProps) {
  $content = Get-Content $LocalProps -Raw
  $content = $content -replace 'sdk\.dir=.*', "sdk.dir=$sdkDir"
  if ($content -notmatch 'sdk\.dir=') { $content += "`nsdk.dir=$sdkDir" }
  Set-Content -Path $LocalProps -Value $content.TrimEnd() -Encoding utf8
  Write-Host "`nUpdated android/local.properties -> D: SDK"
}

# Project Gradle: build cache on D
$GradleProps = Join-Path $FlutterRoot 'android\gradle.properties'
$extra = @"

# VirtuoMate: keep Gradle caches on D: (see GRADLE_USER_HOME)
org.gradle.caching=true
org.gradle.parallel=true
"@
if (-not (Select-String -Path $GradleProps -Pattern 'org.gradle.caching' -Quiet)) {
  Add-Content -Path $GradleProps -Value $extra
}

Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Close and reopen PowerShell / Cursor so new env vars apply."
Write-Host "Then run: .\scripts\cleanup-c-drive-smoke.ps1"
