# VirtuoMate — Android emulator + local backend on port 8080
# Start backend in another terminal first:
#   cd "D:\Virtomate Project\virtuomate_backend_firebase"
#   npm run dev
Set-Location (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot 'env-d-drive.ps1')
flutter run `
  --dart-define=USE_FIREBASE=true `
  --dart-define=USE_BACKEND_API=true `
  --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8080 `
  --dart-define=GOOGLE_WEB_CLIENT_ID=671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com
