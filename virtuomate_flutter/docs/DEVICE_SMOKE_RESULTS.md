# Device smoke test results

**Device:** `emulator-5554` (Android 14, API 34)  
**Date:** 2026-06-02  
**Build flags:** `USE_FIREBASE=true`, `USE_BACKEND_API=true`, Google Web Client ID set

## Automated (executed)

| Step | Result | Evidence |
|------|--------|----------|
| API `/health` | **Pass** | `ok: true`, neural 75% |
| `flutter test` (unit) | **Pass** | 12/12 |
| Debug APK build | **Pass** | `app-debug.apk` |
| APK install on emulator | **Pass** | `adb install -r` Success |
| App process launch | **Pass** | No FATAL in logcat; Flutter loaded |
| Integration: demo login → dashboard | **Pass** | `integration_test/smoke_test.dart` ~4 min |

## Manual (not automated this run)

| Step | Status |
|------|--------|
| Register new email | Not run |
| Email/password login | Not run |
| AI Coach Chat send/receive | Not run |
| Firestore realtime sync (2nd client) | Not run |
| Interview / Voice session | Not run |
| Analytics UI | Not run |
| Settings logout | Not run |
| Overflow / UI polish | Not run |

## Re-run

```powershell
cd "D:\Virtomate Project\virtuomate_flutter"
.\scripts\device-smoke-test.ps1
```

Or integration only:

```powershell
flutter test integration_test/smoke_test.dart -d emulator-5554 `
  --dart-define=USE_FIREBASE=true `
  --dart-define=USE_BACKEND_API=true `
  --dart-define=GOOGLE_WEB_CLIENT_ID=671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com
```

## Known limitations

- Live **Gemini** still fails (billing); coach uses **local** fallback on API.
- First build after cache clean takes ~5–15 minutes.
