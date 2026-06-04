"""DeBERTa encoder + linguistic features + multi-task coaching heads."""

from __future__ import annotations

from pathlib import Path

import torch
import torch.nn as nn
from transformers import AutoConfig, AutoModel, PreTrainedModel


class CoachingMultiTaskModel(PreTrainedModel):
    config_class = AutoConfig

    def __init__(self, config, n_features: int = 10, n_emotions: int = 8):
        super().__init__(config)
        self.encoder = AutoModel.from_config(config)
        hidden = config.hidden_size
        self.feature_proj = nn.Linear(n_features, hidden // 4)
        self.pool = nn.Linear(hidden + hidden // 4, hidden)
        self.dropout = nn.Dropout(0.1)

        def head() -> nn.Sequential:
            return nn.Sequential(
                nn.Linear(hidden, hidden // 2),
                nn.GELU(),
                nn.Dropout(0.1),
                nn.Linear(hidden // 2, 1),
            )

        self.confidence_head = head()
        self.clarity_head = head()
        self.professionalism_head = head()
        self.anxiety_head = head()
        self.communication_head = head()
        self.interview_head = head()
        self.emotion_head = nn.Linear(hidden, n_emotions)

    def forward(
        self,
        input_ids: torch.Tensor,
        attention_mask: torch.Tensor,
        features: torch.Tensor | None = None,
    ) -> dict[str, torch.Tensor]:
        outputs = self.encoder(input_ids=input_ids, attention_mask=attention_mask)
        pooled = outputs.last_hidden_state[:, 0]
        if features is not None:
            feat_h = self.feature_proj(features)
            pooled = torch.cat([pooled, feat_h], dim=-1)
            pooled = self.pool(pooled)
        pooled = self.dropout(pooled)

        def score(head: nn.Module) -> torch.Tensor:
            return torch.sigmoid(head(pooled)).squeeze(-1) * 100.0

        return {
            "confidence": score(self.confidence_head),
            "clarity": score(self.clarity_head),
            "professionalism": score(self.professionalism_head),
            "anxiety": score(self.anxiety_head),
            "communication": score(self.communication_head),
            "interview_readiness": score(self.interview_head),
            "emotion_logits": self.emotion_head(pooled),
        }

    @classmethod
    def from_pretrained_encoder(
        cls,
        model_name: str = "microsoft/deberta-v3-small",
        checkpoint_dir: str | Path | None = None,
    ) -> "CoachingMultiTaskModel":
        if checkpoint_dir and Path(checkpoint_dir).exists():
            return cls.from_pretrained(str(checkpoint_dir))
        config = AutoConfig.from_pretrained(model_name)
        return cls(config)

    def save_pretrained(self, save_directory: str | Path, **kwargs):  # noqa: ANN003
        Path(save_directory).mkdir(parents=True, exist_ok=True)
        super().save_pretrained(save_directory, **kwargs)
        self.encoder.save_pretrained(save_directory)
