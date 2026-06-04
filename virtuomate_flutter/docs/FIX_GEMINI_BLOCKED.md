# Fix: Gemini local fallback responses

## Quota exceeded (429) — most common tonight

If you see `Strengths / Focus / Next` blocks, Gemini returned **429 quota exceeded** (free tier).

**Fast fixes for FYP demo:**
1. https://aistudio.google.com/apikey → **Create API key** in a **new** Google Cloud project (fresh free quota)
2. Or enable billing: https://ai.google.dev
3. Wait ~1 hour and retry

Then update `.env`, run `node scripts/test-gemini-key.js`, redeploy functions.

---

# Fix: Gemini blocked (API key restrictions)

If coach replies look like:

`Conversation • Anxious • Confidence 75% • Strengths: ...`

Gemini is **not** running. The API key is blocking **Generative Language API**.

## Fix in Google Cloud Console

1. **Library** → search **Generative Language API** → **Enable**
2. **Credentials** → open your **Browser key** (or the key in `.env`)
3. **API restrictions** → choose **Don't restrict key** (demo night)
   - OR **Restrict key** and select **Generative Language API** only
4. **Save**
5. Wait 1–2 minutes

## Verify

```powershell
cd "D:\Virtomate Project\virtuomate_backend_firebase"
node scripts/test-gemini-key.js
```

Must print: `Key works - Gemini will respond in the app.`

Then redeploy:

```powershell
.\scripts\fyp-demo-step2-deploy.ps1
```

Restart Flutter and try coach chat again. Replies should be natural paragraphs, not the Strengths/Focus template.
