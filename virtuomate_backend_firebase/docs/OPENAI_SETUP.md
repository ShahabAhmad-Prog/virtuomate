# OpenAI coaching (VirtuoMate API)

Enables GPT-powered feedback on `/ai/coach` instead of the built-in local coach.

## 1. Create an OpenAI API key

1. Sign in at https://platform.openai.com/
2. Add billing: **Settings → Billing** (API calls require a funded account).
3. **API keys → Create new secret key** → copy it once (`sk-proj-...` or `sk-...`).
4. Do **not** commit this key to git or paste it in public chats.

## 2. Set Cloud Function environment variables

Project: **virtuomate** · Function: **api** · Region: **us-central1**

1. Open: https://console.cloud.google.com/functions/details/us-central1/api?project=virtuomate
2. Click **Edit** (top).
3. Expand **Runtime, build, connections and security**.
4. Under **Runtime environment variables**, add:

| Name | Value |
|------|--------|
| `OPENAI_API_KEY` | your secret key |
| `AI_PROVIDER` | `openai` |
| `OPENAI_MODEL` | `gpt-4o-mini` (optional; default in code) |

5. Click through **Deploy** and wait until the new revision is active (~2–5 min).

## 3. Verify

Browser or PowerShell:

```
https://us-central1-virtuomate.cloudfunctions.net/api/health
```

Expected:

```json
{
  "ok": true,
  "backend": "virtuomate-api",
  "aiProvider": "openai",
  "paymentMode": "mock"
}
```

If `aiProvider` is still `"local"`, the key is missing or `AI_PROVIDER` is not `openai`.

## 4. Test in the Flutter app

Hot restart the app, open **Coach Chat**, send:

`Help me prepare for my RSCS job interview.`

Replies should be full paragraphs (GPT), not the short `60% clarity` template.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `aiProvider: local` | Re-check env vars on function `api`; redeploy revision |
| OpenAI 401 | Invalid or revoked API key |
| OpenAI 429 | Rate limit / billing — check OpenAI dashboard |
| App still shows template | Force-stop app; ensure `USE_BACKEND_API=true` when running |
| Function logs show `OpenAI fallback` | Key wrong or model name invalid — check Cloud Logging |

Logs: https://console.cloud.google.com/logs/query?project=virtuomate
