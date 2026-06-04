# VirtuoMate Avatar System — VRM + VSeeFace Official Architecture

**Status:** Phase 1 audit complete · Implementation not started  
**Official stack:** VRoid Studio → VRM → VSeeFace → Gemini → Flutter → Firebase  
**Supersedes:** 2D-only plan as *production coach UI*; preserve Gemini brain + Firebase persistence

---

## Reality check (read before coding)

| Capability | Where it runs | FYP demo viability |
|------------|---------------|-------------------|
| VRoid character design | **VRoid Studio** (desktop) | Export `.vrm` — show file in repo / demo folder |
| VRM preview + expressions + lip sync | **VSeeFace** (Windows desktop) | Live demo on laptop; not inside Flutter APK |
| 3D VRM inside mobile app | **Unity / Godot / custom native** + VRM loader | High effort; not fastest path |
| 2D coach portrait + emotion ring | **Flutter** (`AvatarPresence`) | Works today on phone |
| Emotion / scores / coaching text | **Gemini** via Cloud Functions | Works today |
| TTS | **flutter_tts** on device | Works; does **not** drive VSeeFace unless bridged |
| Video CV lip-sync on PNG | **FFmpeg** on backend | Works; separate from VSeeFace |

### What Flutter can do directly

- Store VRM URL/path, VSeeFace config, avatar preferences in Firestore  
- Map Gemini `avatar_state` → UI state enum  
- Show 2D fallback (`AvatarPresence`) on phones  
- Deep-link / instructions to open VRoid Studio & VSeeFace  
- Optional: WebView or platform channel to a **local** VSeeFace OSC/WebSocket bridge (advanced)

### What requires desktop software

- Authoring the avatar (VRoid Studio)  
- Real blendshape lip sync + VRM expressions (VSeeFace)

### What requires Unity/VRM runtime (if no VSeeFace)

- In-app 3D avatar on Android/iOS without external app

### Fastest FYP path (recommended)

1. **Dual-mode:** Flutter 2D coach on mobile + **VSeeFace live window** on demo laptop synced via OSC from TTS or pre-scripted demo.  
2. Document official pipeline; store `.vrm` in Firebase Storage + profile metadata.  
3. Keep Gemini as brain; rename `AvatarEmotionState` → `AvatarState` (+ `idle`, `listening`).  
4. Remove **Gemini image cartoonize** from critical path (optional / dev-only) to save credits.  
5. Do **not** ship fake mouth overlay as “VSeeFace lip sync” in docs — label as 2D fallback only.

---

## 1. Architecture review (current codebase)

### 1.1 Flutter — screens & routes

| Screen | Route | Avatar usage |
|--------|-------|----------------|
| `AvatarScreen` | `/avatar` | Builder: templates, selfie upload, cartoon/anime via API |
| `CoachChatScreen` | `/coach-chat` | `AvatarPresence` + TTS lip overlay |
| `SessionScreen` | `/session` | `AvatarPresence` + `TtsSpeaker` |
| `VoiceActiveScreen` | `/voice-active` | `AvatarPresence` |
| `VoiceSessionScreen` | `/voice-session` | Raw `Image` portrait (no `AvatarPresence`) |
| `InterviewScreen` | `/interview` | TTS only (no avatar widget) |
| `VideoCvWizardScreen` | `/video-cv` | Portrait preview |
| `DashboardScreen` | `/dashboard` | Neural health (triggers `/health`) |

**Removed (confirmed absent):** Ready Player Me screen/config/service, `webview_flutter`, `/avatar/ready-player-me`.

### 1.2 Flutter — widgets & core

| File | Role |
|------|------|
| `lib/core/avatar_emotion.dart` | `AvatarEmotionState` (7 states), asset paths, `resolveAvatarEmotion()` |
| `lib/ui/shared/avatar_presence.dart` | Circular 2D avatar; template PNGs or portrait URL; **fake** mouth overlay when speaking |
| `lib/core/avatar_customization.dart` | Persona styles + coach voice tones (not VRM) |
| `lib/core/coaching_assessment.dart` | `emotion`, `avatarExpression`, scores from API |

### 1.3 Flutter — services & data

| File | Role |
|------|------|
| `lib/services/storage_service.dart` | `POST /storage/avatar`, `POST /storage/avatar/vroid-from-photo` |
| `lib/services/app_service.dart` | Coach sessions; persists `avatarEmotionState` after Gemini |
| `lib/services/tts_speaker.dart` | `isSpeaking` for UI sync |
| `lib/intelligence/api_coach_engine.dart` | `POST /ai/coach` |
| `lib/data/firebase_app_repository.dart` | Profile fields on `users/{uid}` |
| `lib/data/api_app_repository.dart` | Same via REST profile |
| `lib/ui/virtuomate_scope.dart` | `createVroidAvatarFromPhoto()`, avatar getters |

### 1.4 Flutter — dependencies (`pubspec.yaml`)

| Package | Avatar relevance |
|---------|------------------|
| `image_picker` | Selfie / PNG upload |
| `flutter_tts` | Speech; UI lip overlay only |
| `http` | API + image URLs |
| **None** | `vrm`, `unity_widget`, `rive`, `lottie`, `webview_flutter` |

**Assets:** `assets/avatars/*.png` (7 template expressions).

### 1.5 Backend (Firebase Functions)

| Endpoint | Purpose |
|----------|---------|
| `GET /health` | Lightweight Gemini text ping (image probe **skipped** by default) |
| `POST /ai/coach` | Gemini `generateCoachPackage` → feedback + assessment |
| `POST /ai/analyze-text` | Gemini assessment only |
| `POST /ai/analyze-speech` | Same on transcript |
| `POST /storage/avatar` | Upload portrait PNG/JPEG |
| `POST /storage/avatar/vroid-from-photo` | **Gemini image** cartoon/anime (experimental 2D, not real VRM) |

| Service | Purpose |
|---------|---------|
| `gemini.service.js` | Coach brain; `avatar_expression` in schema |
| `avatar_vroid.service.js` | 2D image generation (misnamed vs true VRM) |
| `coach.service.js` | Orchestration + local/OpenAI fallback |
| `video_cv_render.service.js` | FFmpeg **fake** lip-sync on 2D PNG |

**Removed (confirmed absent):** `avatar.service.js` (OpenAI cartoonize), RPM import routes.

### 1.6 Firestore (actual shape today)

```
users/{uid}
  avatarImageUrl          # 2D portrait URL
  avatarImageObjectPath
  avatarStyle             # persona label
  avatarUseTemplate       # bool
  avatarEmotionState      # string (last expression)
  avatarVroidStyle        # bool (set after Gemini image gen)
  voiceProfile, voiceGender, ...

users/{uid}/sessions/{id}     # coaching_history (sessions)
users/{uid}/assessments/{id}  # analyze-text/speech snapshots
users/{uid}/videoCvJobs/{id}
```

**Not present yet:** `avatar_profile`, `avatar_preferences`, `vrmUrl`, `vseeFaceConfig`, subcollection `coaching_history` (sessions serve this role).

### 1.7 Legacy / experimental systems — removal status

| System | Status in repo |
|--------|----------------|
| Ready Player Me | **Removed** |
| PlayerZero / Avaturn / Tripo / Meshy runtime | **Never integrated** |
| Rive / Lottie avatar | **Not present** |
| OpenAI cartoonize | **Removed** |
| Gemini 2D portrait (`vroid-from-photo`) | **Active** — treat as optional 2D fallback, not official VRM |

### 1.8 Gap vs target architecture

| Target | Current |
|--------|---------|
| VRoid Studio → `.vrm` file | Manual link only; no VRM upload field |
| VSeeFace expressions + lip sync | Not integrated |
| `AvatarState` with idle/listening | `AvatarEmotionState` (no idle/listening) |
| Gemini `avatar_state` field | `avatar_expression` + `emotion` (partial) |
| No fake lip sync for VRM path | 2D mouth overlay + FFmpeg fake lips still active |

---

## 2. Migration plan

### Phase A — Document & model (low risk)

1. Adopt this doc as source of truth; deprecate conflicting lines in `AVATAR_SYSTEM.md`.  
2. Add `AvatarState` enum (8 states) alongside or replacing `AvatarEmotionState`.  
3. Extend Gemini schema: `avatar_state` (canonical) + keep `avatar_expression` alias.  
4. Add Firestore fields: `avatarVrmUrl`, `avatarMode` (`vrm` \| `2d_template` \| `2d_portrait`), `vseeFaceEnabled`.

### Phase B — VRM asset pipeline (no Flutter 3D yet)

1. Avatar screen: upload `.vrm` to Storage `avatars/{uid}/model.vrm`.  
2. Instructions UI: VRoid export steps + VSeeFace import.  
3. Remove or hide **Cartoonize from photo** behind “2D fallback (uses AI credits)”.

### Phase C — VSeeFace bridge (desktop demo)

1. Research VSeeFace OSC / VMC protocol for blendshapes.  
2. Small **Windows helper** or script: TTS → viseme/OSC → VSeeFace (demo only).  
3. Flutter desktop (optional): show “Connect VSeeFace” status via localhost WebSocket.

### Phase D — In-app 3D (post-FYP optional)

1. Evaluate `flutter_unity_widget` or native VRM viewer.  
2. Only if FYP requires avatar *inside* APK without VSeeFace.

### Preserve (do not delete)

- `gemini.service.js` coach package  
- `AvatarPresence` as **2D fallback**  
- `sessions` + assessment persistence  
- Video CV pipeline (update copy: 2D export, not VSeeFace)

---

## 3. Files affected (planned)

### New

| Path | Purpose |
|------|---------|
| `docs/AVATAR_VRM_ARCHITECTURE.md` | Flow diagrams, folder layout |
| `lib/core/avatar_state.dart` | Official 8-state enum + Gemini mapper |
| `lib/models/avatar_profile.dart` | VRM URL, mode, preferences |
| `lib/services/vrm_storage_service.dart` | Upload/download `.vrm` |
| `tool/vseeface/README.md` | OSC demo setup |
| `test/avatar_state_test.dart` | State mapping tests |

### Modify

| Path | Change |
|------|--------|
| `lib/core/avatar_emotion.dart` | Migrate → `avatar_state.dart` or alias |
| `lib/ui/shared/avatar_presence.dart` | Use `AvatarState`; gate fake lips to `mode == 2d` |
| `lib/ui/screens/avatar_screen.dart` | VRM upload + VRoid/VSeeFace guide |
| `lib/data/*_app_repository.dart` | New Firestore fields |
| `virtuomate_backend_firebase/src/app.js` | VRM upload route; profile schema |
| `virtuomate_backend_firebase/src/services/gemini.service.js` | `avatar_state` in JSON schema |
| `docs/AVATAR_SYSTEM.md` | Point to VRM official arch |

### Deprecate / hide (not necessarily delete in Phase A)

| Path | Action |
|------|--------|
| `avatar_vroid.service.js` | Dev-only 2D; not “VRoid Studio VRM” |
| Fake lip overlay in `avatar_presence.dart` | Disable when `avatarMode == vrm` |
| `POST /storage/avatar/vroid-from-photo` | Optional feature flag |

---

## 4. Code changes (summary — not applied in Phase 1)

Phase 1 is **audit only**. Subsequent PRs should implement Phase A→C in order.

---

## 5. Testing plan

### Unit

| Area | Tests |
|------|-------|
| `AvatarState` ↔ Gemini emotion mapping | `test/avatar_state_test.dart` |
| `resolveAvatarState(isSpeaking, isListening, gemini)` | Override rules |
| Firestore serialization | `avatar_profile` round-trip |

### Integration

| Flow | Assert |
|------|--------|
| `POST /ai/coach` | Response includes `avatar_state` |
| Profile save | `avatarVrmUrl` persists |
| Session complete | `avatarEmotionState` / `avatar_state` updated |

### Functional

| Case | Pass criteria |
|------|----------------|
| Template mode | 8 PNG states render, no overflow |
| Portrait mode | Network/local image loads |
| VRM mode (Phase B) | URL stored; UI shows 2D placeholder + “Open in VSeeFace” |
| Coach chat | State changes after reply; TTS → speaking → idle |

### Performance

- `AvatarPresence` rebuilds only on `isSpeaking` / emotion change  
- No image-gen on `/health` (already fixed)  
- VSeeFace: N/A in Flutter metrics; measure OSC bridge latency on desktop

---

## 6. Demo strategy (FYP)

### Setup (examiner laptop + phone)

1. **Phone:** VirtuoMate → Coach chat / Session with 2D avatar + live Gemini.  
2. **Laptop:** VSeeFace with same `.vrm` exported from VRoid.  
3. **Bridge (Phase C):** OSC script driven by coach TTS or prerecorded WAV.

### Narrative script

1. “User creates identity in **VRoid Studio**.”  
2. “We export **VRM** — industry standard for VTubing.”  
3. “**VSeeFace** provides real facial expressions and lip sync.”  
4. “**VirtuoMate + Gemini** decides emotional state from coaching text.”  
5. “**Flutter + Firebase** stores profile and syncs state; mobile uses 2D fallback.”

### Fallback if VSeeFace fails

- Continue on phone with `AvatarPresence` + Gemini states.  
- Show pre-recorded VSeeFace clip or screenshots in appendix.

---

## 7. Risks

| Risk | Mitigation |
|------|------------|
| VSeeFace Windows-only | Document dual-device demo; 2D fallback on phone |
| No in-app VRM | Honest architecture slide; optional Unity phase |
| Gemini image gen costly / “high demand” | Default off; VRM upload instead |
| Fake lip sync mislabeled | Rename UI: “2D preview only” |
| OSC bridge security | Localhost only; no production requirement |
| Firestore schema drift | Version field `avatarSchemaVersion: 2` |

---

## 8. Recommended implementation (priority order)

1. **Phase 1 (done):** This audit + team alignment on dual-mode demo.  
2. **Phase 2:** `AVATAR_VRM_ARCHITECTURE.md` — flows (expression, lip sync, emotion).  
3. **Phase 3:** `AvatarState` enum + mapper; extend Gemini `avatar_state`.  
4. **Phase 4:** Firestore `avatar_profile` fields + VRM Storage upload API.  
5. **Phase 5:** Avatar screen UX (VRoid/VSeeFace guide, VRM file picker).  
6. **Phase 6:** VSeeFace OSC bridge (Windows demo script).  
7. **Phase 7:** Responsiveness pass on `AvatarScreen` + coach screens.  
8. **Phase 8:** Tests per section 5.

**Do not** block FYP on embedding VSeeFace inside Flutter. **Do** show the full pipeline with a live desktop window + working mobile coach brain.

---

## Target architecture (official)

```
User Selfie (optional reference)
        ↓
VRoid Studio  →  export .vrm
        ↓
Firebase Storage  avatars/{uid}/model.vrm
        ↓
VSeeFace (desktop)  ← OSC/VMC ← TTS / demo bridge
        ↓
Blendshapes: speaking, emotions
        ↓
Gemini /ai/coach  →  avatar_state, scores, emotion
        ↓
Flutter VirtuoMate Avatar Module
   ├─ vrm mode: metadata + 2D thumbnail + VSeeFace status
   └─ 2d mode: AvatarPresence templates / portrait
```

---

## Lip sync — realistic plan (Phase 5, no fake sync for VRM)

| Layer | Mechanism |
|-------|-----------|
| **VSeeFace** | Audio input or OSC; drives mouth blendshapes on VRM |
| **Flutter TTS** | Does not move VRM unless bridge sends OSC |
| **Bridge** | Node/Python on demo PC: subscribe TTS events → map to VSeeFace parameters |
| **Video CV** | Keep FFmpeg on **2D PNG** for exported MP4 only |

Remove fake mouth overlay when `avatarMode == vrm` (keep for `2d` only).

---

*Next step when approved: Phase 2 architecture doc + Phase 3 `AvatarState` implementation.*
