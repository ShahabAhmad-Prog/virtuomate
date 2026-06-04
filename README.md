# VirtuoMate — Production Deployment Guide

**End users:** see [USER_START.md](USER_START.md) for simple setup and how to use the app.

VirtuoMate is an AI-powered coaching platform with:
- **Flutter mobile app** (`virtuomate_flutter/`) — Android, iOS, Web, Desktop
- **Firebase backend** (`virtuomate_backend_firebase/`) — Cloud Functions API, Firestore, Storage
- **Expo UI reference** (`virtuomate-mvp/`) — design prototype only

## Architecture

```
Flutter App  →  Firebase Auth (email/password)
            →  Cloud Functions REST API (/api/*)
            →  Firestore (users, sessions)
            →  Cloud Storage (avatars, video CV)
            →  OpenAI GPT (optional, for coaching)
```

## Prerequisites

- Flutter SDK 3.11+
- Node.js 20+
- Firebase CLI (`npm i -g firebase-tools`)
- Firebase project: **virtuomate** (or update configs)
- (Optional) OpenAI API key for GPT-powered coaching

## 1. Backend setup

```bash
cd virtuomate_backend_firebase
npm install
cp .env.example .env
# Edit .env — add OPENAI_API_KEY for real AI coaching
```

### Local API server

```bash
# Uses Application Default Credentials or GOOGLE_APPLICATION_CREDENTIALS
npm start
# API: http://127.0.0.1:8080/health
```

### Deploy to Firebase

```bash
firebase login
firebase deploy --only functions,firestore:rules,firestore:indexes,storage
```

Production API URL:
`https://us-central1-virtuomate.cloudfunctions.net/api`

### Enable Firebase services

1. **Authentication** → Email/Password
2. **Firestore** → production mode + deploy rules/indexes
3. **Storage** → deploy storage rules
4. **Functions** → Node.js 20 runtime

### Admin access

Set custom claim `admin: true` on admin users, or use emails listed in `ADMIN_EMAILS` env var (default: `admin@virtuomate.app`).

## 2. Flutter app setup

```bash
cd virtuomate_flutter
flutter pub get
```

### Development (mock mode — no Firebase)

```bash
flutter run
```

### Development (Firebase + local API)

```bash
# Terminal 1: backend
cd ../virtuomate_backend_firebase && npm start

# Terminal 2: app
flutter run \
  --dart-define=USE_FIREBASE=true \
  --dart-define=USE_BACKEND_API=true \
  --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8080
```

Use `http://127.0.0.1:8080` on iOS simulator; `http://10.0.2.2:8080` on Android emulator.

### Production release build

```bash
flutter build apk --release \
  --dart-define=USE_FIREBASE=true \
  --dart-define=USE_BACKEND_API=true \
  --dart-define=BACKEND_BASE_URL=https://us-central1-virtuomate.cloudfunctions.net/api

flutter build ios --release \
  --dart-define=USE_FIREBASE=true \
  --dart-define=USE_BACKEND_API=true \
  --dart-define=BACKEND_BASE_URL=https://us-central1-virtuomate.cloudfunctions.net/api
```

Release builds default to Firebase + API when dart-defines are omitted (`AppConfig` uses `kReleaseMode`).

## 3. Features

| Feature | Status |
|---------|--------|
| Auth (register/login) | Firebase Auth |
| AI Coach (text + voice) | OpenAI or local fallback |
| Interview simulation (3 steps) | Full |
| Presentation practice (5 slides) | Full |
| Role-play scenarios | Full |
| Video CV wizard + preview | Full |
| Avatar customization + cloud upload | Full |
| Premium subscriptions | Mock gateway (Stripe-ready) |
| Neural analytics | Full |
| Admin dashboard | API-backed |
| GDPR export/delete | API-backed |

## 4. Environment variables

### Backend (`.env`)

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | Enables GPT-4 coaching |
| `PAYMENT_MODE` | `mock` or `stripe` |
| `ADMIN_EMAILS` | Comma-separated admin emails |
| `FREE_SESSION_LIMIT` | Free tier cap (default 5) |

### Flutter (dart-define)

| Flag | Description |
|------|-------------|
| `USE_FIREBASE` | Enable Firebase |
| `USE_BACKEND_API` | Use Cloud Functions API |
| `BACKEND_BASE_URL` | API base URL |

## 5. Store release checklist

- [ ] Update `applicationId` / bundle ID from `com.example.*`
- [ ] Configure release signing in `android/app/build.gradle.kts`
- [ ] Add app icons and splash screens
- [ ] Privacy policy URL in store listing
- [ ] Enable Firebase App Check (recommended)
- [ ] Replace mock payments with Stripe/RevenueCat
- [ ] Set up Firebase Crashlytics / Analytics

## 6. Project structure

```
virtuomate_flutter/lib/
  config/          App environment config
  auth/            Auth gateways
  data/            Repositories (memory, Firebase, API)
  intelligence/    AI coach engines
  network/         HTTP client
  services/        App, storage, admin services
  ui/screens/      Feature screens
  ui/mvp/          Design system components

virtuomate_backend_firebase/
  src/app.js       Express routes
  src/services/    AI coach, config
  index.js         Cloud Functions entry
```

## License

Academic / project use — configure commercial licensing before public deployment.
