#!/usr/bin/env python3
"""Remove em-dash AI tics, middot separators, and boilerplate from handbook prose."""

from __future__ import annotations

import re
from pathlib import Path

VOLUME = Path(__file__).resolve().parents[1]
SKIP_DIRS = {"pipeline-options", "_book", "solutions", "exercises", "figures/pipeline-options"}

BEFORE_R_BLOCK = re.compile(
    r"\n### Before you open R\n\nYou are ready to code when[^\n]+\n",
    re.MULTILINE,
)
TABLE_DASH = re.compile(r"\|\s*—\s*\|")
HEADING = re.compile(r"^#{1,6}\s")
CHAPTER_TITLE = re.compile(r"^(#+ Chapter \d+: [^:\n]+): (.+)$")
NUMBERED_ITEM = re.compile(r"^(\d+\.\s+\*\*[^*]+\*\*)\s+—\s+")
BULLET_ITEM = re.compile(r"^(-\s+\[[^\]]+\]\([^)]+\))\s+—\s+")


def iter_files() -> list[Path]:
    paths: list[Path] = []
    for path in sorted(VOLUME.rglob("*.md")):
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        paths.append(path)
    for extra in [VOLUME / "_quarto.yml", VOLUME / "latex" / "cover-page.tex"]:
        if extra.exists():
            paths.append(extra)
    return paths


def fix_line(line: str) -> str:
    if "—" not in line:
        return line

    if TABLE_DASH.search(line):
        line = TABLE_DASH.sub("| |", line)

    m = NUMBERED_ITEM.match(line)
    if m:
        rest = line[m.end() :]
        return f"{m.group(1)}: {rest}"

    m = BULLET_ITEM.match(line)
    if m:
        rest = line[m.end() :]
        return f"{m.group(1)}: {rest}"

    if HEADING.match(line):
        line = line.replace(" — ", ": ")
        line = line.replace("—", ": ")
        cm = CHAPTER_TITLE.match(line.rstrip("\n"))
        if cm and cm.group(2).strip():
            line = f"{cm.group(1)}, {cm.group(2).rstrip()}\n"
        return line

    # Table cells and prose: em dash → colon (clearer than semicolon for handbook tone)
    line = line.replace(" — ", ": ")
    line = line.replace("—", ": ")
    return line


def fix_middots(text: str) -> str:
    text = re.sub(
        r"## Exercises · (\[Solutions\]\([^)]+\))",
        r"## Exercises (\1)",
        text,
    )
    in_fence = False
    out: list[str] = []
    for line in text.splitlines(keepends=True):
        if line.strip().startswith("```"):
            in_fence = not in_fence
            out.append(line)
            continue
        if not in_fence and " · " in line:
            line = line.replace(" · ", ", ")
        out.append(line)
    return "".join(out)


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    text = "".join(fix_line(line) for line in original.splitlines(keepends=True))
    text = fix_middots(text)
    text = BEFORE_R_BLOCK.sub("\n", text)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = [p.relative_to(VOLUME) for p in iter_files() if process_file(p)]
    print(f"Updated {len(changed)} files")
    for p in changed:
        print(f"  {p}")


if __name__ == "__main__":
    main()
