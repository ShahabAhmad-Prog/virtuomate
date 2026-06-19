# VirtuoMate — Frontend Documentation

## Overview

VirtuoMate Flutter app (`virtuomate_flutter`) is the client for an AI career coaching platform. It targets Android (iOS-capable) with a dark MVP-themed UI aligned to the original web prototype.

---

## Architecture

**Pattern:** Layered architecture with custom state management.

```
main.dart
  └── VirtuoMateRoot (async bootstrap)
        └── VirtuoMateScope (InheritedNotifier)
              └── VirtuoMateApp (MaterialApp + routes)
                    └── Screens → VirtuoMateScope.of(context)
```

| Layer | Location | Responsibility |
|-------|----------|----------------|
| UI | `lib/ui/screens/`, `lib/ui/shared/` | Widgets, navigation, user input |
| State | `lib/ui/virtuomate_scope.dart` | App-wide reactive state |
| Domain | `lib/services/app_service.dart` | Business rules |
| Data | `lib/data/` | Persistence abstraction |
| Network | `lib/network/` | REST client with auth |
| Auth | `lib/auth/` | Firebase / in-memory auth |
| Intelligence | `lib/intelligence/` | Coach AI interface |
| Core | `lib/core/` | Models, enums, achievements |

**State management:** `VirtuoMateController` extends `ChangeNotifier`. `VirtuoMateScope` extends `InheritedNotifier`. Screens use `VirtuoMateScope.of(context)` and `ListenableBuilder` — **not** Provider, Riverpod, or Bloc.

---

## Folder Structure

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Generated Firebase config
├── auth/                     # Auth gateways (3 files)
├── config/                   # AppConfig, demo account, OAuth IDs
├── core/                     # Domain models & logic (7 files)
├── data/                     # Repository implementations (3 files)
├── external/                 # Subscription gateways (3 files)
├── firebase/                 # Firebase init
├── intelligence/             # Coach engines (2 files)
├── network/                  # HTTP client & errors (3 files)
├── services/                 # Business services (15 files)
├── theme/                    # Design tokens
└── ui/
    ├── app.dart              # Root widget & dependency wiring
    ├── app_text.dart         # i18n EN/Urdu
    ├── routes.dart           # Route constants
    ├── virtuomate_scope.dart # Controller + scope
    ├── mvp/                  # Shell & design system widgets
    ├── screens/              # 22 screens
    └── shared/               # Reusable UI components
```

---

## Screens Reference

| Screen | Route | Purpose | Key Firebase/API |
|--------|-------|---------|------------------|
| WelcomeScreen | `/welcome` | Landing, auth entry | Firebase Auth, demo token API |
| LoginScreen | `/login` | Email login | Firebase Auth |
| RegisterScreen | `/register` | Sign up | Firebase Auth + bootstrap |
| DashboardScreen | `/` (home) | Feature hub | Profile sync, neural health |
| SessionScreen | `/session` | Text/voice coaching | `/ai/coach`, `/sessions` |
| CoachChatScreen | `/coach-chat` | Multi-turn chat | Firestore coachChat, TTS |
| VoiceSessionScreen | `/voice-session` | Mic pre-check | STT permissions |
| VoiceActiveScreen | `/voice-active` | Live voice coaching | `/ai/analyze-speech` |
| InterviewScreen | `/interview` | Mock interview steps | `/ai/analyze-text` |
| PresentationScreen | `/presentation` | Slide practice | `/ai/coach` |
| RolePlayScreen | `/role-play` | Scenario practice | `/ai/coach` |
| AvatarScreen | `/avatar` | Avatar builder | Storage upload, Gemini avatar |
| VideoCvWizardScreen | `/video-cv` | CV form + script | `/video-cv/script` |
| VideoCvPreviewScreen | `/video-cv-preview` | Preview/render | `/video-cv/render-job` |
| FeedbackScreen | `/feedback` | Post-session metrics | Latest session data |
| AnalyticsScreen | `/analytics` | Charts & stats | Local analytics from sessions |
| AchievementsScreen | `/achievements` | Gamification | Local + Firestore prefs |
| PremiumScreen | `/premium` | Subscription | `/payments/subscribe` |
| UserConfigScreen | `/user-config` | Edit profile | PUT `/user/profile` |
| SettingsScreen | `/settings` | Prefs, language, GDPR | Preferences, export/delete |
| AdminUserManagementScreen | `/admin-users` | Admin panel | `/admin/users` |
| AdminTrainingAnalyticsScreen | `/admin-training-analytics` | Admin stats | `/admin/analytics` |

---

## Navigation

- **Home gate:** `_AppHomeGate` — logged in → Dashboard, else Welcome
- **Named routes:** `Navigator.pushNamed(context, AppRoutes.xxx)`
- **Logout:** `pushNamedAndRemoveUntil` → Welcome
- **No Navigator 2.0** — classic imperative routing

---

## Theme & Responsive Design

- **Theme:** `virtuomate_mvp_theme.dart` — `VirtuoMvpColors`, spacing, radii
- **Dark mode only** in production UI
- **High contrast mode** via Settings → accessibility
- **Text scale** 0.9–1.4 via controller preferences
- **Responsive:** `responsive.dart` — breakpoints, horizontal padding, max content width
- **Urdu:** Partial i18n via `AppText.tr()`; LTR layout kept for stability

---

## Reusable Components

| Widget | File | Purpose |
|--------|------|---------|
| AvatarPresence | `avatar_presence.dart` | Coach face with emotions |
| ProfileAvatarThumbnail | `profile_avatar_thumbnail.dart` | User avatar circle |
| NeuralConnectivityCard | `neural_connectivity_card.dart` | AI stack health |
| MvpShell | `mvp_shell.dart` | Page wrapper with gradient |
| VButton, VCard | `mvp_widgets.dart` | Design system |
| SpeechCapture | `speech_capture.dart` | Mic + STT |
| TypingIndicator | `typing_indicator.dart` | Chat loading dots |

---

## Error & Loading States

- **Bootstrap:** "Starting VirtuoMate…" while Firebase/API deps load
- **API errors:** `api_error_message.dart`, `connection_error.dart` → SnackBars
- **Coach fallback banner:** When `provider` ≠ gemini on coach screens
- **Neural card:** Shows API/Gemini layer status from `/health`
- **Form validation:** `form_validators.dart` on auth screens

---

## Dependencies (Key Packages)

| Package | Use |
|---------|-----|
| firebase_core, firebase_auth, cloud_firestore | Firebase |
| google_sign_in | Google OAuth |
| http (via api_client) | REST API |
| flutter_tts, speech_to_text | Voice |
| image_picker, google_mlkit_face_detection | Avatar |
| tflite_flutter | On-device cartoon (optional) |
| rive | Optional avatar overlay |
| shared_preferences | Locale persistence |
| share_plus, path_provider | Export/share |

---

## Setup & Run

```powershell
cd virtuomate_flutter
flutter pub get
flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true
```

See **SETUP_GUIDE.md** and **COMMANDS_GUIDE.md** for full details.

---

## Build Release APK

```powershell
.\scripts\build-release-android.ps1
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Future Improvements

- Complete Urdu translation
- iOS App Store release
- Provider/Riverpod migration (optional)
- Offline-first with local DB (Hive/Drift)
- Push notifications (FCM)
- Widget/integration tests for all screens
