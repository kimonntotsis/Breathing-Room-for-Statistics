#!/usr/bin/env python3
"""Move Quick reference sections before Exercises when mis-ordered."""

import re
from pathlib import Path

CH = Path(__file__).resolve().parents[2] / "volume-01" / "chapters"
QUICK = re.compile(
    r"(---\n\n## Quick reference:.*?\n\nFull router:.*?\n\n)",
    re.DOTALL,
)


def fix(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    m = QUICK.search(text)
    if not m:
        return False
    block = m.group(1)
    if "## Exercises" not in text:
        return False
    ex_pos = text.find("## Exercises")
    quick_pos = text.find("## Quick reference")
    if quick_pos < ex_pos:
        return False  # already correct
    text = text.replace(block, "", 1)
    text = text.replace("## Exercises", block + "## Exercises", 1)
    path.write_text(text, encoding="utf-8")
    return True


def main() -> None:
    for path in sorted(CH.glob("[0-9][0-9]-*.md")):
        if fix(path):
            print(f"OK {path.name}")


if __name__ == "__main__":
    main()
