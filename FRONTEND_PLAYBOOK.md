# VIRTUOMATE Frontend Playbook (Start → Finish in One File)

This is your complete, single-file guide to build the React Native (Expo) frontend: what to install, what to create, which file does what, learning links, commands, and success checks. Use mocked services first (no backend), then swap with real APIs later.

---

## 1) Tech and Goals
- Runtime: Expo (React Native)
- Navigation: React Navigation (Stack + optional Tabs)
- State: React Context (Auth, App/global)
- Data: Mock services (AI, storage, persistence)
- UI: Simple theme (colors/spacing/typography) + reusable components

MVP frontend features:
- Auth flow (mock): Welcome → Login/Register → Home → Logout
- Home hub: Buttons to Interview, Chat, Video CV, Analytics, Settings, Premium
- Interview: Text Q/A with mock “AI feedback” + counter
- Chat: GiftedChat + mock AI response
- Video CV: Fake record/preview/upload flow returning a mock URL
- Analytics: Show counts (sessions, chats, videos)
- Settings: Show mock profile and Logout
- Premium: Toggle flag; gate longer usage

---

## 2) Create App + Install Deps
Run in PowerShell:

```powershell
cd %USERPROFILE%\Desktop
npx create-expo-app virtuomate-mvp
cd virtuomate-mvp

npm i @react-navigation/native @react-navigation/native-stack @react-navigation/bottom-tabs
npx expo install react-native-screens react-native-safe-area-context

npm i react-native-gifted-chat
npx expo install expo-camera expo-av expo-file-system
```

Start once and verify:
```powershell
npm start
```
- Press a for Android emulator, or scan QR with Expo Go.

Learning:
- Expo basics: docs.expo.dev
- RN core components: reactnative.dev/docs/components-and-apis

---

## 3) Directory Structure (Create these)

```
src/
  navigation/
    AppNavigator.(ts|js)
    AuthStack.(ts|js)
    AppStack.(ts|js)
  screens/
    Auth/Welcome.(tsx|js)
    Auth/Login.(tsx|js)
    Auth/Register.(tsx|js)
    Home/Home.(tsx|js)
    Interview/Interview.(tsx|js)
    Chat/Chat.(tsx|js)
    VideoCV/VideoCV.(tsx|js)
    Analytics/Analytics.(tsx|js)
    Settings/Settings.(tsx|js)
    Premium/Premium.(tsx|js)
  components/
    Screen.tsx
    Button.tsx
    TextField.tsx
    Card.tsx
  theme/
    colors.ts
    spacing.ts
    typography.ts
  context/
    AuthContext.(ts|js)
    AppContext.(ts|js)
  mocks/
    ai.ts
    storage.ts
    data.ts
  utils/
    validators.ts
    format.ts
App.(tsx|js)
```

Responsibility map:
- navigation/*: Route definitions and stack switching
- screens/*: Each feature UI
- components/*: Reusable UI primitives
- theme/*: Centralized design system tokens
- context/*: Global app state (auth, counts, premium)
- mocks/*: Fake services for AI/storage/persistence
- utils/*: Validation/format helpers

Learning:
- Navigation: reactnavigation.org/docs/getting-started
- Context: react.dev/reference/react/useContext

---

## 4) Theme + Base Components

Create simple tokens:
- colors.ts: brandPrimary, brandSecondary, bg, textPrimary, success, danger
- spacing.ts: export { xxs:4, xs:8, sm:12, md:16, lg:20, xl:24 }
- typography.ts: { heading:24, subheading:18, body:16, caption:12 }

Base components:
- Screen.tsx: SafeAreaView + padding scaffold
- Button.tsx: Primary button (props: title, onPress, loading, disabled)
- TextField.tsx: Label + TextInput + error (controlled)
- Card.tsx: Rounded, shadow, padding wrapper

Learning:
- RN styling + Flexbox: reactnative.dev/docs/flexbox

---

## 5) Context (Global State)

AuthContext:
- state: { isLoggedIn: boolean, user: { email: string } | null }
- actions: login({email,password}), register({email,password}), logout()
- Impl: in-memory only (no backend). Validate non-empty email/password.

AppContext:
- state: { isPremium: boolean, counts: { interviews:number, chats:number, videos:number } }
- actions: togglePremium(), incInterview(), incChat(), incVideo(), resetCounts()

Wrap App root with both providers.

Learning:
- Context patterns, avoiding prop drilling

---

## 6) Navigation

AppNavigator:
- Read isLoggedIn from AuthContext
- if false → AuthStack (Welcome, Login, Register)
- if true → AppStack (Home + features)

AuthStack:
- Welcome → buttons to Login/Register
- Login/Register → on success call AuthContext action → navigate to AppStack

AppStack:
- Home (entry) + routes: Interview, Chat, VideoCV, Analytics, Settings, Premium
- Optionally use a TabNavigator for Home/Analytics/Settings

Learning:
- Stacks, params, headers, deep links (later)

---

## 7) Screens (What each does)

Auth/Welcome:
- Brand intro + 2 buttons → Login, Register

Auth/Login:
- Email, Password fields; “Login” button
- Validate non-empty email/password; set loading state
- On success: AuthContext.login() → navigate AppStack

Auth/Register:
- Same UI as Login; calls AuthContext.register()

Home/Home:
- Grid/cards to routes: Interview, Chat, VideoCV, Analytics, Settings, Premium
- Nice spacing; use Card + Button primitives

Interview/Interview:
- Local array of 5 questions
- Show Q index, TextInput for answer
- Submit → mocks/ai.askAI(answer) → show short feedback text
- Next question button
- Increment counts via AppContext.incInterview()
- If !isPremium and >5 Qs total attempted → show gate message

Chat/Chat:
- GiftedChat with messages state
- On send: push user message; call mocks/ai.askAI() → bot response after delay
- Increment AppContext.incChat()
- If !isPremium and messages > 20 → show gate

VideoCV/VideoCV:
- For frontend-first, simulate record/preview/upload (you can integrate expo-camera later)
- “Record” toggles a mock file path; “Preview” shows mock video (or placeholder)
- “Upload” calls mocks/storage.uploadVideo(localPath) → returns mock URL
- Save URL to mocks/data and increment AppContext.incVideo()

Analytics/Analytics:
- Read counts from AppContext and display cards: Interviews, Chats, Videos
- Optional: mini chart later; keep simple now

Settings/Settings:
- Show user email (from AuthContext)
- Button: Toggle Premium (AppContext.togglePremium())
- Button: Logout (AuthContext.logout())

Premium/Premium:
- Explain benefits
- Toggle switch for isPremium (mock)
- If false, show what’s limited; if true, show unlocked note

Learning:
- Forms/inputs; loading/error/empty states
- GiftedChat basics
- Async UI flows

---

## 8) Mock Services

mocks/ai.ts:
- export async function askAI(prompt: string): Promise<string>
- Simulate network delay with setTimeout; return templated short reply, e.g., “Feedback: …”

mocks/storage.ts:
- export async function uploadVideo(localPath: string): Promise<{ url: string }>
- setTimeout + return “https://example.com/video/123.mp4”

mocks/data.ts:
- In-memory arrays for interview sessions, chat sessions, video items
- Helpers to push/read items if needed

Learning:
- Async patterns (await, try/catch), UI feedback

---

## 9) UX Polish
- Loading indicators on submit/send/upload
- Disable buttons while loading
- Inline error messages for empty inputs
- Empty states on lists (e.g., “No messages yet”)
- Consistent Screen padding, typography, brand colors
- Keyboard handling: wrap forms with KeyboardAvoidingView (Android/iOS behavior)

Learning:
- Accessibility basics; touch target sizes; feedback timing

---

## 10) Run on Device/Emulator

Commands:
```powershell
npm start
```
- Press a (Android emulator) or scan QR with Expo Go

Tests (happy path):
- Register → Home
- Interview: answer 2 Qs → see feedback → counts ↑
- Chat: send 2 messages → mock reply → counts ↑
- VideoCV: mock record → upload → show mock URL → counts ↑
- Analytics: reflects counts
- Premium: toggle and verify limits lifted
- Settings: logout → Welcome

Troubleshooting:
- Metro cache: stop server; run `npm start -- --clear`
- Emulator missing: open Android Studio once and create a device
- Red screens: read error; fix import/typo/state errors

---

## 11) Learning Path (Inline With Build)
- Day A: Expo + RN Basics (components, styling, Flexbox)
- Day B: Navigation + Context (stacks, providers, state)
- Day C: Forms + UX Patterns (validation, loading, errors)
- Day D: Async + Mocks (GiftedChat, pseudo camera/storage)
- Day E: Polish + Device Testing (layout fixes, keyboard, spacing)

Key docs:
- React Native: https://reactnative.dev/
- Expo: https://docs.expo.dev/
- React Navigation: https://reactnavigation.org/docs/getting-started
- React useContext: https://react.dev/reference/react/useContext

---

## 12) Swap Mocks With Real Services (Later)
- Replace AuthContext login/register with Firebase Auth
- Persist sessions to Firestore
- Replace ai.ts with OpenAI API calls
- Replace storage.ts with Cloudinary/Firebase Storage
- Keep the same screen APIs → minimal UI change

---

## 13) Success Checklist
- [ ] App boots on device/emulator
- [ ] Auth screens switch to Home (mock)
- [ ] Home routes navigate to all features
- [ ] Interview/Chat flows work with mocked AI
- [ ] VideoCV flow returns a mock URL
- [ ] Analytics shows correct counters
- [ ] Premium gating limits usage when off
- [ ] UI uses shared theme + components
- [ ] Loading/error/empty states present
- [ ] Logout returns to Welcome

---

## 14) Commands Reference
```powershell
# Create project
npx create-expo-app virtuomate-mvp
cd virtuomate-mvp

# Navigation deps
npm i @react-navigation/native @react-navigation/native-stack @react-navigation/bottom-tabs
npx expo install react-native-screens react-native-safe-area-context

# Chat + media (frontend-only for now)
npm i react-native-gifted-chat
npx expo install expo-camera expo-av expo-file-system

# Run
npm start
```

---

Build this frontend with mocks first. Once UI/UX is solid, you can wire real APIs quickly without changing the screen contracts. This keeps you fast and focused.
