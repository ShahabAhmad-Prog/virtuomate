"""Training hyperparameters and paths."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = ROOT / "datasets" / "processed" / "coaching_train.jsonl"
CHECKPOINT_DIR = ROOT / "models" / "checkpoints" / "best"

MODEL_NAME = "microsoft/deberta-v3-small"
# Alternatives: "roberta-base", "bert-base-uncased"

BATCH_SIZE = 16
LEARNING_RATE = 2e-5
EPOCHS = 3
MAX_LENGTH = 256
WARMUP_RATIO = 0.1
WEIGHT_DECAY = 0.01
VAL_SPLIT = 0.1
SEED = 42

REGRESSION_WEIGHT = 1.0
EMOTION_WEIGHT = 0.5
