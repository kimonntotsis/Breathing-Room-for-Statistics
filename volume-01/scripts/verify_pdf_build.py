#!/usr/bin/env python3
"""Fail CI if built PDF is missing, too short, or has too few figures."""

from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import pypdf
except ImportError:
    pypdf = None

ROOT = Path(__file__).resolve().parents[2]
PDF = ROOT / "Breathing-Room-for-Statistics.pdf"
BASELINE_FILE = Path(__file__).resolve().parent / "pdf_build_baseline.txt"


def parse_baseline() -> tuple[int, int]:
    text = BASELINE_FILE.read_text(encoding="utf-8")
    pages = int(re.search(r"pages=(\d+)", text).group(1))
    figures = int(re.search(r"figures=(\d+)", text).group(1))
    return pages, figures


def count_pdf_figures() -> int:
    if pypdf is None:
        raise RuntimeError("pypdf required")
    reader = pypdf.PdfReader(str(PDF))
    total = 0
    for page in reader.pages:
        text = page.extract_text() or ""
        total += len(re.findall(r"\bFigure\s+\d+", text))
    return total


def main() -> int:
    if not PDF.is_file():
        print(f"Missing PDF: {PDF}", file=sys.stderr)
        return 1

    min_pages, min_figures = parse_baseline()
    if pypdf is None:
        print("pypdf not installed; skipping figure/page checks", file=sys.stderr)
        return 0

    reader = pypdf.PdfReader(str(PDF))
    pages = len(reader.pages)
    figures = count_pdf_figures()

    ok = True
    if pages < min_pages:
        print(f"PDF has {pages} pages; baseline minimum is {min_pages}.", file=sys.stderr)
        ok = False
    if figures < min_figures:
        print(f"PDF has {figures} figure labels; baseline minimum is {min_figures}.", file=sys.stderr)
        ok = False

    if not ok:
        return 1

    # Symbol rendering: catch common LuaLaTeX Unicode failures
    full_text = "\n".join((page.extract_text() or "") for page in reader.pages)
    symbol_failures = []
    if re.search(r"Hern[`´]an", full_text):
        symbol_failures.append("Hernàn grave accent")
    if re.search(r"\(p\s*�\s*n\)", full_text):
        symbol_failures.append("≫ missing in p ≫ n (replacement char)")
    if re.search(r"Pearson\s+²/df", full_text):
        symbol_failures.append("χ missing before ²/df")
    if "Hernán" not in full_text and "Hernan" not in full_text:
        symbol_failures.append("Hernán not found in PDF text")
    if symbol_failures:
        for msg in symbol_failures:
            print(f"PDF symbol check failed: {msg}", file=sys.stderr)
        ok = False

    if not ok:
        return 1

    print(f"OK: PDF {pages} pages, {figures} figure labels (baseline pages>={min_pages}, figures>={min_figures}).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
