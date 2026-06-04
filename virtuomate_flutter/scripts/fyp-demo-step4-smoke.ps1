# Step 4 — Quick API smoke checks (run while logged in on device is manual)
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== STEP 4: API smoke (public health) ===" -ForegroundColor Cyan

$base = "https://us-central1-virtuomate.cloudfunctions.net/api"
$h = Invoke-RestMethod -Uri "$base/health" -TimeoutSec 30
Write-Host "[OK] health.ok = $($h.ok)"
Write-Host "     geminiConfigured = $($h.geminiConfigured)"
Write-Host "     aiProvider = $($h.aiProvider)"
if ($h.neuralConnectivity) {
    Write-Host "     neuralConnectivity.percent = $($h.neuralConnectivity.percent)"
}

Write-Host ""
Write-Host "=== Manual checks on device ===" -ForegroundColor Cyan
Write-Host "  [ ] Demo login works"
Write-Host "  [ ] Dashboard opens (no red overflow stripes)"
Write-Host "  [ ] AI Coach Chat — send message, see coach reply + live sync"
Write-Host "  [ ] Interview or Voice — feedback mentions scores"
Write-Host "  [ ] Analytics shows sessions"
Write-Host "  [ ] Settings -> logout"
Write-Host ""
Write-Host "Step 5 optional: avatar cartoon needs OPENAI_API_KEY on backend" -ForegroundColor DarkGray
