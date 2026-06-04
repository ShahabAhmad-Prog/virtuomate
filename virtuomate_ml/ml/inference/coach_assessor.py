"""Coaching assessment: feature heuristics, optional neural model, narrative output."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from ml.datasets.registry import COACHING_EMOTIONS
from ml.inference.feature_extractor import extract_linguistic_features, feature_vector

CHECKPOINT_DIR = Path(__file__).resolve().parents[2] / "models" / "checkpoints" / "best"

_model = None
_tokenizer = None


def features_to_scores(features: dict[str, float], emotion_hint: str = "neutral") -> dict[str, int]:
    """Derive 0–100 coaching scores from linguistic features (training labels & fallback)."""
    f = features
    clarity = int(
        100
        * (
            0.35 * f["flesch_reading_ease"]
            + 0.25 * (1 - f["filler_rate"])
            + 0.2 * f["type_token_ratio"]
            + 0.2 * (1 - min(f["avg_sentence_length"], 1.0))
        )
    )
    confidence = int(
        100
        * (
            0.3 * f["achievement_rate"]
            + 0.25 * (1 - f["hedge_rate"])
            + 0.2 * f["word_count"]
            + 0.15 * (1 - f["filler_rate"])
            + 0.1 * f["type_token_ratio"]
        )
    )
    professionalism = int(
        100
        * (
            0.35 * (1 - f["filler_rate"])
            + 0.25 * (1 - f["hedge_rate"])
            + 0.2 * f["type_token_ratio"]
            + 0.2 * (1 - f["passive_rate"])
        )
    )
    anxiety = int(
        100
        * (
            0.4 * f["hedge_rate"]
            + 0.35 * f["filler_rate"]
            + 0.15 * f["repetition_score"]
            + 0.1 * (1 - f["word_count"])
        )
    )
    communication = int((clarity * 0.4 + confidence * 0.35 + professionalism * 0.25))
    interview_readiness = int(
        (confidence * 0.35 + professionalism * 0.3 + clarity * 0.2 + (100 - anxiety) * 0.15)
    )

    if emotion_hint == "anxious":
        anxiety = min(100, anxiety + 12)
        confidence = max(0, confidence - 8)
    elif emotion_hint == "confident":
        confidence = min(100, confidence + 10)
        anxiety = max(0, anxiety - 10)

    def clamp(x: int) -> int:
        return max(0, min(100, x))

    return {
        "confidence_score": clamp(confidence),
        "clarity_score": clamp(clarity),
        "professionalism_score": clamp(professionalism),
        "anxiety_score": clamp(anxiety),
        "communication_score": clamp(communication),
        "interview_readiness_score": clamp(interview_readiness),
    }


def _load_neural():
    global _model, _tokenizer
    if _model is not None:
        return True
    if not (CHECKPOINT_DIR / "config.json").exists():
        return False
    try:
        import torch
        from transformers import AutoConfig, AutoTokenizer

        from ml.models.multitask_deberta import CoachingMultiTaskModel

        _tokenizer = AutoTokenizer.from_pretrained(str(CHECKPOINT_DIR))
        config = AutoConfig.from_pretrained(str(CHECKPOINT_DIR))
        _model = CoachingMultiTaskModel(config)
        weights = CHECKPOINT_DIR / "model.safetensors"
        if not weights.exists():
            weights = CHECKPOINT_DIR / "pytorch_model.bin"
        if weights.exists():
            if str(weights).endswith(".safetensors"):
                from safetensors.torch import load_file

                state = load_file(str(weights))
            else:
                try:
                    state = torch.load(weights, map_location="cpu", weights_only=True)
                except TypeError:
                    state = torch.load(weights, map_location="cpu")
            _model.load_state_dict(state, strict=False)
        else:
            _model = CoachingMultiTaskModel.from_pretrained(str(CHECKPOINT_DIR))
        _model.eval()
        return True
    except Exception:
        return False


def _neural_scores(text: str) -> dict[str, Any] | None:
    if not _load_neural():
        return None
    import torch

    enc = _tokenizer(
        text,
        truncation=True,
        max_length=256,
        padding="max_length",
        return_tensors="pt",
    )
    feats = torch.tensor([feature_vector(extract_linguistic_features(text))], dtype=torch.float32)
    with torch.no_grad():
        out = _model(enc["input_ids"], enc["attention_mask"], feats)
    emotion_idx = int(out["emotion_logits"].argmax(dim=-1).item())
    emotion = COACHING_EMOTIONS[emotion_idx] if emotion_idx < len(COACHING_EMOTIONS) else "neutral"
    return {
        "confidence_score": int(out["confidence"].item()),
        "clarity_score": int(out["clarity"].item()),
        "professionalism_score": int(out["professionalism"].item()),
        "anxiety_score": int(out["anxiety"].item()),
        "communication_score": int(out["communication"].item()),
        "interview_readiness_score": int(out["interview_readiness"].item()),
        "emotion": emotion,
        "provider": "neural",
    }


def _blend(heuristic: dict[str, int], neural: dict[str, Any]) -> dict[str, int]:
    w = 0.65
    keys = [
        "confidence_score",
        "clarity_score",
        "professionalism_score",
        "anxiety_score",
        "communication_score",
        "interview_readiness_score",
    ]
    out = {}
    for k in keys:
        out[k] = int(w * neural[k] + (1 - w) * heuristic[k])
    return out


def _strengths_weaknesses(features: dict[str, float], scores: dict[str, int]) -> tuple[list[str], list[str]]:
    strengths: list[str] = []
    weaknesses: list[str] = []
    if scores["confidence_score"] >= 70:
        strengths.append("Confident delivery with assertive phrasing")
    if scores["clarity_score"] >= 70:
        strengths.append("Clear sentence structure and readable flow")
    if features["achievement_rate"] > 0.15:
        strengths.append("Uses outcome-oriented language")
    if features["type_token_ratio"] > 0.45:
        strengths.append("Strong vocabulary variety")

    if features["filler_rate"] > 0.2:
        weaknesses.append("Frequent filler words reduce perceived authority")
    if features["hedge_rate"] > 0.15:
        weaknesses.append("Hedging language signals uncertainty")
    if scores["clarity_score"] < 55:
        weaknesses.append("Responses could be more concise and structured")
    if features["passive_rate"] > 0.25:
        weaknesses.append("Passive voice weakens ownership of achievements")
    if scores["anxiety_score"] > 60:
        weaknesses.append("Anxiety markers detected — practice pacing and breathing")

    if not strengths:
        strengths.append("Good foundation — keep practicing structured answers")
    if not weaknesses:
        weaknesses.append("Fine-tune pacing and add one measurable result per answer")
    return strengths[:4], weaknesses[:4]


def _recommendations(
    scores: dict[str, int],
    weaknesses: list[str],
    session_type: str = "Conversation",
) -> list[str]:
    recs: list[str] = []
    if scores["anxiety_score"] > 55:
        recs.append("Pause briefly before key points; practice answers aloud twice")
    if scores["clarity_score"] < 65:
        recs.append("Use a three-part structure: context → action → result")
    if "filler" in " ".join(weaknesses).lower():
        recs.append("Replace filler words with a one-second pause")
    if "Interview" in session_type:
        recs.append("Prepare two STAR stories with metrics (%, time, revenue)")
        recs.append("End answers with why you are a strong fit for the role")
    elif "Presentation" in session_type:
        recs.append("Open with a hook; close with a clear call to action")
    else:
        recs.append("Add one measurable achievement to strengthen impact")
    if scores["interview_readiness_score"] < 60:
        recs.append("Research the company and prepare three smart questions for the panel")
    return recs[:5]


def assess_text(
    text: str,
    session_type: str = "Conversation",
    context: str | None = None,
) -> dict[str, Any]:
    """Full coaching assessment JSON for API and VirtuoMate integration."""
    t = (text or "").strip()
    if not t:
        return {
            "confidence_score": 0,
            "clarity_score": 0,
            "professionalism_score": 0,
            "anxiety_score": 0,
            "communication_score": 0,
            "interview_readiness_score": 0,
            "emotion": "neutral",
            "strengths": [],
            "weaknesses": ["No input provided"],
            "recommendations": ["Share a specific example so the coach can assess your delivery"],
            "provider": "empty",
            "transcript": "",
        }

    if context:
        t = f"{context.strip()}\n\n{t}"

    features = extract_linguistic_features(t)
    heuristic = features_to_scores(features, "neutral")
    neural = _neural_scores(t)

    if neural:
        scores = _blend(heuristic, neural)
        emotion = neural["emotion"]
        provider = "hybrid"
    else:
        scores = heuristic
        emotion = _emotion_from_scores(scores, features)
        provider = "linguistic"

    strengths, weaknesses = _strengths_weaknesses(features, scores)
    recommendations = _recommendations(scores, weaknesses, session_type)

    return {
        **scores,
        "emotion": emotion,
        "strengths": strengths,
        "weaknesses": weaknesses,
        "recommendations": recommendations,
        "provider": provider,
        "transcript": text.strip(),
        "speaking_pace_wpm": None,
        "pause_frequency": None,
    }


def _emotion_from_scores(scores: dict[str, int], features: dict[str, float]) -> str:
    if scores["anxiety_score"] >= 65:
        return "anxious"
    if scores["confidence_score"] >= 75:
        return "confident"
    if features["achievement_rate"] > 0.2:
        return "professional"
    if scores["clarity_score"] >= 70:
        return "focused"
    return "neutral"


def assess_from_file(path: Path, **kwargs: Any) -> dict[str, Any]:
    return assess_text(path.read_text(encoding="utf-8"), **kwargs)
