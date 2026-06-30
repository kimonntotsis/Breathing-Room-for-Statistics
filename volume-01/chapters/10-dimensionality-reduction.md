# Chapter 10: Dimensionality Reduction (Toolkit)

> **Part VI: Structure Discovery**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](RECURRING_COHORT.md) - `data/marker_panel.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Methods** | PCA + alternatives menu (PLS, sparse/robust PCA, MCA/FAMD, logistic PCA), scree, loadings, biplots |
| **R** | `R/examples/ch10_pca.R` |
| **Figures** | [ch10_scree](../figures/ch10_scree.png), [ch10_pca_biplot](../figures/ch10_pca_biplot.png) |
| **Exercises** | [ch10](../exercises/ch10_exercises.md) |

**Also see:** [QUICK_REFERENCE](../QUICK_REFERENCE.md), Omics reporting: [@mcshane2011biomarker]
## Learning objectives

1. Use PCA for exploratory summarisation of many correlated markers.
2. Scale appropriately and choose number of components defensively.
3. Interpret loadings and scores without overclaiming biology.
4. Recognise exploratory limits and need for replication.
5. Report PCA methods transparently.

## Prerequisites

Chapters 3, 5.

---

## Why this chapter

Marker panels and omics produce too many correlated columns to inspect by eye. PCA and related tools help you **see** structure without pretending every axis is a new biomarker. Use this chapter for exploration; use Ch 13+ when the goal is formal differential analysis.

## Opening question (CASTOR marker panel)

*Thirty blood markers were measured in 120 CASTOR participants. Can we visualise patient similarity without thirty separate plots?*

PCA is **exploratory**. It does not test hypotheses by itself [@jolliffe2016pca].

---

## Start here: choose a dimension-reduction method

PCA is the default for **many continuous markers**, but respiratory datasets often violate PCA’s assumptions (mixed data types, p >> n, batch effects, binary markers).

Use this menu first, then read the relevant technique section.

| Your data / goal | Recommended method | Why | Notes |
|---|---|---|---|
| Many **continuous** correlated markers (p moderate) | **PCA** | Simple, transparent | This chapter §10.2 |
| p >> n (many markers, few patients) | **Sparse PCA** / regularized PCA | Stabilize loadings | “Advanced options” §10.9 |
| Strong outliers / artefacts | **Robust PCA** | Reduce outlier leverage | §10.9 |
| Mixed continuous + categorical variables | **FAMD** | Handles mixed types | §10.9 |
| Mostly categorical (binary/ordinal) | **MCA** | PCA analogue for categorical | §10.9 |
| Binary data but want “PCA-like” latent structure | **Logistic PCA** | Uses Bernoulli likelihood | §10.9 |
| Want supervised reduction to predict Y | **PLS / PLS-DA** | Uses outcome information | §10.10 (with warnings) |

**Wrong analysis ⚠:** pick the method that gives the “best-looking separation” on the same cohort, then name an endotype. Discovery needs stability and external validation (Ch 11) [@mcshane2011biomarker; @wenzel2012asthma].

---

## When PCA is appropriate

| Use | Avoid |
|-----|-------|
| Visualisation, noise reduction | Confirmatory "biomarker axis" without replication |
| Preprocessing before clustering (train only) | Replacing clinical diagnosis |
| Hypothesis generation | p-values on components without plan |

---

## Technique: Principal component analysis (PCA)

### Technique card

| | |
|---|---|
| **Answers** | What orthogonal directions capture most joint variation? |
| **Input** | n × p matrix of continuous features (markers) |
| **Output** | Scores (patients), loadings (variables), eigenvalues |
| **R** | `prcomp(X, scale. = TRUE)` |
| **When to use** | Many correlated continuous features |
| **When NOT to use** | Confirmatory endpoint; mixed binary/continuous without encoding |
| **Does NOT prove** | Biological mechanism; validated endotype |

### Dual interpretation

**Plain language:** PC1 is the weighted combination of markers that separates patients most.

**Precise language:** eigenvector of covariance/correlation matrix; scores are projections; components uncorrelated [@jolliffe2016pca].

**Clinician read:** a statistical summary axis - name it only after independent validation.

### Caveats box

| Caveat | Detail |
|--------|--------|
| Scaling | Unscaled PCA dominated by largest units |
| Outliers | Single patient can pull PC1 |
| p >> n | Unstable; regularized PCA needed |
| Batch effects | Can drive top PCs in omics [@mcshane2011biomarker] |
| Circular analysis | Fit PCA on full data then "predict" outcome on same data |

### In practice

PCA on 30 markers can be dominated by one batch variable. Colour points by batch before colouring by phenotype: the same rule as omics, at smaller scale.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | "PC1 is the asthma endotype axis" from one cohort |
| **Do instead** | Label exploratory; replicate externally |

| | |
|---|---|
| **Mistake** | PCA on training+test before split |
| **Do instead** | Fit PCA on training; apply rotation to test |

### Reporting template

**Methods:** Markers were standardised (z-scores). PCA used the correlation matrix. Scree plot and cumulative variance guided component retention (exploratory) [@jolliffe2016pca].

**Results:** PC1 explained 27% of variance. Loadings were highest on M1-M5 (Table S3). No confirmatory inference was drawn.


### R lab

```r
source("R/examples/ch10_pca.R")
omics <- read_csv("data/marker_panel.csv", show_col_types = FALSE)
X <- scale(omics %>% select(starts_with("M")))
pca <- prcomp(X)
summary(pca)
```

---

## Technique: Choosing number of components

### Technique card

| Method | Rule |
|--------|------|
| **Scree plot** | Elbow in eigenvalues |
| **Cumulative variance** | e.g. 80% (arbitrary) |
| **Kaiser** | Eigenvalue > 1 (correlation PCA) |
| **Domain** | Clinical interpretability - weak alone |

### Caveats

Many rules disagree; components are retained for **description**, not hypothesis tests.

### Wrong analysis ⚠

Keep components until outcome regression is significant → circular.

---

## Technique: Loadings and scores

| Object | Meaning |
|--------|---------|
| **Score** | Patient position on component k |
| **Loading** | Variable weight on component k |

High loading on M3 → M3 contributes strongly to that axis.

### Caveats

Loadings sign arbitrary; rotation changes interpretation (varimax).

---

## Technique: Varimax rotation

### Technique card

| | |
|---|---|
| **Purpose** | Simpler loading structure for interpretation |
| **Use** | Exploratory only |
| **R** | `psych::principal(..., rotate = "varimax")` or similar |

Still not validation of biology.

---

## Technique: Biplot

Joint plot of patients (scores) and variables (loadings). Useful for CASTOR `true_phenotype` visual check - teaching only; real studies lack truth labels. See [ch10_pca_biplot.png](../figures/ch10_pca_biplot.png).

---

## Technique: PC regression (preview)

Regress outcome on first k PCs instead of all markers.

**Caveat:** components lose direct marker interpretability; risk of overfitting if k chosen from same data.

---

## Advanced options (short technique cards)

These are common in modern respiratory biomarker papers. This handbook includes the *decision logic* and minimal R pointers; do not treat them as confirmatory proof.

### Technique: Sparse PCA

| | |
|---|---|
| **Answers** | PCA-like components with many loadings forced to zero |
| **When to use** | p >> n; interpretability focus |
| **Common R** | `elasticnet::spca`, `PMA::SPC` |
| **Caveat** | Tuning choices are flexible; report how chosen |
| **Does NOT prove** | Biological axis; validated marker subset |

### Technique: Robust PCA

| | |
|---|---|
| **Answers** | Reduce influence of outliers/artefacts on components |
| **When to use** | Outliers/batch artefacts likely; QC imperfect |
| **Common R** | `rrcov::PcaHubert`, robust covariance approaches |
| **Caveat** | Different robust methods yield different PCs |

### Technique: MCA (multiple correspondence analysis): “PCA for categorical data”

| | |
|---|---|
| **Data** | Categorical variables (including binary) |
| **When to use** | Many categorical features; survey/symptom patterns |
| **Common R** | `FactoMineR::MCA`, `factoextra` plotting |
| **Caveat** | Interpret with care; axes reflect category frequencies |

### Technique: FAMD: mixed continuous + categorical

| | |
|---|---|
| **Data** | Mixed feature types |
| **When to use** | Combine symptoms (categorical) + labs (continuous) |
| **Common R** | `FactoMineR::FAMD` |
| **Caveat** | Scaling/weighting decisions matter; document them |

### Technique: Logistic PCA (binary matrix)

| | |
|---|---|
| **Data** | Binary features (0/1) |
| **When to use** | Binary “marker present/absent” panels |
| **Common R** | `logisticPCA`-style packages / GLM-based latent factors |
| **Caveat** | More complex; convergence and identifiability issues |

### Technique: Kernel / nonlinear PCA (mention)

| | |
|---|---|
| **When to consider** | Strong nonlinear manifolds suspected |
| **Caveat** | Harder to interpret; higher overfitting risk |
| **Modern alternatives** | UMAP/t-SNE for visualization only (do not call axes “biology”) |

---

## Supervised dimension reduction: Partial Least Squares (PLS)

PLS is **not** an “upgrade of PCA.” It changes the question: components are chosen to explain *covariation with an outcome*.

### Technique card

| | |
|---|---|
| **Answers** | Which linear combinations of markers best predict/associate with Y? |
| **Use when** | Many correlated predictors; prediction/exploration goal |
| **Common variants** | PLS regression (continuous Y), PLS-DA (classification) |
| **Common R** | `pls::plsr`; `mixOmics` for supervised omics workflows |
| **Does NOT prove** | Causal mechanism; validated biomarker signature without external validation |

### Caveats box (PLS in respiratory biomarker papers)

| Caveat | Why it matters |
|---|---|
| Leakage | PLS must be fit inside training folds (like LASSO) |
| Overfitting | p >> n with few events → inflated performance |
| Interpretation | “VIP” importance is not causality |
| Reporting | Use TRIPOD if goal is prediction; otherwise label exploratory [@moons2015tripod] |

### Wrong analysis ⚠

Fit PLS on the full dataset, show perfect separation, and call it “validated endotypes” → external validation required (Ch 11) [@mcshane2011biomarker; @wenzel2012asthma].

---

## CASTOR worked example (PCA as baseline)

1. Scale 30 markers (`marker_panel.csv`).  
2. PCA → PC1 ≈ 27% variance.  
3. Plot PC1 vs PC2 coloured by `true_phenotype` (synthetic ground truth for teaching).  
4. **Conclusion:** separation visible in simulation; would require replication in real omics.

**Sensitivity:** correlation vs covariance PCA; compare scree.

---

## Catalog of wrong analyses

| Wrong | Right |
|-------|-------|
| PCA then test outcome without prespecification | Exploratory label |
| No scaling | `scale. = TRUE` when units differ |
| Name PCs "Th2 axis" immediately | Validate clinically |
| Use PCA scores as definitive subtypes | Clustering + external cohort |

---

## Chapter summary

- PCA summarises correlated markers for exploration [@jolliffe2016pca].
- Scale, scree, and loadings need careful reporting.
- Never skip external validation for clinical claims [@mcshane2011biomarker].

## Where this chapter leads

**Next:** [Chapter 11](11-clustering.md) for patient groups; [Chapter 13](13-differential-analysis-fdr.md) when the goal is formal per-feature inference with FDR.

## Further reading

- Jolliffe & Cadima, PCA review [@jolliffe2016pca]  
- McShane et al., REMARK biomarker reporting [@mcshane2011biomarker]  
- Wenzel, asthma phenotypes/endotypes context [@wenzel2012asthma]
 - ISL (penalization / CV mindset carries over to PLS/omics) [@james2023ISL]

## Exercises ([Solutions](../solutions/ch10_solutions.md))

**Next:** [Chapter 11](11-clustering.md)
