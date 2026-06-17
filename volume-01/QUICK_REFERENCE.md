# Quick reference — which method?

> **Use this page first.** Full detail: [METHOD_MAP.md](METHOD_MAP.md) · Decision figure: [figures/method_decision_tree.png](figures/method_decision_tree.png) · Handbook guide: [HANDBOOK_GUIDE.md](HANDBOOK_GUIDE.md)

---

## Step 0 — Write the estimand

*What number would change your decision?* Example: mean FEV1 difference at 12 weeks (intervention − control).

If you cannot write this sentence, stop. See [Ch 1](chapters/01-statistical-thinking.md).

---

## Step 1 — Outcome type → primary method

| Outcome | Examples | Compare groups (unadjusted) | Adjust for covariates | Chapter |
|---------|----------|----------------------------|------------------------|---------|
| **Continuous** | FEV1, FVC, 6MWD, scores | Welch *t*, paired *t*, ANOVA | Linear regression, ANCOVA | [4](chapters/04-comparing-groups.md), [5](chapters/05-linear-models.md) |
| **Binary** | Exacerbation Y/N, death Y/N | Chi-square, Fisher, McNemar (paired) | Logistic regression | [4](chapters/04-comparing-groups.md), [6](chapters/06-generalized-linear-models.md) |
| **Count** | Exacerbations per year | **Not** *t*-test | Poisson → NB; offset if follow-up varies | [6](chapters/06-generalized-linear-models.md) |
| **Many features** | Biomarker panel | — | PCA, clustering (exploratory) | [10](chapters/10-dimensionality-reduction.md), [11](chapters/11-clustering.md) |
| **Ordinal** | mMRC 0–4 | — | Ordinal logistic | Ch 6 (extensions) |
| **Time-to-event** | Time to first exacerbation | — | Kaplan–Meier, Cox | [Ch 19](chapters/19-survival-analysis.md) |

---

## Step 1b — High-dimensional biology (proteomics, RNA, flow, antibody)

These analyses appear later in the single-volume roadmap, but the decision logic starts here.

| If your data look like... | Typical goal | First methods to reach for | Core warnings |
|---|---|---|---|
| 1000+ proteins (Olink/MS), missingness | differential abundance | per-feature models + FDR; batch as covariate | LOD missingness, batch/plate artefacts |
| gene counts (RNA-seq) | differential expression | NB-style models; library size handling; FDR | counts ≠ continuous; normalize carefully |
| flow cytometry | compare populations | summary proportions/medians; careful drift checks | gating/embedding are descriptive |
| antibody screens | pick hits | threshold + confirmation; stability tiers | ranking noise, confirmation discipline |

Templates for writing these results: [HIGH_DIM_REPORTING_TEMPLATES.md](HIGH_DIM_REPORTING_TEMPLATES.md).

## Step 2 — Continuous outcome: *t*-test or Wilcoxon?

| Situation | Primary | Alternative / sensitivity |
|-----------|---------|---------------------------|
| 2 independent groups | **Welch *t*-test** | Mann–Whitney if very skew + small *n* |
| 2 paired measurements (pre/post BD) | **Paired *t*-test** | Wilcoxon signed-rank |
| 3+ independent groups | **One-way ANOVA** + prespecified contrasts | Kruskal–Wallis |
| Adjust for baseline FEV1 in trial | **ANCOVA** (linear model) | — |

**Remember:** Wilcoxon tests **ranks**, not means. Report mean difference (CI) **and** median difference if they disagree.

**Never:** *t*-test on binary Y/N or count data → see rows below.

Figure: [ch04_fev1_by_group.png](figures/ch04_fev1_by_group.png) · [ch04_paired_bronchodilator.png](figures/ch04_paired_bronchodilator.png)

---

## Step 3 — Binary / categorical outcome

| Situation | Method | Effect measure |
|-----------|--------|----------------|
| 2×2 table, independent | Chi-square; **Fisher** if sparse expected counts | Risk difference, RR, OR + CI |
| Same patient, before/after | **McNemar** | Paired proportions |
| Need adjustment (age, FEV1, …) | **Logistic regression** | Adjusted OR + CI |
| Outcome common (>10%); want RR | **Log-binomial** or modified Poisson | RR + CI |
| Sparse events / separation | **Firth** penalized logistic | OR + CI |

Figure: [ch06_logistic_forest.png](figures/ch06_logistic_forest.png)

---

## Step 4 — Count outcome (exacerbations)

| Situation | Model | Notes |
|-----------|-------|-------|
| Equal follow-up | Poisson GLM | Check overdispersion |
| Varying follow-up | Poisson + **offset(log person-time)** | Required |
| Overdispersion (variance > mean) | **Negative binomial** | Default sensitivity |
| Excess zeros | Zero-inflated Poisson/NB | Ch 6 |

**Never:** *t*-test or linear regression on raw counts.

---

## Step 5 — Regression family (Gaussian vs GLM)

| Outcome | Model | R call | Distribution / link |
|---------|-------|--------|---------------------|
| Continuous FEV1 | **Linear (Gaussian)** | `lm(y ~ x, data)` | Normal / identity |
| Binary | **Logistic** | `glm(y ~ x, family = binomial)` | Binomial / logit |
| Count | **Poisson / NB** | `glm(..., family = poisson)` or `MASS::glm.nb` | Poisson or NB / log |
| Predict risk (Ch 9) | Logistic + validation | + AUC, calibration | — |

This is the **exponential family / GLM** framework ([Ch 6 §6.1](chapters/06-generalized-linear-models.md)). “Exponential regression” usually means **survival** models ([Ch 19](chapters/19-survival-analysis.md)), not a separate core technique.

Figure: [ch05_residual_diagnostics.png](figures/ch05_residual_diagnostics.png)

---

## Step 6 — Goal: inference vs prediction vs discovery

| Goal | Methods | Chapter |
|------|---------|---------|
| **Describe** sample | Table 1, plots | [3](chapters/03-descriptive-analysis.md) |
| **Compare** groups | *t*, ANOVA, chi-square | [4](chapters/04-comparing-groups.md) |
| **Adjust** associations | Linear, logistic, Poisson | [5](chapters/05-linear-models.md), [6](chapters/06-generalized-linear-models.md) |
| **Select predictors** | Prespecification, LASSO, LRT | [7](chapters/07-model-building.md) |
| **Validate / report** | CI, bootstrap, TRIPOD | [8](chapters/08-validation-reporting.md) |
| **Predict** new patients | ML, calibration, AUC | [9](chapters/09-prediction-vs-inference.md) |
| **Discover** subgroups | PCA, clustering (exploratory) | [10](chapters/10-dimensionality-reduction.md), [11](chapters/11-clustering.md) |

---

## Master table (design × outcome)

| Outcome | 2 groups, independent | 2 groups, paired | 3+ groups | Adjust covariates |
|---------|----------------------|------------------|-----------|-------------------|
| Continuous | Welch *t* | Paired *t* | ANOVA | Linear / ANCOVA |
| Binary | Fisher / chi-square | McNemar | Chi-square | Logistic |
| Count | Poisson/NB GLM | — | Poisson/NB GLM | Poisson/NB GLM |

---

## Common mistakes (redirect)

| Wrong | Right | Chapter |
|-------|-------|---------|
| *t*-test on exacerbation Y/N | Logistic / proportions | 4, 6 |
| *t*-test on exacerbation counts | Poisson / NB | 6 |
| `lm()` on 0/1 outcome | `glm(..., binomial)` | 6 |
| OR reported as RR when events common | Log-binomial | 6 |
| Poisson without offset (varying follow-up) | `offset(log(person_years))` | 6 |
| “Endotype” from one k-means run | Endotype claim ladder | 11 |
| p-value only, no CI | Always report CI | 8 |

---

## Reporting checklists

| Study type | Guideline | Reference |
|------------|-----------|-----------|
| RCT | CONSORT | [@schulz2010consort] |
| Observational cohort | STROBE | [@vonelm2007strobe] |
| Prediction model | TRIPOD | [@moons2015tripod] |

See [REFERENCES.md](REFERENCES.md) and [Ch 8](chapters/08-validation-reporting.md).

---

## Visual decision tree

![Method decision tree](figures/method_decision_tree.png)

Regenerate: `source("R/examples/generate_figures.R")`
