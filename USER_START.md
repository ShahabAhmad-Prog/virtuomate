# VirtuoMate — Start here (for users & testers)

VirtuoMate is ready to use when these three items are green:

1. **Firebase** project `virtuomate` with **Email/Password** sign-in enabled  
2. **Cloud API** deployed and public  
3. **Flutter app** built in release/production mode  

---

## 1. One-time cloud setup (project owner)

### Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com/) → project **virtuomate**
2. **Authentication** → Sign-in method → enable **Email/Password**
3. **Firestore** → Create database (production mode)
4. **Storage** → Enable default bucket

### Deploy backend (CMD on Windows)

```cmd
D:
cd "D:\Virtomate Project\virtuomate_backend_firebase"
npm install
firebase login
firebase deploy --only functions,firestore:rules,storage
```

### Verify API

Open in browser:

https://us-central1-virtuomate.cloudfunctions.net/api/health

You should see JSON like: `{"ok":true,"backend":"virtuomate-api",...}`

If you see **403 Forbidden**, add **Cloud Functions Invoker** for `allUsers` on function `api` (see `virtuomate_backend_firebase/DEPLOY_FIX.md`).

---

## 2. Run the app (end user)

### Android / Windows desktop

```cmd
D:
cd "D:\Virtomate Project\virtuomate_flutter"
flutter pub get
flutter run --release
```

Release builds automatically use **Firebase + Cloud API**.

### Explicit production flags (optional)

```cmd
flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true --dart-define=BACKEND_BASE_URL=https://us-central1-virtuomate.cloudfunctions.net/api
```

---

## 3. How to use the app

1. Open app → **Initialize System** → **Register** with your email and password (min 6 characters)
2. Complete **Avatar** setup (style, voice, optional photo)
3. Try modules from the **Dashboard**:
   - **Conversation** / **Voice** — speak or type; AI coach responds
   - **Interview** — 3-step mission with progress saved
   - **Presentation** — speak each slide before advancing
   - **Role Play** — tap **Start Role-play**, then respond
   - **Video CV** — wizard → preview → **Export** (shares HTML/script file)
4. **Premium** — activates subscription (mock payment on server; upgrades your account)
5. **Settings** — notifications, password, privacy, export/delete account

### Quick demo (no registration form)

On login screen, tap **Quick demo** to sign in with a preconfigured demo account.

### Admin (optional)

Sign in with an email containing `admin` or `admin@virtuomate.app` to see **Admin** screens.

---

## 4. Troubleshooting

| Problem | Fix |
|--------|-----|
| App says “could not start cloud services” | Deploy functions; check `/health` URL; retry in app |
| Login fails | Enable Email/Password in Firebase Auth |
| API 403 on health | Set function `api` to public invoker (DEPLOY_FIX.md) |
| Microphone not working | Allow mic permission; use real device (not all emulators support STT) |
| Premium not applied | Use production mode with API; open Premium again after login |

---

## 5. Support

- Full developer guide: `README.md`
- Deploy issues: `virtuomate_backend_firebase/DEPLOY_FIX.md`
