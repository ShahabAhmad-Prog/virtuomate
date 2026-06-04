#!/usr/bin/env python3
"""Fine-tune DeBERTa multi-task coaching assessment model."""

from __future__ import annotations

import argparse
import json
import random
from pathlib import Path

import torch
import torch.nn.functional as F
from torch.utils.data import DataLoader, Dataset
from transformers import AutoTokenizer, get_linear_schedule_with_warmup

from ml.datasets.registry import COACHING_EMOTIONS
from ml.inference.feature_extractor import feature_vector, extract_linguistic_features
from ml.models.multitask_deberta import CoachingMultiTaskModel
from ml.training import config as cfg


class CoachingDataset(Dataset):
    def __init__(self, rows: list[dict], tokenizer, max_length: int):
        self.rows = rows
        self.tokenizer = tokenizer
        self.max_length = max_length

    def __len__(self) -> int:
        return len(self.rows)

    def __getitem__(self, idx: int) -> dict:
        row = self.rows[idx]
        enc = self.tokenizer(
            row["text"],
            truncation=True,
            max_length=self.max_length,
            padding="max_length",
            return_tensors="pt",
        )
        feats = extract_linguistic_features(row["text"])
        emotion = row.get("coaching_emotion", "neutral")
        emotion_idx = COACHING_EMOTIONS.index(emotion) if emotion in COACHING_EMOTIONS else 0
        return {
            "input_ids": enc["input_ids"].squeeze(0),
            "attention_mask": enc["attention_mask"].squeeze(0),
            "features": torch.tensor(feature_vector(feats), dtype=torch.float32),
            "confidence": torch.tensor(row["confidence_score"] / 100.0, dtype=torch.float32),
            "clarity": torch.tensor(row["clarity_score"] / 100.0, dtype=torch.float32),
            "professionalism": torch.tensor(row["professionalism_score"] / 100.0, dtype=torch.float32),
            "anxiety": torch.tensor(row["anxiety_score"] / 100.0, dtype=torch.float32),
            "communication": torch.tensor(row["communication_score"] / 100.0, dtype=torch.float32),
            "interview_readiness": torch.tensor(
                row.get("interview_readiness_score", row["communication_score"]) / 100.0,
                dtype=torch.float32,
            ),
            "emotion": torch.tensor(emotion_idx, dtype=torch.long),
        }


def load_jsonl(path: Path) -> list[dict]:
    rows = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            rows.append(json.loads(line))
    return rows


def train_epoch(model, loader, optimizer, scheduler, device) -> float:
    model.train()
    total_loss = 0.0
    mse = torch.nn.MSELoss()
    for batch in loader:
        input_ids = batch["input_ids"].to(device)
        attention_mask = batch["attention_mask"].to(device)
        features = batch["features"].to(device)
        out = model(input_ids, attention_mask, features)

        reg_loss = (
            mse(out["confidence"] / 100.0, batch["confidence"].to(device))
            + mse(out["clarity"] / 100.0, batch["clarity"].to(device))
            + mse(out["professionalism"] / 100.0, batch["professionalism"].to(device))
            + mse(out["anxiety"] / 100.0, batch["anxiety"].to(device))
            + mse(out["communication"] / 100.0, batch["communication"].to(device))
            + mse(out["interview_readiness"] / 100.0, batch["interview_readiness"].to(device))
        ) / 6.0
        emo_loss = F.cross_entropy(out["emotion_logits"], batch["emotion"].to(device))
        loss = cfg.REGRESSION_WEIGHT * reg_loss + cfg.EMOTION_WEIGHT * emo_loss

        optimizer.zero_grad()
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
        optimizer.step()
        scheduler.step()
        total_loss += loss.item()
    return total_loss / max(len(loader), 1)


@torch.no_grad()
def eval_mae(model, loader, device) -> dict[str, float]:
    model.eval()
    keys = ["confidence", "clarity", "professionalism", "anxiety", "communication"]
    sums = {k: 0.0 for k in keys}
    n = 0
    for batch in loader:
        input_ids = batch["input_ids"].to(device)
        attention_mask = batch["attention_mask"].to(device)
        features = batch["features"].to(device)
        out = model(input_ids, attention_mask, features)
        for k in keys:
            pred = out[k]
            target = batch[k if k != "confidence" else "confidence"] * 100.0
            if k == "confidence":
                target = batch["confidence"] * 100.0
            elif k == "clarity":
                target = batch["clarity"] * 100.0
            elif k == "professionalism":
                target = batch["professionalism"] * 100.0
            elif k == "anxiety":
                target = batch["anxiety"] * 100.0
            else:
                target = batch["communication"] * 100.0
            sums[k] += (pred - target.to(device)).abs().mean().item()
        n += 1
    return {k: sums[k] / max(n, 1) for k in keys}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=Path, default=cfg.DATA_PATH)
    parser.add_argument("--epochs", type=int, default=cfg.EPOCHS)
    parser.add_argument("--batch-size", type=int, default=cfg.BATCH_SIZE)
    parser.add_argument("--output", type=Path, default=cfg.CHECKPOINT_DIR)
    args = parser.parse_args()

    random.seed(cfg.SEED)
    torch.manual_seed(cfg.SEED)

    rows = load_jsonl(args.data)
    random.shuffle(rows)
    split = int(len(rows) * (1 - cfg.VAL_SPLIT))
    train_rows, val_rows = rows[:split], rows[split:]

    tokenizer = AutoTokenizer.from_pretrained(cfg.MODEL_NAME)
    model = CoachingMultiTaskModel.from_pretrained_encoder(cfg.MODEL_NAME)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)

    train_loader = DataLoader(
        CoachingDataset(train_rows, tokenizer, cfg.MAX_LENGTH),
        batch_size=args.batch_size,
        shuffle=True,
    )
    val_loader = DataLoader(
        CoachingDataset(val_rows, tokenizer, cfg.MAX_LENGTH),
        batch_size=args.batch_size,
    )

    optimizer = torch.optim.AdamW(model.parameters(), lr=cfg.LEARNING_RATE, weight_decay=cfg.WEIGHT_DECAY)
    total_steps = len(train_loader) * args.epochs
    scheduler = get_linear_schedule_with_warmup(
        optimizer,
        int(total_steps * cfg.WARMUP_RATIO),
        total_steps,
    )

    best_mae = 1e9
    args.output.mkdir(parents=True, exist_ok=True)

    for epoch in range(args.epochs):
        loss = train_epoch(model, train_loader, optimizer, scheduler, device)
        mae = eval_mae(model, val_loader, device)
        avg_mae = sum(mae.values()) / len(mae)
        print(f"Epoch {epoch + 1} loss={loss:.4f} val_mae={avg_mae:.2f} {mae}")
        if avg_mae < best_mae:
            best_mae = avg_mae
            model.save_pretrained(args.output)
            tokenizer.save_pretrained(args.output)
            print(f"Saved checkpoint -> {args.output}")

    print("Training complete.")


if __name__ == "__main__":
    main()
