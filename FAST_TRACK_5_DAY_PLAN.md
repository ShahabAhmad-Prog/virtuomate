# VIRTUOMATE - 5-Day MVP Fast-Track Plan

Goal: Ship a demo-ready MVP in 5 days. Prioritize speed over completeness.

Tech (optimize for speed):
- Frontend: Expo (React Native)
- Auth/DB: Firebase (Auth + Firestore)
- Media: Cloudinary (upload) or Firebase Storage
- AI: OpenAI API (text only)
- Deploy: Expo build (Android)

Scope (will build):
- Auth: email/password (register, login, logout)
- Home: buttons to features
- Interview Simulation: text Q/A with AI, store transcript
- Conversational Chat: simple chat UI with AI
- Video CV: record (Expo Camera), preview, upload (get URL)
- Analytics: counts (sessions, chats, videos)
- Settings: show email + sign out
- Premium: gate longer interviews/chat behind flag (fake paywall)

Out-of-scope (defer):
- Speech-to-text / text-to-speech
- Real payments
- Advanced analytics
- Avatar generation

---

## Day 1: Setup, Auth, Navigation
Deliverables:
- Expo app bootstrapped
- Firebase configured (Auth + Firestore)
- Auth screens (Welcome/Login/Register)
- Protected routing
- Home screen

Commands:
```bash
npx create-expo-app virtuomate-mvp
cd virtuomate-mvp
npm i @react-navigation/native @react-navigation/native-stack
npx expo install react-native-screens react-native-safe-area-context
npm i firebase react-native-gifted-chat
```

Steps:
1) Firebase project → enable Email/Password; create Firestore.
2) Add Firebase web config in `src/config/firebase.ts`.
3) Auth flow: `onAuthStateChanged` → switch between `AuthStack` and `AppStack`.
4) Screens: `Auth/Welcome`, `Auth/Login`, `Auth/Register`, `Home`.

Check:
- Register/login works; Home loads when logged in.

---

## Day 2: Interview (text) + Chat (text)
Deliverables:
- Interview Simulation: 5 predefined questions; AI feedback per answer
- Chat: GiftedChat with AI replies
- Save sessions/messages to Firestore

Commands:
```bash
npm i openai
```

Steps:
1) `.env` with `OPENAI_API_KEY` (read via app constants).
2) `services/ai.ts`: `askAI(prompt: string): Promise<string>`.
3) Interview: show question → user answers → call `askAI` with short-feedback system prompt → next question; save to `interviews/{userId}/{sessionId}`.
4) Chat: send → `askAI` → append; save to `chats/{userId}/{sessionId}`.

Check:
- Both screens exchange messages with AI and persist to Firestore.

---

## Day 3: Video CV (record, preview, upload)
Deliverables:
- Record ≤60s video, preview, upload, store URL

Commands:
```bash
npx expo install expo-camera expo-av expo-file-system
```

Steps:
1) Permissions + simple record/stop UI (front camera).
2) Preview with `expo-av` Video.
3) Upload: Cloudinary unsigned preset (`CLOUD_NAME`, `UPLOAD_PRESET`) → POST `multipart/form-data` → get `secure_url`; save under `videos/{userId}`.

Check:
- Record → preview → uploaded URL visible, Firestore saved.

---

## Day 4: Analytics + Settings + Premium + Polish
Deliverables:
- Analytics: counts of interviews, chats, videos
- Settings: show email, Sign out
- Premium gating: if `isPremium` false, limit interview>5 Qs, chat>20 msgs with upsell modal
- Basic styling, loading/error states

Steps:
1) Query Firestore counts and display as cards.
2) Settings: current user email + logout.
3) Premium: `users/{uid}.isPremium` toggle; enforce limits.
4) Polish: simple theme, empty states, basic toasts.

Check:
- Counts correct; sign out works; limits enforce.

---

## Day 5: QA, fixes, build
Deliverables:
- Happy-path E2E passes
- Expo Android build (apk/aab)
- README with demo steps

Steps:
1) Test:
   - Register → Login → Home
   - Interview 3 Qs + feedback → history saved
   - Chat 5 messages → history saved
   - Video record 10s → upload → URL saved
   - Analytics counts update
   - Premium gate blocks extended usage
2) Fix only critical bugs.
3) Build:
```bash
npm i -g eas-cli
npx expo login
eas build -p android --profile preview
```
4) README: setup, env vars, test account, feature list, limits.

---

## Env and Secrets
- `.env`: `OPENAI_API_KEY`, `EXPO_PUBLIC_FIREBASE_*`, `EXPO_PUBLIC_CLOUDINARY_CLOUD`, `EXPO_PUBLIC_CLOUDINARY_UPLOAD_PRESET`
- Read with `expo-constants` or `expo-env`

---

## Suggested structure
```
src/
  components/
  screens/
    Auth/
    Home/
    Interview/
    Chat/
    VideoCV/
    Analytics/
    Settings/
    Premium/
  navigation/
  services/
    ai.ts
    firebase.ts
    storage.ts
  hooks/
  utils/
App.tsx
```

---

## If time is tight, cut
- Charts → plain numbers
- Profile edits → email only
- Advanced validation → minimal
- Premium: manual flag only

---

## Demo script
1) Login → Home
2) Interview: answer 2–3 Qs; show feedback + saved history
3) Chat: 2 messages; persistence visible
4) Video CV: record 5–10s → upload → show URL
5) Analytics: counts increased
6) Premium: 6th interview Q blocked → upsell

---

Stay focused on these flows. Ship the MVP, then iterate.
