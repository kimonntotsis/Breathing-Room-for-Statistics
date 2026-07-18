#!/usr/bin/env python3
"""Move appendix and handbook .md links from chapter bodies to a Handbook resources section."""

from __future__ import annotations

import re
from pathlib import Path

VOLUME = Path(__file__).resolve().parent.parent

# filename -> (display title, purpose blurb)
RESOURCE_META: dict[str, tuple[str, str]] = {
    "appendix-a-r-setup.md": (
        "Appendix A: R setup",
        "Install R, Posit Desktop, and run teaching scripts",
    ),
    "appendix-b-quick-reference.md": (
        "Appendix B: Quick reference",
        "Choose a test or model by outcome and design",
    ),
    "appendix-c-glossary.md": (
        "Appendix C: Glossary",
        "Look up statistical and respiratory terms",
    ),
    "appendix-d-missing-data-checklists.md": (
        "Appendix D: Missing data checklists",
        "Analysis-plan and manuscript checklists for missing data",
    ),
    "appendix-f-exercises.md": (
        "Appendix F: Exercises",
        "Exercise index across chapters",
    ),
    "appendix-g-handbook-navigation.md": (
        "Appendix G: Handbook navigation",
        "Full file, dataset, and topic index",
    ),
    "appendix-h-clinicians-route.md": (
        "Appendix H: Clinicians' route",
        "Endpoint routing without running R",
    ),
    "appendix-i-figure-hygiene.md": (
        "Appendix I: Figure hygiene",
        "Right vs wrong plot pairs for slides and papers",
    ),
    "appendix-j-investigator-minimum-path.md": (
        "Appendix J: Investigator minimum path",
        "Shortest read for investigators who will not run R",
    ),
    "appendix-k-in-the-room-stories.md": (
        "Appendix K: In the room — short stories",
        "Extended vignettes of common analysis mistakes",
    ),
    "appendix-l-omics-analyst-track.md": (
        "Appendix L: Omics analyst track",
        "Production DESeq2, limma-voom, fgsea, and ComBat pipelines",
    ),
    "appendix-m-bioinformatics-deliverables.md": (
        "Appendix M: Bioinformatics deliverables",
        "What a bioinformatics core should deliver to the study team",
    ),
    "appendix-n-bulk-vs-singlecell.md": (
        "Appendix N: Bulk vs single-cell",
        "When to escalate beyond bulk omics chapters",
    ),
    "appendix-o-ch04-comparison-extensions.md": (
        "Appendix O: Ch 4 comparison extensions",
        "Extended group-comparison methods beyond the core chapter",
    ),
    "METHOD_MAP.md": (
        "METHOD_MAP",
        "Full method inventory and decision-tree text",
    ),
    "RECURRING_COHORT.md": (
        "RECURRING_COHORT",
        "CASTOR dataset glossary and narrative spine",
    ),
    "POLLUX_VIGNETTE.md": (
        "POLLUX / APATE vignette",
        "Prose-only messy registry — what CASTOR deliberately hides",
    ),
    "APATE_VIGNETTE.md": (
        "APATE vignette",
        "Prose-only messy registry checklist (no CSV)",
    ),
    "FIGURE_INDEX.md": (
        "FIGURE_INDEX",
        "Locate figures by chapter",
    ),
    "HIGH_DIM_REPORTING_TEMPLATES.md": (
        "HIGH_DIM_REPORTING_TEMPLATES",
        "Copy-paste Results paragraphs for omics chapters",
    ),
    "HANDBOOK_GUIDE.md": (
        "HANDBOOK_GUIDE",
        "How to use the book by role",
    ),
    "R_GETTING_STARTED_SOP.md": (
        "R Getting Started SOP",
        "Full beginner path from install to first analysis",
    ),
    "CHAPTER_TEMPLATE.md": (
        "CHAPTER_TEMPLATE",
        "Editorial skeleton for method chapters",
    ),
}

RESOURCE_FILES = set(RESOURCE_META.keys())

LINK_RE = re.compile(
    r"\[([^\]]*)\]\("
    r"(?:\.\./|\./|(?:chapters/)?|(?:\.\./chapters/)?)?"
    r"(" + "|".join(re.escape(f) for f in sorted(RESOURCE_FILES, key=len, reverse=True)) + r")"
    r"(#[^)]*)?\)"
)

# Whole lines to drop after link stripping
DROP_LINE_RES = [
    re.compile(r"^\s*Full router:.*$", re.I),
    re.compile(r"^\s*Full handbook router:.*$", re.I),
    re.compile(r"^\s*Router:.*appendix.*$", re.I),
    re.compile(r"^\s*Full router and regeneration:.*$", re.I),
    re.compile(r"^\s*See \[appendix-b-quick-reference\.md\].*$", re.I),
    re.compile(r"^\s*\*\*Handbook link:\*\*.*appendix-b.*$", re.I),
    re.compile(r"^\s*\*\*Deliverables checklist:\*\*.*Appendix M.*$", re.I),
    re.compile(r"^\s*-\s*Route to methods via \[appendix-b.*$", re.I),
    re.compile(r"^\s*-\s*Use \[Appendix B\].*after the estimand.*$", re.I),
    re.compile(r"^\s*Full navigation, datasets, and part map:.*Appendix G.*$", re.I),
]

SECTION_MARKERS = [
    "## Handbook resources",
    "## Quick reference",
    "## Chapter summary",
    "## Where we go next",
    "## Further reading",
    "## Exercises",
]


def link_prefix(filepath: Path) -> str:
    if filepath.name == "00-welcome.md":
        return ""
    if filepath.parent.name == "parts":
        return "../"
    return "../"


def base_from_href(href: str) -> str:
    return href.split("#")[0].split("/")[-1]


def plain_label(filename: str, anchor: str | None = None) -> str:
    title, _ = RESOURCE_META.get(filename, (filename, ""))
    short = title.split(":")[0] if ":" in title else title
    if anchor and "appendix-k" in filename:
        return f"{short} (linked story)"
    return short


def strip_resource_links(text: str, found: dict[str, str | None]) -> str:
    def repl(m: re.Match[str]) -> str:
        filename = m.group(2)
        anchor = m.group(3)
        if filename not in RESOURCE_FILES:
            return m.group(0)
        found[filename] = anchor[1:] if anchor else found.get(filename)
        return plain_label(filename, anchor[1:] if anchor else None)

    return LINK_RE.sub(repl, text)


def split_body_and_tail(content: str) -> tuple[str, str]:
    """Keep Quick reference and later sections in tail for appendix cleanup too."""
    for marker in ["## Quick reference", "## Handbook resources"]:
        idx = content.find(marker)
        if idx != -1:
            return content[:idx], content[idx:]
    # fallback: split at Where we go next / Further reading
    for marker in ["## Where we go next", "## Further reading", "## Exercises"]:
        idx = content.find(marker)
        if idx != -1:
            return content[:idx], content[idx:]
    return content, ""


def clean_block(text: str, found: dict[str, str | None]) -> str:
    text = strip_resource_links(text, found)
    lines = []
    for line in text.splitlines():
        if any(p.match(line) for p in DROP_LINE_RES):
            continue
        # Drop italic quick-ref appendix notes
        if line.strip().startswith("*Routes you to") and "Appendix" in line:
            line = "*Routes you to **chapters**.*"
        if "Pipeline figure" in line and "METHOD_MAP" in line:
            line = "Pipeline figure (`analysis_pipeline.png`), decision tree (`method_decision_tree.png`)."
        if line.strip().startswith("*Routes you to **chapters**. For tests"):
            line = "*Routes you to **chapters**.*"
        lines.append(line.rstrip())
    # collapse 3+ blank lines
    out: list[str] = []
    blank = 0
    for line in lines:
        if not line.strip():
            blank += 1
            if blank <= 2:
                out.append("")
        else:
            blank = 0
            out.append(line)
    return "\n".join(out).strip() + "\n"


def build_resources_section(found: dict[str, str | None], prefix: str) -> str:
    if not found:
        return ""
    rows = []
    order = list(RESOURCE_META.keys())
    for filename in order:
        if filename not in found:
            continue
        title, purpose = RESOURCE_META[filename]
        anchor = found[filename]
        href = f"{prefix}{filename}"
        if anchor:
            href += f"#{anchor}"
        rows.append(f"| [{title}]({href}) | {purpose} |")
    # any unknown files
    for filename in sorted(found):
        if filename not in RESOURCE_META:
            href = f"{prefix}{filename}"
            if found[filename]:
                href += f"#{found[filename]}"
            rows.append(f"| [{filename}]({href}) | Reference material |")

    table = "\n".join(rows)
    return (
        "## Handbook resources\n\n"
        "Optional reference material for this chapter — use for lookup, not while reading the story.\n\n"
        "| Resource | When to use it |\n"
        "|----------|----------------|\n"
        f"{table}\n"
    )


def insert_resources(content: str, section: str) -> str:
    if not section:
        return content
    if "## Handbook resources" in content:
        # replace existing section
        start = content.index("## Handbook resources")
        end = len(content)
        for marker in ["## Further reading", "## Exercises", "## Where we go next"]:
            pos = content.find(marker, start + 1)
            if pos != -1:
                end = min(end, pos)
        return content[:start] + section + "\n" + content[end:].lstrip("\n")

    for marker in ["## Further reading", "## Exercises", "## Where we go next"]:
        idx = content.find(marker)
        if idx != -1:
            return content[:idx] + section + "\n" + content[idx:]

    return content.rstrip() + "\n\n" + section


def process_file(filepath: Path) -> bool:
    original = filepath.read_text(encoding="utf-8")
    found: dict[str, str | None] = {}
    prefix = link_prefix(filepath)

    body, tail = split_body_and_tail(original)
    body = clean_block(body, found)
    tail = clean_block(tail, found) if tail else ""

    # Ch 01 method map table: unlink appendix rows but keep table
    body = body.replace(
        "| [appendix-b-quick-reference.md](../appendix-b-quick-reference.md) |",
        "| Method quick reference (Handbook resources) |",
    )
    body = body.replace(
        "| [METHOD_MAP.md](../METHOD_MAP.md) |",
        "| METHOD_MAP (Handbook resources) |",
    )

    section = build_resources_section(found, prefix)
    combined = body
    if tail:
        combined = body.rstrip() + "\n\n---\n\n" + tail.lstrip()
    combined = insert_resources(combined, section)

    if combined != original:
        filepath.write_text(combined, encoding="utf-8")
        return True
    return False


def main() -> None:
    targets = list((VOLUME / "chapters").glob("*.md"))
    targets += list((VOLUME / "parts").glob("*.md"))
    changed = []
    for path in sorted(targets):
        if process_file(path):
            changed.append(path.relative_to(VOLUME))
    print(f"Updated {len(changed)} files:")
    for p in changed:
        print(f"  - {p}")


if __name__ == "__main__":
    main()
