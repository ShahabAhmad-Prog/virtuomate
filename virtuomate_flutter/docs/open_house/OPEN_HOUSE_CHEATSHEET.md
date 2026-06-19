# VirtuoMate — Open House Cheat Sheet (Last-Minute Revision)

## One-Line Pitch
**VirtuoMate** is an AI-powered career coaching mobile app that uses **Flutter**, **Firebase**, and **Google Gemini** to deliver conversational coaching, mock interviews, role-play, voice sessions, avatar personalization, and AI-generated Video CVs.

---

## Tech Stack (Memorize)

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.11+, Dart, Material 3 dark theme |
| State | `VirtuoMateController` + `VirtuoMateScope` (InheritedNotifier) |
| Auth | Firebase Auth (Email, Google, Demo custom token) |
| Database | Cloud Firestore |
| Storage | Firebase Cloud Storage |
| Backend API | Node.js Express on Firebase Cloud Functions |
| AI | Google Gemini 2.5 Flash (server-side) + OpenAI fallback |
| Optional ML | `virtuomate_ml` (DeBERTa on Cloud Run) |
| TTS/STT | flutter_tts, speech_to_text |
| Payments | Stripe (optional) or mock premium |

---

## Architecture (30-Second Explanation)

```
User → Flutter UI → VirtuoMateController → AppService → Repository (Firestore OR REST API)
                                                              ↓
                                                    Cloud Functions → Gemini API
                                                              ↓
                                                    Firestore + Storage
```

**Three runtime modes:**
1. **Offline demo** — in-memory auth/data, mock coach
2. **Firebase only** — Firestore realtime, mock coach
3. **Production (release)** — Firebase Auth + REST API + live Gemini coach

---

## Key Folders (Flutter)

| Folder | Purpose |
|--------|---------|
| `lib/ui/screens/` | 22 app screens |
| `lib/ui/virtuomate_scope.dart` | App state controller |
| `lib/services/app_service.dart` | Business logic |
| `lib/data/` | Repository pattern (memory/Firestore/API) |
| `lib/intelligence/` | Coach engine (mock vs API) |
| `lib/network/api_client.dart` | HTTP + Firebase ID token |
| `lib/auth/` | Authentication gateways |
| `lib/core/` | Models, achievements, avatar emotion |

---

## Firebase Collections

```
users/{uid}                    → profile, avatar, preferences, premium
  ├── sessions/{id}            → coaching session history
  ├── coachChat/{id}           → multi-turn chat messages
  ├── assessments/{id}         → AI scores (server write only)
  └── videoCvJobs/{id}         → video render jobs
```

**Security:** Clients cannot set `isPremium`, `videoCvCount` — server-only fields.

---

## Main API Endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /ai/coach` | Gemini coaching feedback |
| `POST /ai/analyze-text` | Text assessment scores |
| `POST /ai/analyze-speech` | Speech assessment |
| `POST /user/bootstrap` | Create/sync user profile |
| `GET /user/profile` | Read profile |
| `POST /sessions` | Save session (free tier limit) |
| `POST /storage/avatar/vroid-from-photo` | Gemini cartoon avatar |
| `POST /video-cv/render-job` | Cloud video CV render |
| `GET /health` | Neural connectivity status |

---

## AI Flow (Explain Confidently)

1. User speaks/types in Session, Interview, Role Play, etc.
2. Flutter calls `VirtuoMateController.completeConversation()` (or similar)
3. `AppService` → `ApiCoachEngine` → `POST /ai/coach` with Firebase Bearer token
4. Backend `gemini.service.js` sends structured prompt → Gemini returns JSON
5. Response: feedback, emotion, confidence, assessment scores, provider=`gemini`
6. Flutter maps emotion → `AvatarEmotionState` → avatar UI updates
7. Session saved to Firestore via API

**Why Gemini?** Multimodal, fast (Flash), good JSON output, Google AI Studio free tier for FYP.

**Fallback:** OpenAI or local templates if quota/billing fails (`provider` ≠ gemini).

---

## Features Checklist

- [x] Login (Email, Google, Demo)
- [x] Dashboard with analytics
- [x] Conversational coaching + chat
- [x] Voice sessions (STT + TTS)
- [x] Mock interview (multi-step)
- [x] Presentation practice
- [x] Role play scenarios
- [x] Avatar builder (photo + on-device cartoon + cloud Gemini)
- [x] Video CV wizard + cloud render
- [x] Achievements & gamification
- [x] Premium/subscription
- [x] EN/Urdu localization (partial)
- [x] Admin user management
- [x] GDPR export + account delete

---

## State Management Answer

> "We use a custom **ChangeNotifier** pattern: `VirtuoMateController` holds app state, exposed via `VirtuoMateScope` (InheritedNotifier). Screens rebuild with `ListenableBuilder`. Business logic stays in `AppService` — UI never talks to Firestore directly."

---

## Why Flutter?

- Single codebase for Android (iOS-ready)
- Fast UI with hot reload during development
- Strong Firebase integration
- Good TTS/STT/camera plugins for voice + avatar features

---

## Why Firebase?

- Auth, Firestore, Storage, Functions in one ecosystem
- Realtime listeners for profile/chat
- Security rules for client/server field separation
- Scales without managing servers (FYP → production path)

---

## Testing Summary

- **7 unit tests** — analytics, auth, avatar emotion, assessment JSON, validators, cartoon filter, logo widget
- **1 integration test** — demo login → dashboard smoke
- **Manual QA** — documented in `docs/QA_REPORT.md`

---

## Run Commands

```powershell
cd "D:\Virtomate Project\virtuomate_flutter"
flutter pub get
flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true
flutter test
.\scripts\build-release-android.ps1
```

---

## Strengths to Highlight

1. **Full-stack** — mobile + cloud + AI, not just a UI mockup
2. **Layered architecture** — Repository pattern, testable services
3. **Graceful degradation** — offline demo, mock coach, API fallbacks
4. **Real AI** — Gemini with structured assessment schema
5. **Production-minded** — security rules, free tier limits, GDPR export
6. **Accessibility** — high contrast, text scale, EN/Urdu

---

## Future Scope (If Asked)

- Full Urdu translation
- iOS release
- Real-time lip sync / VRM avatars
- Push notifications
- Offline coach with on-device LLM
- Team/enterprise dashboards

---

## Common Viva Answers

**Q: Where is Gemini called?**  
A: Server-side only in `virtuomate_backend_firebase/src/services/gemini.service.js`. Flutter never holds the API key.

**Q: How is auth secured?**  
A: Firebase ID tokens on every API request. Backend verifies with `admin.auth().verifyIdToken()`.

**Q: How do you prevent premium hacking?**  
A: `isPremium` is blocked in Firestore rules; only Stripe webhook or admin SDK can set it.

**Q: What if Gemini is down?**  
A: Fallback to OpenAI or local template coach; UI shows banner when `provider` ≠ gemini.

**Q: How many free sessions?**  
A: 20 (`FREE_SESSION_LIMIT` on backend, enforced in `POST /sessions`).

---

## Project Paths

| Component | Path |
|-----------|------|
| Flutter app | `virtuomate_flutter/` |
| Backend | `virtuomate_backend_firebase/` |
| ML engine | `virtuomate_ml/` |
| Production API | `https://us-central1-virtuomate.cloudfunctions.net/api` |
| Firebase project | `virtuomate` |
