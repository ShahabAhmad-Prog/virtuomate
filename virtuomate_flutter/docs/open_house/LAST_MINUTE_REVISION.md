# Last-Minute Revision Guide

## 5-Minute Revision

1. **Project name:** VirtuoMate — AI career coaching app
2. **Stack:** Flutter + Firebase + Node Cloud Functions + Gemini
3. **Architecture:** UI → Controller → Service → Repository → API/Firestore
4. **State:** `VirtuoMateScope` + `VirtuoMateController` (not Provider/Riverpod)
5. **AI:** Gemini on server only; Flutter sends text, gets feedback + scores + emotion
6. **Auth:** Firebase Auth + ID token on API calls
7. **Main features:** Coach chat, voice, interview, role play, avatar, video CV, analytics
8. **Demo login:** `demo@virtuomate.app` via backend custom token

---

## 10-Minute Revision

Read **OPEN_HOUSE_CHEATSHEET.md** fully.

Memorize:
- Firestore structure (`users/{uid}/sessions`, etc.)
- Top 5 API endpoints (`/ai/coach`, `/user/profile`, `/sessions`, `/health`, `/storage/avatar`)
- Three runtime modes
- Why Gemini is server-side (security + key protection)
- Free session limit: 20
- Testing: 22 unit tests + 1 integration smoke test

Practice saying the **2-minute intro** from PRESENTATION_SCRIPTS.md out loud once.

---

## 30-Minute Revision

1. **OPEN_HOUSE_CHEATSHEET.md** (5 min)
2. **CODE_WALKTHROUGH.md** — trace login → dashboard → session (10 min)
3. **AI_GUIDE.md** — Gemini prompts and scoring (5 min)
4. **DATABASE_GUIDE.md** — collections and fields (5 min)
5. **VIVA_QUESTIONS_AND_ANSWERS.md** — skim categories 1, 6, 8, 9 (5 min)

---

## Before You Enter the Booth

- [ ] Phone/emulator has latest APK with demo login working
- [ ] Backend `/health` returns Gemini connected (or know fallback explanation)
- [ ] Can open Dashboard → Session → get AI feedback in 30 seconds
- [ ] Know where Gemini API key lives (backend `.env`, NOT in Flutter)
- [ ] Know your Firebase project ID: `virtuomate`

---

## If Something Breaks Live

| Issue | Say This |
|-------|----------|
| Gemini quota | "We have OpenAI and local template fallbacks; production uses billing-enabled key" |
| Slow network | "First AI call may take 3–5s; we show loading states and neural connectivity status" |
| Demo login fails | "Fallback: email login or offline mock mode with USE_FIREBASE=false" |
