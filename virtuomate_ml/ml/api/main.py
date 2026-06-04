"""
VirtuoMate Intelligence Engine — FastAPI service.

Endpoints:
  POST /analyze-text
  POST /analyze-speech
  GET  /health
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

# Allow running as `python -m ml.api.main` from virtuomate_ml root
ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from ml.api.schemas import AnalyzeTextRequest, CoachingAssessmentResponse
from ml.inference.coach_assessor import assess_text

app = FastAPI(
    title="VirtuoMate Intelligence Engine",
    version="1.0.0",
    description="AI Coaching Assessment — multi-dimensional communication analysis",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.environ.get("CORS_ORIGIN", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    from ml.inference.coach_assessor import CHECKPOINT_DIR

    return {
        "status": "ok",
        "engine": "virtuomate-intelligence",
        "neural_checkpoint": (CHECKPOINT_DIR / "config.json").exists(),
        "whisper": bool(os.environ.get("OPENAI_API_KEY")),
    }


@app.post("/analyze-text", response_model=CoachingAssessmentResponse)
def analyze_text(body: AnalyzeTextRequest):
    result = assess_text(
        body.text,
        session_type=body.session_type,
        context=body.context,
    )
    return CoachingAssessmentResponse(**result)


@app.post("/analyze-speech", response_model=CoachingAssessmentResponse)
async def analyze_speech(
    file: UploadFile = File(...),
    session_type: str = Form("Conversation"),
    duration_sec: float | None = Form(None),
    transcript: str | None = Form(None),
):
    from ml.inference.speech import estimate_voice_prosody, transcribe_audio

    if transcript and transcript.strip():
        text = transcript.strip()
        stt_provider = "client-transcript"
    else:
        try:
            text, stt_provider = transcribe_audio(file.file, filename=file.filename or "audio.wav")
        except RuntimeError as e:
            raise HTTPException(status_code=501, detail=str(e)) from e

    if not text:
        raise HTTPException(status_code=400, detail="Empty transcript after speech recognition.")

    result = assess_text(text, session_type=session_type)
    prosody = estimate_voice_prosody(text, duration_sec)
    result["transcript"] = text
    result["speaking_pace_wpm"] = prosody["speaking_pace_wpm"]
    result["pause_frequency"] = prosody["pause_frequency"]
    result["provider"] = f"{result['provider']}+{stt_provider}"
    return CoachingAssessmentResponse(**result)


def run():
    import uvicorn

    # Cloud Run sets PORT=8080; local default 8090
    port = int(os.environ.get("PORT", "8090"))
    uvicorn.run("ml.api.main:app", host="0.0.0.0", port=port, reload=False)


if __name__ == "__main__":
    run()
