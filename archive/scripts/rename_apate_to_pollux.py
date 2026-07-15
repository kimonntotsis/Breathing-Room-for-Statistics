#!/usr/bin/env python3
"""Rename APATE → POLLUX across handbook prose."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
VOLUME = REPO / "volume-01"

REPLACEMENTS = [
    ("APATE_VIGNETTE.md", "POLLUX_VIGNETTE.md"),
    ("APATE_VIGNETTE", "POLLUX_VIGNETTE"),
    ("APATE vignette", "POLLUX vignette"),
    ("APATE-style", "POLLUX-style"),
    ("APATE skepticism", "POLLUX judgement"),
    ("J/K/APATE", "J/K/POLLUX"),
    ("and APATE", "and POLLUX"),
    ("**APATE**", "**POLLUX**"),
    ("[APATE]", "[POLLUX]"),
    ("Read APATE ", "Read POLLUX "),
    ("; APATE ", "; POLLUX "),
    (". APATE ", ". POLLUX "),
    ("APATE ", "POLLUX "),
    ("APATE.", "POLLUX."),
    ("APATE,", "POLLUX,"),
    ("apate.csv", "pollux.csv"),
    ("*Apate*", "*Pollux*"),
    ("Greek *Apate* (deceit)", "Greek twin of CASTOR (Κάστωρ / Πολυδεύκης)"),
    ("Greek *Apate* (Ἀπάτη), personification of deceit; handbook **prose-only** messy-registry vignette",
     "Greek *Pollux* (Πολυδεύκης), Castor's twin; handbook **prose-only** messy-registry vignette"),
    ("Greek *Apate*, deceit: fictional mess", "fictional POLLUX registry mess"),
    ("teaching-datasets-castor-castor-hd-and-apate", "teaching-datasets-castor-castor-hd-and-pollux"),
    ("CASTOR, CASTOR-HD, and APATE", "CASTOR, CASTOR-HD, and POLLUX"),
]

SKIP = {".git", "_book", "node_modules"}


def should_process(path: Path) -> bool:
    if any(part in SKIP for part in path.parts):
        return False
    if path.name == "rename_apate_to_pollux.py":
        return False
    if path.suffix not in {".md", ".yml", ".tex", ".lua", ".py", ".R"} and path.name != "README.md":
        return False
    return True


def process_file(path: Path) -> bool:
    if path.name == "APATE_VIGNETTE.md":
        return False
    text = path.read_text(encoding="utf-8")
    if "APATE" not in text and "Apate" not in text and "apate" not in text:
        return False
    original = text
    for old, new in REPLACEMENTS:
        text = text.replace(old, new)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = []
    for path in sorted(REPO.rglob("*")):
        if path.is_file() and should_process(path):
            if process_file(path):
                changed.append(path.relative_to(REPO))
    print(f"Updated {len(changed)} files")
    for p in changed:
        print(f"  {p}")


if __name__ == "__main__":
    main()
