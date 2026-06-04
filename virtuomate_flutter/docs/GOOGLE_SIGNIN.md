# Google Sign-In setup (VirtuoMate)

Project: **virtuomate** · Package: `com.example.virtuomate_flutter`

App code uses `google_sign_in` + Firebase Auth (`lib/auth/google_auth_helper.dart`).

## Quick status (repo)

| Item | Status |
|------|--------|
| `android/app/google-services.json` | Refreshed — `oauth_client` populated |
| `ios/Runner/GoogleService-Info.plist` | Refreshed — `CLIENT_ID` + `REVERSED_CLIENT_ID` |
| `ios/Runner/Info.plist` | URL scheme for Google Sign-In added |
| Debug SHA-1 (this machine) | `B9:A0:A9:43:DD:F1:B6:E9:35:24:EF:31:52:2C:0F:15:46:F0:1F:14` |

Re-download configs anytime:

```powershell
cd "D:\Virtomate Project\virtuomate_flutter"
.\tool\refresh_firebase_config.ps1
```

## 1. Enable Google provider (one-time, Console)

1. [Authentication → Sign-in method → Google](https://console.firebase.google.com/project/virtuomate/authentication/providers)
2. **Enable**, set support email, **Save**.

## 2. Android SHA-1

If Google Sign-In fails with `12500` / `developer_error`:

1. [Project settings → Your apps → Android](https://console.firebase.google.com/project/virtuomate/settings/general)
2. Add **SHA-1** (debug + release). Debug on this PC:

   `B9:A0:A9:43:DD:F1:B6:E9:35:24:EF:31:52:2C:0F:15:46:F0:1F:14`

   Regenerate locally:

   ```cmd
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

3. Run `.\tool\refresh_firebase_config.ps1` and confirm `oauth_client` is not `[]` in `google-services.json`.

**OAuth clients (from Firebase):**

- Android: `671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com`
- iOS: `671835013493-51l32nbs1bqah3ms96dbklskvu220k77.apps.googleusercontent.com`

## 3. Web + Android `serverClientId`

Firebase needs the **Web** OAuth client ID for Android id tokens.

1. In Console → **Authentication → Google** → copy **Web client ID** (or [Google Cloud Credentials](https://console.cloud.google.com/apis/credentials?project=virtuomate) → OAuth 2.0 **Web client**).
2. Build/run with:

```bash
flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID.apps.googleusercontent.com
```

Same value is used as `serverClientId` on Android/iOS unless you set `GOOGLE_SERVER_CLIENT_ID`.

## 4. iOS

- `GoogleService-Info.plist` and `Info.plist` URL scheme are configured in the repo.
- Bundle ID: `com.example.virtuomateFlutter`

## 5. Verify

```bash
flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true --dart-define=GOOGLE_WEB_CLIENT_ID=<web-client-id>
```

On **Login** or **Register**, tap **Continue with Google**.

| Symptom | Fix |
|---------|-----|
| `12500` / `developer_error` | Add SHA-1, refresh `google-services.json` |
| `idToken` null / auth fails on Android | Set `GOOGLE_WEB_CLIENT_ID` (Web OAuth client) |
| Web: missing client ID | Set `GOOGLE_WEB_CLIENT_ID` at build time |
| Cancelled | User closed the Google account picker |
