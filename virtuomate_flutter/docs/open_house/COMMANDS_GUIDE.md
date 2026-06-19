# VirtuoMate — Commands Guide

## Flutter Commands

| Command | What it does | When to use |
|---------|--------------|-------------|
| `flutter doctor` | Check SDK, Android toolchain | First setup, debugging env |
| `flutter pub get` | Install dependencies from pubspec.yaml | After clone, after pubspec change |
| `flutter clean` | Delete build cache | Weird build errors |
| `flutter analyze` | Static analysis / lint | Before commit, CI |
| `flutter test` | Run unit/widget tests | Verify code quality |
| `flutter run` | Debug run on device/emulator | Daily development |
| `flutter run --release` | Release mode on device | Performance testing |
| `flutter build apk --release` | Build APK | Distribution |
| `flutter devices` | List connected devices | Before run |
| `flutter emulators` | List emulators | Setup emulator |
| `flutter emulators --launch <id>` | Start emulator | Before run |

### Run with Firebase + API (production-like)

```powershell
flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true --dart-define=GOOGLE_WEB_CLIENT_ID=671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com
```

### Build release (project script)

```powershell
.\scripts\build-release-android.ps1
```

---

## Firebase Commands

| Command | What it does | When to use |
|---------|--------------|-------------|
| `firebase login` | Authenticate CLI | First deploy |
| `firebase projects:list` | List projects | Verify project |
| `firebase use virtuomate` | Select project | Before deploy |
| `firebase deploy --only functions` | Deploy Cloud Functions | Backend update |
| `firebase deploy --only firestore:rules` | Deploy security rules | Rule changes |
| `firebase deploy --only storage` | Deploy storage rules | Storage rule changes |
| `firebase functions:log` | View function logs | Debug production |
| `firebase emulators:start` | Local Firebase emulators | Offline dev |

---

## Backend (Node.js) Commands

| Command | What it does | When to use |
|---------|--------------|-------------|
| `npm install` | Install dependencies | First setup |
| `npm start` | Run local API :8080 | Local backend dev |
| `npm test` | Run backend tests | Verify backend |
| `npm run check` | Lint/check script | CI |

---

## Git Commands

| Command | What it does | When to use |
|---------|--------------|-------------|
| `git clone <url>` | Clone repository | First setup |
| `git pull` | Get latest changes | Sync with team |
| `git status` | See changed files | Before commit |
| `git add .` | Stage changes | Before commit |
| `git commit -m "msg"` | Commit changes | Save work |
| `git push` | Push to remote | Share code |

---

## Android ADB Commands

| Command | What it does |
|---------|--------------|
| `adb devices` | List devices |
| `adb install -r app-release.apk` | Install APK |
| `adb logcat` | View device logs |

---

## Branding Scripts

| Command | What it does |
|---------|--------------|
| `.\scripts\apply-branding.ps1` | Logo, launcher icons, native splash |
| `node tool/copy_logo_assets.js` | Copy logo PNGs |
| `node tool/generate_avatar_assets.js` | Generate avatar template PNGs |

---

## ML Service (Optional)

```powershell
cd virtuomate_ml
.\scripts\deploy-cloud-run.ps1 -AllowPublic
.\scripts\wire-intelligence-engine.ps1 -EngineUrl "https://..."
```
