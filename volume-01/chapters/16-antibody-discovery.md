# Chapter 16: Antibody discovery screens - hit calling, confirmation, and stability

> **Part VI: High-dimensional biology and discovery**

## At a glance

| | |
|---|---|
| **Recurring datasets** | `data/antibody_screen.csv`, `data/antibody_confirmation.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Core idea** | treat screening as triage; confirmation is where claims begin |
| **Primary tools** | replicate agreement, prespecified thresholds, PPV, stability tiers |
| **R** | `R/examples/ch16_antibody_screening.R` |
| **Figures** | [FIGURE_INDEX](../FIGURE_INDEX.md) - `ch16_*.png` |
| **Templates** | [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md) |
| **Exercises** | [Chapter 16 exercises](../exercises/ch16_exercises.md) |

**Also see:** [Ch 13 FDR](13-differential-analysis-fdr.md), [Ch 17 pipeline](17-integrated-castor-hd.md)
## Learning objectives

1. Combine replicates and quantify replicate agreement before hit calling.
2. Define hits using **prespecified thresholds** (or control-based rules), not post hoc cutoffs.
3. Evaluate screen performance with **confirmation PPV**, not screen p-values alone.
4. Assign **stability tiers** when ranks change under replicate resampling.
5. Report shortlists as tiers, not fragile 1..K rankings.
6. Distinguish screen triage from confirmation endpoints.

## Prerequisites

Ch 8 (reporting), Ch 13 (multiplicity mindset), Ch 14 (batch), Ch 11 (do not overclaim discovery).

---

## Why this chapter

Screens are triage, not truth. This chapter is for teams deciding which clones to pay to validate: using PPV, prespecified thresholds, and stability tiers instead of rank #7 versus #9 storytelling.

## Opening question

*Which clones should we spend money validating - and how confident are we that the top of the list stays the top when noise is resampled?*

Discovery screens are not hypothesis tests. They are **prioritisation pipelines**. The "result" is not a p-value; it is a defensible shortlist and a confirmation plan.

---

## The screen-to-confirmation workflow

1. **Replicate QC**: agreement between technical replicates; batch plots.
2. **Prespecified hit rule**: threshold or control-based cutoff (not post hoc).
3. **Shortlist**: hits per antigen; report hit count.
4. **Confirmation assay**: orthogonal readout with prespecified positivity (e.g. KD).
5. **PPV**: confirmed hits / screen hits; **per antigen**.
6. **Stability tiers**: top-*K* overlap across replicates; advance Tier 1 first.

---

## Worked mini-case: threshold, PPV, and stability tiers

The chapter script walks through three linked decisions on CASTOR-HD.

### Step 1: Replicate agreement (QC gate)

Before calling hits, check that replicates agree. Poor agreement means ranks are noise.

| QC signal | Interpretation |
|---|---|
| Strong rep1 vs rep2 correlation | Ranking is reasonably stable |
| Batch-separated clouds | Drift may inflate false hits (Ch 14) |
| Wide scatter at low signal | threshold choice matters a lot |

### Step 2: Hit calling with a prespecified threshold

**Teaching rule in the script:** call a hit when mean screen signal > **1.4** (prespecified for illustration).

| Quantity | What it means |
|---|---|
| **Hits** | clones above threshold (screen positives) |
| **Confirmed in hits** | hits with `confirm_positive == TRUE` in confirmation assay |
| **PPV** | confirmed in hits / hits |

PPV answers: *of the clones we would advance, what fraction actually confirm?*

This is more actionable than a screen p-value.

**Teaching numbers** (`ch16_screen_ppv_by_antigen.csv`, threshold = 1.4):

| Antigen | Hits | Confirmed in hits | PPV |
|---------|------|-------------------|-----|
| AgA | 85 | 44 | 0.52 |
| AgB | 69 | 37 | 0.54 |
| AgC | 61 | 34 | 0.56 |

PPV ≈ 50% means **half** of screen hits fail confirmation: normal for screens. Budget confirmation for Tier 1 clones first.

### Step 3: Ranking stability tiers (when ranks are noisy)

Recompute top-20 lists using replicate 1, 2, and 3 separately. Assign each clone to a **stability tier**:

| Tier | Rule (AgA example) | How to report |
|---|---|---|
| **Tier 1** | Top 20 in **all 3** replicates | Highest-priority confirmation |
| **Tier 2** | Top 20 in **2 of 3** replicates | Secondary shortlist |
| **Tier 3** | Top 20 in **1 of 3** replicates | Exploratory only |
| **Below tier** | Never top 20 in any replicate | Do not emphasise in main text |

**Practice read:** tiers are like "high / medium / low confidence shortlist" - more honest than pretending rank #7 is meaningfully better than rank #9.

### Decision rule (screen to confirmation)

1. Check **replicate agreement** and batch QC.
2. Apply a **prespecified** hit rule (threshold or control-based).
3. Report **PPV** among hits (and confirmation rate by antigen).
4. Compute **stability tiers**; prefer Tier 1 for claims.
5. Confirm Tier 1/2 candidates; report KD/functional readout with prespecified positivity rule.

---

## Technique: Hit calling + confirmation as the estimand

### Technique card

| | |
|---|---|
| **Answers** | Which candidates exceed a prespecified screen criterion, and how many confirm? |
| **Outcome type** | continuous screen signal; binary confirmed positive (after follow-up assay) |
| **Design** | replicates + batches; often multiple antigens |
| **Data required** | replicates, controls, batch IDs, confirmation readout |
| **Effect measure** | PPV of screen; tiered shortlist; confirmation rate |
| **R** | replicate summaries + thresholding; confusion table vs confirmation |
| **When to use** | any screening/triage workflow (antibodies, CRISPR, drug screens) |
| **When NOT to use** | claiming "best antibody" from screen alone |
| **Does NOT prove** | clinical utility; in vivo efficacy; specificity without orthogonal tests |

### Dual interpretation

**Plain language:** we used the screen to shortlist candidates, then checked which of those actually worked in a stronger assay.

**Precise language:** the screen defines a ranking/threshold; confirmation defines the target endpoint. Screen utility is summarised by PPV and stability of the shortlist under replicate noise.

**Practice read:** a screen is like a triage test: useful if it reliably enriches true positives, but it is not the final diagnosis.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Replicate noise | ranks can change with small measurement noise |
| Batch effects | plates/days shift signals; false positives cluster by batch |
| Threshold fishing | changing the cutoff after seeing results inflates claims |
| Multiple antigens | multiplicity across targets; avoid cherry-picked antigen |
| Confirmation bias | only confirming "pretty" candidates hides failure rates |
| Definition drift | "confirmed positive" must be prespecified (KD cutoff etc.) |

### In practice

Changing the hit threshold after seeing the plate layout is post hoc tuning. Prespecify the rule (or control-based z-score) and show sensitivity across a grid of cutoffs.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Report the top 10 clones as "best" without confirmation |
| **Why it fails** | screens have false positives; ranks are noisy |
| **Do instead** | report tiers + confirmation rate and PPV |

| | |
|---|---|
| **Mistake** | Pick a threshold that maximises "story" after seeing the data |
| **Why it fails** | post hoc thresholding is hidden multiple testing |
| **Do instead** | prespecify threshold or use controls; report sensitivity analysis |

### Catalog of wrong analyses (antibody / discovery screens)

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **Screen p-value as final result** | Screen is triage, not confirmatory endpoint | Report PPV and confirmation outcomes |
| **Post hoc threshold** chosen to maximise hits | Inflates false discovery and PPV looks better than it is | Prespecify threshold; show sensitivity curve |
| **Rank #1..#10 reported as precise ordering** | Ranks are unstable under replicate noise | Use stability tiers |
| **Confirm only "good-looking" clones** | PPV becomes meaningless (selection bias) | Confirm prespecified shortlist rule |
| **Ignore batch in screen QC** | Hits cluster by plate/day | Plot by batch; adjust or block in design |
| **Single replicate** | No assessment of ranking stability | Require replicates or repeat measurements |
| **Mix antigens in one threshold** | Different targets have different background | Threshold/PPV **per antigen** |
| **KD reported without positivity rule** | "Strong binder" becomes subjective | Prespecify KD cutoff for `confirm_positive` |
| **Cherry-pick one antigen for the paper** | Multiplicity and hype | Report all targets or prespecify primary antigen |
| **Claim therapeutic antibody from screen** | No specificity, affinity, or function in context | Confirmation + orthogonal assays + replication |

### Reporting template

Use Template D in [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md).

> Screening used [R] technical replicates per clone against [antigens]. Replicate agreement was assessed [correlation/plot]. Hits were defined prespecification as mean signal > [threshold] (or control-based rule). Confirmation used [assay] with positivity defined as KD < [X] nM. We report PPV among hits and stability tiers based on overlap of top-[K] lists across replicates.

---

## Technique: Threshold sensitivity (prespecified vs exploratory)

A single threshold is not enough for transparency. Report a **sensitivity curve**:

- x-axis: threshold
- y-axis: number of hits and PPV (where confirmation data exist)

If PPV collapses when you move the threshold slightly, your shortlist is fragile.

!Replicate agreement (AgA screen) (`ch16_screen_replicate_agreement.png`)

Low replicate correlation flags unstable hits before you spend confirmation budget.

!Threshold sensitivity: hits and PPV vs cutoff (`ch16_threshold_sensitivity.png`)

A cliff edge in PPV means the shortlist is threshold-dependent: show the curve, not one lucky cutoff.

---

## Technique: Stability tiers (ranking under replicate resampling)

### Technique card

| | |
|---|---|
| **Answers** | Which clones are consistently top-ranked under noise? |
| **Input** | replicate-level signals per clone |
| **Output** | Tier 1/2/3 shortlist |
| **When to use** | whenever confirmation budget is limited |
| **Does NOT prove** | clone is "best"; only that it is **stable** in the screen |

---

## Alternatives & extensions

| Situation | Approach | Notes |
|---|---|---|
| High background variability | control-normalised signal (e.g., z-score vs negative controls) | more defensible than arbitrary cutoff |
| Many weak binders | FDR across clones (Ch 13 mindset) | still requires confirmation |
| Functional screen endpoint | hit = response in primary assay; confirm in secondary | define two-stage estimands |
| Multi-batch screen | include batch in hit model or stratify | Ch 14 logic |

### Mini-lab: control-normalised screen signal

```r
screen <- readr::read_csv(
  file.path(paths$data, "antibody_screen.csv"),
  show_col_types = FALSE
)
# Teaching: z-score within antigen across clones (exploratory)
screen %>% group_by(antigen) %>%
  mutate(z = as.numeric(scale(signal_mean))) %>%
  filter(z > 1.5) %>% count(antigen)
```

---


## R lab: Antibody screening on CASTOR-HD

**Script:** `R/examples/ch16_antibody_screening.R`

Outputs:

- `ch16_screen_replicate_agreement.png`
- `ch16_screen_ppv.png` (PPV by antigen at prespecified threshold)
- `ch16_threshold_sensitivity.png` (hits and PPV vs threshold)
- `ch16_stability_tiers.png` (tier counts + PPV by tier for AgA)
- `ch16_ranking_stability.png` (top-20 overlap across replicate pairs)
- Tables in `volume-01/tables/`:
  - `ch16_screen_ppv_by_antigen.csv`
  - `ch16_threshold_sensitivity.csv`
  - `ch16_ranking_tiers_aga.csv`
  - `ch16_mini_case_summary.csv`

```r
source("R/00_setup.R")
library(tidyverse)

screen <- readr::read_csv(
  file.path(paths$data, "antibody_screen.csv"),
  show_col_types = FALSE
)
conf <- readr::read_csv(
  file.path(paths$data, "antibody_confirmation.csv"),
  show_col_types = FALSE
)
```

### Sensitivity (minimum)

- Vary threshold over a prespecified grid; show PPV and hit count.
- Report stability tiers and restrict main claims to Tier 1 (and optionally Tier 2).

!Stability tiers and PPV by tier (AgA) (`ch16_stability_tiers.png`)

Tier 1 clones are the only defensible primary shortlist; lower tiers belong in supplementary exploration.

!Top-20 overlap across replicate pairs (`ch16_ranking_stability.png`)

Low overlap between replicate top-20 lists means ranking noise, not biology.

## Exercises ([Solutions](../solutions/ch16_solutions.md))

**E16.1** What is PPV among screen hits, and why is it more useful than a screen p-value?

**E16.2** Define Tier 1 stability in this chapter's rule.

**E16.3** Why is post hoc threshold tuning dangerous?

**E16.3** Why is post hoc threshold tuning dangerous?

**E16.4** Why report PPV **per antigen**?

**Applied**

1. Run `source("R/examples/ch16_antibody_screening.R")`.
2. Report PPV by antigen from `ch16_screen_ppv_by_antigen.csv`.
3. Interpret `ch16_threshold_sensitivity.png` at the prespecified threshold.
4. List Tier 1 clones from `ch16_ranking_tiers_aga.csv` and their confirmation status.
5. Draft Methods + Results sentences using Template D.

---

## Where this chapter leads

**Next:** [Chapter 17](17-integrated-castor-hd.md) stitches omics, flow, and antibody steps into one report.

## Further reading

- Confirmation assay standards; [Ch 17](17-integrated-castor-hd.md) integrated pipeline

## Chapter summary

- Screens are for **triage**, not final proof.
- Prespecify **hit rules** and **confirmation positivity**.
- Report **PPV among hits**, not just rankings.
- Use **stability tiers** when replicate resampling changes the top list.
- Batch QC and replicate agreement are part of the estimand, not optional extras.
