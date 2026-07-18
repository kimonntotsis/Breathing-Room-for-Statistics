#!/usr/bin/env python3
"""Insert Quick reference sections from git HEAD method tables (ch 3-22)."""

from __future__ import annotations

import re
import subprocess
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CH = REPO / "volume-01" / "chapters"
QUICK = "## Quick reference: methods in this chapter"

ANCHORS = [
    "## Chapter summary",
    "## Where we go next",
    "## Exercises",
    "## Further reading",
]


def git_chapter_text(name: str) -> str:
    r = subprocess.run(
        ["git", "show", f"HEAD:volume-01/chapters/{name}"],
        cwd=REPO,
        capture_output=True,
        text=True,
    )
    return r.stdout if r.returncode == 0 else ""


def extract_method_block(old: str) -> str | None:
    m = re.search(
        r"^## Method choice at a glance\s*\n(.*?)(?=^## (?:Learning objectives|In this chapter|---))",
        old,
        flags=re.MULTILINE | re.DOTALL,
    )
    if not m:
        return None
    body = m.group(1).strip()
    if not body.startswith("|"):
        return None
    return body


def insert_quick_ref(path: Path, table_body: str) -> bool:
    text = path.read_text(encoding="utf-8")
    if QUICK in text:
        return False

    block = (
        f"---\n\n{QUICK}\n\n"
        f"{table_body}\n\n"
        f"Full router: [Appendix B](../appendix-b-quick-reference.md).\n\n"
    )

    for anchor in ANCHORS:
        if anchor in text:
            text = text.replace(anchor, block + anchor, 1)
            path.write_text(text, encoding="utf-8")
            return True

    text = text.rstrip() + "\n\n" + block
    path.write_text(text, encoding="utf-8")
    return True


def main() -> None:
    for path in sorted(CH.glob("[0-9][0-9]-*.md")):
        num = int(path.name[:2])
        if num < 3:
            continue
        old = git_chapter_text(path.name)
        table = extract_method_block(old)
        if not table:
            print(f"SKIP no table {path.name}")
            continue
        if insert_quick_ref(path, table):
            print(f"OK {path.name}")
        else:
            print(f"-- {path.name} (already has quick ref)")


if __name__ == "__main__":
    main()
