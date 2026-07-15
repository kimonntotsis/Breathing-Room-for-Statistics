#!/usr/bin/env python3
"""Replace markdown links to figure assets with plain filenames (backticks)."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIG_LINK = re.compile(
    r"\[([^\]]*)\]\(([^)]*figures/[^)]+\.(?:png|pdf|jpe?g|svg|gif))\)",
    re.IGNORECASE,
)


def replacement(match: re.Match[str]) -> str:
    text = match.group(1).strip()
    path = match.group(2)
    filename = path.rsplit("/", 1)[-1]

    if text in {"", filename, f"figures/{filename}"}:
        return f"`{filename}`"

    lowered = text.lower().replace(" ", "")
    if lowered == filename.lower().replace("_", "").replace(".png", ""):
        return f"`{filename}`"

    return f"{text} (`{filename}`)"


def process(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    updated = FIG_LINK.sub(replacement, original)
    if updated != original:
        path.write_text(updated, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed: list[str] = []
    for path in sorted(ROOT.rglob("*.md")):
        if "_book" in path.parts or ".quarto" in path.parts:
            continue
        if process(path):
            changed.append(str(path.relative_to(ROOT)))
    print("Updated:", ", ".join(changed) if changed else "(none)")


if __name__ == "__main__":
    main()
