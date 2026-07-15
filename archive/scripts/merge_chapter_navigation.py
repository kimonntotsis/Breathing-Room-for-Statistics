#!/usr/bin/env python3
"""Merge 'At a glance' and 'In this chapter'; remove 'Also see' header clutter."""

from __future__ import annotations

import re
from pathlib import Path

VOLUME = Path(__file__).resolve().parents[1]
CHAPTERS = sorted((VOLUME / "chapters").glob("*.md"))
SKIP = {"00-preface.md", "00-welcome.md"}


def merge_file(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    original = text

    if "## At a glance" not in text:
        return False

    text = re.sub(r"\n\*\*Also see:\*\*[^\n]+\n", "\n", text)

    if "## In this chapter" in text:
        m = re.search(
            r"## In this chapter\n\n(.*?)\n---\n\n(## )",
            text,
            re.DOTALL,
        )
        if not m:
            return False
        body = m.group(1).strip()
        text = text[: m.start()] + text[m.end() - 3 :]  # keep next ##
        insert_at = text.index("## At a glance")
        after_glance = text[insert_at:]
        # Find end of glance block: last --- before next ## (not In this chapter)
        end_m = re.search(r"\n---\n\n(?=## |\*\*Read in order)", after_glance)
        if end_m:
            pos = insert_at + end_m.start()
            read_block = f"\n\n**Read in order:**\n\n{body}\n"
            text = text[:pos] + read_block + text[pos:]
        else:
            # No --- after hooks: insert before first ## Method choice or similar
            next_sec = re.search(r"\n\n(## (?!At a glance))", after_glance)
            if not next_sec:
                return False
            pos = insert_at + next_sec.start()
            read_block = f"\n\n**Read in order:**\n\n{body}\n"
            text = text[:pos] + read_block + text[pos:]

    # Clean duplicate read-in-order blocks from a prior partial run.
    text = re.sub(
        r"\n---\n\n\*\*Read in order:\*\*\n\nYou do not need this entire chapter on first pass\. Read in order:\n\n",
        "\n\n**Read in order:**\n\n",
        text,
    )
    text = re.sub(
        r"\n\*\*Read in order:\*\*\n\nYou do not need this entire chapter on first pass\. Read in order:\n\n",
        "\n\n**Read in order:**\n\n",
        text,
    )
    # Collapse double read-in-order headers.
    while "**Read in order:**\n\n**Read in order:**" in text:
        text = text.replace(
            "**Read in order:**\n\n**Read in order:**",
            "**Read in order:**",
            1,
        )

    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = [p.name for p in CHAPTERS if p.name not in SKIP and merge_file(p)]
    print(f"Updated {len(changed)} chapters")
    for name in changed:
        print(f"  {name}")


if __name__ == "__main__":
    main()
