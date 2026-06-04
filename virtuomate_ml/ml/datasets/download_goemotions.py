#!/usr/bin/env python3
"""Download and normalize GoEmotions for VirtuoMate training."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
from urllib.request import urlretrieve

from ml.datasets.registry import DATASET_SOURCES, GOEMOTIONS_TO_COACHING

DEFAULT_OUT = Path(__file__).resolve().parents[2] / "datasets" / "raw" / "goemotions.jsonl"


def download_csv(dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    csv_path = dest.with_suffix(".csv")
    url = DATASET_SOURCES["goemotions"]["url"]
    print(f"Downloading GoEmotions from {url} ...")
    urlretrieve(url, csv_path)
    return csv_path


def csv_to_jsonl(csv_path: Path, out_path: Path, max_rows: int | None = None) -> int:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    count = 0
    with open(csv_path, encoding="utf-8", errors="replace") as fin, open(
        out_path, "w", encoding="utf-8"
    ) as fout:
        reader = csv.DictReader(fin)
        for row in reader:
            text = (row.get("text") or row.get("comment_text") or "").strip()
            if len(text) < 8:
                continue
            # GoEmotions CSV: emotion columns are 0/1 flags
            emotions = []
            for key, val in row.items():
                if key in ("text", "comment_text", "id", "reddit_id"):
                    continue
                if str(val).strip() in ("1", "1.0", "True"):
                    emotions.append(key)
            primary = emotions[0] if emotions else "neutral"
            coaching_emotion = GOEMOTIONS_TO_COACHING.get(primary, "neutral")
            record = {
                "text": text[:2000],
                "goemotions": emotions,
                "coaching_emotion": coaching_emotion,
            }
            fout.write(json.dumps(record, ensure_ascii=False) + "\n")
            count += 1
            if max_rows and count >= max_rows:
                break
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description="Download GoEmotions dataset")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--max-rows", type=int, default=None)
    args = parser.parse_args()
    csv_path = download_csv(args.output)
    n = csv_to_jsonl(csv_path, args.output, args.max_rows)
    print(f"Wrote {n} rows to {args.output}")


if __name__ == "__main__":
    main()
