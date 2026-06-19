# One-time: upload VirtuoMate monorepo to GitHub (uses GitHub CLI).
# Prereq: install GitHub CLI OR use portable gh from a prior agent run.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# winget install does not refresh PATH in an already-open terminal
$ghDir = "${env:ProgramFiles}\GitHub CLI"
if (Test-Path $ghDir) {
  $env:Path = "$ghDir;$env:Path"
}

function Find-Gh {
  $paths = @(
    'gh',
    "$env:ProgramFiles\GitHub CLI\gh.exe",
    "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe"
  )
  $tempGh = Get-ChildItem $env:TEMP -Recurse -Filter gh.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($tempGh) { $paths += $tempGh.FullName }
  foreach ($p in $paths) {
    if ($p -eq 'gh') {
      $cmd = Get-Command gh -ErrorAction SilentlyContinue
      if ($cmd) { return $cmd.Source }
    } elseif (Test-Path $p) { return $p }
  }
  throw 'GitHub CLI (gh) not found. Install: winget install GitHub.cli'
}

$gh = Find-Gh
Write-Host "Using: $gh" -ForegroundColor Cyan

& $gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Host "`nSign in to GitHub (browser opens). In Cursor: Terminal -> Run this script again after login." -ForegroundColor Yellow
  & $gh auth login -h github.com -p https -w
}

$repoName = 'virtuomate'
$owner = (& $gh api user --jq .login).Trim()
Write-Host "GitHub user: $owner" -ForegroundColor Green

if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
  git init -b main
}

if (-not (git rev-parse HEAD 2>$null)) {
  git add .
  git commit -m "Initial VirtuoMate monorepo"
}

$remoteUrl = "https://github.com/$owner/$repoName.git"
if (git remote get-url origin 2>$null) {
  git remote set-url origin $remoteUrl
} else {
  git remote add origin $remoteUrl
}

if (-not (& $gh repo view "$owner/$repoName" 2>$null)) {
  Write-Host "Creating public repo $owner/$repoName ..." -ForegroundColor Cyan
  & $gh repo create $repoName --public --source=. --remote=origin --description "VirtuoMate — AI coaching app (Flutter + Firebase + ML)"
}

Write-Host "Pushing main ..." -ForegroundColor Cyan
git push -u origin main

Write-Host "`nDone: https://github.com/$owner/$repoName" -ForegroundColor Green
