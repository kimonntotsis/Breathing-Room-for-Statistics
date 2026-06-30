#!/usr/bin/env python3
"""Add editorial layer: Why this chapter, In practice, Before you open R, Chapter bridge."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHAPTERS = ROOT / "chapters"
PARTS = ROOT / "parts"

WHY = {
    "01-statistical-thinking.md": """## Why this chapter

Every later chapter assumes you can name the estimand before touching R. Trialists use this chapter to align with statisticians; analysts use it to push back when a protocol question is vague. If you skip straight to Chapter 4, you will still run code — but you may answer a question nobody meant to ask.

""",
    "02-respiratory-data.md": """## Why this chapter

The wrong method usually starts with the wrong **outcome type**, not the wrong R function. This chapter is where you classify continuous FEV1, binary exacerbation, counts, survival, and omics before opening a test. Keep [QUICK_REFERENCE](../QUICK_REFERENCE.md) closed until you can complete the checklist at the end of this chapter.

""",
    "03-descriptive-analysis.md": """## Why this chapter

Reviewers and clinicians meet your study in Table 1 and the first figure. Description is not “preliminary”; it is where missingness, skew, and protocol quirks become visible. CASTOR starts here so you see the same patients before any test is run.

""",
    "04-comparing-groups.md": """## Why this chapter

Most respiratory papers still hinge on a comparison: means, proportions, or rates between arms or exposure groups. This is the longest reference chapter because the mistakes are repetitive — wrong pairing, wrong outcome type, p-values without effect sizes. Bookmark it.

""",
    "05-linear-models.md": """## Why this chapter

Trials rarely stop at a raw mean difference; they adjust for baseline FEV1, centre, or stratification factors. Linear models are the workhorse for continuous lung function and for ANCOVA-style trial analysis. You need this chapter before interpreting “adjusted” results in papers.

""",
    "06-generalized-linear-models.md": """## Why this chapter

Exacerbation yes/no, exacerbation counts, and ordinal symptoms do not belong on a Gaussian model. GLMs are where CASTOR’s binary and count endpoints live. If your outcome is 0/1 or a small non-negative integer, you are in this chapter.

""",
    "07-model-building.md": """## Why this chapter

Model building is where optimism hides: too many predictors, data-driven selection, and overfitted “risk scores.” This chapter separates prespecified adjustment from fishing. Read it before adding “one more covariate” because it improved the p-value.

""",
    "08-validation-reporting.md": """## Why this chapter

A correct analysis reported badly is still unusable in a protocol or journal. This chapter is for anyone writing the Methods or Results — CONSORT, STROBE, TRIPOD, intervals instead of “p > 0.05 means no effect.” CASTOR examples show how to report evidence, not just significance.

""",
    "09-prediction-vs-inference.md": """## Why this chapter

Prediction models are everywhere in respiratory research — admission risk, exacerbation scores, classifier AUCs — but they answer a different question than association. This chapter stops you from reporting an odds ratio when the clinical need is calibrated risk, and vice versa.

""",
    "10-dimensionality-reduction.md": """## Why this chapter

Marker panels and omics produce too many correlated columns to inspect by eye. PCA and related tools help you **see** structure without pretending every axis is a new biomarker. Use this chapter for exploration; use Ch 13+ when the goal is formal differential analysis.

""",
    "11-clustering.md": """## Why this chapter

“Endotypes” and “subgroups” sell papers; unstable clusters do not. This chapter teaches clustering as **hypothesis generation** with explicit stability and batch checks — the antidote to naming k-means groups after Greek letters without validation.

""",
    "12-case-studies.md": """## Why this chapter

Technique cards teach atoms; case studies teach **workflow**. You will walk four complete CASTOR narratives (trial, cohort, discovery, omics pipeline, longitudinal/survival) and practice saying what each analysis does **not** prove. This is the chapter to read before your first manuscript discussion section.

""",
    "13-differential-analysis-fdr.md": """## Why this chapter

Omics generates thousands of p-values. Without FDR and effect sizes, you will chase false proteins and genes. This chapter is for anyone with a volcano plot in a manuscript or team readout who cannot yet explain what q = 0.11 means for follow-up budget.

""",
    "14-batch-effects.md": """## Why this chapter

Batch effects are the default in proteomics, RNA, and flow — not the exception. This chapter asks the uncomfortable question first: did we rediscover the lab calendar? Read it before interpreting any hit list from Chapter 13.

""",
    "15-flow-cytometry.md": """## Why this chapter

Flow data are beautiful and easy to mis-analyse. A stunning UMAP is not evidence; pooling cells as if they were patients is pseudo-replication. This chapter keeps immune phenotyping at the **participant** level where clinicians can interpret it.

""",
    "16-antibody-discovery.md": """## Why this chapter

Screens are triage, not truth. This chapter is for teams deciding which clones to pay to validate — using PPV, prespecified thresholds, and stability tiers instead of rank #7 versus #9 storytelling.

""",
    "17-integrated-castor-hd.md": """## Why this chapter

Real discovery is a pipeline, not a single heatmap. This chapter strings proteomics, batch QC, flow, antibody confirmation, and optional prediction into one honest narrative — including where to **stop** when batch and group are confounded.

""",
    "18-longitudinal-mixed-models.md": """## Why this chapter

Repeated FEV1 visits carry more information than a single timepoint; a week-52 t-test discards most of that structure. This chapter is for extension trials and observational spirometry trajectories where the same patient appears more than once.

""",
    "19-survival-analysis.md": """## Why this chapter

Sponsors often ask “exacerbation yes/no at 12 months” when dates of event and censoring are already in the database. Survival methods use follow-up time properly. This chapter also teaches when a hazard ratio is not enough for clinicians.

""",
    "20-missing-data.md": """## Why this chapter

Missing FEV1 is rarely random in severe COPD. Complete-case analysis can quietly describe healthier subsets. This chapter makes missingness visible in tables and figures before you defend an association.

""",
    "21-causal-inference.md": """## Why this chapter

Observational smoking and therapy comparisons invite causal language. This chapter separates associational estimands from causal claims, introduces IPW as sensitivity (not proof), and points back to randomised Case A when you need real causal evidence.

""",
}

IN_PRACTICE = {
    "01": """### In practice

Grant deadlines and sponsor calls still push “quick t-tests.” Your job is to spend five minutes on the estimand and write it in the analysis plan — before the first line of R. That single habit prevents more errors than any test choice.

""",
    "02": """### In practice

Real spreadsheets mix litres and millilitres, duplicate IDs, and “exacerbation” columns defined differently across sites. Run the quality checks in this chapter **before** you fit models, not after the output looks interesting.

""",
    "03": """### In practice

Table 1 is often drafted by a junior author while the statistician is busy elsewhere. Agree on variable definitions and missingness rules first; otherwise Table 1 and the model use different populations.

""",
    "04": """### In practice

The protocol says “compare FEV1 at week 12.” The data have baseline visits, dropouts, and one site that measured post-bronchodilator values only. Map protocol → estimand → test before opening `t.test()` — and document deviations in the SAP.

""",
    "05": """### In practice

“Adjust for baseline FEV1” usually means ANCOVA, not change scores unless prespecified. Check whether baseline was measured pre-randomisation and whether missing baseline rows are excluded silently.

""",
    "06": """### In practice

Exacerbation counts of 0, 1, 2, 3 dominate COPD cohorts. Poisson will look fine in R and fail on overdispersion. Always check observed vs fitted counts and consider negative binomial before trusting the rate ratio.

""",
    "07": """### In practice

Stepwise selection after seeing results is still common in submitted manuscripts. If variables were not in the prespecified SAP, call the model exploratory and show stability (bootstrap or penalization), not a definitive p-value.

""",
    "08": """### In practice

Reviewers will ask for CIs even when you reported p-values. Build tables with estimate, CI, and n from the start — retrofitting intervals before resubmission wastes a week and invites arithmetic errors.

""",
    "09": """### In practice

AUC of 0.85 on 11 events in the test set is not deployable. Report calibration and event counts; plan external validation before anyone uses the score in clinic.

""",
    "10": """### In practice

PCA on 30 markers can be dominated by one batch variable. Colour points by batch before colouring by phenotype — the same rule as omics, at smaller scale.

""",
    "11": """### In practice

Clusters that align perfectly with processing batch are a QC finding, not an endotype. Say so in the team meeting before the abstract draft uses the word “subtype.”

""",
    "12": """### In practice

Manuscripts often mix discovery language (omics hits) with confirmatory language (trial primary endpoint). Use separate paragraphs — and separate limitations — for each CASTOR case narrative you mirror.

""",
    "13": """### In practice

A collaborator emails “we have 47 significant proteins.” Ask for effect sizes, q-values, and whether batch was in the model. Zero FDR hits after batch adjustment is a valid result worth reporting.

""",
    "14": """### In practice

ComBat on the full dataset before train/test split has sunk prediction papers. Any correction — covariate or ComBat — must respect the same leakage rules as Chapter 9.

""",
    "15": """### In practice

A flow core returns 50,000 events per patient and a beautiful t-SNE. Summarise to participant proportions first; show the embedding in supplementary material as QC.

""",
    "16": """### In practice

Changing the hit threshold after seeing the plate layout is post hoc tuning. Prespecify the rule (or control-based z-score) and show sensitivity across a grid of cutoffs.

""",
    "17": """### In practice

Integrated omics slides often show only the volcano. Decision-makers need the stop/go gates: batch overlap, discovery count with/without adjustment, PPV, Tier 1 clones — in that order.

""",
    "18": """### In practice

Week-52 t-tests on last observation carried forward still appear in extension studies. Mixed models or principled missing-data methods (Ch 20) are the defensible default when visits are scheduled.

""",
    "19": """### In practice

Censored patients are not “event-free forever.” Administrative censoring at 365 days must appear in the Methods; person-time and event counts belong in Results alongside any hazard ratio.

""",
    "20": """### In practice

“No missing data” sometimes means missing was coded as zero or carried forward. Audit the raw CRF before trusting `complete.cases()`.

""",
    "21": """### In practice

“Adjusted for confounders” in an abstract is not causal language. Match verbs to design: randomised trial → effect; observational cohort → association unless prespecified causal framework and sensitivity are in place.

""",
}

BEFORE_R = """### Before you open R

State the estimand, unit of analysis, data file, and one prespecified sensitivity before running the script. Do not explore the data first and pick the test that looks best.

"""

BRIDGE = {
    "01": """## Where this chapter leads

**Next:** [Chapter 2](02-respiratory-data.md) classifies CASTOR variables so [QUICK_REFERENCE](../QUICK_REFERENCE.md) routes you to the right method. Keep your estimand sentence from this chapter on hand.

""",
    "02": """## Where this chapter leads

**Next:** [Chapter 3](03-descriptive-analysis.md) describes the cohort before [Chapter 4](04-comparing-groups.md) compares groups. If you already know you need survival or mixed models, skim [Ch 18–19](18-longitudinal-mixed-models.md) after the checklist here.

""",
    "03": """## Where this chapter leads

**Next:** [Chapter 4](04-comparing-groups.md) is the comparison reference. Bring your Table 1 insights (skew, missingness, n per arm) into every test choice.

""",
    "04": """## Where this chapter leads

**Next:** Continuous outcomes with covariates → [Chapter 5](05-linear-models.md). Binary/count outcomes → [Chapter 6](06-generalized-linear-models.md). Repeated visits → [Chapter 18](18-longitudinal-mixed-models.md).

""",
    "05": """## Where this chapter leads

**Next:** Non-Gaussian outcomes → [Chapter 6](06-generalized-linear-models.md). Model selection and penalization → [Chapter 7](07-model-building.md). Reporting → [Chapter 8](08-validation-reporting.md).

""",
    "06": """## Where this chapter leads

**Next:** [Chapter 7](07-model-building.md) for selection and LASSO; [Chapter 8](08-validation-reporting.md) for reporting ORs and rate ratios with intervals. Time-to-event endpoints → [Chapter 19](19-survival-analysis.md).

""",
    "07": """## Where this chapter leads

**Next:** [Chapter 8](08-validation-reporting.md) for honest reporting; [Chapter 9](09-prediction-vs-inference.md) if the goal is risk prediction rather than association.

""",
    "08": """## Where this chapter leads

**Next:** Prediction workflows → [Chapter 9](09-prediction-vs-inference.md). Discovery on marker panels → [Chapters 10–12](10-dimensionality-reduction.md). Omics → [Chapter 13](13-differential-analysis-fdr.md).

""",
    "09": """## Where this chapter leads

**Next:** Unsupervised structure → [Chapters 10–11](10-dimensionality-reduction.md). End-to-end CASTOR stories → [Chapter 12](12-case-studies.md). High-dimensional omics prediction → [Chapter 17](17-integrated-castor-hd.md).

""",
    "10": """## Where this chapter leads

**Next:** [Chapter 11](11-clustering.md) for patient groups; [Chapter 13](13-differential-analysis-fdr.md) when the goal is formal per-feature inference with FDR.

""",
    "11": """## Where this chapter leads

**Next:** [Chapter 12](12-case-studies.md) integrates discovery narratives. Formal omics DE → [Chapter 13](13-differential-analysis-fdr.md).

""",
    "12": """## Where this chapter leads

**Next:** CASTOR-HD omics pipeline → [Chapters 13–17](13-differential-analysis-fdr.md). Longitudinal and survival extensions → [Chapters 18–19](18-longitudinal-mixed-models.md).

""",
    "13": """## Where this chapter leads

**Next:** [Chapter 14](14-batch-effects.md) before trusting any hit list. Integrated pipeline → [Chapter 17](17-integrated-castor-hd.md).

""",
    "14": """## Where this chapter leads

**Next:** [Chapter 15](15-flow-cytometry.md) for immune summaries; [Chapter 16](16-antibody-discovery.md) for screens. Return to [Chapter 13](13-differential-analysis-fdr.md) sensitivity after batch QC.

""",
    "15": """## Where this chapter leads

**Next:** [Chapter 16](16-antibody-discovery.md) for confirmation assays; [Chapter 17](17-integrated-castor-hd.md) for the full CASTOR-HD story.

""",
    "16": """## Where this chapter leads

**Next:** [Chapter 17](17-integrated-castor-hd.md) stitches omics, flow, and antibody steps into one report.

""",
    "17": """## Where this chapter leads

**Next:** [Chapters 18–21](18-longitudinal-mixed-models.md) for repeated measures, survival, missing data, and causal framing on CASTOR extensions.

""",
    "18": """## Where this chapter leads

**Next:** [Chapter 19](19-survival-analysis.md) for time-to-exacerbation; [Chapter 20](20-missing-data.md) when dropout is informative.

""",
    "19": """## Where this chapter leads

**Next:** [Chapter 20](20-missing-data.md) for spirometry missingness; [Chapter 21](21-causal-inference.md) for observational effect language.

""",
    "20": """## Where this chapter leads

**Next:** [Chapter 21](21-causal-inference.md) for confounding and IPW. Revisit [Chapter 18](18-longitudinal-mixed-models.md) if missing visits drove the sensitivity analysis.

""",
    "21": """## Where this chapter leads

You have completed the single-volume path (Ch 0–21). Return to [Chapter 12](12-case-studies.md) when writing integrated discussions, or to [QUICK_REFERENCE](../QUICK_REFERENCE.md) for day-to-day method choice.

""",
}

PART_VIGNETTES = {
    "part-02-describe-compare.md": """

## CASTOR vignette: the week-12 readout

Dr Chen’s COPD extension trial is due a week-12 snapshot for the steering committee. The CRA exports a spreadsheet: FEV1, arm, smoking, three patients with missing post-BD spirometry, one site using different visit windows. **Part II** is where the team decides whether to describe first (Ch 3) and which comparison estimand the protocol actually specifies (Ch 4) — before anyone runs a t-test in Excel.

""",
    "part-05-discovery.md": """

## CASTOR vignette: the marker panel meeting

A postdoc presents PCA and k-means on CASTOR’s 30-marker panel. Clusters separate beautifully — but colour by `processing_batch` shows the same separation. **Part V** is how you turn a pretty slide into a defensible discovery story: reduce dimensions honestly (Ch 10), cluster with stability checks (Ch 11), and write what Case C in Ch 12 does *not* prove.

""",
    "part-06-highdim-biology.md": """

## CASTOR vignette: the omics email

At the start of the week: “We have 1,000 proteins and 200 DE hits.” After batch QC, the FDR-controlled list may be empty — and that is the honest result to report. **Part VI** walks proteomics, RNA, flow, and antibody screens with the same question: what are we willing to fund for validation?

""",
    "part-08-longitudinal-survival.md": """

## CASTOR vignette: the extension analysis plan

The same trial now has four visits per patient and a separate cohort with time to first exacerbation. A fellow proposes a week-52 t-test and a logistic “any exacerbation” model. **Part VIII** keeps trajectories (Ch 18), timing and censoring (Ch 19), missing visits (Ch 20), and causal language (Ch 21) aligned with what the protocol can support.

""",
}


def insert_why(content: str, why: str) -> str:
    if "## Why this chapter" in content:
        return content
    return re.sub(r"\n(## Opening question[^\n]*\n)", "\n" + why + r"\1", content, count=1)


def insert_in_practice(content: str, block: str) -> str:
    if "### In practice" in content:
        return content
    return re.sub(
        r"\n(#{3,4} Wrong analysis)",
        "\n" + block + r"\1",
        content,
        count=1,
    )


def insert_before_r(content: str) -> str:
    if "### Before you open R" in content:
        return content
    return re.sub(
        r"\n(#{2,3} R lab[^\n]*\n)",
        "\n" + BEFORE_R + r"\1",
        content,
        count=1,
    )


def insert_bridge(content: str, bridge: str) -> str:
    if "## Where this chapter leads" in content:
        return content
    for heading in ("## Further reading", "## Exercises", "## Chapter summary"):
        if heading in content:
            return content.replace("\n" + heading, "\n" + bridge + heading, 1)
    return content + "\n" + bridge


def process_chapter(path: Path) -> bool:
    content = path.read_text(encoding="utf-8")
    original = content
    key = path.name
    num = key.split("-")[0]
    if key in WHY:
        content = insert_why(content, WHY[key])
    if num in IN_PRACTICE:
        content = insert_in_practice(content, IN_PRACTICE[num])
    if "## R lab" in content:
        content = insert_before_r(content)
    if num in BRIDGE:
        content = insert_bridge(content, BRIDGE[num])
    if content != original:
        path.write_text(content, encoding="utf-8")
        return True
    return False


def process_part(path: Path) -> bool:
    content = path.read_text(encoding="utf-8")
    if path.name in PART_VIGNETTES and "CASTOR vignette" not in content:
        content = content.rstrip() + PART_VIGNETTES[path.name] + "\n"
        path.write_text(content, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = []
    for path in sorted(CHAPTERS.glob("*.md")):
        if path.name.startswith("00-"):
            continue
        if process_chapter(path):
            changed.append(path.name)
    for path in sorted(PARTS.glob("*.md")):
        if process_part(path):
            changed.append(f"parts/{path.name}")
    print("Updated:", ", ".join(changed) if changed else "(none)")


if __name__ == "__main__":
    main()
