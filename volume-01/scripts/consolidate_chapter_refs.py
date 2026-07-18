#!/usr/bin/env python3
"""Move cross-chapter .md links from body tables to a Related chapters section at chapter end."""

from __future__ import annotations

import re
from pathlib import Path

VOLUME = Path(__file__).resolve().parent.parent
CHAPTERS_DIR = VOLUME / "chapters"

CHAPTER_META: dict[str, tuple[str, str]] = {
    "00-welcome.md": ("Welcome", "Book entry point, CASTOR cast, reading paths"),
    "00-preface.md": ("Preface", "Why this book exists; scope and synthetic data"),
    "01-statistical-thinking.md": ("Chapter 1: Statistical thinking", "Estimand, PICO, CASTOR workflow"),
    "02-respiratory-data.md": ("Chapter 2: Respiratory data", "Outcome type, unit of analysis, CASTOR files"),
    "03-descriptive-analysis.md": ("Chapter 3: Descriptive analysis", "Table 1, plots, distribution checks"),
    "04-comparing-groups.md": ("Chapter 4: Comparing groups", "Welch *t*, proportions, group comparisons"),
    "05-linear-models.md": ("Chapter 5: Linear models", "ANCOVA, adjusted continuous associations"),
    "06-generalized-linear-models.md": ("Chapter 6: GLMs", "Logistic, Poisson, count and binary outcomes"),
    "07-model-building.md": ("Chapter 7: Model building", "Covariate choice, LASSO, prespecification"),
    "08-validation-reporting.md": ("Chapter 8: Validation & reporting", "CONSORT, CIs, limits, calibration"),
    "09-prediction-vs-inference.md": ("Chapter 9: Prediction vs inference", "AUC, calibration, nested CV"),
    "10-dimensionality-reduction.md": ("Chapter 10: Dimensionality reduction", "PCA, exploration, p ≫ n"),
    "11-clustering.md": ("Chapter 11: Clustering", "Unsupervised subgroups — claim discipline"),
    "12-case-studies.md": ("Chapter 12: Case studies", "Integrated CASTOR narratives A–E"),
    "13-differential-analysis-fdr.md": ("Chapter 13: Differential analysis & FDR", "Omics discovery, BH-FDR"),
    "14-batch-effects.md": ("Chapter 14: Batch effects", "Technical confounding before DE"),
    "15-flow-cytometry.md": ("Chapter 15: Flow cytometry", "Immune summaries at participant level"),
    "16-antibody-discovery.md": ("Chapter 16: Antibody discovery", "Screen triage and confirmation"),
    "17-integrated-castor-hd.md": ("Chapter 17: Integrated CASTOR-HD", "Full omics pipeline story"),
    "18-longitudinal-mixed-models.md": ("Chapter 18: Longitudinal mixed models", "Repeated FEV₁, slopes, clustering"),
    "19-survival-analysis.md": ("Chapter 19: Survival analysis", "Time to exacerbation, censoring"),
    "20-missing-data.md": ("Chapter 20: Missing data", "MAR/MNAR, MICE, sensitivity analyses"),
    "21-causal-inference.md": ("Chapter 21: Causal inference", "Confounding, IPW, DAGs"),
    "22-mediation-analysis.md": ("Chapter 22: Mediation", "Direct vs indirect effects"),
}

# Sections where chapter links stay clickable (navigation zone).
PRESERVE_SECTIONS = frozenset(
    {
        "quick reference",
        "where we go next",
        "exercises",
        "further reading",
        "handbook resources",
        "related chapters",
    }
)

CHAPTER_FILE_RE = re.compile(
    r"\[([^\]]+)\]\("
    r"(?:\.\./)?(?:chapters/)?"
    r"((?:00-(?:welcome|preface)|[0-9]{2}-[a-z0-9-]+|12-case-studies)\.md)"
    r"(?:#([^)]*))?\)"
)


def split_sections(content: str) -> list[tuple[str, str]]:
    """Return list of (heading_line, body) starting with ('', preamble)."""
    parts = re.split(r"(^## .+$)", content, flags=re.M)
    if not parts:
        return [("", "")]
    out: list[tuple[str, str]] = [("", parts[0])]
    i = 1
    while i < len(parts):
        heading = parts[i]
        body = parts[i + 1] if i + 1 < len(parts) else ""
        out.append((heading, body))
        i += 2
    return out


def section_key(heading: str) -> str:
    if not heading.startswith("## "):
        return ""
    return heading[3:].split(":")[0].strip().lower()


def plain_from_label(label: str, filename: str) -> str:
    label = label.strip()
    if filename.startswith("00-"):
        return "Welcome" if "welcome" in filename else "Preface"
    if label and not label.startswith("http"):
        return label
    num = filename[:2]
    if filename.startswith("12-"):
        return "Case studies (Ch 12)"
    return f"Ch {int(num)}"


def strip_chapter_links(text: str, found: dict[str, str | None]) -> str:
    def repl(m: re.Match[str]) -> str:
        label, filename, anchor = m.group(1), m.group(2), m.group(3)
        found[filename] = anchor
        return plain_from_label(label, filename)

    return CHAPTER_FILE_RE.sub(repl, text)


def link_prefix(filepath: Path) -> str:
    return "" if filepath.name == "00-welcome.md" else ""


def build_related_section(found: dict[str, str | None], current_file: str) -> str:
    if not found:
        return ""
    rows = []
    order = list(CHAPTER_META.keys())
    for filename in order:
        if filename not in found or filename == current_file:
            continue
        title, purpose = CHAPTER_META[filename]
        anchor = found[filename]
        href = filename
        if anchor:
            href += f"#{anchor}"
        rows.append(f"| [{title}]({href}) | {purpose} |")
    for filename in sorted(found):
        if filename in CHAPTER_META or filename == current_file:
            continue
        href = filename
        if found[filename]:
            href += f"#{found[filename]}"
        rows.append(f"| [{filename}]({href}) | See chapter |")
    if not rows:
        return ""
    table = "\n".join(rows)
    return (
        "## Related chapters\n\n"
        "Open these when the body points you to a technique chapter — not while reading the narrative.\n\n"
        "| Chapter | When to open it |\n"
        "|---------|------------------|\n"
        f"{table}\n"
    )


def insert_related(content: str, section: str) -> str:
    if not section:
        return content
    if "## Related chapters" in content:
        start = content.index("## Related chapters")
        end = len(content)
        for marker in ["## Handbook resources", "## Further reading", "## Exercises"]:
            pos = content.find(marker, start + 1)
            if pos != -1:
                end = min(end, pos)
        return content[:start] + section + "\n" + content[end:].lstrip("\n")
    if "## Handbook resources" in content:
        idx = content.index("## Handbook resources")
        return content[:idx] + section + "\n" + content[idx:]
    for marker in ["## Further reading", "## Exercises", "## Where we go next"]:
        idx = content.find(marker)
        if idx != -1:
            return content[:idx] + section + "\n" + content[idx:]
    return content.rstrip() + "\n\n" + section


def process_file(filepath: Path) -> bool:
    original = filepath.read_text(encoding="utf-8")
    found: dict[str, str | None] = {}
    sections = split_sections(original)
    rebuilt: list[str] = []

    for heading, body in sections:
        if section_key(heading) in PRESERVE_SECTIONS:
            rebuilt.append(heading + body)
        else:
            rebuilt.append(heading + strip_chapter_links(body, found))

    content = "".join(rebuilt)
    # Collapse triple+ blank lines
    content = re.sub(r"\n{4,}", "\n\n\n", content)
    section = build_related_section(found, filepath.name)
    content = insert_related(content, section)

    if content != original:
        filepath.write_text(content, encoding="utf-8")
        return True
    return False


def main() -> None:
    targets = sorted(CHAPTERS_DIR.glob("*.md"))
    targets += sorted((VOLUME / "parts").glob("*.md"))
    changed = []
    for path in targets:
        if process_file(path):
            changed.append(path.relative_to(VOLUME))
    print(f"Updated {len(changed)} files:")
    for p in changed:
        print(f"  - {p}")


if __name__ == "__main__":
    main()
