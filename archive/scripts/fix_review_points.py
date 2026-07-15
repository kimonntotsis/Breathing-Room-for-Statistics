#!/usr/bin/env python3
"""One-off fixes from literary review (anchors, POLLUX labels, openings)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

ANCHOR_MAP = {
    "chapters/01-statistical-thinking.md#in-this-chapter": "chapters/01-statistical-thinking.md#at-a-glance",
    "chapters/04-comparing-groups.md#in-this-chapter": "chapters/04-comparing-groups.md#at-a-glance",
    "chapters/05-linear-models.md#in-this-chapter": "chapters/05-linear-models.md#at-a-glance",
    "chapters/06-generalized-linear-models.md#in-this-chapter": "chapters/06-generalized-linear-models.md#at-a-glance",
    "chapters/18-longitudinal-mixed-models.md#in-this-chapter": "chapters/18-longitudinal-mixed-models.md#at-a-glance",
    "chapters/19-survival-analysis.md#in-this-chapter": "chapters/19-survival-analysis.md#at-a-glance",
    "chapters/20-missing-data.md#in-this-chapter": "chapters/20-missing-data.md#at-a-glance",
    "chapters/21-causal-inference.md#in-this-chapter": "chapters/21-causal-inference.md#at-a-glance",
    "chapters/17-integrated-castor-hd.md#in-this-chapter": "chapters/17-integrated-castor-hd.md#at-a-glance",
}

POLLUX_UNIFIED = (
    "**POLLUX vignette** (messy-registry judgement; optional `data/pollux_registry_messy.csv` for Ch 20 drills)"
)


def fix_appendix_j(path: Path) -> None:
    t = path.read_text()
    for old, new in ANCHOR_MAP.items():
        t = t.replace(old, new)
    t = t.replace("Ch 1: In this chapter", "Ch 1: At a glance")
    t = t.replace("Ch 4: In this chapter", "Ch 4: At a glance")
    t = t.replace("Ch 5 in this chapter", "Ch 5 At a glance")
    t = t.replace("Ch 6 in this chapter", "Ch 6 At a glance")
    t = t.replace("Ch 18 in this chapter", "Ch 18 At a glance")
    t = t.replace("Ch 19 in this chapter", "Ch 19 At a glance")
    t = t.replace("Ch 20 in this chapter", "Ch 20 At a glance")
    t = t.replace("Ch 21 in this chapter", "Ch 21 At a glance")
    path.write_text(t)


def fix_pollux_labels(path: Path) -> None:
    t = path.read_text()
    t = t.replace(
        "**POLLUX vignette (messy registry, no data)**",
        POLLUX_UNIFIED,
    )
    path.write_text(t)


if __name__ == "__main__":
    fix_appendix_j(ROOT / "appendix-j-investigator-minimum-path.md")
    fix_pollux_labels(ROOT / "appendix-g-handbook-navigation.md")
    print("done")
