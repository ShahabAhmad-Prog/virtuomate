# VirtuoMate — debug run with Firebase + API + Google Sign-In
Set-Location (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot 'env-d-drive.ps1')
flutter run `
  --dart-define=USE_FIREBASE=true `
  --dart-define=USE_BACKEND_API=true `
  --dart-define=GOOGLE_WEB_CLIENT_ID=671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com
