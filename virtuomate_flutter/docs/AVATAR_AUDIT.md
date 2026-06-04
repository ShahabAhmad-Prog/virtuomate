# VirtuoMate Avatar System — Audit (pre-migration)

## 1. Avatar-related files

### Flutter (remove / replace)
| File | Role | Action |
|------|------|--------|
| `lib/ui/screens/ready_player_me_avatar_screen.dart` | RPM WebView creator | **Delete** |
| `lib/config/ready_player_me_config.dart` | RPM subdomain config | **Delete** |
| `lib/services/ready_player_me_service.dart` | RPM postMessage parser | **Delete** |
| `test/ready_player_me_service_test.dart` | RPM tests | **Delete** |
| `docs/READY_PLAYER_ME.md` | RPM docs | **Delete** |
| `docs/AVATAR_CARTOON.md` | OpenAI cartoon docs | **Delete** → `AVATAR_SYSTEM.md` |

### Flutter (keep / update)
| File | Role | Action |
|------|------|--------|
| `lib/ui/screens/avatar_screen.dart` | Avatar builder UI | **Rewrite** (selfie + templates) |
| `lib/ui/shared/avatar_presence.dart` | Coach avatar widget | **Update** (emotion assets) |
| `lib/core/avatar_customization.dart` | Voice/persona tones | **Keep** |
| `lib/services/storage_service.dart` | Selfie upload | **Keep** (remove cartoon/RPM) |
| `lib/data/*_app_repository.dart` | Profile persistence | **Update** fields |
| `lib/ui/virtuomate_scope.dart` | Avatar API surface | **Update** |
| `lib/services/video_cv_render_service.dart` | Video CV portrait | **Keep** (selfie URL only) |

### Backend (remove)
| File | Role | Action |
|------|------|--------|
| `src/services/avatar.service.js` | OpenAI cartoonize | **Delete** |
| `scripts/test-avatar-render.js` | Video CV test (not avatar gen) | **Keep** |

### Backend endpoints to remove
- `POST /storage/avatar/cartoonize`
- `POST /storage/avatar/rpm-import`

### Backend endpoints to keep
- `POST /storage/avatar` (selfie upload)
- `POST /ai/coach` (Gemini brain)
- `POST /ai/analyze-text`

## 2. Packages (Flutter)

| Package | Avatar use | Action |
|---------|------------|--------|
| `webview_flutter` | RPM only | **Remove** |
| `image_picker` | Selfie upload | **Keep** |
| `http` | Upload / CDN | **Keep** |

No PlayerZero, Unity, VRM, or VRoid packages found in the project.

## 3. Dependencies (backend)

| Dependency | Avatar use | Action |
|------------|------------|--------|
| OpenAI (`avatar.service.js`) | Cartoon generation | **Remove** from avatar path |
| Gemini (`gemini.service.js`) | Coach + emotion | **Extend** (avatar_expression) |
| `gtts` / FFmpeg | Video CV only | **Keep** |

## 4. Services

| Service | Action |
|---------|--------|
| `StorageService` | Selfie upload only |
| `ReadyPlayerMeService` | Delete |
| `coach.service.js` / `gemini.service.js` | Emotion-driven avatar brain |
| `video_cv_render.service.js` | Uses `avatarImageUrl` (unchanged) |

## 5. Firestore (`users/{uid}`)

| Field | Action |
|-------|--------|
| `avatarImageUrl` | Keep (selfie) |
| `avatarStyle` | Keep (persona/voice) |
| `avatarCartoonized` | **Remove usage** |
| `avatarRpmGlbUrl` | **Remove usage** |
| `avatarUseTemplate` | **Add** (bool) |
| `avatarEmotionState` | **Add** (string) |
| `voiceProfile`, `voiceGender` | Keep |

Storage path: `avatars/{uid}/...` (unchanged)

## 6. Routes

| Route | Action |
|-------|--------|
| `/avatar` | Keep |
| `/avatar/ready-player-me` | **Delete** |

## 7. Widgets

| Widget | Action |
|--------|--------|
| `AvatarPresence` | Emotion asset resolver |
| `MvpWelcomeLogo` | Unrelated branding — keep |
| `CoachToneSelector` | Keep |

## 8. Models

| Model | Action |
|-------|--------|
| `CoachingAssessment` | Already has emotion + scores |
| `SessionRecord.emotion` | Drives live avatar state |
| New `AvatarEmotionState` enum | Add |

---

*Migration applied in same commit series as this audit.*
