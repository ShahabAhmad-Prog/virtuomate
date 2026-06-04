# Stripe payments (VirtuoMate API)

## Environment variables

Set on Firebase Functions:

| Variable | Description |
|----------|-------------|
| `PAYMENT_MODE` | `mock` or `stripe` |
| `STRIPE_SECRET_KEY` | Stripe secret key (`sk_...`) |
| `STRIPE_WEBHOOK_SECRET` | Webhook signing secret (`whsec_...`) |
| `STRIPE_PRICE_MONTHLY` | Price ID for monthly plan |
| `STRIPE_PRICE_ANNUAL` | Price ID for annual plan |
| `STRIPE_PRICE_LIFETIME` | Price ID for lifetime one-time plan |

## Webhook

1. Stripe Dashboard → Developers → Webhooks → Add endpoint  
2. URL: `https://us-central1-virtuomate.cloudfunctions.net/api/payments/webhook`  
3. Events: `checkout.session.completed`  
4. Copy signing secret to `STRIPE_WEBHOOK_SECRET`

The webhook sets `isPremium: true` on the user's Firestore document using `metadata.firebaseUid`.

## Flutter

When `PAYMENT_MODE=stripe`, `/payments/subscribe` returns `checkoutUrl`. The app opens it in the browser via `url_launcher`.

## Deploy

```bash
cd virtuomate_backend_firebase
npm install
firebase deploy --only functions
```
