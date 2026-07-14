#!/usr/bin/env python3
"""Remove em dashes, middot separators, and repeated editorial boilerplate."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
VOLUME = REPO / "volume-01"

GLOBS = [
    VOLUME / "**/*.md",
    VOLUME / "_quarto.yml",
    VOLUME / "latex" / "*.tex",
    REPO / "README.md",
    REPO / "BOOK_OUTLINE.md",
    REPO / "R" / "**/*.R",
]

PHRASE_FIXES = [
    (" — or ", ", or "),
    (" — and ", ", and "),
    (" — not ", ", not "),
    (" — including ", ", including "),
    (" — in that order", ", in that order"),
    (" — continue ", ". Continue "),
    (" — detecting ", ", detecting "),
    (" — misalignment ", ". Misalignment "),
    (" — never ", "; never "),
    (" — see ", "; see "),
    (" — use ", "; use "),
    (" — give ", "; give "),
    (" — comment ", "; comment "),
    (" — should ", "; should "),
    (" — differences ", "; differences "),
    (" — permutation ", "; permutation "),
    (" — biological ", ". Biological "),
    (" — no outcome ", "; no outcome "),
    (" — real ", "; real "),
    (" — rank ", "; rank "),
    (" — choose ", ": choose "),
    (" — full ", "; full "),
    (" — how ", "; how "),
    (" — adjusted ", "; adjusted "),
    (" — this is ", "; this is "),
    (" — slope ", "; slope "),
    (" — report ", ". Report "),
    (" — clinicians ", ". Clinicians "),
    (" — both ", "; both "),
    (" — randomised ", "; randomised "),
    (" — wrong ", "; wrong "),
    (" — equivalence ", "; equivalence "),
    (" — illustrate ", "; illustrate "),
    (" — they answer ", "; they answer "),
    (" — modest ", "; modest "),
    (" — before opening ", " before opening "),
    (" — and document ", ", and document "),
    (" — separate ", "; separate "),
    (" — or inline:", " or inline:"),
    (" — elastic net", ", elastic net"),
    (" — proteomics subset", ", proteomics subset"),
    (" — a subtle", ", a subtle"),
    (" — inference,", ": inference,"),
    (" — inference, prediction", ": inference, prediction"),
    (" — title upper-left", ": title upper-left"),
    (" — teaching contrast", ", teaching contrast"),
    (" — not a full", ", not a full"),
    (" — sample if needed", ", sample if needed"),
    (" — deciles", ", deciles"),
    (" — CASTOR marker panel", ", CASTOR marker panel"),
    (" — handbook", " (handbook)"),
    (" — Solutions", " solutions"),
    (" — Exercises", " exercises"),
    (" — Validation", ": Validation"),
    (" — Descriptive analysis", ": Descriptive analysis"),
    (" — Comparing groups", ": Comparing groups"),
    (" — Linear models", ": Linear models"),
    (" — GLMs", ": GLMs"),
    (" — Prediction", ": Prediction"),
    (" — PCA & clustering", ": PCA and clustering"),
    (" — High-dimensional biology (CASTOR-HD)", ": High-dimensional biology (CASTOR-HD)"),
    (" — Integrated CASTOR-HD", ": Integrated CASTOR-HD"),
    (" — Longitudinal, survival, missing data, causal", ": Longitudinal, survival, missing data, causal"),
    (" — longitudinal & survival (Ch 18–19, Case E)", ": longitudinal and survival (Ch 18–19, Case E)"),
    (" — high-dimensional biology (Ch 13–17)", ": high-dimensional biology (Ch 13–17)"),
    (" — recurring example across the handbook", ": recurring example across the handbook"),
    (" — which method?", ": which method?"),
    (" — Write the estimand", ". Write the estimand"),
    (" — Outcome type → primary method", ". Outcome type to primary method"),
    (" — High-dimensional biology (proteomics, RNA, flow, antibody)", ". High-dimensional biology (proteomics, RNA, flow, antibody)"),
    (" — Continuous outcome: *t*-test or Wilcoxon?", ". Continuous outcome: t-test or Wilcoxon?"),
    (" — Binary / categorical outcome", ". Binary or categorical outcome"),
    (" — Count outcome (exacerbations)", ". Count outcome (exacerbations)"),
    (" — Regression family (Gaussian vs GLM)", ". Regression family (Gaussian vs GLM)"),
    (" — Goal: inference vs prediction vs discovery", ". Goal: inference vs prediction vs discovery"),
    (" — handbook signature format", ": handbook signature format"),
    (" — Clinical question", ": Clinical question"),
    (" — Technique card", ": Technique card"),
    (" — Dual interpretation", ": Dual interpretation"),
    (" — Caveats box (respiratory-specific)", ": Caveats box (respiratory-specific)"),
    (" — Wrong analysis ⚠", ": Wrong analysis"),
    (" — Reporting template", ": Reporting template"),
    (" — R lab + sensitivity", ": R lab and sensitivity"),
    (" — instructor edition, Ch 1–21)", " (instructor edition, Ch 1–21)"),
    (" — handbook (Ch 1–21)", " (handbook, Ch 1–21)"),
    (" — handbook (Ch 0–21)", " (handbook, Ch 0–21)"),
    (" — Statistical Methods for Respiratory Research", ": Statistical Methods for Respiratory Research"),
    (" — handbook outline", " (handbook outline)"),
    (" — confounding and IPW", ", confounding and IPW"),
    (" — Causal inference", ": Causal inference"),
    (" — Missing data", ": Missing data"),
    (" — Survival analysis", ": Survival analysis"),
    (" — Longitudinal mixed models", ": Longitudinal mixed models"),
    (" — Case Studies", ": Case studies"),
    (" — Statistical Thinking", ": Statistical thinking"),
    (" — Respiratory Data", ": Respiratory data"),
    (" — Descriptive Analysis", ": Descriptive analysis"),
    (" — Comparing Groups", ": Comparing groups"),
    (" — Linear Models", ": Linear models"),
    (" — Model Building", ": Model building"),
    (" — Validation & Reporting", ": Validation and reporting"),
    (" — PCA", ": PCA"),
    (" — Clustering", ": Clustering"),
    (" — Differential analysis and FDR", ": Differential analysis and FDR"),
    (" — Batch effects", ": Batch effects"),
    (" — Flow cytometry", ": Flow cytometry"),
    (" — Antibody screening", ": Antibody screening"),
    (" — logistic ", ": logistic "),
    (" — one ", ": one "),
    (" — what ", ": what "),
    (" — any ", ": any "),
    (" — which ", "; which "),
    (" — is ", ": is "),
    (" — if ", ": if "),
    (" — aim ", "; aim "),
    (" — declaring ", ": declaring "),
    (" — failing ", ": failing "),
    (" — time to first exacerbation", ", time to first exacerbation"),
    (" — **associational**", " (**associational**)"),
    (" (IPW — introductory)", " (IPW, introductory)"),
    (" — remains for future expansion", "; remains for future expansion"),
    (" for clinicians, analysts, and researchers, with reproducible R", "; for clinicians, analysts, and researchers, with reproducible R"),
    (" — eight steps", " (eight steps)"),
    (" — DAP and manuscript standards", " (DAP and manuscript standards)"),
    (" — install, packages, shortcuts, troubleshooting", " (install, packages, troubleshooting)"),
    (" — outcome → method routing tables", " (method routing)"),
    (" — plain language for clinicians; precise definitions", ""),
    (" — solutions in repository", " (solutions in repository)"),
    (" — cited bibliography", " (bibliography)"),
    (" — do not explore", ". Do not explore"),
]

TABLE_DASH = re.compile(r"\|\s*—\s*\|")
HEADING = re.compile(r"^#{1,6}\s")
CHAPTER_TITLE = re.compile(r"^(#+ Chapter \d+: [^:\n]+): (.+)$")
BEFORE_R_BLOCK = re.compile(
    r"\n### Before you open R\n\nYou are ready to code when[^\n]+\n",
    re.MULTILINE,
)
APPENDICES_TABLE = """## Appendices

| Appendix | Content |
|----------|---------|
| **A** | [R environment](appendix-a-r-setup.md) |
| **B** | [Quick reference](appendix-b-quick-reference.md) |
| **C** | [Glossary](appendix-c-glossary.md) |
| **D** | [Missing data checklists](appendix-d-missing-data-checklists.md) |
| **F** | [Exercises](appendix-f-exercises.md) |
| **G** | [Handbook navigation + topic index](appendix-g-handbook-navigation.md) |
| **References** | [Bibliography](references.qmd) |"""


def iter_files() -> list[Path]:
    paths: set[Path] = set()
    paths.update(VOLUME.rglob("*.md"))
    paths.update((REPO / "R").rglob("*.R"))
    for extra in [VOLUME / "_quarto.yml", VOLUME / "latex" / "cover-page.tex", REPO / "README.md", REPO / "BOOK_OUTLINE.md"]:
        if extra.exists():
            paths.add(extra)
    return sorted(paths)


def fix_line(line: str) -> str:
    if "—" in line:
        for old, new in PHRASE_FIXES:
            line = line.replace(old, new)

        if TABLE_DASH.search(line):
            line = TABLE_DASH.sub("| |", line)

        if HEADING.match(line):
            line = line.replace(" — ", ": ")
            line = line.replace("—", ": ")
            m = CHAPTER_TITLE.match(line.rstrip("\n"))
            if m and m.group(2).strip():
                line = f"{m.group(1)}, {m.group(2).rstrip()}\n"
            return line

        if line.strip().startswith("#"):
            return line.replace(" — ", ": ").replace("—", ": ")

        line = line.replace(" — ", ": ")
        line = line.replace("—", ": ")

    return line


def fix_middots(text: str) -> str:
    """Replace middot list separators with commas or semicolons."""
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
            line = line.replace(" · ", "; ")
        out.append(line)
    return "".join(out)


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    text = "".join(fix_line(line) for line in original.splitlines(keepends=True))
    text = fix_middots(text)
    text = BEFORE_R_BLOCK.sub("\n", text)

    if path.name == "index.md" and path.parent == VOLUME:
        text = re.sub(
            r"## Appendices\n\n\| Appendix \| Content \|\n\|[-| ]+\|\n(?:\|[^\n]+\n)+",
            APPENDICES_TABLE + "\n",
            text,
            count=1,
        )

    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = [p.relative_to(REPO) for p in iter_files() if process_file(p)]
    print(f"Updated {len(changed)} files")
    for p in changed:
        print(f"  {p}")


if __name__ == "__main__":
    main()
