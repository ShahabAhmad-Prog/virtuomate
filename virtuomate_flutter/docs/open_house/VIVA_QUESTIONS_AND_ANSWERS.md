# VirtuoMate — Viva Questions & Answers (120+)

> Answers based on **actual implementation** in `virtuomate_flutter` and `virtuomate_backend_firebase`.

---

## 1. Project Introduction (12)

**Q1: What is VirtuoMate?**  
A: VirtuoMate is an AI-powered mobile career coaching application built with Flutter and Firebase. It provides conversational coaching, mock interviews, role-play, voice sessions, avatar personalization, Video CV generation, and analytics — powered by Google Gemini on the server.

**Q2: What problem does it solve?**  
A: Professional coaching is expensive and not available 24/7. Students and job seekers lack realistic practice with structured feedback on confidence, clarity, and interview readiness.

**Q3: Who is the target user?**  
A: University students, fresh graduates, and professionals preparing for interviews, presentations, and workplace communication.

**Q4: What makes it different from ChatGPT?**  
A: VirtuoMate is a structured coaching product — not a generic chatbot. It has session types, scoring dimensions, avatar emotions, gamification, analytics, Video CV, and a mobile-first UX designed for career development.

**Q5: Is this a web app or mobile app?**  
A: Primary deliverable is **Android mobile** (Flutter). The architecture supports iOS and web, but FYP focus is APK.

**Q6: What is the project scope for FYP?**  
A: Full-stack: Flutter frontend, Firebase backend, Cloud Functions API, Gemini AI integration, authentication, database, avatar system, and testing — not just a UI prototype.

**Q7: What modules does the app have?**  
A: Auth, Dashboard, Conversational Session, Coach Chat, Voice Session, Interview, Presentation, Role Play, Avatar Builder, Video CV, Analytics, Achievements, Premium, Settings, Admin.

**Q8: What is your Firebase project name?**  
A: `virtuomate`

**Q9: What is your production API URL?**  
A: `https://us-central1-virtuomate.cloudfunctions.net/api`

**Q10: Is the app deployed?**  
A: Backend is deployed on Firebase Cloud Functions. Mobile app is distributed as release APK built locally.

**Q11: Can it work offline?**  
A: Partially. `USE_FIREBASE=false` enables fully offline demo mode with in-memory data and mock coach. Full AI requires network.

**Q12: What platforms did you target?**  
A: Android (primary). Flutter codebase is cross-platform capable.

---

## 2. Problem Statement & Objectives (10)

**Q13: What was the main problem statement?**  
A: Lack of accessible, affordable, AI-driven career coaching with measurable feedback for communication skills.

**Q14: What are the project objectives?**  
A: (1) Build mobile coaching app, (2) Integrate Gemini AI for feedback, (3) Implement Firebase auth/database, (4) Provide multi-modal coaching (text/voice), (5) Gamify progress, (6) Support avatar personalization.

**Q15: What are functional requirements?**  
A: User registration, AI coaching sessions, session history, analytics, avatar builder, video CV, premium tier, admin panel, settings/localization.

**Q16: What are non-functional requirements?**  
A: Security (token auth, Firestore rules), graceful degradation (fallback coach), responsive UI, accessibility (text scale, high contrast), performance acceptable on mid-range Android.

**Q17: What constraints did you face?**  
A: Gemini API quotas, Firebase billing, mobile TTS/STT limitations, partial Urdu support, time limits for FYP.

**Q18: What is the scope boundary?**  
A: Not a full HR hiring platform; not real human coach marketplace; lip sync removed; iOS not released in FYP.

**Q19: How do you measure success?**  
A: Working end-to-end demo, structured AI scores, session persistence, 22 passing tests, deployable backend.

**Q20: What SDLC model did you use?**  
A: Iterative/agile — MVP web design first (`virtuomate-mvp`), then Flutter implementation, then backend API, then AI integration.

**Q21: What is SRS alignment?**  
A: Flutter frontend implements SRS modules: coaching, avatar, video CV, analytics, auth — verified against project requirements documents.

**Q22: Who are stakeholders?**  
A: Students/job seekers (users), university evaluators, potential employers/investors (future).

---

## 3. Frontend (15)

**Q23: Why Flutter?**  
A: Single codebase for mobile, fast UI development, hot reload, strong Firebase/plugin ecosystem, good for FYP timeline.

**Q24: Why not React Native?**  
A: Team expertise, Flutter performance, Material 3 theming, and consistent UI across devices.

**Q25: What state management do you use?**  
A: Custom `VirtuoMateController` (ChangeNotifier) + `VirtuoMateScope` (InheritedNotifier). Not Provider/Riverpod/Bloc.

**Q26: Why custom state management instead of Provider?**  
A: Keeps dependencies minimal, full control over rebuild scope, controller acts as single app facade — appropriate for app size.

**Q27: How many screens?**  
A: 22 screen files in `lib/ui/screens/`.

**Q28: How does navigation work?**  
A: Named routes via `AppRoutes` in `MaterialApp.routes`. Home uses `_AppHomeGate` (Dashboard vs Welcome). `Navigator.pushNamed` for feature screens.

**Q29: What design system do you use?**  
A: Custom MVP theme (`virtuomate_mvp_theme.dart`) — dark gradient, cyan accent, `VButton`, `VCard`, `MvpShell`.

**Q30: How is responsiveness handled?**  
A: `responsive.dart` — breakpoints, adaptive horizontal padding, max content width.

**Q31: How is localization implemented?**  
A: `AppText` static map for EN/Urdu. `LocaleStorage` + Firestore preferences. Partial Urdu — coaching stays English.

**Q32: What is VirtuoMateController?**  
A: ChangeNotifier exposing all UI actions: auth, sessions, avatar, settings, premium, neural refresh. Single source of truth.

**Q33: What is AppService?**  
A: Pure Dart business logic layer between controller and repository. No Flutter imports.

**Q34: What is the repository pattern?**  
A: `AppRepository` interface with three implementations: InMemory, FirebaseAppRepository, ApiAppRepository — swappable by runtime mode.

**Q35: How does the avatar show emotions?**  
A: Gemini returns `emotion` → `resolveAvatarEmotion()` → `AvatarCoachView` changes ring color and template image.

**Q36: How does TTS work?**  
A: `TtsSpeaker` wraps `flutter_tts`, applies voice profile pitch/rate, exposes `isSpeaking` for avatar state.

**Q37: What is neural connectivity card?**  
A: UI showing `/health` status — whether Gemini, API, and intelligence engine layers are reachable.

---

## 4. Backend (12)

**Q38: What backend technology?**  
A: Node.js Express in `virtuomate_backend_firebase`, deployed as Firebase Cloud Function `api`.

**Q39: Why Cloud Functions instead of standalone server?**  
A: Integrated with Firebase, auto-scaling, no server management, fits FYP budget, same GCP project as Firestore.

**Q40: Where are routes defined?**  
A: Single file `src/app.js` — all REST endpoints.

**Q41: How many API endpoints?**  
A: ~25 including health, auth, user, sessions, AI, storage, video CV, payments, admin.

**Q42: How is the backend tested?**  
A: `test/assessment.local.test.js` + manual API testing. CI runs `npm run check`.

**Q43: What is FREE_SESSION_LIMIT?**  
A: Default 20 free sessions enforced in `POST /sessions` before requiring premium.

**Q44: How does demo login work?**  
A: `POST /auth/demo` creates/resets demo Firebase user, returns custom token, client signs in.

**Q45: How does video CV render work?**  
A: `POST /video-cv/render-job` creates Firestore job, server runs FFmpeg pipeline, client polls status, downloads MP4.

**Q46: What is profile bootstrap?**  
A: `POST /user/bootstrap` creates Firestore user document on first login with defaults.

**Q47: How are errors returned?**  
A: JSON HTTP status codes; Flutter `api_error_message.dart` parses for SnackBars.

**Q48: Can backend run locally?**  
A: Yes — `npm start` on port 8080. Flutter debug points to `127.0.0.1:8080` (10.0.2.2 on emulator).

**Q49: What is virtuomate_ml?**  
A: Optional Python FastAPI service with DeBERTa on Cloud Run — supplementary intelligence engine, not primary coach path.

---

## 5. Firebase (12)

**Q50: Why Firebase?**  
A: Auth, Firestore, Storage, Functions in one platform — fast FYP development, realtime sync, security rules.

**Q51: Why not MongoDB directly?**  
A: Firebase provides auth integration, mobile SDKs, security rules, and serverless functions — less ops overhead for FYP.

**Q52: What Firebase services are used?**  
A: Authentication, Cloud Firestore, Cloud Storage, Cloud Functions.

**Q53: What is stored in Firestore?**  
A: User profiles, sessions, chat, assessments, video jobs — see DATABASE_GUIDE.md.

**Q54: What is stored in Cloud Storage?**  
A: Avatar images, rendered video CV files.

**Q55: How do security rules work?**  
A: Owner-based access on `users/{uid}` and subcollections. Clients blocked from writing `isPremium`, `videoCvCount`. Assessments server-write-only.

**Q56: What is realtime sync?**  
A: In Firestore mode, `FirebaseAppRepository.startRealtimeSync()` listens to profile/session snapshots. In API mode, `ProfileSyncService` polls every 30s.

**Q57: How is Firebase initialized?**  
A: `initFirebase()` in `firebase_bootstrap.dart` using `firebase_options.dart`.

**Q58: What auth providers?**  
A: Email/password, Google Sign-In, demo custom token.

**Q59: How do you prevent premium hacking?**  
A: Firestore rules reject client writes to premium fields. Only Admin SDK/Stripe webhook sets `isPremium`.

**Q60: What is google-services.json?**  
A: Android Firebase config linking app to project `virtuomate`.

**Q61: Do you use Firebase Analytics/Crashlytics?**  
A: Not in current codebase — future enhancement.

---

## 6. AI & Gemini (15)

**Q62: Why Gemini?**  
A: Fast Flash models, Google AI Studio access, good JSON structured output, multimodal for avatar images, GCP integration.

**Q63: Why not train your own model?**  
A: FYP timeline and resources — pre-trained LLM with prompt engineering is practical and industry-standard.

**Q64: Where is Gemini called?**  
A: Server-side only: `virtuomate_backend_firebase/src/services/gemini.service.js`.

**Q65: Is the API key in the mobile app?**  
A: **No.** Keys are in backend environment variables only.

**Q66: What Gemini model?**  
A: Default `gemini-2.5-flash-lite` with fallbacks in code.

**Q67: What scores does AI return?**  
A: confidence, clarity, professionalism, anxiety, communication, interview_readiness (0-100), plus emotion and recommendations.

**Q68: What is prompt engineering?**  
A: System instructions in gemini.service.js define coach persona and JSON schema (`ASSESSMENT_SCHEMA`) for consistent parseable output.

**Q69: What if Gemini fails?**  
A: Fallback chain: OpenAI (`coach.service.js`) → local template coach. UI shows banner when provider ≠ gemini.

**Q70: How is emotion detected?**  
A: Gemini analyzes text and returns `emotion` and `avatar_expression` fields in JSON assessment.

**Q71: Does Flutter call Gemini for avatars?**  
A: Flutter calls `POST /storage/avatar/vroid-from-photo`; backend uses Gemini image model.

**Q72: What is MockCoachEngine?**  
A: Local keyword-based coach in `coach_engine.dart` when backend API disabled — for offline dev/demo.

**Q73: What is ApiCoachEngine?**  
A: Production coach calling `/ai/coach`, `/ai/analyze-text`, `/ai/analyze-speech`.

**Q74: How do you know AI is live?**  
A: Response includes `provider: "gemini"`. `CoachFeedbackResult.isLiveProvider()` checks this. Neural card shows `/health`.

**Q75: What are Gemini limitations you faced?**  
A: Quota/billing 429 errors, latency 2-5s, inconsistent JSON without schema enforcement, English-first responses.

**Q76: Future AI improvements?**  
A: Streaming responses, fine-tuned coach model, on-device Gemini Nano, prompt A/B testing.

---

## 7. Security (10)

**Q77: How is API authenticated?**  
A: Firebase ID token in `Authorization: Bearer` header, verified by `admin.auth().verifyIdToken()`.

**Q78: Why not store passwords in Firestore?**  
A: Firebase Auth handles password hashing — never stored in our database.

**Q79: How is admin access controlled?**  
A: Firebase custom claim `admin: true` OR email in `ADMIN_EMAILS` env var.

**Q80: GDPR features?**  
A: `POST /user/export` exports JSON; `DELETE /user` deletes Firestore data and Auth account.

**Q81: CORS policy?**  
A: Configurable via `CORS_ORIGIN` env (default `*` for development).

**Q82: Are assessments tamper-proof?**  
A: Clients cannot write to `assessments` collection — server Admin SDK only.

**Q83: Stripe webhook security?**  
A: Verified with `STRIPE_WEBHOOK_SECRET`.

**Q84: Network security on Android?**  
A: `network_security_config.xml`; cleartext allowed for local dev only.

**Q85: What sensitive data is encrypted?**  
A: Firebase handles encryption at rest. TLS in transit. API keys server-side only.

**Q86: Session hijacking prevention?**  
A: Short-lived Firebase ID tokens, refreshed by SDK.

---

## 8. Database (8)

**Q87: Why subcollections under users?**  
A: Natural data isolation per user, simpler security rules (`isOwner(userId)`), scalable session history.

**Q88: Why not one big sessions collection?**  
A: Subcollections enforce ownership in rules and avoid cross-user query complexity.

**Q89: How is session history queried?**  
A: `orderBy('createdAt', descending: true).limit(50)`.

**Q90: What indexes are needed?**  
A: None composite currently — single-field createdAt queries.

**Q91: How are preferences stored?**  
A: Nested map `preferences` on user document — language, notifications, accessibility.

**Q92: How is mergeFromJson used?**  
A: When syncing profile from server, local language preference isn't wiped if server omits field.

**Q93: What is videoCvDraft?**  
A: Embedded map on user doc storing wizard form state between sessions.

**Q94: Relational vs NoSQL choice?**  
A: Firestore document model fits user-centric mobile app; no complex joins needed.

---

## 9. Performance & Scalability (10)

**Q95: App startup time?**  
A: Native splash → Firebase init → deps FutureBuilder → home gate. Not formally benchmarked; see QA_REPORT.

**Q96: AI response latency?**  
A: Typically 2-5 seconds depending on Gemini load; loading indicators shown.

**Q97: How to scale backend?**  
A: Cloud Functions auto-scale; Firestore scales horizontally; CDN for storage URLs.

**Q98: Bottlenecks?**  
A: Gemini API rate limits, FFmpeg video render CPU, large avatar uploads.

**Q99: Caching strategy?**  
A: Image cache in Flutter; profile in memory via repository; no Redis currently.

**Q100: Free tier limits?**  
A: 20 sessions per user on backend; premium removes limit.

**Q101: How handle 1000 users?**  
A: Firebase/GCP auto-scaling; may need Gemini billing tier increase and function memory tuning.

**Q102: Image optimization?**  
A: cacheWidth/cacheHeight on avatar images; compressed uploads to Storage.

**Q103: Polling vs realtime?**  
A: API mode polls profile 30s; Firestore mode uses snapshots — trade-off for API-only architecture.

**Q104: Future performance work?**  
A: Response caching, Gemini streaming, lazy screen loading, App Check.

---

## 10. Testing (8)

**Q105: How many tests?**  
A: 21 unit/widget + 1 integration = 22 total passing.

**Q106: What do unit tests cover?**  
A: Analytics, auth, avatar emotion, assessment JSON, validators, cartoon filter, logo widget.

**Q107: Integration test flow?**  
A: Launch → demo login → dashboard markers visible.

**Q108: Why no full E2E for Gemini?**  
A: Requires live API key and network; would be flaky in CI — tested manually.

**Q109: CI pipeline?**  
A: GitHub Actions — backend check + flutter analyze + flutter test.

**Q110: Manual testing?**  
A: QA_REPORT.md, device smoke tests documented.

**Q111: Test coverage percentage?**  
A: Not measured with coverage tool — focused on critical path unit tests.

**Q112: How test Firestore rules?**  
A: Manual verification + Firebase emulator (recommended future work).

---

## 11. UI/UX (8)

**Q113: Why dark theme?**  
A: Matches MVP brand, reduces eye strain, modern professional look for coaching app.

**Q114: Accessibility features?**  
A: Text scale slider, high contrast mode, font fallbacks for Urdu script.

**Q115: Gamification?**  
A: Achievements with unlock notifications, mission progress bar on dashboard.

**Q116: Error UX?**  
A: SnackBars, neural connectivity warnings, coach fallback banners, form validation messages.

**Q117: Onboarding flow?**  
A: Welcome → login/register/demo → Dashboard with feature discovery.

**Q118: Why avatar coach?**  
A: Increases engagement and provides visual feedback for emotional coaching — more human than text-only.

**Q119: Urdu UX decision?**  
A: Partial translation for settings/navigation; LTR layout kept to avoid mixed-language layout bugs.

**Q120: Design reference?**  
A: `virtuomate-mvp` Expo prototype informed Flutter MVP theme.

---

## 12. Architecture & Code-Based (15)

**Q121: Why repository pattern?**  
A: Decouples UI from data source — swap InMemory/Firestore/API without changing AppService.

**Q122: Why separate AppService from Controller?**  
A: Testable business logic without Flutter; controller handles UI-specific notifyListeners.

**Q123: Why InheritedNotifier over Provider?**  
A: Built-in Flutter mechanism; single app-wide notifier; no extra package dependency.

**Q124: How is auth separated from UI?**  
A: `AuthGateway` interface — `FirebaseAuthGateway` or `InMemoryAuthGateway` injected into AppService.

**Q125: How is coach separated from UI?**  
A: `CoachEngine` interface — `ApiCoachEngine` or `MockCoachEngine` injected into AppService.

**Q126: What breaks if api_client.dart is removed?**  
A: Production mode completely broken — no API calls possible.

**Q127: What breaks if gemini.service.js is removed?**  
A: Live AI coach and avatar generation fail; fallbacks may still give template responses.

**Q128: How is USE_BACKEND_API chosen?**  
A: `AppConfig.useBackendApi` — `true` in release profile, `false` in debug by default.

**Q129: How are dart-defines passed?**  
A: `--dart-define=KEY=value` on flutter run/build; release script sets Firebase and OAuth flags.

**Q130: Why ApiAppRepository over direct Firestore in release?**  
A: Centralizes business rules on server (session limits, premium, AI orchestration), single API surface.

**Q131: How does achievement unlock work?**  
A: `AppService.syncAchievements()` evaluates rules after sessions; stores IDs in preferences.

**Q132: How is voice profile encoded?**  
A: `gender|toneId` string via `voice_profile_codec.dart` — sent to TTS and video CV render.

**Q133: What is ProfileSyncService?**  
A: Timer polling `bootstrapUserProfile()` in API mode when Firestore realtime unavailable.

**Q134: Why ListenableBuilder on dashboard?**  
A: Rebuilds when controller notifies — profile name, premium badge, session stats update.

**Q135: Entry point workflow?**  
A: main → VirtuoMateRoot → FutureBuilder deps → VirtuoMateScope → VirtuoMateApp → _AppHomeGate.

---

## 13. Future Scope & Business (10)

**Q136: Future features?**  
A: iOS release, full Urdu, push notifications, VRM avatars, team dashboards, offline LLM.

**Q137: Business model?**  
A: Freemium — 20 free sessions, premium unlimited via Stripe subscription.

**Q138: Market potential?**  
A: EdTech + career services — universities, bootcamps, HR training departments.

**Q139: Competitors?**  
A: Generic AI chatbots, interview prep apps (Pramp, Yoodli) — VirtuoMate combines coaching + avatar + Video CV.

**Q140: Monetization implemented?**  
A: Premium screen + Stripe checkout API + mock payment mode for demo.

**Q141: Can universities deploy this?**  
A: Yes — multi-tenant admin analytics could be added; current admin panel lists users.

**Q142: Open source potential?**  
A: Could open-source Flutter client; API keys and Firebase project remain private.

**Q143: Maintenance plan?**  
A: Monitor Gemini API changes, Firebase billing, dependency updates via CI.

**Q144: Technical debt?**  
A: Single app.js file, partial i18n, limited test coverage, no App Check.

**Q145: If you had 6 more months?**  
A: iOS App Store, streaming AI, comprehensive E2E tests, real lip sync/VRM, enterprise SSO.

---

## 14. Difficult Technical Questions (50)

**Q146: Explain verifyIdToken flow step by step.**  
A: Client gets ID token from Firebase Auth SDK → sends in Authorization header → middleware extracts Bearer token → Firebase Admin SDK verifies signature and expiry → attaches decoded uid to request → route handler uses uid for Firestore paths.

**Q147: How does mergeFromJson prevent language reset?**  
A: `AppPreferences.mergeFromJson(current, serverJson)` uses copyWith with null coalescing — if server omits languageCode, local value preserved.

**Q148: Difference between Firebase and API repository mode?**  
A: Firebase mode: Flutter writes Firestore directly with security rules. API mode: all mutations go through Cloud Functions which use Admin SDK — enables server-side validation and AI orchestration.

**Q149: How does ApiCoachEngine parse snake_case?**  
A: `CoachingAssessment.fromJson` handles both snake_case and camelCase keys from backend.

**Q150: What happens on POST /sessions when limit exceeded?**  
A: Backend returns error; AppService throws; UI shows SnackBar with premium upsell message.

**Q151: How is custom token generated for demo?**  
A: Admin SDK `createCustomToken(uid)` after ensuring demo user exists in Firebase Auth.

**Q152: Explain Cloud Function export.**  
A: `index.js` exports `api` as HTTPS function wrapping Express app from `src/app.js`.

**Q153: How does Google Sign-In get Firebase credential?**  
A: `google_sign_in` package → ID token → `GoogleAuthProvider.credential` → `signInWithCredential`.

**Q154: What is the assessment normalization pipeline?**  
A: Raw Gemini JSON → `normalizeAssessment()` → clamp scores 0-100 → ensure arrays → set provider: gemini.

**Q155: How does on-device cartoon work without Gemini?**  
A: ML Kit face detection → crop portrait → TFLite or CPU cel-shade filter in `on_device_avatar_stylizer.dart`.

**Q156: Why ChangeNotifier instead of Stream?**  
A: Simpler imperative UI updates for form-driven app; single notifyListeners after batch operations.

**Q157: How prevent duplicate session saves?**  
A: AppService creates one session per completeConversation call; backend assigns unique doc ID.

**Q158: Firestore timestamp handling?**  
A: Backend uses `FieldValue.serverTimestamp()`; Flutter parses via repository hydrate.

**Q159: How handle token expiry mid-session?**  
A: Firebase SDK auto-refreshes token; ApiClient tokenProvider fetches fresh token each request.

**Q160: What is encodedVoiceProfile used for?**  
A: Passed to TTS for pitch/rate and to video CV cloud render for voice gender/tone.

**Q161: How does interview multi-step work?**  
A: `kInterviewSteps` constant in models.dart defines phases; InterviewScreen advances steps, calls analyze per answer.

**Q162: Role play scenarios source?**  
A: Defined in role_play_screen.dart — salary negotiation, leadership, conflict, pitch scenarios.

**Q163: How chat differs from session?**  
A: Chat uses Firestore coachChat subcollection for message history; Session uses single-turn or voice with session record.

**Q164: Admin analytics data source?**  
A: `GET /admin/analytics` aggregates Firestore user/session counts server-side.

**Q165: Stripe webhook flow?**  
A: checkout.session.completed → verify signature → set isPremium on user doc via Admin SDK.

**Q166: Why health endpoint public?**  
A: Allows app to check AI stack before auth; no sensitive data returned.

**Q167: Gemini JSON parsing failure handling?**  
A: Try/catch in gemini.service.js → fallback model or OpenAI or local template.

**Q168: How mission progress calculated?**  
A: AppService missionProgress() based on session count and achievements — stored 0-100 on profile.

**Q169: Can user have multiple devices?**  
A: Yes — same Firebase account; profile syncs via Firestore/API; locale also in SharedPreferences per device.

**Q170: Delete account cascade?**  
A: DELETE /user removes Firestore user doc, subcollections, Storage files, Firebase Auth user.

**Q171: Why separate video_cv_render.service?**  
A: Heavy FFmpeg processing isolated from main request handlers; async job pattern.

**Q172: audio_lipsync.js purpose?**  
A: Server-side lip sync for video CV render (FFmpeg pipeline) — not Flutter lip sync (removed).

**Q173: voice_tuning.js purpose?**  
A: Post-processes gTTS audio with pitch/speed for video CV voice gender matching.

**Q174: How AppConfig resolves emulator localhost?**  
A: Maps 127.0.0.1 to 10.0.2.2 on Android emulator automatically.

**Q175: release vs debug backend default?**  
A: `useBackendApi = true` in release profile via `bool.fromEnvironment` + kReleaseMode fallback.

**Q176: What is VirtuoMateRuntime widget?**  
A: InheritedWidget exposing firebaseEnabled, useBackendApi, bootstrapWarning to deep widgets without controller.

**Q177: How form validators used?**  
A: Login/register screens call validateEmail/validatePassword before auth calls.

**Q178: Achievement drain pattern?**  
A: Controller `drainAchievementUnlocks()` returns pending unlocks once for Snackbar display — prevents duplicate toasts.

**Q179: Why splash screen unused in routes?**  
A: Replaced by native splash + direct _AppHomeGate to avoid double splash flash on startup.

**Q180: How neural connectivity percent computed?**  
A: Backend `neural_connectivity.js` checks Gemini ping, FFmpeg, intelligence engine URL — returns layer status array.

**Q181: Conflict between Firestore realtime and API sync?**  
A: Mutually exclusive modes — API mode uses polling; Firestore mode uses snapshots. Not both simultaneously.

**Q182: How premium checked on client?**  
A: `AppService.isPremiumUser()` reads repository; server enforces on session create.

**Q183: Presentation screen slide count?**  
A: 5 slides defined in presentation_screen.dart with per-slide coaching calls.

**Q184: Export video CV without cloud render?**  
A: `VideoCvExportService` generates local HTML + narration script for share.

**Q185: Error boundary for Firebase init failure?**  
A: Debug: fallback to InMemory with warning banner. Release: error screen with retry button.

**Q186: How uuid/session IDs generated?**  
A: Firestore auto-ID on document create via `.doc()` without ID.

**Q187: Why coach hint field?**  
A: Backend returns human-readable hint when Gemini unavailable — shown in UI banner.

**Q188: OpenAI fallback trigger?**  
A: `AI_PROVIDER=openai` or Gemini quota error in coach.service.js selection logic.

**Q189: Local coach fallback quality?**  
A: Template strings with keyword matching — adequate for demo, not production coaching quality.

**Q190: How to add new coaching module?**  
A: Add screen → route in app.dart → controller method → AppService.completeX() → ApiCoachEngine with sessionType → backend handles in coach service.

**Q191: Dependency injection pattern?**  
A: Manual constructor injection in VirtuoMateRoot._buildDeps() — no get_it framework.

**Q192: Why firestore in Flutter at all if API mode default?**  
A: Coach chat may use Firestore; debug mode uses direct Firestore; Auth always uses Firebase SDK.

**Q193: Image picker permissions?**  
A: Android manifest CAMERA + READ_MEDIA; runtime permission via image_picker plugin.

**Q194: ProGuard rules purpose?**  
A: `proguard-rules.pro` — keep rules for release APK minification without breaking Firebase/TFLite.

**Q195: How build script sets defines?**  
A: `build-release-android.ps1` passes USE_FIREBASE, USE_BACKEND_API, GOOGLE_WEB_CLIENT_ID to flutter build apk.

---

## Quick Fire Round (5-word answers)

| Q | A |
|---|---|
| State management? | VirtuoMateScope ChangeNotifier |
| Database? | Cloud Firestore |
| AI provider? | Google Gemini server-side |
| Auth? | Firebase ID tokens |
| Mobile framework? | Flutter Dart |
| Backend? | Node Cloud Functions |
| Free sessions? | Twenty per user |
| Tests passing? | Twenty-two |
| Firebase project? | virtuomate |
| Premium payment? | Stripe or mock |

---

**Total: 195 questions with answers.** Good luck at Open House! 🎓

Read **OPEN_HOUSE_CHEATSHEET.md** 10 minutes before your evaluation.
