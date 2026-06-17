# Chapter 17: Integrated CASTOR-HD discovery pipeline

> **Part VII: Integrated CASTOR-HD capstone**

## At a glance

| | |
|---|---|
| **Recurring datasets** | CASTOR-HD: proteomics, RNA-seq, flow, antibody screen/confirmation |
| **Format** | End-to-end narrative + supervised \(p \gg n\) extension |
| **Pipeline** | DE → batch QC → shortlist → flow summary → screen confirmation → reporting |
| **R** | `R/examples/ch17_integrated_castor_hd.R`, `R/examples/ch17_elastic_net_proteomics.R` |
| **Templates** | [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md) |

## Learning objectives

1. Execute a coherent discovery workflow across omics, flow, and antibody data.
2. State what each step proves vs suggests at each stage.
3. Fit elastic net with nested cross-validation for \(p \gg n\) proteomics prediction.
4. Draft an integrated Methods/Results section using the reporting templates.

## Prerequisites

Chapters 13–16 and Case D in [Ch 12](12-case-studies.md).

---

## Opening question (CASTOR-HD)

*If we start with a proteomics differential analysis, how do batch checks, immune phenotyping, and antibody confirmation change what we are willing to claim?*

This chapter is the **advanced capstone**: same CASTOR-HD cohort, one narrative thread, explicit stopping rules when batch or stability fail.

---

## Master workflow (CASTOR-HD discovery)

| Step | Action | Chapter | Output |
|------|--------|---------|--------|
| 1 | Per-feature DE + BH FDR | 13 | Top table, volcano |
| 2 | Batch/plate PCA + sensitivity | 14 | Overlap check, discovery count with/without batch |
| 3 | Shortlist top features for follow-up | 13 | Ranked list (effect + q) |
| 4 | Flow: participant-level proportions | 15 | Adjusted effects by cell type |
| 5 | Antibody screen → confirmation + tiers | 16 | PPV, Tier 1 clones |
| 6 | Integrated report | Templates | Methods + Results draft |
| 7 | (Optional) Supervised elastic net | 17 R | Nested CV AUC |

```r
source("R/00_setup.R")
source("R/examples/ch17_integrated_castor_hd.R")
```

---

## Step 1–2: Proteomics DE with batch awareness

Run differential analysis (Ch 13), then immediately run batch diagnostics (Ch 14). **Do not** interpret top hits until overlap is acceptable.

![Proteomics volcano (BH FDR)](../figures/ch13_volcano_proteomics.png)

![PCA by batch — proteomics subset](../figures/ch14_pca_proteomics_batch.png)

**Stopping rule:** if group and batch are perfectly confounded, report non-identifiability and do not claim group-specific protein differences.

---

## Step 3: Shortlist for follow-up

Export the top 20–50 features by q-value **and** absolute effect. Prioritise features stable with vs without batch adjustment.

See `volume-01/tables/ch17_integrated_shortlist.csv` from the integrated script.

---

## Step 4: Flow cytometry summary

Link immune phenotyping to the discovery story at the **participant** level (Ch 15). Cell embeddings are QC only.

![Monocyte proportions by group](../figures/ch15_flow_props_by_group.png)

---

## Step 5: Antibody screen confirmation

Translate screen hits into confirmation PPV and stability tiers (Ch 16).

![Threshold sensitivity: hits and PPV](../figures/ch16_threshold_sensitivity.png)

---

## Step 6: Reporting (integrated)

Use [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md):

- **Template A** for omics DE (n, model, FDR, batch handling)
- **Template B** for batch sensitivity
- **Template C** for flow proportions
- **Template D** for antibody discovery

**Clinician read:** one paragraph per modality; separate “discovery” from “confirmed binding.”

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

### Wrong analysis ⚠

| Mistake | Do instead |
|---------|------------|
| Tune λ on the same data you evaluate | Nested CV (outer fold = performance, inner = λ) |
| Impute/batch-correct before splitting | All preprocessing inside training folds |
| Report training AUC as validation | Report outer-fold mean AUC ± SD |

### R lab

```r
source("R/examples/ch17_elastic_net_proteomics.R")
```

![Nested CV AUC — elastic net on proteomics](../figures/ch17_elastic_net_nested_cv.png)

---

## Cross-modality synthesis

| Modality | Inference level | Key metric |
|----------|-----------------|------------|
| Proteomics DE | Discovery (FDR) | Effect + q; batch sensitivity |
| RNA-seq DE | Discovery (NB + FDR) | Same; library offset stated |
| Flow | Associational | Participant n; batch-adjusted proportion |
| Antibody screen | Prioritisation | PPV + Tier 1 stability |
| Elastic net | Prediction (internal) | Nested CV AUC |

---

## Exercises · [Solutions](../solutions/ch17_solutions.md)

**E17.1** At which pipeline step would you stop if batch and group are confounded?

**E17.2** Why is nested CV required for elastic net on 1000 proteins?

**E17.3** What is the difference between a Tier 1 antibody clone and a proteomics q < 0.05 hit?

**Applied**

1. Run `source("R/examples/ch17_integrated_castor_hd.R")`.
2. Run `source("R/examples/ch17_elastic_net_proteomics.R")`.
3. Draft a 300-word integrated Results section using the templates.
4. List three claims you would **not** make from this pipeline alone.

---

## Further reading

- McShane et al., biomarker reporting [@mcshane2011biomarker]
- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Ch 12 Case D for the bridge from core CASTOR to CASTOR-HD
