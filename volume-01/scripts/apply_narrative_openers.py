#!/usr/bin/env python3
"""Apply story-first openings to handbook chapters (batch pass)."""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CH = REPO / "volume-01" / "chapters"

# Opening scene + Why this chapter (markdown). Keys: filename stem without .md
OPENERS: dict[str, str] = {
    "02-respiratory-data": """## Opening scene: the data dictionary meeting

Mei spreads a printout across Dr Rivera's desk. CASTOR's first clean export: patient ID, age, sex, smoking, therapy line, FEV₁, FVC, exacerbation yes/no, exacerbation counts, visit week. The protocol mentions a primary endpoint; the spreadsheet mentions twelve other columns that could become "exploratory primaries" if someone is tired on a Friday.

*\"Which column is the outcome?\"* Rivera asks. *\"All of them,\"* Mei says, *\"until we decide which one answers the protocol. That's today.\"*

This chapter is that meeting. You classify outcome type, unit of analysis, and design **before** any test name.

---

## Why this chapter

The wrong method usually starts with the wrong **outcome type**, not the wrong R function. When you finish here, you can complete the pre-analysis checklist at chapter end and route to the right technique chapter — not to a menu of tests.""",

    "03-descriptive-analysis": """## Opening scene: the steering committee wants numbers

Two weeks before interim lock, the DSMB asks for baseline balance. Dr Rivera needs Table 1 by tomorrow. Mei has the CASTOR export but not yet a prespecified primary test — and that is fine. Description comes **first**.

A sponsor slide shows mean FEV₁ bars with a cropped *y*-axis; the arms look worlds apart. Mei replaces it with violins on the full scale. *\"If this is our only figure,\"* she tells Rivera, *\"would you still sign the SAP?\"*

---

## Why this chapter

Reviewers meet your study in Table 1 and Figure 1. Description is not preamble — it is where missingness, skew, and protocol quirks become visible. CASTOR starts here so you see the same four hundred participants before any inferential claim.""",

    "04-comparing-groups": """## Opening scene: \"Can we call this a win?\"

Interim CASTOR results land: mean FEV₁ 3.85 L intervention vs 3.76 L standard care. The forest-plot snippet looks encouraging; *p* = 0.20. A steering member reads significance from colour alone.

Mei projects the mean difference and 95% CI: 0.09 L (−0.04 to 0.21). The prespecified MCID was 0.10 L. *\"Non-significant superiority is inconclusive,\"* she says, *\"not proof the arms are equal. We report the estimand we wrote in the SAP.\"*

This chapter is the reference for that conversation — and for every other group comparison in respiratory work.

---

## Why this chapter

Most respiratory papers hinge on a comparison: means, proportions, or rates between arms. The mistakes repeat — wrong pairing, wrong outcome family, *p*-values without effect sizes. Work through the CASTOR primary here; bookmark the chapter when your endpoint changes.""",

    "05-linear-models": """## Opening scene: \"Can we adjust for baseline?\"

The primary Welch *t*-test on week-12 FEV₁ is prespecified; the sponsor now asks whether baseline FEV₁ changes the story. That is not a post hoc rescue — it is ANCOVA, if it was in the SAP. Separately, an observational question arrives from the same cohort: *Is FEV₁ lower in smokers after age and height?* Different estimand, same regression family.

Mei draws two columns on the whiteboard: **trial contrast** vs **adjusted association**. Same `lm()` syntax; different sentences in the abstract.

---

## Why this chapter

Linear models carry adjusted mean differences, ANCOVA, and diagnostic discipline. You need them when a *t*-test is too crude or when confounders are part of the question — not when you are fishing for significance.""",

    "06-generalized-linear-models": """## Opening scene: the secondary endpoint email

Regulatory affairs asks for exacerbation results. Binary: any vs none in twelve months. Count: events per person-year. A fellow already ran `lm()` on 0/1 exacerbation; coefficients look tidy and completely wrong.

Mei converts the thread into two families: **logistic** for proportions, **Poisson/negative binomial** for rates with exposure time. Rivera gets one slide with event tables, not six mislabelled *p*-values.

---

## Why this chapter

Respiratory endpoints are often binary or count-shaped. This chapter is where CASTOR's exacerbation variables get the model family they deserve — and where you learn why a Gaussian test on 0/1 is a silent failure.""",

    "07-model-building": """## Opening scene: the variable-selection workshop

The CRO proposes "let the data tell us" which covariates belong in the FEV₁ model. Twelve baseline variables, stepwise AIC, one hour before the abstract deadline. Mei opens the prespecified SAP: age, sex, smoking, baseline FEV₁ — full stop.

*\"The data can suggest sensitivity analyses,\"* she says. *\"It cannot rewrite the primary model after unblinding.\"*

---

## Why this chapter

Model building is where good studies leak degrees of freedom. This chapter separates prespecification from exploration — and gives you language for the meeting when someone wants "just one more predictor.""",

    "08-validation-reporting": """## Opening scene: the manuscript deadline

CONSORT checklist on one monitor, CASTOR Results on the other. Reviewer 2 will ask for confidence intervals, flow counts, and what the trial **did not** prove. Rivera drafts *\"trend toward benefit\"*; Mei replaces it with the CI against MCID and a Limits paragraph.

This chapter is sign-off discipline: reporting frameworks, intervals, multiplicity, and honest language.

---

## Why this chapter

Correct analysis that is reported badly still misleads clinicians. CASTOR Case A's publishable narrative lives here — CONSORT-aligned tables, estimand-first sentences, and what to say when the primary is inconclusive.""",

    "09-prediction-vs-inference": """## Opening scene: the partner wants a risk score

An industry collaborator loves the CASTOR baseline variables. *\"Can we predict twelve-month exacerbation for clinic triage?\"* Different question from *\"Does treatment reduce exacerbation?\"* Mei pulls up Story 2 from the grant appendix: random forest, training-set AUC, no calibration — a deck that cannot answer *\"what risk for this patient?\"*

---

## Why this chapter

Prediction and inference share code but not goals. This chapter is where you evaluate discrimination **and** calibration, and where you refuse causal language for a risk score.""",

    "10-dimensionality-reduction": """## Opening scene: thirty markers, one slide

CASTOR's marker panel arrives for exploratory work: thirty correlated proteins, true phenotype labels for teaching only. A translational postdoc runs PCA coloured by case/control; the ellipses separate beautifully. Mei asks: *\"Colour by processing batch first. Then show me the scree.\"*

---

## Why this chapter

High-dimensional summaries are exploration tools, not endpoints. PCA and friends reduce noise before clustering or hypothesis tests — when you use them with batch awareness and modest claims.""",

    "11-clustering": """## Opening scene: \"Cluster B is the T2-high endotype\"

k-means on PCA scores yields three colourful groups. Marketing language writes itself. Mei asks for silhouette, stability, and whether cluster membership was defined **before** looking at treatment response. The claim ladder goes up one rung at a time — or stops.

---

## Why this chapter

Clustering sells endotypes; statistics asks whether groups replicate and what they predict. CASTOR Case C lives here — discovery language only until external validation.""",

    "12-case-studies": """## Opening scene: five manuscripts, one cohort

By now you have met CASTOR as trial, registry, and omics substudy. This chapter replays five complete arcs — A through E — the way a methods group actually works: estimand on paper, analysis path in a table, Results template, explicit **does not prove**.

Read Case A if you read nothing else. It is the steering-committee FEV₁ story from Chapter 4, told start to finish.

---

## Why this chapter

Technique chapters teach parts. Case studies teach **sequence** — and the sign-off checklist investigators use before Methods goes to the journal.""",

    "13-differential-analysis-fdr": """## Opening scene: the CRO's week-one email

Nine hundred twenty proteins. Forty-one nominally significant. No batch column attached. Dr Rivera forwards the PDF to Mei with one line: *\"Is this our subgroup analysis now?\"*

This chapter is the omics discovery workflow: per-feature models, FDR, volcano plots as **triage**, and language that separates discovery from the week-12 FEV₁ primary.

---

## Why this chapter

Volume intimidates; estimands do not change. CASTOR-HD teaches defensible differential analysis when features outnumber patients — and what to demand before you fund validation.""",

    "14-batch-effects": """## Opening scene: PCA that looks too good

The first PCA separates cases and controls cleanly — until Mei colours points by plate. The same separation tracks batch, not biology. The CRO insists normalisation is "proprietary." This chapter is the vocabulary for that fight.

---

## Why this chapter

Batch is the commonest confounder in omics. You will diagnose it, adjust with prespecified methods, and report sensitivity — before anyone names an endotype.""",

    "15-flow-cytometry": """## Opening scene: proportions that sum to one

Flow summaries arrive: sixteen cell populations as percentages per participant. A bar chart shows "more neutrophils in cases." Mei asks whether the increase is composition — more neutrophils **within** patients — or different patient mix. Pseudoreplication waits in the per-cell file.

---

## Why this chapter

Flow data are compositional and hierarchical. This chapter teaches participant-level summaries, drift checks, and when the per-cell toy file is only a warning — not the primary analysis.""",

    "16-antibody-discovery": """## Opening scene: the hit list

A screen ranks four hundred clones; the PI wants the top ten in validation by Friday. Mei asks for replicate agreement, prespecified hit rules, and confirmation positivity before anyone says *\"lead candidate.\"* PPV matters more than the prettiest rank plot.

---

## Why this chapter

Antibody and biomarker screens are triage exercises. This chapter connects screen thresholds, confirmation assays, and honest PPV — CASTOR's `antibody_screen.csv` carries the teaching example.""",

    "17-integrated-castor-hd": """## Opening scene: one Results section, two worlds

Proteomics hits, RNA fold-changes, and trial FEV₁ all land in the same manuscript draft. Reviewer 2 will ask which claims are confirmatory. Mei splits Results into discovery and clinical paragraphs — and a limitations block that admits what integration **did not** establish.

---

## Why this chapter

Integrated omics capstones need stop/go gates. CASTOR-HD walks bulk matrices plus participant summaries without pretending one volcano plot replaces the SAP.""",

    "18-longitudinal-mixed-models": """## Opening scene: week 52 only?

The extension study has four FEV₁ visits per patient. A collaborator pools all rows and runs a *t*-test at week 52. Mei draws spaghetti: dropout visible, slopes heterogeneous, correlation within person ignored. Mixed models use every visit without pretending rows are independent.

---

## Why this chapter

Longitudinal spirometry is the commonest place independence assumptions break. CASTOR's `longitudinal_spirometry.csv` and Case E teach trajectories, random intercepts, and when a single visit snapshot is prespecified instead.""",

    "19-survival-analysis": """## Opening scene: \"% with an event\" on a bar chart

Twelve-month follow-up, censored at day 365, exacerbation events unevenly spaced. A bar chart of *\"percent exacerbated\"* throws away timing. Mei replaces it with Kaplan–Meier: curves, censoring marks, log-rank only if prespecified.

---

## Why this chapter

Time-to-event endpoints need time in the model. CASTOR's `time_to_exacerbation.csv` teaches censoring, Cox models, and why a proportion bar is the wrong plot.""",

    "20-missing-data": """## Opening scene: twelve percent missing FEV₁

Week-12 spirometry missing for forty-eight participants — clinic closure, COVID, plain refusal. ITT says analyse everyone randomised. Mei maps missingness by arm and diagnosis before choosing complete-case, multiple imputation, or a principled sensitivity.

---

## Why this chapter

Missing data is where ITT meets reality. This chapter connects patterns, mechanisms, and sensitivity — so missingness is a result, not a footnote.""",

    "21-causal-inference": """## Opening scene: \"Smoking reduces exacerbation risk\"

The observational CASTOR cohort shows a significant adjusted OR after `lm()` on 0/1 was finally replaced by logistic regression. A fellow drafts causation language. Mei rewrites: **association**, confounding, positivity — and what randomisation would have required to claim more.

---

## Why this chapter

Observational respiratory studies dominate the literature. This chapter gives IPW, matching, and honest limits — without selling association as intervention effect.""",

    "22-mediation-analysis": """## Opening scene: \"Is it mediated by FEV₁?\"

Smoking associates with exacerbation; FEV₁ sits on the path. A PI asks how much is **direct** vs **through** lung function. Mediation decomposes associational paths — not mechanistic proof — when prespecified and interpreted with humility.

---

## Why this chapter

Mediation answers a specific estimand question. CASTOR closes the volume here: total, direct, and indirect language tied to bootstrap CIs — and explicit limits on causal reading.""",
}

# Sections that end the boilerplate block (first match wins)
BOILERPLATE_END = [
    "## Why this chapter",
    "## Opening question",
    "## Clinical and biostatistics notes",
    "## The data classification workflow",
    "## The descriptive workflow",
    "## The comparison workflow",
    "## Three layers of every analysis",
    "## When linear regression",
    "## Opening scene",  # already transformed
]

METHOD_SECTION = "## Method choice at a glance"
QUICK_REF = "## Quick reference: methods in this chapter"


def find_boilerplate_end(text: str, start: int) -> int:
    for marker in BOILERPLATE_END:
        pos = text.find(marker, start)
        if pos != -1:
            # skip if it's our new opener's "Why this chapter" inside OPENERS - handled separately
            return pos
    return start


def extract_method_block(text: str) -> tuple[str, str]:
    """Return (text_without_method, method_block_or_empty)."""
    m = re.search(
        r"^## Method choice at a glance\s*\n(.*?)(?=^## (?!Method choice))",
        text,
        flags=re.MULTILINE | re.DOTALL,
    )
    if not m:
        return text, ""
    block = m.group(0).rstrip() + "\n\n"
    block = block.replace(METHOD_SECTION, QUICK_REF, 1)
    new_text = text[: m.start()] + text[m.end() :]
    return new_text, block


def insert_before_chapter_summary(text: str, block: str) -> str:
    if not block.strip():
        return text
    if QUICK_REF in text:
        return text
    anchor = "## Chapter summary"
    if anchor not in text:
        anchor = "## Where this chapter leads"
    if anchor not in text:
        anchor = "## Where we go next"
    if anchor not in text:
        return text + "\n\n---\n\n" + block
    return text.replace(anchor, "---\n\n" + block + anchor, 1)


def transform_chapter(path: Path, opener: str) -> bool:
    text = path.read_text(encoding="utf-8")
    if "## Opening scene:" in text and "## At a glance" not in text:
        return False

    # Title block: through first --- after part line
    title_m = re.match(
        r"(# Chapter[^\n]+\n\n> \*\*Part[^\n]+\n\n)",
        text,
    )
    if not title_m:
        return False
    title_block = title_m.group(1)

    rest = text[len(title_block) :]
    if not rest.lstrip().startswith("## At a glance"):
        # try without At a glance - maybe partial edit
        if "## Opening scene:" in rest[:500]:
            return False

    # Find end of boilerplate: after Prerequisites or before first content
    ag_pos = rest.find("## At a glance")
    if ag_pos == -1:
        return False

    # Find --- after prerequisites / opening question block
    search_from = ag_pos
    end_pos = None
    for marker in [
        "## Why this chapter",
        "## Opening question",
        "## Clinical and biostatistics notes",
        "## The data classification workflow",
        "## The descriptive workflow",
        "## The comparison workflow",
        "## Three layers of every analysis",
    ]:
        p = rest.find(marker, search_from)
        if p != -1:
            # include through that section until next ## or ---
            sec = rest[p:]
            nxt = re.search(r"\n---\n\n## ", sec)
            if nxt:
                end_pos = p + nxt.start() + 1  # keep ---
                break
            nxt2 = re.search(r"\n## ", sec[len(marker) :])
            if nxt2 and marker != "## Why this chapter":
                end_pos = p
                break

    if end_pos is None:
        # fallback: skip until three layers or first major section after learning objectives
        for marker in [
            "## Three layers",
            "## Teaching datasets",
            "## Plot choice",
            "## Continuous outcomes",
        ]:
            p = rest.find(marker)
            if p != -1:
                end_pos = p
                break

    if end_pos is None:
        return False

    body = rest[end_pos:].lstrip()
    if body.startswith("---"):
        body = body[4:].lstrip()

    new_text = title_block + opener + "\n\n---\n\n" + body
    new_text, method_block = extract_method_block(new_text)
    new_text = insert_before_chapter_summary(new_text, method_block)

    # Rename "Where this chapter leads" -> "Where we go next"
    new_text = new_text.replace("## Where this chapter leads", "## Where we go next")

    path.write_text(new_text, encoding="utf-8")
    return True


def main() -> None:
    changed = []
    for stem, opener in sorted(OPENERS.items()):
        path = CH / f"{stem}.md"
        if not path.exists():
            print(f"SKIP missing {path.name}")
            continue
        if transform_chapter(path, opener):
            changed.append(path.name)
            print(f"OK {path.name}")
        else:
            print(f"-- {path.name} (already transformed or skipped)")

    print(f"\nTransformed {len(changed)} chapters.")


if __name__ == "__main__":
    main()
