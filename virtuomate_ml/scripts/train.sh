#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python -m ml.datasets.download_goemotions --max-rows 50000
python -m ml.datasets.prepare_coaching_labels
python -m ml.training.train_multitask "$@"
