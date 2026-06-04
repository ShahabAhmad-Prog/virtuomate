"""Linguistic feature engineering for coaching assessment."""

from __future__ import annotations

import math
import re
from collections import Counter

try:
    import textstat
except ImportError:
    textstat = None  # type: ignore

FILLERS = re.compile(
    r"\b(um+|uh+|er+|ah+|like|you know|i mean|sort of|kind of|basically|actually)\b",
    re.I,
)
HEDGES = re.compile(
    r"\b(maybe|perhaps|i think|i guess|probably|might|could be|not sure)\b",
    re.I,
)
ACHIEVEMENT = re.compile(
    r"\b(i led|i achieved|i delivered|i improved|i increased|i reduced|we launched|result)\b",
    re.I,
)
PASSIVE = re.compile(r"\b(was|were|been|being)\s+\w+ed\b", re.I)
REPEAT_WORD = re.compile(r"\b(\w{4,})\b", re.I)


def _safe_flesch(text: str) -> float:
    if not textstat:
        words = max(len(text.split()), 1)
        sents = max(len(re.split(r"[.!?]+", text)), 1)
        return min(100.0, max(0.0, 206.835 - 1.015 * (words / sents) - 84.6 * (5 / words)))
    try:
        return float(textstat.flesch_reading_ease(text))
    except Exception:
        return 50.0


def extract_linguistic_features(text: str) -> dict[str, float]:
    """Return normalized 0–1 features used by model and heuristic blender."""
    t = (text or "").strip()
    words = re.findall(r"[a-zA-Z']+", t)
    n_words = len(words)
    sentences = [s for s in re.split(r"[.!?]+", t) if s.strip()]
    n_sents = max(len(sentences), 1)

    fillers = len(FILLERS.findall(t))
    hedges = len(HEDGES.findall(t))
    achievements = len(ACHIEVEMENT.findall(t))
    passive = len(PASSIVE.findall(t))

    word_counts = Counter(w.lower() for w in words if len(w) > 3)
    repeated = sum(1 for c in word_counts.values() if c > 2)
    ttr = len(word_counts) / max(n_words, 1)

    avg_sent_len = n_words / n_sents
    flesch = _safe_flesch(t)

    return {
        "word_count": min(n_words / 200.0, 1.0),
        "avg_sentence_length": min(avg_sent_len / 30.0, 1.0),
        "flesch_reading_ease": max(0.0, min(flesch / 100.0, 1.0)),
        "type_token_ratio": min(ttr, 1.0),
        "filler_rate": min(fillers / max(n_words, 1) * 20, 1.0),
        "hedge_rate": min(hedges / max(n_words, 1) * 15, 1.0),
        "achievement_rate": min(achievements / max(n_words, 1) * 25, 1.0),
        "passive_rate": min(passive / max(n_sents, 1) * 3, 1.0),
        "repetition_score": min(repeated / max(len(word_counts), 1) * 5, 1.0),
        "char_entropy": min(_entropy(t) / 5.0, 1.0),
    }


def feature_vector(features: dict[str, float]) -> list[float]:
    keys = [
        "word_count",
        "avg_sentence_length",
        "flesch_reading_ease",
        "type_token_ratio",
        "filler_rate",
        "hedge_rate",
        "achievement_rate",
        "passive_rate",
        "repetition_score",
        "char_entropy",
    ]
    return [float(features.get(k, 0.0)) for k in keys]


def _entropy(text: str) -> float:
    if not text:
        return 0.0
    counts = Counter(text.lower())
    total = sum(counts.values())
    return -sum((c / total) * math.log2(c / total) for c in counts.values() if c)
