"""Evaluation metrics for coaching assessment."""

from __future__ import annotations

import numpy as np
from sklearn.metrics import f1_score, mean_absolute_error


def regression_mae(y_true: list[float], y_pred: list[float]) -> float:
    return float(mean_absolute_error(y_true, y_pred))


def emotion_macro_f1(y_true: list[int], y_pred: list[int], labels: list[int] | None = None) -> float:
    return float(f1_score(y_true, y_pred, average="macro", labels=labels, zero_division=0))


def coaching_report(rows: list[dict]) -> dict[str, float]:
    """Aggregate MAE across dimensions from list of {target, pred} dicts."""
    dims = [
        "confidence_score",
        "clarity_score",
        "professionalism_score",
        "anxiety_score",
        "communication_score",
    ]
    report = {}
    for dim in dims:
        t = [r["target"][dim] for r in rows if dim in r["target"]]
        p = [r["pred"][dim] for r in rows if dim in r["pred"]]
        if t and p:
            report[f"mae_{dim}"] = regression_mae(t, p)
    return report
