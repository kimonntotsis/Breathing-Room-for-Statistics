#!/usr/bin/env bash
# Build handbook PDF and copy to repository root (run from anywhere).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT_NAME="Breathing-Room-for-Statistics.pdf"

python3 "$ROOT/volume-01/scripts/prepare_cover_assets.py"
python3 "$ROOT/volume-01/scripts/prepare_build_metadata.py"

cd "$ROOT/volume-01"

TL_YEAR="$(lualatex --version 2>/dev/null | grep -oE '20[0-9]{2}' | head -1 || true)"
PDF_UA_FLAG=()
if [[ "${FORCE_PDF_UA:-}" == "1" ]] || [[ "${TL_YEAR:-0}" -ge 2025 ]]; then
  echo "Building with PDF/UA-2 tagging (TeX Live ${TL_YEAR:-unknown})."
  PDF_UA_FLAG=(-M "pdf-standard:ua-2")
else
  echo "WARN: TeX Live ${TL_YEAR:-unknown} — PDF/UA-2 tagging requires TeX Live 2025+."
  echo "      Building untagged PDF (figure alt-text and lang metadata still apply)."
  echo "      Upgrade TinyTeX/TeX Live or set FORCE_PDF_UA=1 after upgrading."
fi

if ((${#PDF_UA_FLAG[@]})); then
  quarto render --to pdf "${PDF_UA_FLAG[@]}"
else
  quarto render --to pdf
fi

SRC="_book/${OUT_NAME}"
if [[ ! -f "$SRC" ]]; then
  SRC="$(ls -t _book/*.pdf | head -1)"
fi

cp "$SRC" "$ROOT/$OUT_NAME"
echo "PDF saved: $ROOT/$OUT_NAME"

python3 "$ROOT/volume-01/scripts/verify_pdf_build.py" || exit 1

if ((${#PDF_UA_FLAG[@]})); then
  if command -v verapdf >/dev/null 2>&1; then
    echo "Validating PDF/UA with veraPDF..."
    verapdf --flavour ua2 "$ROOT/$OUT_NAME" || echo "WARN: veraPDF UA-2 validation reported issues."
  elif quarto verapdf --version >/dev/null 2>&1; then
    echo "Tip: run 'quarto install verapdf' for automated PDF/UA validation."
  fi
fi
