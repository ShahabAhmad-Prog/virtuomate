# Scan common folders that fill C: during Flutter / Android / Node / Cursor work
$ErrorActionPreference = 'SilentlyContinue'

function Get-FolderSizeGB([string]$Path) {
  if (-not (Test-Path $Path)) { return $null }
  $sum = (Get-ChildItem $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum).Sum
  if ($null -eq $sum) { return 0 }
  return [math]::Round($sum / 1GB, 2)
}

Write-Host "`n=== C: drive ===" -ForegroundColor Cyan
$vol = Get-Volume -DriveLetter C
$freeGb = [math]::Round($vol.SizeRemaining / 1GB, 2)
$totalGb = [math]::Round($vol.Size / 1GB, 2)
$usedGb = [math]::Round(($vol.Size - $vol.SizeRemaining) / 1GB, 2)
Write-Host "Used: $usedGb GB  |  Free: $freeGb GB  |  Total: $totalGb GB"

$candidates = @(
  @{ Label = 'Gradle cache (Flutter/Android builds)'; Path = "$env:USERPROFILE\.gradle" },
  @{ Label = 'Android SDK'; Path = "$env:LOCALAPPDATA\Android\Sdk" },
  @{ Label = 'Android AVD emulators'; Path = "$env:USERPROFILE\.android\avd" },
  @{ Label = 'Flutter pub cache'; Path = "$env:LOCALAPPDATA\Pub\Cache" },
  @{ Label = 'Pub cache (alt)'; Path = "$env:APPDATA\Pub\Cache" },
  @{ Label = 'npm cache'; Path = "$env:LOCALAPPDATA\npm-cache" },
  @{ Label = 'Temp'; Path = $env:TEMP },
  @{ Label = 'Cursor (IDE + agent data)'; Path = "$env:USERPROFILE\.cursor" },
  @{ Label = 'Cursor projects cache'; Path = "$env:USERPROFILE\.cursor\projects" },
  @{ Label = 'Android Studio'; Path = "$env:LOCALAPPDATA\Google\AndroidStudio*" },
  @{ Label = 'VirtuoMate Flutter build'; Path = "D:\Virtomate Project\virtuomate_flutter\build" },
  @{ Label = 'Backend node_modules'; Path = "D:\Virtomate Project\virtuomate_backend_firebase\node_modules" },
  @{ Label = 'ML venv / data (if on C)'; Path = "$env:USERPROFILE\.cache" }
)

Write-Host "`n=== Largest dev-related folders ===" -ForegroundColor Cyan
$rows = foreach ($c in $candidates) {
  $resolved = $c.Path
  if ($c.Path -like '*`*') {
    $dirs = Get-Item $c.Path -ErrorAction SilentlyContinue
    if ($dirs) { $resolved = $dirs.FullName } else { continue }
  }
  $gb = Get-FolderSizeGB $resolved
  if ($null -ne $gb -and $gb -gt 0.01) {
    [PSCustomObject]@{ GB = $gb; What = $c.Label; Path = $resolved }
  }
}
$rows | Sort-Object GB -Descending | Format-Table -AutoSize

Write-Host "=== Safe cleanup (run only what you understand) ===" -ForegroundColor Yellow
Write-Host "  flutter clean          (in virtuomate_flutter)"
Write-Host "  flutter pub cache clean"
Write-Host "  npm cache clean --force  (in backend folder)"
Write-Host "  Delete old files in %TEMP%"
Write-Host "  Android Studio -> Settings -> Storage -> wipe caches"
Write-Host "  Remove unused AVDs in Device Manager"
Write-Host "  Gradle: delete C:\Users\YOU\.gradle\caches (re-downloads on next build)"
Write-Host ""
