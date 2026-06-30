#!/usr/bin/env python3
"""One-off / repeatable cleanup for PDF-friendly handbook markdown."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHAPTERS = ROOT / "chapters"


def move_at_a_glance_navigation(text: str) -> str:
    """Move | **Navigation** | ... | out of At a glance tables (PDF overflow)."""
    marker = "## At a glance"
    if marker not in text:
        return text

    start = text.index(marker)
    rest = text[start:]
    table_end = rest.find("\n\n", rest.find("\n|"))
    if table_end == -1:
        return text

    table_block = rest[:table_end]
    nav_match = re.search(r"^\| \*\*Navigation\*\* \| (.+) \|\s*$", table_block, re.M)
    if not nav_match:
        return text

    nav_line = nav_match.group(1).strip()
    new_table = re.sub(r"^\| \*\*Navigation\*\* \| .+ \|\s*\n", "", table_block, flags=re.M)
    insert = f"\n\n**Also see:** {nav_line}\n"
    new_rest = new_table + insert + rest[table_end + 2 :]
    return text[:start] + new_rest


def demote_case_study_subheads(text: str) -> str:
    """Under each Case study X block, demote repeated ## to ### for PDF TOC."""
    if "case-studies" not in text and "Case study" not in text:
        return text

    lines = text.splitlines()
    in_case = False
    subheads = {
        "## Clinical question",
        "## Estimand",
        "## Design",
        "## Analysis path",
        "## Results template",
        "## Three-reader interpretation",
        "## Caveats",
        "## Wrong analysis",
    }
    out = []
    for line in lines:
        if re.match(r"^# Case study [A-E]:", line) or line.startswith("## Case study"):
            in_case = True
            out.append(line)
            continue
        if in_case and line.startswith("## ") and not re.match(r"^## Case study", line):
            if any(line.startswith(h) for h in subheads):
                out.append("#" + line)
                continue
            if line.startswith("## Extended") or line.startswith("## Closing") or line.startswith("## Master"):
                in_case = False
        out.append(line)
    return "\n".join(out)


def main() -> None:
    for path in sorted(CHAPTERS.glob("*.md")):
        original = path.read_text(encoding="utf-8")
        updated = move_at_a_glance_navigation(original)
        if path.name == "12-case-studies.md":
            updated = demote_case_study_subheads(updated)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            print(f"updated {path.name}")


if __name__ == "__main__":
    main()
