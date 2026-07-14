#!/usr/bin/env python3
"""Rename branded section labels, drop reading-time estimates."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
VOLUME = REPO / "volume-01"

GLOBS = list(VOLUME.rglob("*.md")) + [
    REPO / "README.md",
    REPO / "BOOK_OUTLINE.md",
    VOLUME / "HANDBOOK_STATUS.md",
    VOLUME / "HANDBOOK_GUIDE.md",
]

# Order matters: longer / more specific patterns first.
TEXT_REPLACEMENTS = [
    ("## Investigator path (≈20 min)", "## In this chapter"),
    ("#investigator-path-20-min", "#in-this-chapter"),
    ("**Investigator path (≈20 min)**", "**In this chapter**"),
    ("Investigator path (≈20 min)", "In this chapter"),
    ("| **Investigator path (≈20 min)** |", "| **In this chapter** |"),
    ("| **Investigator path** |", "| **In this chapter** |"),
    ("After Investigator path", "After In this chapter"),
    ("[Ch 1: Investigator path]", "[Ch 1: In this chapter]"),
    ("[Ch 4: Investigator path]", "[Ch 4: In this chapter]"),
    ("[Ch 5 investigator path]", "[Ch 5 in this chapter]"),
    ("[Ch 6 investigator path]", "[Ch 6 in this chapter]"),
    ("[Ch 18 investigator path]", "[Ch 18 in this chapter]"),
    ("[Ch 19 investigator path]", "[Ch 19 in this chapter]"),
    ("[Ch 20 investigator path]", "[Ch 20 in this chapter]"),
    ("[Ch 21 investigator path]", "[Ch 21 in this chapter]"),
    ("After Ch 13–16 investigator paths", "After Ch 13–16 chapter openers"),
    ("Full investigator path:", "Full short read:"),
    ("**shortest investigator path (~2 h)**", "**shortest route**"),
    ("Investigator minimum path (~2 hours)", "Short read (without R)"),
    ("Investigator minimum path (~2 h)", "Short read (without R)"),
    ("investigator minimum path (~2 h)", "short read (without R)"),
    ("Appendix J — investigator minimum path (~2 h)", "Appendix J: short read (without R)"),
    ("Appendix J (~2 hours)", "Appendix J"),
    ("(~2 hours)", ""),
    ("(~2 h total)", ""),
    ("(~2 h)", ""),
    ("Shortest investigator route (~2 h total):", "Shortest route:"),
    ("Shortest route (~2 h):", "Shortest route:"),
    ("**Minimum path (~2 h):**", "**Minimum path:**"),
    ("# Appendix H: Investigator path (without R)", "# Appendix H: Reviewing without R"),
    ("Investigator path (without R)", "Reviewing without R"),
    ("## Read this (in order, ~90 min)", "## Read this in order"),
    ("Add (≈20 min each)", "Add when needed"),
    ("**Investigator shortcut:**", "**Chapter layout:**"),
    ("Investigator paths and Method choice tables", "In this chapter sections and method choice tables"),
]

TIME_COLUMN_HEADER = re.compile(
    r"(\| Step \| Read \|) Time (\| You can sign off on… \|\n"
    r"\|[-| ]+\|\n)"
)

TIME_CELL = re.compile(r"\| \d+ min \|")


def strip_time_column(text: str) -> str:
    """Remove the Time column from Appendix J reading-order table."""
    if "appendix-j-investigator-minimum-path" not in text and "Read this in order" not in text:
        return text

    def fix_header(m: re.Match[str]) -> str:
        return m.group(1) + m.group(2)

    text = TIME_COLUMN_HEADER.sub(
        r"\1\2",
        text,
    )
    text = text.replace(
        "| Step | Read | Time | You can sign off on… |",
        "| Step | Read | You can sign off on… |",
    )
    text = text.replace(
        "|------|------|------|---------------------|",
        "|------|------|---------------------|",
    )
    text = TIME_CELL.sub("|", text)
    return text


def process(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    text = original
    for old, new in TEXT_REPLACEMENTS:
        text = text.replace(old, new)
    text = strip_time_column(text)
    # Collapse double spaces left by empty parens removal
    text = re.sub(r"  +", " ", text)
    text = re.sub(r" \n", "\n", text)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = []
    for path in sorted(set(GLOBS)):
        if path.exists() and process(path):
            changed.append(path.relative_to(REPO))
    print(f"Updated {len(changed)} files")
    for p in changed:
        print(f"  {p}")


if __name__ == "__main__":
    main()
