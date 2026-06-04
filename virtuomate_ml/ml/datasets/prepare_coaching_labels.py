#!/usr/bin/env python3
"""Build multi-task training JSONL with pseudo coaching scores from text features."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from ml.inference.feature_extractor import extract_linguistic_features
from ml.inference.coach_assessor import features_to_scores

DEFAULT_IN = Path(__file__).resolve().parents[2] / "datasets" / "raw" / "goemotions.jsonl"
DEFAULT_OUT = Path(__file__).resolve().parents[2] / "datasets" / "processed" / "coaching_train.jsonl"


def label_row(text: str, coaching_emotion: str) -> dict:
    feats = extract_linguistic_features(text)
    scores = features_to_scores(feats, coaching_emotion)
    return {
        "text": text,
        "coaching_emotion": coaching_emotion,
        "confidence_score": scores["confidence_score"],
        "clarity_score": scores["clarity_score"],
        "professionalism_score": scores["professionalism_score"],
        "anxiety_score": scores["anxiety_score"],
        "communication_score": scores["communication_score"],
        "interview_readiness_score": scores["interview_readiness_score"],
        "features": feats,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=DEFAULT_IN)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUT)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    n = 0
    with open(args.input, encoding="utf-8") as fin, open(args.output, "w", encoding="utf-8") as fout:
        for line in fin:
            row = json.loads(line)
            labeled = label_row(row["text"], row.get("coaching_emotion", "neutral"))
            fout.write(json.dumps(labeled, ensure_ascii=False) + "\n")
            n += 1
    print(f"Prepared {n} labeled rows -> {args.output}")


if __name__ == "__main__":
    main()
