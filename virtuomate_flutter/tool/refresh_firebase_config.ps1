# Refreshes android/app/google-services.json and ios/Runner/GoogleService-Info.plist
# from the virtuomate Firebase project (requires: firebase login).
$ErrorActionPreference = "Stop"
$backend = Join-Path $PSScriptRoot "..\..\virtuomate_backend_firebase"
$flutterRoot = Join-Path $PSScriptRoot ".."
$androidOut = Join-Path $flutterRoot "android\app\google-services.json"
$iosOut = Join-Path $flutterRoot "ios\Runner\GoogleService-Info.plist"
$androidAppId = "1:671835013493:android:d91e70b9dc7642ab0b133c"
$iosAppId = "1:671835013493:ios:fafa7966712942880b133c"

Push-Location $backend
try {
  firebase apps:sdkconfig ANDROID $androidAppId --project virtuomate | Set-Content -Path $androidOut -Encoding utf8
  firebase apps:sdkconfig IOS $iosAppId --project virtuomate | Set-Content -Path $iosOut -Encoding utf8
  Write-Host "Updated:" $androidOut
  Write-Host "Updated:" $iosOut
} finally {
  Pop-Location
}
