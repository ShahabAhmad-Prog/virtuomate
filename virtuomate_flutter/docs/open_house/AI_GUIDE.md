# VirtuoMate — AI & Gemini Guide

## Architecture Decision

**Gemini is never called from Flutter.** All AI requests go through the backend Cloud Function. This protects API keys, enables prompt versioning, and allows fallback providers.

```
Flutter → ApiCoachEngine → POST /ai/coach → gemini.service.js → Gemini REST API
```

---

## Why Gemini?

| Reason | Detail |
|--------|--------|
| Speed | Flash models (`gemini-2.5-flash-lite`) — low latency for mobile |
| Cost | Google AI Studio free tier suitable for FYP/demo |
| JSON output | Structured assessment schema via system instructions |
| Multimodal | Text coaching + image generation for avatars |
| Google ecosystem | Integrates with Firebase/GCP deployment |

**Alternatives considered:**
- **OpenAI GPT-4o-mini** — implemented as fallback in `coach.service.js`
- **Local templates** — `MockCoachEngine` / linguistic fallback when API unavailable
- **virtuomate_ml (DeBERTa)** — optional Cloud Run for specialized NLP

**Limitations:**
- Quota/billing can block requests (429 errors)
- Requires network connectivity
- Partial Urdu support in coach responses
- No true realtime streaming in current implementation

---

## Assessment Schema

Defined in `gemini.service.js` as `ASSESSMENT_SCHEMA`:

```
confidence_score, clarity_score, professionalism_score, anxiety_score,
communication_score, interview_readiness_score (0-100 integers)
emotion: neutral|happy|thinking|confident|nervous|encouraging|focused|anxious|concerned
avatar_expression: neutral|happy|thinking|confident|nervous|encouraging|speaking
strengths[], weaknesses[], recommendations[] (max 4-5 each)
```

Flutter parses this via `CoachingAssessment.fromJson()` in `lib/core/coaching_assessment.dart`.

---

## Key Backend Files

| File | Role |
|------|------|
| `src/services/gemini.service.js` | Gemini API calls, JSON normalization |
| `src/services/coach.service.js` | Coach orchestration, OpenAI fallback |
| `src/services/assessment.service.js` | Assessment pipeline |
| `src/services/avatar_vroid.service.js` | Gemini image prompts for avatars |
| `src/app.js` | Route handlers `/ai/*` |

---

## Prompt Strategy

### 1. Coach Assessment (`assessCoachingText`)

**System instruction:** Expert career coach analyzing user speech/text for interview readiness.

**User prompt includes:**
- Session type (conversation, interview, presentation, role play)
- User's actual text/transcript
- Request for JSON matching `ASSESSMENT_SCHEMA`

**Temperature:** 0.35 (consistent scoring)

### 2. Coach Feedback Package (`generateCoachPackage`)

Combines assessment + natural language feedback in one Gemini call for efficiency.

### 3. Feedback Text (`generateCoachFeedbackText`)

Generates empathetic, actionable coach reply based on assessment scores.

### 4. Avatar Image (`avatar_vroid.service.js`)

Prompts like `vroidPrompt()`, `cartoonPrompt()` — instruct Gemini image model to produce professional cartoon/anime portrait from user photo.

### 5. Health Ping

Minimal prompt: `"Reply with exactly: OK"` — verifies API key without heavy token use.

---

## Request Flow (Coach Session)

```
1. User submits: "I am nervous about my interview tomorrow..."
2. Flutter: ApiCoachEngine.generateFeedbackDetailed(sessionType, prompt)
3. POST /ai/coach { sessionType, prompt, context? }
4. coach.service.js selects provider (gemini → openai → local)
5. geminiJsonRequest(systemInstruction, userPrompt)
6. Response parsed → normalizeAssessment()
7. Returns: { feedback, emotion, confidenceScore, assessment, provider: "gemini" }
8. Saved to Firestore session + returned to Flutter
9. avatar_emotion.dart maps emotion → AvatarEmotionState
```

---

## Scoring Logic

| Score | Meaning |
|-------|---------|
| confidence_score | Self-assurance in delivery |
| clarity_score | Structure and understandability |
| professionalism_score | Tone and workplace appropriateness |
| anxiety_score | Detected nervousness (higher = more anxious) |
| communication_score | Overall comms (derived if missing) |
| interview_readiness_score | Holistic interview prep level |

Scores clamped 0–100 in `clampScore()`.

---

## Emotion → Avatar Mapping

Flutter `lib/core/avatar_emotion.dart`:

- Gemini returns `emotion` or `avatar_expression`
- `resolveAvatarEmotion()` maps to 8 UI states
- Speaking/listening flags override static emotion
- Drives `AvatarCoachView` ring color and template image

---

## Flutter AI Integration Files

| File | Purpose |
|------|---------|
| `lib/intelligence/api_coach_engine.dart` | HTTP calls to `/ai/*` |
| `lib/intelligence/coach_engine.dart` | Interface + MockCoachEngine |
| `lib/core/coaching_assessment.dart` | Parse assessment JSON |
| `lib/core/avatar_emotion.dart` | Emotion mapping |
| `lib/services/app_service.dart` | Wires coach into sessions |

---

## Detecting Live vs Fallback AI

```dart
CoachFeedbackResult.isLiveProvider(provider)
// true when provider == 'gemini' or 'openai'
```

UI shows banner when not live — guides user to check API billing.

---

## API Key Configuration

**Backend only:**
```
GEMINI_API_KEY=... (from aistudio.google.com)
GEMINI_MODEL=gemini-2.5-flash-lite
```

Set via `.env` locally or Firebase Functions config in production.

**Never** commit keys to git or embed in Flutter dart-defines.

---

## Future Improvements

- Prompt templates in versioned JSON files
- Gemini streaming for faster perceived response
- Fine-tuned model on coaching transcripts
- On-device Gemini Nano for offline hints
- A/B testing prompts via Remote Config
