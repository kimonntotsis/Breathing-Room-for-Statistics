# Chapter 14: Batch effects, plate effects, and unwanted variation

> **Part VI: High-dimensional biology and discovery**

## At a glance

| | |
|---|---|
| **Recurring datasets** | `data/proteomics_olink_like.csv`, `data/rnaseq_counts.csv`, `data/flowcytometry_summary.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Core idea** | diagnose technical structure first, then decide how (or whether) to adjust |
| **Primary tools** | QC plots, PCA by batch, batch as covariate, sensitivity analysis |
| **R** | `R/examples/ch14_batch_effects.R` |
| **Figures** | [FIGURE_INDEX](../FIGURE_INDEX.md) - `ch14_*.png` |
| **Exercises** | [Chapter 14 exercises](../exercises/ch14_exercises.md) |

**Also see:** [Ch 13 DE](13-differential-analysis-fdr.md), [Ch 17 pipeline](17-integrated-castor-hd.md)
## Learning objectives

1. Recognise when "discoveries" are likely technical.
2. Use **PCA/QC plots** to detect batch/plate/run effects.
3. Distinguish **adjustable batch** from **confounded batch** (not identifiable).
4. Apply three defensible strategies: covariate adjustment, adjustment inside resampling (prediction), or redesign.
5. Avoid overcorrection when batch removal would erase real site differences.
6. Report discovery counts with and without batch adjustment.

## Prerequisites

Ch 10 (PCA intuition), Ch 13 (differential analysis logic), Ch 8 (reporting).

---

## Why this chapter

Batch effects are the default in proteomics, RNA, and flow, not the exception. This chapter asks the uncomfortable question first: did we rediscover the lab calendar? Read it before interpreting any hit list from Chapter 13.

## Opening question

*Are my "signals" biological - or did I just rediscover the lab calendar?*

Batch effects are not a niche issue; they are the default in real omics and cytometry:

- site differences (sample handling)
- run day / instrument drift
- plate effects
- processing batches

If batch aligns with group (e.g., all cases measured later), adjustment cannot create truth from confounding. At that point the honest conclusion is: **the study is not identifiable without stronger design.**

---

## The batch QC workflow

1. **Record** batch, plate, run day, site, operator (whatever exists).
2. **Tabulate** `group × batch` (and plate if relevant).
3. **Plot** PCA or similar QC embedding coloured by batch **and** group.
4. **Quantify** variance explained by batch on leading PCs (if helpful).
5. **Sensitivity**: fit DE with and without batch; compare discovery counts.
6. **Stop rule**: if batch == group, report non-identifiability; do not force ComBat.

---

## Worked mini-case: when adjustment is valid vs not identifiable

The chapter script compares two designs side by side.

### Case A (CASTOR-HD proteomics): batch overlaps both groups

In `proteomics_olink_like.csv`, cases and controls appear in **both** batches. Batch is measurable technical variation, not a perfect proxy for disease status.

| Design feature | CASTOR-HD proteomics (teaching) |
|---|---|
| Group × batch overlap | Both groups in Batch1 and Batch2 |
| PCA pattern | Batch shifts scores, but groups are not separated by batch alone |
| Covariate adjustment | **Defensible** as sensitivity: `y ~ group + batch + plate + covariates` |
| Interpretation | Group effects are **conditional on measured technical variables**; still need replication |

**Practice read:** we can attempt to separate biology from lab process because both patient types were measured under multiple conditions.

**Teaching numbers** (`ch14_batch_mini_case_summary.csv`): with batch overlap, **3** proteomics discoveries at FDR *q* < 0.05 **with** batch adjustment and **3 without** in this synthetic run. Stability across adjustment is reassuring; a large flip (e.g. 50 → 0) would signal an unstable conclusion.

### Case B (synthetic confounding): batch == group

Imagine a study where **all controls** were run on Batch1 and **all cases** on Batch2.

| Design feature | Confounded mini-case |
|---|---|
| Group × batch overlap | **None** (perfect confounding) |
| PCA pattern | Batch and group occupy the same direction in PC space |
| Covariate adjustment | **Not identifiable**: `group` and `batch` are redundant |
| Interpretation | You cannot claim a group effect "after adjusting for batch" |

**Practice read:** if disease status and lab day are inseparable, the analysis cannot tell you whether the signal is biology or processing.

### Decision rule (use before any "ComBat" or covariate adjustment)

1. **Tabulate** `group × batch` (and plate/run if available).
2. If any cell has **zero** samples for a group-batch combination you need, treat confounding as likely.
3. **Plot** PCA (or another QC embedding) colored by batch **and** group.
4. Fit a **sensitivity model** with and without batch; if the main conclusion flips, report instability.
5. If batch and group are perfectly confounded, stop claiming adjusted group effects; redesign or collect new data.

---

## Technique: Diagnose batch with PCA + simple QC

### Technique card

| | |
|---|---|
| **Answers** | Is technical structure large enough to distort inference? |
| **Outcome type** | many features (proteins/genes/cytometry markers) |
| **Design** | any, but batch variables must be recorded |
| **Data required** | feature matrix + batch labels (plate/run/day/site) |
| **Assumptions** | PCA is descriptive; large PCs tracking batch suggests trouble |
| **Effect measure** | none (diagnostic) |
| **R** | `prcomp(X, scale.=TRUE)` + plot colored by batch |
| **When to use** | always before DE/ML on high-dimensional data |
| **When NOT to use** | never "skip" this step |
| **Does NOT prove** | that correction fixes the problem |

### Dual interpretation

**Plain language:** we checked whether samples cluster by lab process rather than disease.

**Precise language:** we examined whether leading principal components correlate with batch variables; if so, batch explains a meaningful portion of variance.

**Practice read:** if batch drives the main variation, a "biomarker panel" is probably not real.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| PCA is descriptive | it does not tell you what to adjust, only what to worry about |
| Confounding | if batch == group, adjustment is guesswork |
| Overcorrection | removing batch can remove real biology if biology differs by site |
| Leakage | correction must be inside resampling when doing prediction |
| Missingness | LOD missingness can mimic batch clustering (proteomics) |
| Reporting | you must say what batch variables existed and what you did |

### In practice

ComBat on the full dataset before train/test split has sunk prediction papers. Any correction: covariate or ComBat: must respect the same leakage rules as Chapter 9.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | "ComBat everything" without checking confounding or sensitivity |
| **Why it fails** | correction can manufacture group differences or erase biology |
| **Do instead** | show PCA by batch and group, run sensitivity, and state limits |

### Catalog of wrong analyses (batch effects)

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **Skip batch QC** because "the analyst will fix it" | Technical structure becomes "biology" in DE/ML outputs | Always tabulate group × batch and plot PCA by batch |
| **Adjust for batch when batch == group** | Model is not identifiable; coefficients are arbitrary | Report confounding; redesign (balance batches) or external validation |
| **Report only the batch-adjusted model** | Hides instability and post hoc storytelling | Show with vs without batch; report overlap of top features |
| **Use ComBat on the full matrix before splitting data** (prediction) | Leakage: test set informs correction | Fit correction inside training folds only |
| **Treat plate as "random noise"** | Plates are structured batch effects with known labels | Include plate/run as covariate or blocking factor when measured |
| **Interpret PCA separation as proof** | Embeddings are descriptive; separation can be driven by one outlier feature | Check feature loadings; validate with targeted QC metrics |
| **Remove "batch genes" then test group** | Feature selection using batch information contaminates group tests | Prespecify feature sets or use models that include batch explicitly |
| **Claim transportability across sites** after single-site ComBat | Correction does not create external validity | Validate on held-out site/batch or new cohort |
| **Ignore missingness patterns by batch** (proteomics) | LOD missingness can track batch and mimic disease signal | Plot missingness by group and batch (see Ch 13 figure) |
| **Single sentence: "batch corrected"** in Methods | Not auditable; reviewers cannot assess identifiability | State variables, model structure, and sensitivity outcome |

### Reporting template

> Batch and plate variables were recorded. We tabulated group × batch overlap and examined PCA colored by batch and group. Per-feature models included batch/plate as covariates where identifiable. Sensitivity analyses with and without batch adjustment [changed/did not change] the number of discoveries at FDR q < 0.05. [If confounded: group effects were not identifiable after adjusting for batch.]

---

## Technique: Adjust batch by including it as a covariate

This is the most defensible "first-line" strategy for **inference** when batch is not perfectly confounded with group.

### Technique card

| | |
|---|---|
| **Answers** | Group effect after accounting for measured technical variables |
| **R (concept)** | `lm(feature ~ group + batch + plate + covariates)` |
| **When to use** | DE/DA when batch is measured and partially overlaps both groups |
| **When NOT to use** | batch fully confounded with group; batch unmeasured |
| **Does NOT prove** | transportability; that unmeasured artefacts are absent |

### Dual interpretation

**Plain language:** we estimated the group difference while allowing for known lab differences.

**Precise language:** group effect is conditional on batch/plate indicators in a per-feature linear model; interpretability requires overlap in the group × batch table.

**Practice read:** this is a reasonable attempt to separate signal from process - but only if both groups were measured across batches.

!PCA colored by batch (proteomics subset) (`ch14_pca_proteomics_batch.png`)

Separation along PC1 by colour (batch) means batch-aware models or redesign, not a raw hit list: come first.

!Valid overlap vs confounded group × batch design (`ch14_group_batch_overlap.png`)

Only the left-hand pattern supports identifiable group effects after batch adjustment; the right-hand pattern is a stop/go gate.

---

## Alternatives & extensions (when covariates are not enough)

| Situation | Primary approach | Notes |
|---|---|---|
| Strong unknown technical variation | RUV / surrogate variable analysis (conceptual) | requires negative controls or careful assumptions |
| Prediction goal | correction inside CV folds | prevents leakage (Ch 9 mindset) |
| Multi-site biology is real | do not "remove site" | site may be effect modifier, not nuisance |
| Batch confounded | blocked redesign / prospective balancing | statistical fix cannot replace design |
| Flow cytometry drift | include run day + control beads in model | see Ch 15 |

### Mini-lab: ComBat is not automatic

ComBat and similar tools can help when batch is measured and **not fully confounded** with group. Always run the overlap + PCA checks in this chapter first. If `table(group, batch)` has empty cells, report non-identifiability instead of forcing correction.

---


## R lab: Batch effects on CASTOR-HD

**Script:** `R/examples/ch14_batch_effects.R`

The script produces:

- PCA diagnostics (`ch14_pca_proteomics_batch.png`, `ch14_pca_proteomics_plate.png`)
- Sensitivity bar chart (`ch14_batch_sensitivity_discoveries.png`)
- **Mini-case figures:**
  - `ch14_group_batch_overlap.png` (valid overlap vs confounding)
  - `ch14_pc1_variance_explained.png` (how much PC1 tracks batch vs group)
- Summary table: `volume-01/tables/ch14_batch_mini_case_summary.csv`

```r
source("R/00_setup.R")
library(tidyverse)

prot <- readr::read_csv(
  file.path(paths$data, "proteomics_olink_like.csv"),
  show_col_types = FALSE
)
table(prot$group, prot$batch)
```

### Sensitivity rule (non-negotiable)

If the *existence* of your main result depends on whether batch is included, say so explicitly and treat the result as **unstable** until replication / better design.

### Niche figures (recommended)

- **Group × batch overlap plot:** the fastest confounding check.
- **PC1 variance explained by batch vs group:** quantifies whether technical structure dominates the leading axis.

!Discoveries with vs without batch adjustment (`ch14_batch_sensitivity_discoveries.png`)

A large drop in hit count after batch adjustment means many “discoveries” were technical. Report both numbers.

!PC1 variance explained by batch vs group (`ch14_pc1_variance_explained.png`)

When batch explains more variance than group on PC1, prioritise batch QC over interpreting loadings.

## Exercises ([Solutions](../solutions/ch14_solutions.md))

**E14.1** When is including batch as a covariate defensible?

**E14.2** What does perfect confounding of batch and group imply for identifiability?

**E14.3** Why is ComBat before train/test split a leakage problem?

**E14.3** Why is ComBat before train/test split a leakage problem?

**E14.4** What should you report if discoveries go from 50 to 0 when batch is added?

**Applied**

1. Run `source("R/examples/ch14_batch_effects.R")`.
2. Interpret `ch14_group_batch_overlap.png` for Cases A and B.
3. Read `volume-01/tables/ch14_batch_mini_case_summary.csv`.
4. Draft a Methods sentence on batch handling for a proteomics paper.
5. Write a one-sentence **stop** message for a perfectly confounded design.

---

## Where this chapter leads

**Next:** [Chapter 15](15-flow-cytometry.md) for immune summaries; [Chapter 16](16-antibody-discovery.md) for screens. Return to [Chapter 13](13-differential-analysis-fdr.md) sensitivity after batch QC.

## Further reading

- Leek et al. on batch effects; [Ch 13](13-differential-analysis-fdr.md) for DE context

## Chapter summary

- Batch effects are expected; **diagnosis comes before correction**.
- Covariate adjustment is valid when **group and batch overlap**.
- Perfect confounding makes group effects **not identifiable** after adjusting for batch.
- Always report **sensitivity** (with vs without batch) and avoid "batch corrected" as a black box.
