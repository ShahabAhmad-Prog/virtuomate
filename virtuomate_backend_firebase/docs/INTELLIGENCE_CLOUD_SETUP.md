# Intelligence Engine — Firebase + Google Cloud Run

Wire the Python **VirtuoMate Intelligence** service to your existing Firebase API (`virtuomate` project).

## Architecture

```
Flutter app
    → Firebase Cloud Function (api)
        → Cloud Run (virtuomate-intelligence)  POST /analyze-text
        → Firestore (sessions + assessments)
```

If Cloud Run is unreachable, the Function falls back to the **linguistic assessor** built into Node.js.

---

## Prerequisites

1. **Google Cloud SDK (`gcloud`)** — required for Cloud Run deploy.

   If PowerShell says `gcloud is not recognized`:

   ```powershell
   cd "D:\Virtomate Project\virtuomate_ml"
   .\scripts\install-gcloud.ps1
   ```

   Close PowerShell, open a **new** window, then:

   ```powershell
   gcloud --version
   gcloud auth login
   gcloud config set project virtuomate
   ```

   Manual installer: https://cloud.google.com/sdk/docs/install#windows (check **Add gcloud to PATH**).
2. [Firebase CLI](https://firebase.google.com/docs/cli) logged in:
   ```powershell
   firebase login
   firebase use virtuomate
   ```
3. Billing enabled on project `virtuomate` (Cloud Run requires it).

---

## Step 1 — Deploy Intelligence Engine to Cloud Run

```powershell
cd "D:\Virtomate Project\virtuomate_ml"
.\scripts\deploy-cloud-run.ps1 -AllowPublic
```

Copy the printed URL, e.g. `https://virtuomate-intelligence-xxxxx-uc.a.run.app`

Verify:

```powershell
curl "https://YOUR-CLOUD-RUN-URL/health"
```

Expected:

```json
{
  "status": "ok",
  "engine": "virtuomate-intelligence",
  "neural_checkpoint": false,
  "whisper": false
}
```

### Optional: Whisper on Cloud Run

Redeploy with OpenAI key (server-side transcription):

```powershell
gcloud run services update virtuomate-intelligence `
  --region us-central1 `
  --set-env-vars "OPENAI_API_KEY=sk-YOUR-KEY,CORS_ORIGIN=*"
```

`/health` will show `"whisper": true`.

---

## Step 2 — Connect Firebase Functions

```powershell
cd "D:\Virtomate Project\virtuomate_backend_firebase"
.\scripts\wire-intelligence-engine.ps1 -EngineUrl "https://YOUR-CLOUD-RUN-URL"
```

This runs:

- `firebase functions:config:set intelligence.engine_url="..."`
- `firebase deploy --only functions`

Config is read in `src/config.js` as `intelligenceEngineUrl`.

### Manual alternative (Firebase Console)

1. [Google Cloud Console](https://console.cloud.google.com/functions/list?project=virtuomate) → function **api** → **Edit**
2. **Runtime environment variables** → add:
   - `INTELLIGENCE_ENGINE_URL` = your Cloud Run URL (no trailing slash)
3. Deploy / save.

---

## Step 3 — Test end-to-end

1. Run the Flutter app with backend API enabled.
2. Complete a coaching session or call (with Firebase ID token):

```http
POST https://us-central1-virtuomate.cloudfunctions.net/api/ai/analyze-text
Authorization: Bearer <firebase-id-token>
Content-Type: application/json

{
  "text": "I led a team of five and delivered a 20% revenue increase.",
  "sessionType": "Interview"
}
```

Response should include `confidence_score`, `clarity_score`, `strengths`, `recommendations`.

3. Firestore: `users/{uid}/assessments` — new documents after analyze calls.

---

## Securing Cloud Run (recommended after testing)

Deploy **without** public access:

```powershell
cd "D:\Virtomate Project\virtuomate_ml"
.\scripts\deploy-cloud-run.ps1
# no -AllowPublic
```

Grant the Functions service account permission to invoke:

```powershell
gcloud run services add-iam-policy-binding virtuomate-intelligence `
  --region=us-central1 `
  --member="serviceAccount:virtuomate@appspot.gserviceaccount.com" `
  --role="roles/run.invoker"
```

Then update `assessment.service.js` to send an ID token (contact dev if you need this enabled).

For fastest setup, `-AllowPublic` is fine; the URL is not shown in the app UI.

---

## Local development

| Service | URL |
|---------|-----|
| Intelligence API | `http://localhost:8090` |
| Firebase API | `http://localhost:8080` or deployed URL |

```powershell
# Terminal 1
cd virtuomate_ml
.\.venv\Scripts\Activate.ps1
python -m ml.api.main

# Terminal 2 — backend .env
INTELLIGENCE_ENGINE_URL=http://localhost:8090
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Functions still use local fallback | Redeploy functions after `functions:config:set` |
| `403` from Cloud Run | Use `-AllowPublic` or add `run.invoker` for Appspot SA |
| `whisper: false` on Cloud Run | Set `OPENAI_API_KEY` on the Cloud Run service |
| `neural_checkpoint: false` | Normal for cloud image; train model locally and use full `Dockerfile` if needed |
