# VirtuoMate Backend API

Firebase Cloud Functions + Express REST API for the VirtuoMate coaching platform.

## Quick start

```bash
npm install
cp .env.example .env
npm start
curl http://127.0.0.1:8080/health
```

## Deploy

```bash
firebase deploy --only functions,firestore:rules,firestore:indexes,storage
```

## API endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | No | Health check |
| POST | `/user/bootstrap` | Yes | Create/sync user profile |
| GET/PUT | `/user/profile` | Yes | Profile CRUD |
| POST/GET | `/sessions` | Yes | Coaching sessions |
| GET | `/analytics/user` | Yes | User analytics |
| POST | `/ai/coach` | Yes | AI coaching feedback |
| POST | `/video-cv/script` | Yes | CV narration script |
| POST | `/video-cv/generate` | Yes | Record CV generation |
| POST | `/storage/upload-url` | Yes | Signed upload URL |
| POST | `/payments/subscribe` | Yes | Premium activation |
| GET | `/admin/users` | Admin | User list |
| GET | `/admin/analytics` | Admin | Platform stats |
| POST | `/user/export` | Yes | GDPR data export |
| DELETE | `/user` | Yes | Account deletion |

## AI coaching

Set `OPENAI_API_KEY` in environment. Without it, intelligent local fallback is used.

## Payments

`PAYMENT_MODE=mock` activates premium instantly. Integrate Stripe webhooks for production.
