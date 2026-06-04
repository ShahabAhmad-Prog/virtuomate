# On-device avatar (Layer 1 — Option A)

Free, mobile-first pipeline: **your photo → cartoon portrait** without Gemini image API.

## Flow

```
Gallery / Camera
    → ML Kit face detection (largest face)
    → Square bust crop
    → TFLite avatar_cartoon.tflite (if bundled)
       OR CPU cartoon filter (always available)
    → PNG saved locally
    → Optional Firebase upload (POST /storage/avatar)
```

## UI

**Avatar Builder** → **My portrait** → **Create avatar from photo (free, on-device)**

Cloud cartoon is under **Cloud cartoon (uses AI credits)** when `USE_BACKEND_API=true`.

## Optional TFLite model

```powershell
.\tool\download_avatar_stylize_model.ps1
```

Place custom models at `assets/models/avatar_cartoon.tflite` (RGB in, RGB out, NHWC).

## Packages

- `google_mlkit_face_detection`
- `image`
- `tflite_flutter`

## Layer 2 — Emotion animations

- Cross-fade between expression PNGs (`AvatarCoachView`)
- Idle breathing, listening ring pulse
- States: idle, happy, thinking, confident, encouraging, speaking, listening
- Optional **Rive** overlay: add `assets/rive/coach_avatar.riv` (state machine `Coach`)

## Layer 3 — Lip sync

- `TtsSpeaker.mouthOpen` (0–1) driven by `flutter_tts` **word progress** + fallback pulse
- Portrait mode: mouth overlay scales with `mouthOpen`
- Template mode: subtle scale pulse while speaking

Wire in coach / session / voice screens via `ValueListenableBuilder` on `mouthOpen`.
