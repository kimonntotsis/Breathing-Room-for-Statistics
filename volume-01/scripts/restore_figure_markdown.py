#!/usr/bin/env python3
"""Restore handbook figure lines: !Caption (`file.png`) -> ![Caption](../figures/file.png)"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PAT = re.compile(
    r"^!(?P<caption>.*?)\(`(?P<file>[^`]+?\.(?:png|pdf|jpg))`\)(?P<attrs>\{[^}]+\})?\s*$"
)
PAT_BARE = re.compile(
    r"^!`(?P<file>[^`]+?\.(?:png|pdf|jpg))`\s*$"
)


def figures_prefix(path: Path) -> str:
    if path.parent.name == "chapters":
        return "../figures/"
    return "figures/"


def convert_line(line: str, prefix: str) -> str | None:
    stripped = line.strip()
    m = PAT.match(stripped) or PAT_BARE.match(stripped)
    if not m:
        return None
    caption = (m.groupdict().get("caption") or "").strip()
    file_name = m.group("file")
    attrs = m.groupdict().get("attrs") or ""
    if not caption:
        caption = Path(file_name).stem.replace("_", " ").replace("-", " ")
    return f"![{caption}]({prefix}{file_name}){attrs}"


def process_file(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    prefix = figures_prefix(path)
    lines = text.splitlines(keepends=True)
    changed = 0
    out: list[str] = []
    for line in lines:
        stripped = line.rstrip("\n")
        new = convert_line(stripped, prefix)
        if new is not None:
            out.append(new + ("\n" if line.endswith("\n") else ""))
            changed += 1
        else:
            out.append(line)
    if changed:
        path.write_text("".join(out), encoding="utf-8")
    return changed


def main() -> None:
    targets = list((ROOT / "chapters").glob("*.md"))
    targets += list(ROOT.glob("appendix-*.md"))
    targets += list((ROOT / "_includes").glob("*.md"))
    total = 0
    for path in sorted(targets):
        n = process_file(path)
        if n:
            print(f"{path.relative_to(ROOT)}: {n}")
            total += n
    print(f"restored {total} figure lines")


if __name__ == "__main__":
    main()
