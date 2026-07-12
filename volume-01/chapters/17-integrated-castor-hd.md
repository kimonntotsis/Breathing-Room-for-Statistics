# Chapter 17: Integrated CASTOR-HD discovery pipeline

> **Part VII: Integrated CASTOR-HD capstone**

## At a glance

| | |
|---|---|
| **Recurring datasets** | CASTOR-HD: proteomics, RNA-seq, flow, antibody screen/confirmation |
| **Format** | End-to-end narrative + supervised \(p \gg n\) extension |
| **Pipeline** | DE → batch QC → shortlist → flow summary → screen confirmation → reporting |
| **R** | `R/examples/ch17_integrated_castor_hd.R`, `R/examples/ch17_elastic_net_proteomics.R` |
| **Figures** | volcano (`ch13_volcano_proteomics.png`), batch PCA (`ch14_pca_proteomics_batch.png`), flow props (`ch15_flow_props_by_group.png`), screen threshold (`ch16_threshold_sensitivity.png`), nested CV AUC (`ch17_elastic_net_nested_cv.png`) |
| **Templates** | [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md) |
| **Exercises** | [Chapter 17 exercises](../exercises/ch17_exercises.md) |

---

## Investigator path (≈20 min)

1. [Why this chapter](#why-this-chapter) — pipeline stop/go gates
2. [Method choice at a glance](#method-choice-at-a-glance) — step order and what each proves
3. [The discovery claim ladder](#the-discovery-claim-ladder) — what each step may claim
4. [Step 6: Reporting (integrated)](#step-6-reporting-integrated) — one paragraph per modality
5. [Pipeline failure modes](#pipeline-failure-modes-what-to-report-honestly) — stop/go gates

**Analyst read:** elastic net nested CV, R scripts below.

---

## Method choice at a glance

| Step / method | When to use | Why |
|---------------|-------------|-----|
| **DE + FDR (proteomics/RNA)** | First biology screen | Per-feature effects with multiplicity control ([Ch 13](13-differential-analysis-fdr.md)) |
| **Batch QC before DE** | Any multi-site omics | Prevents funding false hits ([Ch 14](14-batch-effects.md)) |
| **Flow participant summaries** | Immune phenotyping arm | Inference at person level ([Ch 15](15-flow-cytometry.md)) |
| **Antibody screen tiers** | Hybridoma / phage triage | PPV and confirmation ([Ch 16](16-antibody-discovery.md)) |
| **Elastic net + nested CV** | p ≫ n prediction on proteins | Tuning without leakage ([Ch 9](09-prediction-vs-inference.md)) |
| **Stop if batch = group** | Confounded design | No amount of stats replaces redesign |
| **Separate discovery vs confirmation prose** | Manuscript writing | Different claim strength per modality |

---

## Learning objectives

1. Execute a coherent discovery workflow across omics, flow, and antibody data.
2. State what each step proves vs suggests at each stage.
3. Apply stopping rules when batch, overlap, or stability fail.
4. Fit elastic net with nested cross-validation for \(p \gg n\) proteomics prediction.
5. Draft an integrated Methods/Results section using the reporting templates.
6. List claims that are **not** justified by an internal discovery pipeline alone.

## Prerequisites

Chapters 13–16 and Case D in [Ch 12](12-case-studies.md).

---

## Why this chapter

Real discovery is a pipeline, not a single heatmap. This chapter strings proteomics, batch QC, flow, antibody confirmation, and optional prediction into one honest narrative, including where to **stop** when batch and group are confounded.

## Opening question (CASTOR-HD)

*If we start with a proteomics differential analysis, how do batch checks, immune phenotyping, and antibody confirmation change what we are willing to claim?*

This chapter is the **advanced capstone**: same CASTOR-HD cohort, one narrative thread, explicit stopping rules when batch or stability fail.

Discovery is staged. A q < 0.05 protein is **not** the same as a Tier 1 confirmed antibody clone with stable ranking across replicates.

---

## The discovery claim ladder

| Rung | Evidence | Language allowed |
|------|----------|----------------|
| 1 | DE hit (FDR) | "Candidate feature" |
| 2 | Batch-robust DE | "Candidate after technical sensitivity" |
| 3 | Flow association at participant level | "Immune phenotype association" |
| 4 | Screen + confirmation PPV | "Confirmed binding in replicate assay" |
| 5 | External cohort + clinical outcome | "Validated biomarker" (still not causal) |

Do not skip rungs in a title or abstract.

---

## Master workflow (CASTOR-HD discovery)

**Pipeline steps**

| Step | Action | Chapter | Output |
|------|--------|---------|--------|
| 1 | Per-feature DE + BH FDR | 13 | Top table, volcano |
| 2 | Batch/plate PCA + sensitivity | 14 | Overlap check, discovery count |
| 3 | Shortlist top features | 13 | Ranked list (effect + q) |
| 4 | Flow: participant-level proportions | 15 | Adjusted effects by cell type |
| 5 | Antibody screen → confirmation + tiers | 16 | PPV, Tier 1 clones |
| 6 | Integrated report | Templates | Methods + Results draft |
| 7 | (Optional) Supervised elastic net | 17 R | Nested CV AUC |

**Stopping rules**

| Step | Stop if… |
|------|----------|
| 1 | Model misspecified |
| 2 | Group ⊗ batch confounded |
| 3 | Batch sensitivity reverses rank |
| 4 | Pseudo-replication (cells) |
| 5 | Threshold tuned post hoc |
| 7 | Outer-fold AUC only (no claim beyond internal validation) |

```r
source("R/00_setup.R")
source("R/examples/ch17_integrated_castor_hd.R")
```

---

## Step 1–2: Proteomics DE with batch awareness

Run differential analysis (Ch 13), then immediately run batch diagnostics (Ch 14). **Do not** interpret top hits until overlap is acceptable.

### Technique card (Step 1–2 gate)

| | |
|---|---|
| **Answers** | Are group differences identifiable after accounting for batch structure? |
| **Checks** | PCA coloured by batch; group × batch contingency |
| **Stopping rule** | If group and batch are perfectly confounded, report non-identifiability |
| **Does NOT prove** | Clinical utility or causation |

!Proteomics volcano (BH FDR) (`ch13_volcano_proteomics.png`)

Volcano plots are **descriptive**; inference lives in the per-feature models and FDR.

!PCA by batch, proteomics subset (`ch14_pca_proteomics_batch.png`)

If colour tracks batch more than group, technical structure dominates.

**Stopping rule:** if group and batch are perfectly confounded, report non-identifiability and do not claim group-specific protein differences.

---

## Step 3: Shortlist for follow-up

Export the top 20–50 features by q-value **and** absolute effect. Prioritise features stable with vs without batch adjustment.

See `volume-01/tables/ch17_integrated_shortlist.csv` from the integrated script.

**Plain language:** narrow thousands of proteins to a short list for cheaper assays.

**Precise language:** prespecified ranking by adjusted effect size and BH q-value, with sensitivity to batch covariate inclusion.

---

## Step 4: Flow cytometry summary

Link immune phenotyping to the discovery story at the **participant** level (Ch 15). Cell embeddings are QC only.

### Technique card (flow at participant level)

| | |
|---|---|
| **Unit** | One row per participant (proportions), not per cell |
| **Wrong unit** | Pooled cells across patients |
| **Figure role** | Proportions by group; compositional awareness |

!Monocyte proportions by group (`ch15_flow_props_by_group.png`)

---

## Step 5: Antibody screen confirmation

Translate screen hits into confirmation PPV and stability tiers (Ch 16).

### Technique card (screen → confirm)

| | |
|---|---|
| **Screen** | High-throughput ranking; many false positives expected |
| **Confirmation** | Replicate binding; PPV among hits |
| **Tiers** | Ranking stability across replicates |
| **Does NOT prove** | In vivo neutralisation or treatment effect |

!Threshold sensitivity: hits and PPV (`ch16_threshold_sensitivity.png`)

Prespecify thresholds. Post-hoc threshold tuning inflates apparent PPV.

---

## Step 6: Reporting (integrated)

Use [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md):

- **Template A** for omics DE (*n*, model, FDR, batch handling)
- **Template B** for batch sensitivity
- **Template C** for flow proportions
- **Template D** for antibody discovery

**Practice read:** one paragraph per modality; separate “discovery” from “confirmed binding.”

### Example integrated Results paragraph (skeleton)

> In CASTOR-HD (*n* = … cases, … controls), we tested … proteins on … plates. After linear models with batch adjustment, … proteins had BH q < 0.05 (Figure). Batch PCA showed …; sensitivity without batch yielded … discoveries. Participant-level flow cytometry found … cell proportion associated with case status (adjusted …). Antibody screening at prespecified threshold … identified … hits; confirmation PPV was … among Tier 1 stable clones. These findings are **hypothesis-generating** and require external replication.

---

## Technique: Elastic net + nested CV (\(p \gg n\) prediction)

### Technique card

| | |
|---|---|
| **Answers** | Can proteomics predict case/control with honest internal performance? |
| **Outcome** | Binary group label |
| **Predictors** | Many proteins (\(p \gg n\)) |
| **Method** | `glmnet` elastic net inside nested CV |
| **When to use** | Exploratory risk stratification; hypothesis for external validation |
| **When NOT to use** | Causal inference; diagnostic approval without external cohort |
| **Does NOT prove** | Mechanism; transportability; clinical utility |

### Dual interpretation

**Plain language:** can a small panel of proteins classify case vs control better than chance in cross-validation?

**Precise language:** nested CV provides an internally honest estimate of discrimination (AUC) when tuning λ; optimism remains for external transport.

### In practice

Integrated omics slides often show only the volcano. Decision-makers need the stop/go gates: batch overlap, discovery count with/without adjustment, PPV, Tier 1 clones, in that order.

### Wrong analysis ⚠

| Mistake | Do instead |
|---------|------------|
| Tune λ on the same data you evaluate | Nested CV (outer fold = performance, inner = λ) |
| Impute/batch-correct before splitting | All preprocessing inside training folds |
| Report training AUC as validation | Report outer-fold mean AUC ± SD |
| Claim clinical utility from AUC alone | Calibration, decision curve, external cohort |


### R lab

```r
source("R/examples/ch17_elastic_net_proteomics.R")
```

!Nested CV AUC, elastic net on proteomics (`ch17_elastic_net_nested_cv.png`)

Outer-fold AUC with variability across folds is the honest performance summary; training AUC is not shown here on purpose.

---

## Cross-modality synthesis

| Modality | Inference level | Key metric | Typical failure mode |
|----------|-----------------|------------|----------------------|
| Proteomics DE | Discovery (FDR) | Effect + q; batch sensitivity | Batch confounding |
| RNA-seq DE | Discovery (NB + FDR) | Same; library offset stated | Global shift (teaching data) |
| Flow | Associational | Participant *n*; batch-adjusted proportion | Cell-level pseudo-replication |
| Antibody screen | Prioritisation | PPV + Tier 1 stability | Post-hoc threshold |
| Elastic net | Prediction (internal) | Nested CV AUC | Leakage across folds |

---

## Pipeline failure modes (what to report honestly)

| Failure | Honest sentence |
|---------|-----------------|
| 0 BH hits after batch adjustment | "No proteins met FDR < 0.05 after batch adjustment." |
| Perfect group–batch confounding | "Group effect not identifiable; analysis stopped at Step 2." |
| Unstable antibody ranking | "No Tier 1 clones; hits exploratory only." |
| Nested CV AUC ≈ 0.5 | "No internal predictive signal; not a classifier." |

---

## Exercises ([Solutions](../solutions/ch17_solutions.md))

**E17.1** At which pipeline step would you stop if batch and group are confounded?

**E17.2** Why is nested CV required for elastic net on 1000 proteins?

**E17.3** What is the difference between a Tier 1 antibody clone and a proteomics q < 0.05 hit?

**E17.4** Why must flow analyses use participant-level proportions?

**E17.5** Name one claim that would be **too strong** after this pipeline alone.

**Applied**

1. Run `source("R/examples/ch17_integrated_castor_hd.R")`.
2. Run `source("R/examples/ch17_elastic_net_proteomics.R")`.
3. Draft a 300-word integrated Results section using the templates.
4. List three claims you would **not** make from this pipeline alone.
5. For each pipeline step, write one sentence for Methods and one for Results.

---

## Where this chapter leads

**Next:** [Chapters 18–21](18-longitudinal-mixed-models.md) for repeated measures, survival, missing data, and causal framing on CASTOR extensions.

## Further reading

- McShane et al., biomarker reporting [@mcshane2011biomarker]
- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Ch 12 Case D for the bridge from core CASTOR to CASTOR-HD
