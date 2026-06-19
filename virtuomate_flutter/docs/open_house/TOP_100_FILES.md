# VirtuoMate — Top 100 Important Files

## Tier 1 — Must Know (Explain Confidently)

| # | File | Why Important | If Removed | Evaluator May Ask |
|---|------|---------------|------------|-------------------|
| 1 | `lib/main.dart` | App entry | App won't start | "Where does app begin?" |
| 2 | `lib/ui/app.dart` | Bootstrap, routes, deps wiring | No navigation, no Firebase | "How are dependencies injected?" |
| 3 | `lib/ui/virtuomate_scope.dart` | All app state | UI has no data/actions | "How is state managed?" |
| 4 | `lib/services/app_service.dart` | Business logic hub | No sessions, no coach | "Where is business logic?" |
| 5 | `lib/data/api_app_repository.dart` | REST persistence | Production data broken | "How does app talk to backend?" |
| 6 | `lib/network/api_client.dart` | HTTP + auth token | API calls fail | "How is API secured?" |
| 7 | `lib/intelligence/api_coach_engine.dart` | Gemini coach calls | No live AI | "Where is AI integrated?" |
| 8 | `backend/src/app.js` | All API routes | No backend | "Show me your API" |
| 9 | `backend/src/services/gemini.service.js` | Gemini prompts | No AI responses | "Where are prompts?" |
| 10 | `backend/firestore.rules` | Security | Data vulnerable | "How do you secure Firestore?" |

## Tier 2 — Core Features

| # | File | Purpose |
|---|------|---------|
| 11 | `lib/config/app_config.dart` | Compile-time flags (Firebase, API URL) |
| 12 | `lib/auth/firebase_auth_gateway.dart` | Login, register, Google, demo |
| 13 | `lib/data/firebase_app_repository.dart` | Direct Firestore mode |
| 14 | `lib/data/app_repository.dart` | Repository interface + in-memory |
| 15 | `lib/core/models.dart` | UserProfile, SessionRecord, preferences |
| 16 | `lib/core/coaching_assessment.dart` | Parse AI scores |
| 17 | `lib/core/avatar_emotion.dart` | Map Gemini emotion → UI |
| 18 | `lib/ui/screens/dashboard_screen.dart` | Main hub |
| 19 | `lib/ui/screens/session_screen.dart` | Core coaching UX |
| 20 | `lib/ui/screens/coach_chat_screen.dart` | Multi-turn chat |
| 21 | `lib/ui/shared/avatar_presence.dart` | Coach avatar widget |
| 22 | `lib/services/tts_speaker.dart` | Text-to-speech |
| 23 | `lib/services/storage_service.dart` | Avatar cloud upload |
| 24 | `lib/firebase_options.dart` | Firebase project config |
| 25 | `backend/src/middleware/auth.js` | Token verification |

## Tier 3 — Feature Screens

| # | File | Feature |
|---|------|---------|
| 26 | `voice_active_screen.dart` | Voice coaching |
| 27 | `interview_screen.dart` | Mock interview |
| 28 | `role_play_screen.dart` | Role play |
| 29 | `presentation_screen.dart` | Presentation practice |
| 30 | `avatar_screen.dart` | Avatar builder |
| 31 | `video_cv_wizard_screen.dart` | Video CV form |
| 32 | `video_cv_preview_screen.dart` | Video render |
| 33 | `analytics_screen.dart` | Stats |
| 34 | `settings_screen.dart` | Settings/i18n |
| 35 | `premium_screen.dart` | Subscriptions |
| 36 | `auth_screens.dart` | Login/register/welcome |
| 37 | `admin_screens.dart` | Admin panel |

## Tier 4 — Supporting Services

| # | File | Purpose |
|---|------|---------|
| 38 | `chat_service.dart` | Firestore chat sync |
| 39 | `video_cv_render_service.dart` | Cloud video jobs |
| 40 | `profile_sync_service.dart` | API mode polling |
| 41 | `neural_connectivity_service.dart` | /health status |
| 42 | `on_device_avatar_stylizer.dart` | Offline cartoon |
| 43 | `locale_storage.dart` | Language persistence |
| 44 | `coach.service.js` | Coach orchestration |
| 45 | `assessment.service.js` | Assessment pipeline |
| 46 | `video_cv_render.service.js` | FFmpeg render |
| 47 | `avatar_vroid.service.js` | Gemini avatar images |

## Tier 5 — UI/Theme/Utils

| # | File | Purpose |
|---|------|---------|
| 48 | `virtuomate_mvp_theme.dart` | Design tokens |
| 49 | `mvp_shell.dart` | Page wrapper |
| 50 | `mvp_widgets.dart` | VButton, VCard |
| 51 | `app_text.dart` | EN/Urdu strings |
| 52 | `routes.dart` | Route constants |
| 53 | `form_validators.dart` | Input validation |
| 54 | `responsive.dart` | Breakpoints |
| 55 | `neural_connectivity_card.dart` | Health UI |

## Tier 6 — Tests

| # | File | Tests |
|---|------|-------|
| 56 | `test/coaching_assessment_test.dart` | JSON parsing |
| 57 | `test/avatar_emotion_test.dart` | Emotion mapping |
| 58 | `integration_test/smoke_test.dart` | E2E demo login |

## Tier 7–100 — Remaining lib/ files (Quick Reference)

| File | One-line purpose |
|------|------------------|
| `achievements.dart` | Achievement definitions |
| `avatar_customization.dart` | Persona/tone catalogs |
| `voice_profile_codec.dart` | gender\|tone encoding |
| `neural_connectivity.dart` | Health model |
| `auth_gateway.dart` | Auth interface |
| `google_auth_helper.dart` | Google OAuth |
| `demo_account_config.dart` | Demo credentials |
| `google_oauth_config.dart` | OAuth client IDs |
| `coach_engine.dart` | Mock coach |
| `subscription_gateway.dart` | Premium interface |
| `api_subscription_gateway.dart` | Stripe API |
| `firebase_bootstrap.dart` | Firebase.init |
| `connection_error.dart` | Network errors |
| `api_error_message.dart` | API error parsing |
| `cartoon_filter_fallback.dart` | CPU cartoon filter |
| `cloud_download_service.dart` | Download videos |
| `video_cv_export_service.dart` | Local HTML export |
| `tts_voice_picker.dart` | System TTS voice |
| `startup_health.dart` | Boot health check |
| `admin_api_service.dart` | Admin REST |
| `virtuomate_runtime.dart` | Runtime flags widget |
| `virtuomate_bindings.dart` | Export barrel |
| `achievement_feedback.dart` | Unlock toasts |
| `avatar_coach_view.dart` | Avatar rendering |
| `profile_avatar_thumbnail.dart` | Profile photo |
| `speech_capture.dart` | STT wrapper |
| `typing_indicator.dart` | Chat dots |
| `ui_helpers.dart` | Badges, bars |
| `virtuomate_logo.dart` | Brand logo |
| `voice_sync_diagnostic_card.dart` | Voice debug UI |
| `coach_tone_selector.dart` | Tone picker |
| `avatar_rive_overlay.dart` | Optional Rive layer |
| `feedback_screen.dart` | Post-session feedback |
| `achievements_screen.dart` | Achievement list |
| `user_config_screen.dart` | Edit profile |
| `voice_session_screen.dart` | Mic check |
| `splash_screen.dart` | Splash widget (unused route) |
| `splash_screen.dart` | Brand splash |
| `index.js` | Cloud Function export |
| `config.js` | Backend env config |
| `storage.rules` | Storage security |
| `firestore.indexes.json` | DB indexes |
| `pubspec.yaml` | Flutter dependencies |
| `build-release-android.ps1` | Release build script |
| `google-services.json` | Android Firebase config |

---

## How to Explain Any File in Viva

**Template:** "This file is in [layer]. It [does X]. It's called by [Y] when [user action]. It depends on [Z]. Without it, [consequence]."

**Example — api_client.dart:**
> "This is in the network layer. It wraps HTTP calls and attaches the Firebase ID token to every request. AppService and repositories use it when USE_BACKEND_API is true. Without it, the app couldn't reach our Cloud Functions securely."
