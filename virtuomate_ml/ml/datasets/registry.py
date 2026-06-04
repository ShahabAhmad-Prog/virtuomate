"""Dataset registry and GoEmotions → coaching emotion mapping."""

from __future__ import annotations

# GoEmotions label indices (subset) → coaching bucket
GOEMOTIONS_TO_COACHING: dict[str, str] = {
    "admiration": "confident",
    "amusement": "happy",
    "anger": "concerned",
    "annoyance": "concerned",
    "approval": "confident",
    "caring": "focused",
    "confusion": "anxious",
    "curiosity": "focused",
    "desire": "focused",
    "disappointment": "concerned",
    "disapproval": "concerned",
    "disgust": "concerned",
    "embarrassment": "anxious",
    "excitement": "happy",
    "fear": "anxious",
    "gratitude": "confident",
    "grief": "concerned",
    "joy": "happy",
    "love": "happy",
    "nervousness": "anxious",
    "optimism": "confident",
    "pride": "confident",
    "realization": "focused",
    "relief": "confident",
    "remorse": "concerned",
    "sadness": "concerned",
    "surprise": "neutral",
    "neutral": "neutral",
}

COACHING_EMOTIONS = [
    "confident",
    "anxious",
    "happy",
    "concerned",
    "neutral",
    "focused",
    "professional",
    "energetic",
]

DATASET_SOURCES = {
    "goemotions": {
        "url": "https://storage.googleapis.com/gresearch/goemotions/data/full_dataset/goemotions_1.csv",
        "description": "Reddit comments with 27 emotion labels (Google Research)",
        "license": "CC BY 4.0",
    },
    "sentiment140": {
        "url": "http://cs.stanford.edu/people/alecmgo/trainingandtestdata/training.1600000.processed.noemoticon.csv",
        "description": "Twitter sentiment (auxiliary polarity)",
        "license": "Academic use",
    },
    "meld": {
        "url": "https://github.com/declare-lab/MELD",
        "description": "Multimodal emotion in dialogue",
        "license": "Research",
    },
    "isear": {
        "url": "https://www.unige.ch/cisa/research/materials-and-online-research/research-material/",
        "description": "International Survey on Emotion Antecedents and Reactions",
        "license": "Academic",
    },
}
