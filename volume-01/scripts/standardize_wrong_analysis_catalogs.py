#!/usr/bin/env python3
"""Replace in-chapter wrong-analysis catalogues with Appendix R pointers."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# chapter file -> (anchor, short title for pointer)
CHAPTER_ANCHORS: dict[str, tuple[str, str]] = {
    "01-statistical-thinking.md": ("chapter-1", "Chapter 1"),
    "02-respiratory-data.md": ("chapter-2", "Chapter 2"),
    "03-descriptive-analysis.md": ("chapter-3", "Chapter 3"),
    "04-comparing-groups.md": ("chapter-4", "Chapter 4"),
    "05-linear-models.md": ("chapter-5", "Chapter 5"),
    "06-generalized-linear-models.md": ("chapter-6", "Chapter 6"),
    "07-model-building.md": ("chapter-7", "Chapter 7"),
    "08-validation-reporting.md": ("chapter-8", "Chapter 8"),
    "09-prediction-vs-inference.md": ("chapter-9", "Chapter 9"),
    "10-dimensionality-reduction.md": ("chapter-10-11", "Chapters 10–11"),
    "11-clustering.md": ("chapter-10-11", "Chapters 10–11"),
    "12-case-studies.md": ("chapter-12", "Chapter 12"),
    "13-differential-analysis-fdr.md": ("chapter-13-14", "Chapters 13–14"),
    "14-batch-effects.md": ("chapter-13-14", "Chapters 13–14"),
    "15-flow-cytometry.md": ("chapter-15-17", "Chapters 15–17"),
    "16-antibody-discovery.md": ("chapter-15-17", "Chapters 15–17"),
    "17-integrated-castor-hd.md": ("chapter-15-17", "Chapters 15–17"),
    "18-longitudinal-mixed-models.md": ("chapter-18-19", "Chapters 18–19"),
    "19-survival-analysis.md": ("chapter-18-19", "Chapters 18–19"),
    "20-missing-data.md": ("chapter-20-22", "Chapters 20–22"),
    "21-causal-inference.md": ("chapter-20-22", "Chapters 20–22"),
    "22-mediation-analysis.md": ("chapter-20-22", "Chapters 20–22"),
}

CATALOG_RE = re.compile(
    r"^##+ Catalog of wrong analyses[^\n]*\n(?:.*?\n)*?(?=^##+ |\Z)",
    re.MULTILINE,
)

POINTER_TEMPLATE = """> **Extended catalogue (four-part format):** [Appendix R — {title}](../appendix-r-wrong-analysis-catalog.md#{anchor}).

"""


def main() -> None:
    chapters_dir = ROOT / "chapters"
    for fname, (anchor, title) in CHAPTER_ANCHORS.items():
        path = chapters_dir / fname
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        if "appendix-r-wrong-analysis-catalog" in text:
            continue
        new_text, n = CATALOG_RE.subn(POINTER_TEMPLATE.format(anchor=anchor, title=title), text, count=1)
        if n:
            path.write_text(new_text, encoding="utf-8")
            print(f"Updated catalog pointer: {fname}")
        elif fname == "05-linear-models.md":
            # Ch5 had no catalog; skip
            print(f"No catalog in {fname} (expected for ch5)")


if __name__ == "__main__":
    main()
