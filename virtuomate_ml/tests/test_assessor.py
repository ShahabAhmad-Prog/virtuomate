"""Smoke tests for coaching assessment (no GPU required)."""

from ml.inference.coach_assessor import assess_text
from ml.inference.feature_extractor import extract_linguistic_features


def test_empty_input():
    out = assess_text("")
    assert out["confidence_score"] == 0
    assert "No input" in out["weaknesses"][0]


def test_confident_interview_answer():
    text = (
        "I led a cross-functional team of eight and delivered a 20% revenue increase. "
        "We launched on schedule by improving our sprint planning and stakeholder communication."
    )
    out = assess_text(text, session_type="Interview")
    assert out["confidence_score"] >= 55
    assert out["clarity_score"] >= 50
    assert len(out["strengths"]) >= 1
    assert len(out["recommendations"]) >= 1


def test_anxious_fillers():
    text = "Um, I think maybe I was kind of nervous, you know, about the interview."
    feats = extract_linguistic_features(text)
    assert feats["filler_rate"] > 0.1
    out = assess_text(text)
    assert out["anxiety_score"] >= 40
