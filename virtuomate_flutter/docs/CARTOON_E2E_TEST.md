# Cartoon avatar — end-to-end test

Backend was deployed with the fixed OpenAI image API (`gpt-image-1` multipart + `model` parameter).

## 1. Run the app (PowerShell)

```powershell
Set-Location "D:\Virtomate Project\virtuomate_flutter"

$env:GOOGLE_WEB_CLIENT_ID = "671835013493-2985ntmhtttbia0sj90nkcj93cfmcsof.apps.googleusercontent.com"

flutter run `
  --dart-define=USE_FIREBASE=true `
  --dart-define=USE_BACKEND_API=true `
  --dart-define=GOOGLE_WEB_CLIENT_ID=$env:GOOGLE_WEB_CLIENT_ID
```

## 2. In the app

1. Sign in (Google or email).
2. Open **Avatar Builder**.
3. Tap **Gallery** and pick a clear selfie (face visible).
4. Wait for **Photo saved to cloud.**
5. Tap **Create cartoon avatar** (wait 15–45 seconds).
6. You should see **Cartoon avatar saved to cloud.** and a stylized image.
7. Open **Start Conversation with AI Coach** — while the coach speaks, the cartoon should show a simple mouth animation (lip-sync demo).

## 3. Verify backend (optional)

```powershell
Invoke-RestMethod "https://us-central1-virtuomate.cloudfunctions.net/api/health"
```

Expect: `ok: true`, `aiProvider: openai`.

## If cartoon fails

| Message | Fix |
|--------|-----|
| `OPENAI_API_KEY is not configured` | Set `OPENAI_API_KEY` on Cloud Function (Firebase Console → Functions → api → Environment variables). |
| `gpt-image-1` / billing errors | Enable billing on OpenAI; ensure Image API access on your key. |
| `401` on upload | Sign out and sign in again. |
| Button does nothing | Hot restart app after pulling latest code. |

Redeploy backend after code changes:

```powershell
Set-Location "D:\Virtomate Project\virtuomate_backend_firebase"
firebase deploy --only functions
```
