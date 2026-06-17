#!/usr/bin/env python3
"""Fix handbook formatting: section numbers, em dashes, en dashes in prose."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHAPTERS = ROOT / "chapters"

SECTION_NUM = re.compile(r"^(#{2,3}) \d+\.\d+(?:\.\d+)?\s+")
ANCHOR_NUM = re.compile(r"\]\(#[0-9]+[.\-]*([a-z][a-z0-9-]*)\)")
FILE_ANCHOR_NUM = re.compile(r"\.md#([0-9]+)([a-z0-9-]*)")


def fix_dashes(line: str) -> str:
    if line.startswith("#"):
        return line.replace(" — ", ": ").replace("—", ":")
  # prose / tables / code comments outside fences handled line-wise
    line = line.replace(" — ", " - ")
    line = line.replace("—", "-")
    line = line.replace("–", "-")
    return line


def fix_anchors(text: str) -> str:
    text = ANCHOR_NUM.sub(r"](#\1)", text)
    text = FILE_ANCHOR_NUM.sub(r".md#\2", text)
    return text


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    lines = original.splitlines(keepends=True)
    out = []
    in_fence = False
    for line in lines:
        stripped = line.lstrip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            out.append(line)
            continue
        if not in_fence and path.parent.name == "chapters":
            line = SECTION_NUM.sub(r"\1 ", line)
        if not in_fence:
            line = fix_dashes(line)
        out.append(line)
    text = "".join(out)
    text = fix_anchors(text)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = []
    for path in sorted(CHAPTERS.glob("*.md")):
        if process_file(path):
            changed.append(path.name)
    print("Updated chapters:", ", ".join(changed) if changed else "(none)")


if __name__ == "__main__":
    main()
