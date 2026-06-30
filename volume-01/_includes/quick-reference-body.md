## Step 0. Write the estimand

*What number would change your decision?* Example: mean FEV1 difference at 12 weeks (intervention − control).

If you cannot write this sentence, stop. See [Chapter 1](chapters/01-statistical-thinking.md).

---

## Step 1. Outcome type to primary method

**Compare groups (unadjusted)**

| Outcome | Examples | Primary test |
|---------|----------|--------------|
| **Continuous** | FEV1, FVC, 6MWD, scores | Welch *t*, paired *t*, ANOVA |
| **Binary** | Exacerbation Y/N, death Y/N | Chi-square, Fisher, McNemar (paired) |
| **Count** | Exacerbations per year | **Not** *t*-test; use count model |
| **Repeated continuous** | FEV1 at multiple visits |, (see mixed models) |
| **Time-to-event** | Time to first exacerbation |, (see survival) |
| **Many features** | Biomarker panel |, (see PCA / clustering) |
| **Ordinal** | mMRC 0–4, CAT | Ordinal logistic ([Ch 6](chapters/06-generalized-linear-models.md#technique-ordinal-logistic-regression-mmrccat)); not `lm` on 0–4 |

**Adjust for covariates**

| Outcome | Model | Chapter |
|---------|-------|---------|
| Continuous | Linear regression, ANCOVA | Ch [4](chapters/04-comparing-groups.md), [5](chapters/05-linear-models.md) |
| Binary | Logistic regression | Ch [4](chapters/04-comparing-groups.md), [6](chapters/06-generalized-linear-models.md) |
| Count | Poisson → NB; offset if needed | Ch [6](chapters/06-generalized-linear-models.md) |
| Repeated continuous | Mixed models / GEE | Ch [18](chapters/18-longitudinal-mixed-models.md) |
| Time-to-event | Kaplan-Meier, Cox | Ch [19](chapters/19-survival-analysis.md) |
| Many features | PCA, clustering (exploratory) | Ch [10](chapters/10-dimensionality-reduction.md), [11](chapters/11-clustering.md) |

---

## Step 1b. High-dimensional biology

| If your data look like... | Typical goal | First methods | Core warnings |
|---|---|---|---|
| 1000+ proteins (Olink/MS) | differential abundance | per-feature models + FDR; batch covariate | LOD missingness, batch/plate |
| gene counts (RNA-seq) | differential expression | NB models; library size; FDR | counts ≠ continuous |
| flow cytometry | compare populations | participant-level proportions | gating/embedding are descriptive |
| antibody screens | pick hits | threshold + confirmation; stability tiers | ranking noise |

See Chapters [13](chapters/13-differential-analysis-fdr.md)–[17](chapters/17-integrated-castor-hd.md).

---

## Step 2. Continuous outcome: *t*-test or Wilcoxon?

| Situation | Primary | Alternative / sensitivity |
|-----------|---------|---------------------------|
| 2 independent groups | **Welch *t*-test** | Mann–Whitney if very skew + small *n* |
| 2 paired measurements (pre/post BD) | **Paired *t*-test** | Wilcoxon signed-rank |
| 3+ independent groups | **One-way ANOVA** + prespecified contrasts | Kruskal–Wallis |
| Adjust for baseline FEV1 in trial | **ANCOVA** (linear model) |, |

**Remember:** Wilcoxon tests **ranks**, not means. Report mean difference (CI) **and** median difference if they disagree.

**Never:** *t*-test on binary Y/N or count data.

---

## Step 3. Binary or categorical outcome

| Situation | Method | Effect measure |
|-----------|--------|----------------|
| 2×2 table, independent | Chi-square; **Fisher** if sparse | Risk difference, RR, OR + CI |
| Same patient, before/after | **McNemar** | Paired proportions |
| Need adjustment | **Logistic regression** | Adjusted OR + CI |
| Outcome common (>10%); want RR | **Log-binomial** or modified Poisson | RR + CI |
| Sparse events / separation | **Firth** penalized logistic | OR + CI |

---

## Step 4. Count outcome (exacerbations)

| Situation | Model | Notes |
|-----------|-------|-------|
| Equal follow-up | Poisson GLM | Check overdispersion |
| Varying follow-up | Poisson + **offset(log person-time)** | Required |
| Overdispersion | **Negative binomial** | Default sensitivity |
| Excess zeros | Zero-inflated Poisson/NB | Ch 6 |

**Never:** *t*-test or linear regression on raw counts.

---

## Step 5. Regression family (Gaussian vs GLM)

| Outcome | Model | R call | Distribution / link |
|---------|-------|--------|---------------------|
| Continuous FEV1 | **Linear (Gaussian)** | `lm(y ~ x, data)` | Normal / identity |
| Binary | **Logistic** | `glm(y ~ x, family = binomial)` | Binomial / logit |
| Count | **Poisson / NB** | `glm(..., family = poisson)` or `MASS::glm.nb` | Poisson or NB / log |
| Predict risk (Ch 9) | Logistic + validation | + AUC, calibration |, |

---

## Step 6. Goal: inference vs prediction vs discovery

| Goal | Methods | Chapter |
|------|---------|---------|
| **Describe** sample | Table 1, plots | [3](chapters/03-descriptive-analysis.md) |
| **Compare** groups | *t*, ANOVA, chi-square | [4](chapters/04-comparing-groups.md) |
| **Adjust** associations | Linear, logistic, Poisson | [5](chapters/05-linear-models.md), [6](chapters/06-generalized-linear-models.md) |
| **Select predictors** | Prespecification, LASSO | [7](chapters/07-model-building.md) |
| **Validate / report** | CI, bootstrap, TRIPOD | [8](chapters/08-validation-reporting.md) |
| **Predict** new patients | ML, calibration, AUC | [9](chapters/09-prediction-vs-inference.md) |
| **Discover** subgroups | PCA, clustering (exploratory) | [10](chapters/10-dimensionality-reduction.md), [11](chapters/11-clustering.md) |

---

## Master table (design × outcome)

| Outcome | 2 groups, independent | 2 groups, paired | 3+ groups | Adjust covariates |
|---------|----------------------|------------------|-----------|-------------------|
| Continuous | Welch *t* | Paired *t* | ANOVA | Linear / ANCOVA |
| Binary | Fisher / chi-square | McNemar | Chi-square | Logistic |
| Count | Poisson/NB GLM |, | Poisson/NB GLM | Poisson/NB GLM |

---

## Common mistakes (redirect)

| Wrong | Right | Chapter |
|-------|-------|---------|
| *t*-test on exacerbation Y/N | Logistic / proportions | 4, 6 |
| *t*-test on exacerbation counts | Poisson / NB | 6 |
| `lm()` on 0/1 outcome | `glm(..., binomial)` | 6 |
| OR reported as RR when events common | Log-binomial | 6 |
| Poisson without offset (varying follow-up) | `offset(log(person_years))` | 6 |
| Week-52 *t*-test on last visit only | Mixed model | 18 |
| “Endotype” from one k-means run | Endotype claim ladder | 11 |
| p-value only, no CI | Always report CI | 8 |

---

## Reporting checklists

| Study type | Guideline |
|------------|-----------|
| RCT | CONSORT [@schulz2010consort] |
| Observational cohort | STROBE [@vonelm2007strobe] |
| Prediction model | TRIPOD [@moons2015tripod] |

Details: [Chapter 8](chapters/08-validation-reporting.md) and [References](references.qmd).

---

## Visual workflow

**Process first** (eight steps), then **method choice** (outcome type):

![CASTOR analysis pipeline: question to report](figures/analysis_pipeline.png){width=92%}

## Visual decision tree

![Method decision tree: start from outcome type](figures/method_decision_tree.png){width=88%}

Regenerate from the project root: `source("R/examples/generate_figures.R")` after [Appendix A](appendix-a-r-setup.md) setup.
