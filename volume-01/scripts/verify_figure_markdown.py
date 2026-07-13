#!/usr/bin/env python3
"""Fail CI if handbook figure markdown is broken or below baseline."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASELINE_FILE = Path(__file__).resolve().parent / "figure_markdown_baseline.txt"

SCAN_DIRS = [
    ROOT / "chapters",
]
SCAN_FILES = list(ROOT.glob("appendix-*.md")) + list((ROOT / "_includes").glob("*.md"))

BROKEN = re.compile(r"^![^\[]")


def count_embedded_figures() -> int:
    total = 0
    for path in sorted(SCAN_DIRS[0].glob("*.md")):
        total += len(re.findall(r"!\[[^\]]*\]\([^)]*figures/", path.read_text(encoding="utf-8")))
    for path in sorted(SCAN_FILES):
        if path.exists():
            total += len(re.findall(r"!\[[^\]]*\]\([^)]*figures/", path.read_text(encoding="utf-8")))
    return total


def find_broken_lines() -> list[str]:
    bad: list[str] = []
    for path in sorted(SCAN_DIRS[0].glob("*.md")):
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if BROKEN.match(line.strip()):
                bad.append(f"{path.relative_to(ROOT)}:{i}: {line.strip()[:80]}")
    for path in sorted(SCAN_FILES):
        if not path.exists():
            continue
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if BROKEN.match(line.strip()):
                bad.append(f"{path.relative_to(ROOT)}:{i}: {line.strip()[:80]}")
    return bad


def main() -> int:
    baseline = int(BASELINE_FILE.read_text(encoding="utf-8").strip())
    count = count_embedded_figures()
    broken = find_broken_lines()

    if broken:
        print("Broken figure syntax (use ![caption](../figures/file.png)):", file=sys.stderr)
        for line in broken:
            print(f"  {line}", file=sys.stderr)
        return 1

    if count < baseline:
        print(
            f"Figure embed count {count} is below baseline {baseline}. "
            "Figures may not render in the PDF.",
            file=sys.stderr,
        )
        return 1

    print(f"OK: {count} figure embeds (baseline >= {baseline}), no broken syntax.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
