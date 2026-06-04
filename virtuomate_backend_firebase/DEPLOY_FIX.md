# Fix Firebase Functions deploy errors

## Your current error

`Build failed: Build error details not available` on **Gen-1** `api` — almost always **missing IAM roles** on the **Default compute service account** (used as the build account). The real error is in Cloud Build logs (link in terminal).

---

## Step 1 — Add ALL required roles (Google Cloud Console)

Open IAM: https://console.cloud.google.com/iam-admin/iam?project=virtuomate

Edit **Default compute service account**:

`671835013493-compute@developer.gserviceaccount.com`

Add **every** role below (if not already present):

| Role | Why |
|------|-----|
| **Cloud Build Service Account** | Runs the function build |
| **Storage Object Viewer** | Reads `gcf-sources-…` bucket |
| **Artifact Registry Writer** | Pushes Docker image to `gcf-artifacts` |
| **Logs Writer** | Writes Cloud Build logs |

Save. Wait **2–3 minutes**.

### Cloud Build service account (second principal)

Edit: `671835013493@cloudbuild.gserviceaccount.com`

Add if missing:

| Role |
|------|
| **Cloud Functions Admin** (or Developer) |
| **Artifact Registry Writer** |
| **Service Account User** (on the compute SA — see below) |

**Service Account User on compute SA:**

1. Open: https://console.cloud.google.com/iam-admin/serviceaccounts?project=virtuomate
2. Click **671835013493-compute@…** → **Permissions** tab → **Grant access**
3. Principal: `671835013493@cloudbuild.gserviceaccount.com`
4. Role: **Service Account User** → Save

### Bucket (if you still see “Access to bucket gcf-sources denied”)

https://console.cloud.google.com/storage/browser/gcf-sources-671835013493-us-central1?project=virtuomate

→ **Permissions** → grant `671835013493-compute@developer.gserviceaccount.com` → **Storage Object Viewer**

---

## Step 2 — Check Cloud Build log (optional)

Open the link from your terminal, e.g.:

https://console.cloud.google.com/cloud-build/builds;region=us-central1/b9b60ad2-5ab7-48ee-83ad-ac379b48bc03?project=671835013493

Look for `DENIED`, `permission`, or `npm ERR!` at the bottom.

---

## Step 3 — Deploy again

```cmd
D:
cd "D:\Virtomate Project\virtuomate_backend_firebase"
firebase deploy --only functions
```

Success:

```text
+  functions[api(us-central1)]: Successful update operation.
Function URL (api): https://us-central1-virtuomate.cloudfunctions.net/api
```

Test: https://us-central1-virtuomate.cloudfunctions.net/api/health  
Expected: `{"ok":true,"backend":"virtuomate-api",...}`

---

## 403 Forbidden on `/api/health`

The function deployed but is **not public**. Fix in code: `invoker: 'public'` in `index.js` `runWith(...)`, then:

```cmd
firebase deploy --only functions
```

**Or** fix in Console (no redeploy):

1. Open: https://console.cloud.google.com/functions/details/us-central1/api?project=virtuomate&tab=permissions
2. **Permissions** → **Add principal**
3. Principal: `allUsers`
4. Role: **Cloud Functions Invoker** → Save
5. Confirm “Allow public access” if prompted

Refresh https://us-central1-virtuomate.cloudfunctions.net/api/health

If your org blocks `allUsers`, ask the project owner to allow public Cloud Functions or use authenticated calls only.

---

## Code notes

- `index.js` uses `require('firebase-functions/v1')` (required for firebase-functions v7).
- API URL: `https://us-central1-virtuomate.cloudfunctions.net/api`
- Do **not** switch Gen-2 ↔ Gen-1 without deleting the old function first:

```cmd
firebase functions:delete api --region us-central1 --force
```

---

## gcloud (if you install Google Cloud SDK)

```cmd
gcloud config set project virtuomate

gcloud projects add-iam-policy-binding virtuomate --member=serviceAccount:671835013493-compute@developer.gserviceaccount.com --role=roles/cloudbuild.builds.builder

gcloud projects add-iam-policy-binding virtuomate --member=serviceAccount:671835013493-compute@developer.gserviceaccount.com --role=roles/storage.objectViewer

gcloud projects add-iam-policy-binding virtuomate --member=serviceAccount:671835013493-compute@developer.gserviceaccount.com --role=roles/artifactregistry.writer

gcloud projects add-iam-policy-binding virtuomate --member=serviceAccount:671835013493-compute@developer.gserviceaccount.com --role=roles/logging.logWriter

gcloud iam service-accounts add-iam-policy-binding 671835013493-compute@developer.gserviceaccount.com --member=serviceAccount:671835013493@cloudbuild.gserviceaccount.com --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding virtuomate --member=serviceAccount:671835013493@cloudbuild.gserviceaccount.com --role=roles/artifactregistry.writer

firebase deploy --only functions
```

---

## Local API (no deploy)

```cmd
npm start
```

Flutter: `BACKEND_BASE_URL=http://127.0.0.1:8080` (Android emulator: `http://10.0.2.2:8080`)
