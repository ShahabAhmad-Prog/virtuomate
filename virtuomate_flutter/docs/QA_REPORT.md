# VirtuoMate — QA Report

**Date:** 2026-06-02  
**Scope:** FYP demo path (Firebase + Cloud API + local/Gemini coach)  
**Automated:** `flutter test` (12 tests), `dart analyze lib`, backend `assessment.local.test.js`, `/health` probe

---

## Executive summary

| Area | Result |
|------|--------|
| Unit tests (added) | **12/12 Pass** |
| Static analysis | **0 errors**, 17 infos/warnings |
| Live API health | **Pass** (`ok: true`) |
| Live Gemini | **Fail** (billing / 429) |
| Local coach fallback | **Pass** (paragraph feedback + scores) |
| Device E2E | **Manual required** (emulator/build) |

**Demo readiness:** **Not complete** until device smoke test passes and Gemini billing is fixed (optional for demo if local coach is acceptable).

---

## Unit testing

### Authentication services

**Feature:** Email validation, in-memory register/sign-in, demo email detection  
**Status:** **Pass**  
**Tests:** `test/form_validators_test.dart`, `test/auth_gateway_test.dart`  
**Issues found:** Register previously used sign-in path → “Incorrect email or password” for new users.  
**Fix applied:** `registerWithEmail` / `signInWithEmail` split in `firebase_auth_gateway.dart`, `app_service.dart`, `auth_screens.dart`.  
**Retest:** **Pass** (automated). Firebase E2E: **manual pending**.

### Firestore services (client)

**Feature:** `ChatMessage.fromDoc`, `ChatService` paths `users/{uid}/coachChat`  
**Status:** **Pass** (code review + rules)  
**Issues found:** None in rules; requires signed-in user for writes.  
**Files:** `lib/services/chat_service.dart`, `virtuomate_backend_firebase/firestore.rules`  
**Retest:** Manual — send chat message while logged in.

### Gemini AI service

**Feature:** `generateCoachPackage`, quota detection  
**Status:** **Fail** (live), **Pass** (fallback)  
**Issues found:** `geminiStatus: error`, HTTP 429 prepayment depleted.  
**Fix applied:** `isQuotaError` includes prepayment; coach returns `gemini-quota` + local paragraph feedback.  
**Retest:** **Pass** local coach; **Fail** live Gemini until billing restored.

### Session management

**Feature:** `AppService._completeSession`, repository save  
**Status:** **Pass** (code review)  
**Retest:** Manual — complete interview/conversation, check Analytics count.

### Analytics calculations

**Feature:** `AppService.analytics()` averages  
**Status:** **Pass**  
**Tests:** `test/analytics_test.dart` (avg confidence 70 from 80+60)  
**Retest:** **Pass**

### Emotion / confidence (backend linguistic)

**Feature:** `assessTextLocally`, `featuresToScores`, `emotionFromScores`  
**Status:** **Pass**  
**Tests:** `virtuomate_backend_firebase/test/assessment.local.test.js`  
**Sample:** emotion `confident`, confidence `76`  
**Retest:** **Pass**

### CoachingAssessment JSON (Flutter)

**Feature:** API response parsing  
**Status:** **Pass**  
**Tests:** `test/coaching_assessment_test.dart`  
**Retest:** **Pass**

---

## Integration testing

| Integration | Status | Notes |
|-------------|--------|-------|
| Flutter ↔ Firebase Auth | **Manual** | Requires `USE_FIREBASE=true` on device |
| Flutter ↔ Firestore chat | **Manual** | Stream on `coachChat`; rules deployed |
| Flutter ↔ Cloud API `/ai/coach` | **Pass** | Auth header required; local fallback works |
| Flutter ↔ Gemini | **Fail** | Billing; fallback OK |
| Flutter ↔ Storage | **Not verified** | Video CV paths not automated |
| Realtime updates | **Manual** | `ChatService.watchMessages()` |
| Session persistence | **Manual** | API repository hydrate |

---

## Functional testing (manual checklist)

Run on emulator with:

```powershell
.\scripts\fyp-demo-step3-run.ps1
```

| Flow | Status | Notes |
|------|--------|-------|
| Register | **Manual** | Use new email, 6+ char password |
| Login | **Manual** | |
| Logout | **Manual** | Settings |
| Password reset | **Manual** | Firebase email enabled |
| Session persistence | **Manual** | Kill app, reopen |
| Dashboard load | **Manual** | Watch overflow stripes |
| AI Coach send/receive | **Manual** | Expect paragraph + scores |
| Firestore chat sync | **Manual** | Two tabs/devices optional |
| Interview / Voice feedback | **Manual** | |
| Analytics charts/stats | **Manual** | After sessions |
| Settings profile | **Manual** | |
| Video CV wizard | **Manual** | |
| Avatar module | **Manual** | |
| Demo login | **Manual** | `Try demo login` |

---

## UI testing

| Check | Status | Notes |
|-------|--------|-------|
| Dashboard `Expanded` in `Wrap` | **Fixed** | `_miniStatBox` |
| Coach chat keyboard | **Partial fix** | `use_build_context_synchronously` info remains |
| Tablet / landscape | **Not verified** | |
| Pixel overflow | **Manual** | Run with debug overflow banner |

---

## Performance testing

| Target | Status |
|--------|--------|
| App launch < 3s | **Not measured** |
| Screen transition < 1s | **Not measured** |
| Chat response speed | **Pass** local (~30s with Gemini attempt); faster when billing fixed |
| Memory leaks | **Not measured** |
| Unnecessary rebuilds | **Not measured** |

---

## Regression testing

| Area | Status |
|------|--------|
| Auth compile | **Pass** after `signInOrRegister` removed from interface |
| Gradle build | **At risk** — corrupted cache; use `fix-gradle-cache.ps1` |
| Navigation | **Manual** |
| Firebase | **Pass** health |
| Chat | **Manual** |
| Analytics | **Pass** unit |

---

## Demo readiness checklist

| Item | Status |
|------|--------|
| App launches | **Manual** |
| Login | **Manual** |
| Signup | **Pass** (code), **Manual** (device) |
| Session persistence | **Manual** |
| Firestore persistence | **Manual** |
| Realtime chat | **Manual** |
| Gemini coaching | **Fail** live / **Pass** fallback |
| Confidence / emotion analysis | **Pass** (local) |
| Analytics | **Pass** (unit) / **Manual** (UI) |
| Avatar | **Manual** |
| Video CV | **Manual** |
| Settings | **Manual** |
| No crashes | **Manual** |
| No overflow | **Manual** |
| No console errors | **Manual** |
| Professional UI | **Subjective** |

---

## How to re-run automated tests

```powershell
# Flutter (12 tests)
cd "D:\Virtomate Project\virtuomate_flutter"
flutter test

# Backend linguistic assessment
cd "D:\Virtomate Project\virtuomate_backend_firebase"
node test/assessment.local.test.js

# API health
curl https://us-central1-virtuomate.cloudfunctions.net/api/health
```

---

## Completion rule

**Project is NOT declared complete.** Critical path for FYP demo:

1. **Device smoke test** — `fyp-demo-step4-smoke.ps1` + manual checklist above.  
2. **Stable Android build** — `fix-gradle-cache.ps1` if Gradle metadata errors return.  
3. **Gemini (optional)** — restore AI Studio billing for live AI branding.
