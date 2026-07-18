#!/usr/bin/env bash
# Build handbook PDF and copy to repository root (run from anywhere).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT_NAME="Breathing-Room-for-Statistics.pdf"

python3 "$ROOT/volume-01/scripts/prepare_cover_assets.py"
python3 "$ROOT/volume-01/scripts/prepare_build_metadata.py"

cd "$ROOT/volume-01"
quarto render --to pdf

SRC="_book/${OUT_NAME}"
if [[ ! -f "$SRC" ]]; then
  SRC="$(ls -t _book/*.pdf | head -1)"
fi

cp "$SRC" "$ROOT/$OUT_NAME"
echo "PDF saved: $ROOT/$OUT_NAME"
