# VirtuoMate production checklist



## 1. Firebase Console

- [ ] Enable Email/Password + **Google** auth (Console — one click)

- [x] `google-services.json` + iOS plist refreshed (`tool/refresh_firebase_config.ps1`)

- [x] `lib/firebase_options.dart` via `flutterfire configure`

- [x] iOS URL scheme for Google Sign-In

- [ ] Add Android SHA-1 if sign-in fails — see `docs/GOOGLE_SIGNIN.md` (debug SHA-1 documented)

- [ ] Set `GOOGLE_WEB_CLIENT_ID` for Web/Android id token (Web OAuth client from Console)

- [x] Deploy Firestore rules + Storage rules (with backend deploy)



## 2. Backend deploy

```powershell

Set-Location "D:\Virtomate Project\virtuomate_backend_firebase"

npm install

firebase deploy --only functions,firestore:rules,storage

```

- [x] `/health` returns `ok: true`

- [x] Cartoon avatar route `/storage/avatar/cartoonize`

- [ ] Set `ADMIN_EMAILS`, `OPENAI_API_KEY` (optional but recommended)

- [ ] Stripe: `PAYMENT_MODE=stripe`, keys — see `docs/STRIPE_SETUP.md`



## 3. Flutter release

```powershell

Set-Location "D:\Virtomate Project\virtuomate_flutter"

flutter pub get

flutter run --release `

  --dart-define=USE_FIREBASE=true `

  --dart-define=USE_BACKEND_API=true `

  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID

```



## 4. Feature smoke test

- [ ] Register / login / forgot password / Google

- [ ] Coach chat + voice session (OpenAI, not offline fallback)

- [ ] Avatar photo upload + cartoon avatar (OpenAI billing required)

- [ ] Video CV wizard → preview → export (+ cloud render package in API mode)

- [ ] Premium (mock or Stripe)

- [ ] Settings export / delete account



## 5. Architecture modules (split)

| Module | File |

|--------|------|

| Routes | `lib/ui/routes.dart` |

| Scope + controller | `lib/ui/virtuomate_scope.dart` |

| i18n helpers | `lib/ui/app_text.dart` |

| Auth screens | `lib/ui/screens/auth_screens.dart` |

| Dashboard | `lib/ui/screens/dashboard_screen.dart` |

| Settings | `lib/ui/screens/settings_screen.dart` |

| Coach chat | `lib/ui/screens/coach_chat_screen.dart` |

| App shell + remaining screens | `lib/ui/app.dart` |



## 6. Still manual / not in code

- [ ] Change `com.example.*` package IDs before Play Store / App Store release

- [ ] OpenAI billing limit for cartoon + coach AI

- [ ] Real MP4 video render (current export is JSON/HTML package)

- [ ] Stripe live keys + webhook in production



Re-run split tooling: `node tool/split_app.js` (after editing line ranges if needed).

