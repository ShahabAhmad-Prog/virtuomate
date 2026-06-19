# VirtuoMate — Database Guide (Firestore)

## Collection Hierarchy

```
firestore.root
└── users/
    └── {userId}/
        ├── (document fields — profile)
        ├── sessions/
        │   └── {sessionId}
        ├── coachChat/
        │   └── {messageId}
        ├── assessments/
        │   └── {assessmentId}
        └── videoCvJobs/
            └── {jobId}
```

---

## Collection: `users/{userId}`

**Purpose:** Master user profile and app state.

**CRUD:**
| Operation | Who |
|-----------|-----|
| Create | `POST /user/bootstrap` (Admin SDK) |
| Read | Owner, admin; client direct in Firestore mode |
| Update | Owner via API `PUT /user/profile` or Firestore merge |
| Delete | `DELETE /user` removes doc + subcollections |

**Relationships:**
- Parent of all subcollections
- Linked to Firebase Auth UID as document ID

**Protected fields (client cannot write):**
- `isPremium`, `premiumPlan`, `premiumActivatedAt`, `videoCvCount`

---

## Collection: `users/{uid}/sessions`

**Purpose:** Coaching session history for analytics and feedback.

**Fields:**
| Field | Type |
|-------|------|
| type | string |
| prompt | string |
| feedback | string |
| emotion | string |
| confidenceScore | number |
| assessment | map (optional) |
| createdAt | timestamp |

**CRUD:** Created via `POST /sessions`; read via `GET /sessions` or Firestore listener.

**Used by:** AnalyticsScreen, FeedbackScreen, Dashboard recent sessions.

---

## Collection: `users/{uid}/coachChat`

**Purpose:** Multi-turn coach chat messages.

**Fields:** `isUser`, `text`, `emotion?`, `createdAt`

**CRUD:** Flutter `ChatService` writes directly (Firestore mode).

---

## Collection: `users/{uid}/assessments`

**Purpose:** Detailed AI assessment snapshots.

**Fields:** All scoring fields from Gemini schema + `provider`, `transcript`, `sessionType`, `createdAt`

**CRUD:** Server write only (security rules: `write: false` for clients).

---

## Collection: `users/{uid}/videoCvJobs`

**Purpose:** Async video CV render jobs.

**Fields:** `status`, `script`, `draft`, `downloadUrl`, `videoDownloadUrl`, `renderError`, timestamps

**CRUD:** Created by client; status updated by server (FFmpeg pipeline).

---

## Cloud Storage (Not Firestore)

| Bucket path | Purpose |
|-------------|---------|
| `avatars/{uid}/photo.jpg` | User/coach portrait |
| `video-cv/{uid}/renders/{jobId}.mp4` | Rendered video CV |

---

## Indexes

`firestore.indexes.json` — empty (single-field queries only).

---

## Flutter Repository Mapping

| Repository method | Firestore/API |
|-------------------|---------------|
| `saveSession()` | sessions subcollection |
| `savePreferences()` | users.preferences map |
| `sessions()` | Query sessions orderBy createdAt desc |
| `hydrate()` | Read full user doc or GET /user/profile |

---

## Sample Document (users/{uid})

```json
{
  "email": "user@example.com",
  "displayName": "Alex Coach",
  "avatarStyle": "Professional",
  "avatarImageUrl": "https://storage.googleapis.com/...",
  "avatarUseTemplate": false,
  "voiceProfile": "confident-neutral",
  "voiceGender": "female",
  "isPremium": false,
  "missionProgress": 65,
  "preferences": {
    "languageCode": "en",
    "textScale": 1.0,
    "highContrast": false,
    "emailNotifications": true
  },
  "videoCvDraft": { "fullName": "", "headline": "" }
}
```
