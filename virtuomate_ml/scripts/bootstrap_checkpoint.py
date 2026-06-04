#!/usr/bin/env python3
"""Train a small DeBERTa checkpoint (runs in Cloud Build or local Linux)."""

from __future__ import annotations

import json
import random
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

OUT = ROOT / "models" / "checkpoints" / "best"

SAMPLE_TEXTS = [
    "I led a cross-functional team of eight and increased revenue by twenty percent.",
    "Um, I think maybe I was kind of nervous about the presentation, you know.",
    "We delivered the project on schedule by improving sprint planning and communication.",
    "I achieved measurable results including a thirty percent reduction in processing time.",
    "Honestly I am excited and happy about this opportunity to grow with your company.",
    "The situation was difficult and frustrating but we found a collaborative solution.",
    "In my previous role I managed stakeholders and presented quarterly results to leadership.",
    "STAR example: situation was declining sales, task was turnaround, action was new strategy, result was growth.",
    "I am confident in my technical skills and eager to contribute from day one.",
    "Our team launched the product successfully with strong user adoption and positive feedback.",
]


def label_row(text: str, coaching_emotion: str) -> dict:
    from ml.inference.feature_extractor import extract_linguistic_features
    from ml.inference.coach_assessor import features_to_scores

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
    }


def build_jsonl(n: int = 400) -> Path:
    emotions = ["confident", "anxious", "neutral", "focused", "happy", "concerned", "professional"]
    path = ROOT / "datasets" / "processed" / "bootstrap_train.jsonl"
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        for i in range(n):
            text = random.choice(SAMPLE_TEXTS)
            if i % 7 == 0:
                text = text + " " + random.choice(SAMPLE_TEXTS)
            emo = emotions[i % len(emotions)]
            f.write(json.dumps(label_row(text, emo), ensure_ascii=False) + "\n")
    return path


def main() -> None:
    if (OUT / "config.json").exists():
        print(f"Checkpoint already exists: {OUT}")
        return

    data = build_jsonl(400)
    print(f"Bootstrap dataset: {data} ({data.stat().st_size} bytes)")

    subprocess.check_call(
        [
            sys.executable,
            "-m",
            "ml.training.train_multitask",
            "--data",
            str(data),
            "--epochs",
            "1",
            "--batch-size",
            "8",
            "--output",
            str(OUT),
        ],
        cwd=str(ROOT),
    )

    if not (OUT / "config.json").exists():
        raise SystemExit("Training finished but config.json missing.")
    print(f"Checkpoint ready: {OUT}")


if __name__ == "__main__":
    main()
