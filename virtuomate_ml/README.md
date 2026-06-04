# VirtuoMate Intelligence Engine

Production-oriented **AI Coaching Assessment** stack (not simple sentiment). Analyzes text and speech transcripts across confidence, clarity, professionalism, anxiety, communication effectiveness, and interview readiness.

## Quick start

```bash
cd virtuomate_ml
python -m venv .venv
# Windows: .venv\Scripts\activate
pip install -r requirements.txt

# Run API (linguistic assessor works immediately; train for neural hybrid)
python -m ml.api.main
# → http://localhost:8090/health
```

```bash
curl -X POST http://localhost:8090/analyze-text \
  -H "Content-Type: application/json" \
  -d "{\"text\":\"I led a team of five and increased revenue by 20 percent. I was nervous at first but delivered confidently.\",\"session_type\":\"Interview\"}"
```

## Training pipeline (Option A — full)

**Windows (recommended):**

```powershell
cd "D:\Virtomate Project\virtuomate_ml"
.\scripts\train-full.ps1
.\scripts\deploy-with-checkpoint.ps1
```

**Manual steps:**

```bash
# 1. Download GoEmotions (Google Cloud Storage)
python -m ml.datasets.download_goemotions --max-rows 50000

# 2. Pseudo-label coaching scores
python -m ml.datasets.prepare_coaching_labels

# 3. Fine-tune DeBERTa multi-task heads (GPU recommended; ~1–4 h on CPU)
python -m ml.training.train_multitask --epochs 3
```

Checkpoint output: `models/checkpoints/best/`. Deploy with `scripts/deploy-with-checkpoint.ps1` so Cloud Run loads your trained weights (`neural_checkpoint: true` on `/health`).

## Deploy (Cloud Run + Firebase)

See **`../virtuomate_backend_firebase/docs/INTELLIGENCE_CLOUD_SETUP.md`** for the full guide.

```powershell
cd "D:\Virtomate Project\virtuomate_ml"
.\scripts\deploy-cloud-run.ps1 -AllowPublic

cd "D:\Virtomate Project\virtuomate_backend_firebase"
.\scripts\wire-intelligence-engine.ps1 -EngineUrl "https://YOUR-CLOUD-RUN-URL"
```

## Layout

| Path | Purpose |
|------|---------|
| `ARCHITECTURE.md` | Datasets, model choice, training strategy |
| `ml/datasets/` | Download & labeling |
| `ml/training/` | PyTorch training |
| `ml/models/` | DeBERTa multi-task |
| `ml/inference/` | Features + assessor + speech |
| `ml/evaluation/` | MAE / F1 metrics |
| `ml/api/` | FastAPI REST |

## VirtuoMate integration

- **Backend:** `virtuomate_backend_firebase/src/services/assessment.service.js`
- **Routes:** `POST /ai/analyze-text`, `POST /ai/analyze-speech`, enriched `POST /ai/coach`
- **Flutter:** `lib/core/coaching_assessment.dart`
