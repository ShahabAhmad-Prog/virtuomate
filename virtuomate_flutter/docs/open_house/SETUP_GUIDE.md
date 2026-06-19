# VirtuoMate — Setup Guide (From Scratch)

## Prerequisites

- Windows 10/11
- Flutter SDK 3.11+ (`flutter doctor`)
- Android Studio + Android SDK
- VS Code or Cursor (optional)
- Node.js 18+ (backend)
- Firebase CLI (`npm install -g firebase-tools`)
- Google account for Firebase & Gemini

---

## 1. Flutter Setup

```powershell
# Verify installation
flutter doctor -v

# Clone/open project
cd "D:\Virtomate Project\virtuomate_flutter"
flutter pub get
```

---

## 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) → project **virtuomate**
2. Enable **Authentication:** Email/Password, Google
3. Create **Firestore** database (production mode → deploy rules from repo)
4. Enable **Storage**
5. Android app registered → `google-services.json` in `android/app/`
6. `lib/firebase_options.dart` generated via FlutterFire CLI

```powershell
# If regenerating:
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 3. Gemini Setup

1. [Google AI Studio](https://aistudio.google.com/apikey) → Create API key
2. Backend `.env`:
   ```
   GEMINI_API_KEY=your_key_here
   GEMINI_MODEL=gemini-2.5-flash-lite
   AI_PROVIDER=gemini
   ```

---

## 4. Backend Setup

```powershell
cd "D:\Virtomate Project\virtuomate_backend_firebase"
npm install
copy .env.example .env
# Edit .env with GEMINI_API_KEY
npm start
# Runs on http://127.0.0.1:8080
```

Deploy:
```powershell
firebase login
firebase deploy --only functions,firestore:rules,storage
```

---

## 5. Flutter Configuration (Dart Defines)

| Define | Value | Purpose |
|--------|-------|---------|
| USE_FIREBASE | true | Enable Firebase |
| USE_BACKEND_API | true | Live AI coach |
| BACKEND_BASE_URL | production URL or localhost | API endpoint |
| GOOGLE_WEB_CLIENT_ID | OAuth client ID | Google Sign-In |

**Debug localhost (emulator):** Android maps `127.0.0.1` → `10.0.2.2` automatically in `AppConfig`.

---

## 6. Run on Emulator

```powershell
cd virtuomate_flutter
flutter emulators --launch <id>
flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true
```

---

## 7. Build Release APK

```powershell
.\scripts\build-release-android.ps1
```

---

## 8. Google Sign-In (Android)

- SHA-1 fingerprint in Firebase Console
- `GOOGLE_WEB_CLIENT_ID` in build script
- See `docs/GOOGLE_SIGNIN.md`

---

## 9. Demo Account

- Email: `demo@virtuomate.app`
- Backend `POST /auth/demo` creates/resets user
- Tap "Try demo login" on Welcome screen

---

## 10. Troubleshooting

| Issue | Fix |
|-------|-----|
| Gemini blocked | Check billing at AI Studio; see `docs/FIX_GEMINI_BLOCKED.md` |
| Backend unreachable | Verify URL, emulator uses 10.0.2.2:8080 |
| Firebase init fail | Check `google-services.json` and `firebase_options.dart` |
| Google Sign-In fail | Add SHA-1, correct Web Client ID |

---

## Project Structure (Monorepo)

```
D:/Virtomate Project/
├── virtuomate_flutter/          # Flutter app
├── virtuomate_backend_firebase/ # Node API
├── virtuomate_ml/               # Optional ML service
└── virtuomate-mvp/              # UI prototype (Expo)
```
