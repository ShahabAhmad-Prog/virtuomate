# VirtuoMate — Testing Report

## Testing Strategy Overview

| Type | Status | Location |
|------|--------|----------|
| Unit tests | ✅ 21 tests | `test/` |
| Widget tests | ✅ 1 test | `test/widget_test.dart` |
| Integration tests | ✅ 1 smoke test | `integration_test/smoke_test.dart` |
| Backend tests | ✅ 1 file | `virtuomate_backend_firebase/test/` |
| Manual QA | ✅ Documented | `docs/QA_REPORT.md`, `docs/DEVICE_SMOKE_RESULTS.md` |
| Performance | ⚠️ Not automated | Manual observation |
| UI golden tests | ❌ Not implemented | Future work |

**Run all Flutter tests:**
```powershell
cd virtuomate_flutter
flutter test
```

---

## Unit Tests

### `test/analytics_test.dart`
- **Tests:** `AppService.analytics()` averages confidence from saved sessions
- **Why:** Validates dashboard/analytics numbers are computed correctly

### `test/auth_gateway_test.dart`
- **Tests:** InMemoryAuthGateway register/sign-in; demo email detection
- **Why:** Auth logic works offline without Firebase

### `test/avatar_emotion_test.dart`
- **Tests:** `resolveAvatarEmotion()` — Gemini labels, speaking/listening overrides
- **Why:** Avatar UI must match AI emotion output

### `test/coaching_assessment_test.dart`
- **Tests:** `CoachingAssessment.fromJson()` snake_case, camelCase, empty JSON
- **Why:** Backend Gemini returns mixed JSON formats

### `test/form_validators_test.dart`
- **Tests:** Email format, password min length 6
- **Why:** Registration/login validation

### `test/on_device_cartoon_test.dart`
- **Tests:** Cartoon filter dimensions, portrait crop square output
- **Why:** On-device avatar pipeline doesn't corrupt images

### `test/widget_test.dart`
- **Tests:** `VirtuoMateLogo.welcome()` renders without error
- **Why:** Basic widget smoke

---

## Integration Tests

### `integration_test/smoke_test.dart`
**Flow:** Launch app → Welcome → Demo login → Dashboard visible

**Markers checked:** "Your AI Coach", "Initialize AI Session", or "Open Coach Chat"

**Run:**
```powershell
flutter test integration_test/smoke_test.dart
# Or on device:
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/smoke_test.dart
```

---

## Backend Tests

### `virtuomate_backend_firebase/test/assessment.local.test.js`
- Local assessment service logic tests
- Run: `cd virtuomate_backend_firebase && npm test`

---

## CI Pipeline

GitHub Actions (`.github/workflows/ci.yml`):
- Backend: `npm run check`
- Flutter: `flutter analyze`, `flutter test`

---

## Manual Testing Performed

Documented in project docs:
- **QA_REPORT.md** — feature checklist
- **DEVICE_SMOKE_RESULTS.md** — Android device launch log
- **CARTOON_E2E_TEST.md** — avatar pipeline
- **FYP_DEMO_NIGHT.md** — demo script

---

## What Is NOT Tested (Be Honest in Viva)

- Full Firebase integration (requires emulator/device)
- Live Gemini API responses (mocked in unit tests)
- Stripe payment flow end-to-end
- Video CV cloud render pipeline
- All 22 screens individually
- Load/performance under 1000+ users

---

## How to Demo Testing to Evaluators

1. Run `flutter test` live — show 22 passing
2. Show `avatar_emotion_test.dart` — proves AI emotion mapping is tested
3. Show `coaching_assessment_test.dart` — proves API JSON parsing is tested
4. Mention CI runs on every push

---

## Future Testing Plan

- Firebase Emulator Suite for integration tests
- Mock `ApiClient` for coach engine tests
- Golden tests for dashboard/settings
- Backend supertest for all `/ai/*` routes
- Performance profiling with Flutter DevTools
