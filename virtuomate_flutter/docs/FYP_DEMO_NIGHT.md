# VirtuoMate — FYP demo night checklist



## Billing (Gemini) — optional for demo night



If AI Studio shows **prepayment credits depleted**, the app still works: coach uses **local linguistic feedback** (scores + paragraphs). Fix billing later at https://aistudio.google.com — then redeploy with a new key.



## 1. Backend deploy (once)



```powershell

cd "D:\Virtomate Project\virtuomate_backend_firebase"

firebase deploy --only functions,firestore:rules

```



## 2. Run Flutter (Step 3)



```powershell

cd "D:\Virtomate Project\virtuomate_flutter"

.\scripts\fyp-demo-step3-run.ps1

```



Uses `USE_FIREBASE=true` + `USE_BACKEND_API=true`. Connect a phone (USB) or start an emulator first.



## 3. Smoke check (Step 4)



```powershell

cd "D:\Virtomate Project\virtuomate_flutter"

.\scripts\fyp-demo-step4-smoke.ps1

```



Expect `health.ok = True`. `/health` uses a cheap text ping only (no image gen). `geminiImageStatus: configured` means avatar API is available; run `node scripts/test-gemini-image.js` to test image gen. `geminiStatus: error` is OK until billing is fixed.



## 4. Demo flow (5 minutes)



1. Login or **Demo login**

2. Dashboard — neural connectivity card

3. **AI Coach Chat** — send a message; replies sync in Firestore

4. Interview or Voice session — feedback with scores

5. Analytics — session trends

6. Video CV wizard → preview → export

7. Settings — profile, logout



## 5. Firestore



Chat: `users/{uid}/coachChat/{messageId}` — owner read/write.



Assessments: Cloud Functions `/ai/analyze-text`.



## 6. When Gemini billing is restored



```powershell

cd "D:\Virtomate Project\virtuomate_backend_firebase"

.\scripts\set-gemini-env.ps1 -ApiKey "YOUR_KEY"

node scripts/test-gemini-key.js

firebase deploy --only functions

```



`/health` should show `geminiStatus: ok`.


