# VirtuoMate Avatar System

Lightweight, offline-friendly emotion avatars controlled by Gemini coaching responses.

## Architecture

| Layer | Responsibility |
|--------|----------------|
| **On-device (free)** | ML Kit face crop + CPU cartoon / optional `avatar_cartoon.tflite` — see `docs/ON_DEVICE_AVATAR.md` |
| **Local assets** | `assets/avatars/*.png` — seven expression templates |
| **Portrait mode** | User photo or VRoid PNG via `POST /storage/avatar` → Firebase Storage |
| **Template mode** | `avatarUseTemplate: true` — no upload required |
| **Brain** | Gemini `/ai/coach` returns `emotion`, `avatar_expression`, scores |
| **UI** | `AvatarPresence` → `AvatarCoachView` (emotion cross-fade + TTS lip-sync) |
| **Lip sync** | `TtsSpeaker.mouthOpen` from word progress + pulse fallback |
| **Rive (optional)** | `assets/rive/coach_avatar.riv` state machine `Coach` |

## Firestore profile fields

- `avatarImageUrl` — portrait image URL (selfie or VRoid PNG)
- `avatarUseTemplate` — `true` for template PNGs, `false` for custom portrait
- `avatarEmotionState` — last detected expression name
- `avatarStyle` — persona label (Professional, etc.)

## Removed (legacy)

- Ready Player Me SDK / WebView creator
- OpenAI cartoonize pipeline
- `avatarCartoonized`, `avatarRpmGlbUrl`, VRM/VRoid experiments

## VRoid-style portrait from photo (2D)

VirtuoMate does **not** run VRoid Studio inside the app. Instead:

1. User picks a **clear front-facing photo** in Avatar Builder.
2. Tap **Cartoonize from photo** or **Anime (VRoid-style)** → backend calls **Gemini image generation** (OpenAI fallback if configured).
3. Result is saved to Firebase Storage as `avatarImageUrl` with `avatarUseTemplate: false`.
4. **Same URL** is used for:
   - Coach UI (`AvatarPresence` portrait mode + mouth animation when TTS is speaking)
   - Video CV FFmpeg render (lip-sync portrait in exported MP4)

Body field `style`: `cartoon` (default) or `vroid` / `anime`.

Manual alternative: design in [VRoid Studio](https://vroid.com/en/studio) and upload the PNG via Gallery.

API: `POST /storage/avatar/vroid-from-photo` (auth required, base64 photo in body).

`GET /health` uses a **lightweight text ping** only (no image generation). To test image gen manually: `node scripts/test-gemini-image.js`. Optional deep health probe: set `HEALTH_PROBE_GEMINI_IMAGE=true` on Cloud Functions (not recommended for production).

## Regenerate placeholder assets

```bash
node tool/generate_avatar_assets.js
```

Replace PNGs in `assets/avatars/` with final art when ready.
