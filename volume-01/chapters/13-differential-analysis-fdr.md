# Chapter 13: Differential analysis and false discovery rate (omics)

> **Part VI: High-dimensional biology and discovery**

## At a glance

| | |
|---|---|
| **Recurring datasets** | `data/proteomics_olink_like.csv`, `data/rnaseq_counts.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Primary goal** | Estimate per-feature effects **and** control false discoveries |
| **Core methods** | per-feature models, Benjamini–Hochberg FDR, volcano plot (descriptive), sensitivity checks |
| **R** | `R/examples/ch13_differential_fdr.R` |
| **Templates** | [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md) |

## Learning objectives

1. Understand why “\(p < 0.05\)” becomes meaningless when you test 1000+ features.
2. Report **effect sizes and uncertainty**, not a list of “significant proteins”.
3. Use FDR control (BH) and interpret what it means in plain language.
4. Recognise when differential results are likely batch/plate artefacts.

## Prerequisites

Chapter 8 (reporting and multiplicity) and Chapters 10–11 (high-dimensional intuition).

---

## Opening question (CASTOR-HD)

*Which proteins (or genes) differ between cases and controls - and how many “discoveries” should we expect to be false if we act on them?*

In omics, the two most common failure modes are:

1. **Overclaiming**: treating 50 nominal \(p < 0.05\) hits as biology.
2. **Underreporting uncertainty**: listing q-values without effect sizes.

---

## Technique: Per-feature differential analysis + BH FDR

### Technique card

| | |
|---|---|
| **Answers** | Which features differ between groups, by how much, with multiplicity control? |
| **Outcome type** | Many continuous features (proteins) or many count features (genes) |
| **Design** | Usually independent groups; may include covariates and batch variables |
| **Data required** | group label, optional covariates, optional batch/plate/run |
| **Assumptions** | Model is approximately correct per feature; independence not required for BH (but strong dependence can distort) |
| **Effect measure** | mean difference or log2 fold-change (plus CI) |
| **Multiplicity** | BH FDR (q-values) for the family of tests |
| **R** | `p.adjust(p, method="BH")` after per-feature p-values |
| **When to use** | discovery with controlled false positives; prioritisation for follow-up |
| **When NOT to use** | mechanistic proof; “endotype” claims without replication |
| **Does NOT prove** | causation; diagnostic utility; pathway truth; transportability |

### Dual interpretation

**Plain language:** we tested many markers and adjusted the results so that only a small fraction of the “discoveries” are expected to be false.

**Precise language:** for each feature \(j\) we fit a model to estimate \(\beta_j\) for group; we then applied Benjamini–Hochberg to control the expected false discovery proportion among features called significant.

**Clinician read:** FDR protects you from a “shopping list of biomarkers” that will not replicate. It does not tell you which marker is clinically useful.

### Caveats box

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| Batch and plate effects | “Significant proteins” often track run day/site rather than disease |
| Missingness near LOD (proteomics) | cases can have fewer detectable proteins; naive imputation can create signal |
| Normalization choices | log transform, scaling, library-size normalization change rankings |
| Small \(n\), huge \(p\) | effect estimates are noisy; ranks are unstable without shrinkage |
| Confounding | smoking/age/therapy correlate with both disease and omics; adjust or stratify |
| Interpretation inflation | top q-values are not “most important” without effect size and uncertainty |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Run 1000 t-tests and report every \(p < 0.05\) as biology |
| **Why it fails** | expected false positives ≈ 50 even if **no** true differences |
| **Do instead** | control FDR (BH), report effect sizes + uncertainty, plan validation |

| | |
|---|---|
| **Mistake** | Volcano plot + “top hits” without mentioning preprocessing and batch |
| **Why it fails** | rankings are highly sensitive to normalization and technical drift |
| **Do instead** | show QC (PCA by batch), include batch as covariate, run sensitivity |

### Catalog of wrong analyses (omics discovery)

Use this as a pre-submission audit. If any row describes your workflow, rewrite.

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **List of hits without effect sizes** (“Protein X significant, q = …”) | You cannot judge clinical or biological importance | Report effect + 95% CI + q-value; rank by effect + stability, not only q |
| **Nominal p-value hunting** (top 20 p-values) | Multiple testing turns this into a false-positive generator | Use BH FDR; show how many tests were run |
| **“Volcano proof”** (figure implies causality) | Volcano plots are descriptive; they do not validate biology | Present as prioritisation; specify validation/confirmation plan |
| **Batch ignored** | Many top hits are technical; FDR cannot fix confounding | Diagnose (Ch 14), include batch/plate/run covariates, run sensitivity |
| **Batch “corrected” without checking confounding** | Overcorrection can erase biology or manufacture differences | Show PCA by batch and group; if confounded, state identifiability limits |
| **LOD missingness imputed as a constant** (e.g., replace NA with 0) | Creates artificial group differences if detection differs by group/batch | Prefer sensitivity: complete-case vs simple within-feature imputation; report missingness by group |
| **CPM-style normalization treated as neutral** (RNA) | If some genes truly change, others can look changed due to compositional constraints | Interpret “global shifts” cautiously; prefer methods designed for counts and composition; validate with spike-ins / external data |
| **Imputation done before train/test split** (prediction) | Information leakage inflates performance | Perform all preprocessing within resampling (see Ch 9 mindset) |
| **Genes/proteins treated as independent evidence** | Correlation means “50 hits” may be 1 pathway signal | Summarise at pathway/module level as a secondary interpretation; keep per-feature results for transparency |
| **“No hits, therefore no biology”** | Low power can hide large effects; FDR can be conservative | Report effect size distributions and uncertainty; discuss detectable effect sizes |
| **Single-cohort “signature” claim** | Signatures are unstable without external validation | Treat as hypothesis; validate on external cohort or held-out batch |

### Reporting template

Use Template A in [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md).

![Volcano plots: proteomics and RNA differential analysis (BH FDR)](../figures/ch13_volcano_panel.png)

---

## Alternatives & extensions (choose by goal)

| Situation | Primary approach | Why |
|---|---|---|
| Very small \(n\), want stable ranking | shrinkage / empirical Bayes (conceptually) | stabilises noisy effects |
| Strong batch structure | handle batch explicitly (Ch 14) | prevents technical discoveries |
| Many missing values (LOD) | sensitivity: complete-case vs simple imputation | avoids imputation-created signal |
| Goal is prediction, not discovery | nested CV + calibration (Ch 9, [Ch 17](17-integrated-castor-hd.md)) | prevents leakage and overfit |

### Mini-lab: sparse PCA pointer (exploratory)

When \(p \gg n\), dense PCA loadings are noisy. For exploratory views only, try sparse PCA (`elasticnet` / `PMA` packages) with a prespecified sparsity penalty — never treat as confirmatory DE.

```r
# Teaching pointer (not run in ch13 script):
# library(PMA)
# sparse.pca(scale(prot_matrix), K = 2, para = c(0.5, 0.5))
```

### Mini-lab: LOD missingness check (proteomics)

```r
# After source("R/examples/ch13_differential_fdr.R") — or inline:
prot <- readr::read_csv(file.path(paths$data, "proteomics_olink_like.csv"), show_col_types = FALSE)
prot %>% mutate(miss = rowMeans(is.na(dplyr::select(., starts_with("Prot_"))))) %>%
  ggplot(aes(group, miss, fill = group)) + geom_boxplot() + theme_minimal()
```

![Proteomics missingness by group (LOD-style)](../figures/ch13_proteomics_missingness_by_group.png)

---

## R lab: Differential analysis on CASTOR-HD

**Script:** `R/examples/ch13_differential_fdr.R`

### 1) Proteomics (Olink-like): per-protein model + BH FDR + top-table

Your minimum output should be a table with:

- **feature** (protein)
- **effect** (control - case or log2FC)
- **95% CI**
- **p-value** and **q-value**
- **n used** (after missingness)

The script writes a copy-ready top-table to `volume-01/tables/`.

```r
source("R/00_setup.R")
library(tidyverse)

prot <- readr::read_csv(file.path(paths$data, "proteomics_olink_like.csv"), show_col_types = FALSE)
prot %>% count(group)
```

### 2) RNA-seq counts: negative binomial differential expression

For RNA counts, use a **count model** (negative binomial), not a Gaussian model on raw or log-transformed counts. The teaching workflow fits one NB model per gene with an **offset for library size**:

```r
library(MASS)
rna <- readr::read_csv(file.path(paths$data, "rnaseq_counts.csv"), show_col_types = FALSE)
# Per gene: glm.nb(count ~ group + batch + offset(log(library_size)))
# Then BH FDR across genes — see R/examples/ch13_differential_fdr.R
```

**Teaching note:** CASTOR-HD synthetic RNA includes a global expression shift, so many genes can pass FDR in this demo. In real studies, interpret discovery counts alongside MA plots and batch QC.

![RNA MA plot (NB log-fold-change teaching output)](../figures/ch13_rnaseq_ma_plot.png)

![Proteomics q-value distribution (BH)](../figures/ch13_proteomics_qvalue_hist.png)

### Sensitivity checklist (minimum)

- Run the differential analysis twice:
  - **with** batch/run as covariate
  - **without** batch/run
- Compare overlap of top 50 features and discuss stability.

### Niche figures to include (recommended)

- **Missingness by group** (proteomics): if cases have more missing, LOD is part of the story.
- **MA plot** (RNA): average abundance vs effect to spot mean–variance artefacts.
- **q-value distribution**: a flat distribution suggests “mostly null”; a spike near 0 suggests signal.

These are generated by the chapter script and saved to `volume-01/figures/`:

- `ch13_proteomics_missingness_by_group.png`
- `ch13_proteomics_qvalue_hist.png`
- `ch13_rnaseq_ma_plot.png`

## Exercises · [Solutions](../solutions/ch13_solutions.md)

**E13.1** Why is testing 1000 proteins at α = 0.05 a problem even if only 50 are "significant"?

**E13.2** What three columns must appear in a defensible DE/DA top table?

**E13.3** When would you distrust a volcano plot as "proof" of biology?

**Applied**

1. Run `source("R/examples/ch13_differential_fdr.R")`.
2. Open `volume-01/tables/ch13_proteomics_top_table.csv` and interpret the top 5 rows (effect + CI + q).
3. Compare discovery counts with vs without batch adjustment (Ch 14 link).
4. Write a Results paragraph using [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md) Template A.

