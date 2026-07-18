#!/usr/bin/env python3
"""Replace out-of-context 'go to Chapter N' pings with in-flow language."""

from __future__ import annotations

import re
from pathlib import Path

VOLUME = Path(__file__).resolve().parent.parent
CHAPTERS = VOLUME / "chapters"

# (pattern, replacement) — order matters (longer/more specific first)
REPLACEMENTS: list[tuple[str, str]] = [
    # Ch 8 used for "report a CI" while doing inference — same workflow
    (r"Report the estimate and CI \(Ch 8\)", "Report the estimate and 95% CI in Results — not *p* alone"),
    (r"see Ch 8 §8\.7", "remember: wide CIs can include both null and clinically important effects"),
    (r"Details: Chapter 8\.", "Use CONSORT/STROBE wording when you draft Methods and Discussion."),
    (r"\| Reporting discipline \| Protocol \+ checklist alignment \| Ch 8 \|", "| Reporting discipline | Protocol + checklist alignment | manuscript sign-off |"),
    (r"CONSORT primary endpoint \(Ch 8\)", "CONSORT primary endpoint (prespecify in SAP)"),
    (r"\[Multiplicity\]\(#multiplicity\) below; Ch 8", "[Multiplicity](#multiplicity) below"),
    (r"\| Ch 8, Ch 12 \|", "| prespecify in SAP; Case 12 capstone |"),
    (r"\| Ch 8 \|", "| report CIs + limits in Results |"),
    (r"See Ch 8 \[@efron1993bootstrap\]", "Bootstrap CI as optional sensitivity"),
    (r"See also Chapter 8 reporting checklist for NI trials\.", "NI trials: prespecify margin and CI-against-margin in the SAP."),
    (r"Reporting → \[Chapter 8\]", "Manuscript sign-off comes after the model fits"),
    (r"\[Chapter 8\]\(08-validation-reporting\.md\) for reporting ORs", "report ORs with 95% CIs and event counts in Results"),
    (r"\[Chapter 8\]\(08-validation-reporting\.md\) for honest reporting", "Part IV when the manuscript is on the desk"),
    (r"Associational language only \(Ch 8\)\.", "Associational language only; state limits in Discussion."),
    (r"Bootstrap CI \| Ch 8", "Bootstrap CI | optional sensitivity"),
    (r"Secondary endpoints \(FVC, CAT\) in Holm family \| Ch 4, 8", "Secondary endpoints (FVC, CAT) in Holm family | Ch 4 + SAP"),
    (r"Power note \(if negative\) \| Ch 4, 8", "Power note (if negative) | Ch 4 + SAP"),
    (r"No stepwise selection \| Ch 7", "No stepwise selection | prespecify covariates in SAP"),
    (r"prespecify confounders in the SAP \(Ch 7\)", "prespecify confounders in the SAP before unblinding"),
    (r"Prespecify confounders \(Ch 7\)", "Prespecify confounders in the SAP"),
    (r"confounders \(Ch 7\)", "prespecified confounders"),
    (r"\| Ch 7 \|", "| prespecify in SAP |"),
    (r"route adjustment to regression \(Ch 5, Ch 6\)", "route adjustment to regression (next two chapters in Part III)"),
    (r"Poisson / NB GLM \(Ch 6\)", "Poisson / NB GLM (binary/count chapter)"),
    (r"Logistic for adjustment \(Ch 6\)", "Logistic regression for adjustment"),
    (r"See Chapter 6\.", "Use count/binary GLMs (Chapter 6)."),
    (r"Full treatment in Chapter 5\.", "Full ANCOVA treatment is the subject of Chapter 5."),
    (r"See also Chapter 5\.", "Chapter 5 extends this model."),
    (r"Calibration plot, Brier score \(Ch 9\)", "Calibration plot, Brier score (prediction chapter)"),
    (r"Not for prediction \| Use calibration/AUC separately \(Ch 9\)", "Not for prediction — evaluate calibration separately when the goal is risk scoring"),
]

# Where we go next: strip laundry-list **Next:** with 3+ chapter arrows when followed by narrative section
LAUNDRY_NEXT = re.compile(
    r"\*\*Next:\*\*[^.]+\[Chapter \d+\][^.]+\[Chapter \d+\][^.]+\[Chapter \d+\][^\n]*\n",
    re.I,
)


def in_preserve_zone(content: str, pos: int) -> bool:
    """Allow chapter links in Related chapters / Quick reference tables."""
    before = content[:pos]
    for heading in ["## Related chapters", "## Quick reference", "## Exercises"]:
        hpos = before.rfind(heading)
        if hpos != -1 and before[hpos:].find("\n## ", 1) == -1:
            return True
    return False


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    content = original
    for pat, repl in REPLACEMENTS:
        content = re.sub(pat, repl, content)
    if path.name in ("05-linear-models.md", "06-generalized-linear-models.md", "07-model-building.md"):
        content = LAUNDRY_NEXT.sub("", content)
    if content != original:
        path.write_text(content, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = [p.name for p in CHAPTERS.glob("*.md") if process_file(p)]
    print(f"Cross-ref voice: {len(changed)} files — {', '.join(changed)}")


if __name__ == "__main__":
    main()
