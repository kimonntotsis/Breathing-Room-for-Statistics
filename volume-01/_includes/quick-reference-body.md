## Step 0. Write the estimand

```{=latex}
\footnotesize
```

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
| **Ordinal** | mMRC 0–4, CAT **items/bands** | Ordinal logistic ([Ch 6](chapters/06-generalized-linear-models.md#technique-ordinal-logistic-regression-mmrccat)); not `lm` on 0–4 items. **CAT/ACQ totals** often continuous when prespecified |

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

## Step 1a. Unadjusted vs adjusted; linking outcomes

| Question | Rule of thumb | Chapter |
|----------|---------------|---------|
| **Crude arm difference?** | Welch *t*, Fisher, etc.: label **unadjusted**; report CI + *n* (+ events) | [4](chapters/04-comparing-groups.md) |
| **Adjust for baseline / confounders?** | Linear, logistic, Poisson GLM: list **prespecified** covariates | [4](chapters/04-comparing-groups.md), [5](chapters/05-linear-models.md), [6](chapters/06-generalized-linear-models.md) |
| **RCT primary** | Freeze unadjusted ITT **or** ANCOVA **or** change score in SAP, not all three | [4](chapters/04-comparing-groups.md#unadjusted-adjusted-and-multiple-endpoints), [5](chapters/05-linear-models.md) |
| **Observational main analysis** | Adjusted model; unadjusted = sensitivity for confounding | [21](chapters/21-causal-inference.md) |
| **Mechanism through mediator** | Mediation: total vs direct vs indirect (prespecified) | [22](chapters/22-mediation-analysis.md) |
| **FEV1 + FVC + symptoms + exacerbations** | **One primary**; secondaries in a **family** (Holm / gatekeeping) | [4](chapters/04-comparing-groups.md#multiplicity), [8](chapters/08-validation-reporting.md) |
| **Omics + clinical endpoint** | **Separate families**: FDR for features; clinical hierarchy unchanged | [8](chapters/08-validation-reporting.md), [13](chapters/13-differential-analysis-fdr.md) |

**Never:** call an unadjusted OR “adjusted”; never put four primary *p*-values on one slide.

---

## Step 0b. Sample size (before recruitment)

You do not need to derive power formulas. You **do** need to align sample size with the **prespecified estimand** and MCID (or risk difference for binary endpoints).

| Endpoint type | Inputs to discuss with your statistician | CASTOR pointer |
|---------------|------------------------------------------|----------------|
| **Continuous FEV1** | Expected mean difference (e.g. MCID), SD, α, power (80%), design | [Ch 4 power section](chapters/04-comparing-groups.md#technique-power-analysis-for-continuous-outcomes) |
| **Binary / composite** | Baseline event rate, minimally important risk difference, α, power | Protocol + clinician judgment; not post hoc |
| **Time-to-event** | Event rate, hazard ratio, follow-up length, censoring | [Ch 19](chapters/19-survival-analysis.md) |
| **Omics discovery** | Usually **not** powered like a trial endpoint | Prespecify FDR and validation budget ([Ch 13](chapters/13-differential-analysis-fdr.md)) |

**Practice read:** “We enrolled 120 because feasible” is not a power argument. If the trial is negative, the CI relative to MCID matters more than p > 0.05 ([Ch 8](chapters/08-validation-reporting.md)).

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
| Adjust for baseline FEV1 in trial | **ANCOVA** (linear model) | Change score (if prespecified in SAP) |

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
| Predict risk (Ch 9) | Logistic + validation | `glm(..., family = binomial)` + hold-out metrics | Binomial / logit; AUC, calibration |

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
| Count | Poisson/NB GLM | Rare; use paired design with care | Poisson/NB GLM | Poisson/NB GLM |

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
| Unadjusted OR called “adjusted” | Label crude; prespecify covariate model | 4, 5, 6 |
| Four lung endpoints, four primaries | One primary; Holm / gatekeeping on secondaries | 4, 8 |

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

![Analysis pipeline: question to report](figures/analysis_pipeline.png){width=92%}

## Visual decision tree

![Method decision tree: start from outcome type](figures/method_decision_tree.png){width=88%}

Regenerate from the project root: `source("R/examples/generate_figures.R")` after [Appendix A](appendix-a-r-setup.md) setup.

---

## Scope: not covered in this volume

Use this table when a question falls outside the handbook's core path. Ask a statistician or specialist text rather than forcing CASTOR scripts.

| Topic | Status in this book | Where to go next |
|-------|---------------------|------------------|
| Trial estimands / intercurrent events | Introduced only | ICH E9(R1); specialist trial statistician |
| Non-inferiority, equivalence, cluster RCT | Not covered | Trial design texts; [Appendix O](appendix-o-ch04-comparison-extensions.md) (Welch/NI pointers only) |
| Recurrent events, competing risks | Survival basics only | Ch 19 limits; specialist extensions |
| Diagnostic accuracy (ROC for tests) | Prediction framing in Ch 9 | Diagnostic medicine methods |
| Bland–Altman / agreement | Not covered | Measurement error literature |
| Meta-analysis / evidence synthesis | Not covered | Cochrane Handbook; specialist reviews |
| Sample-size formulas | Power sketch in Ch 1 | `pwr` package; trial statistician |
| Multi-state / joint longitudinal–survival | Not covered | Specialist biostatistics texts |
| Imaging statistics | Not covered | Domain-specific methods |
| Bayesian workflows | Not covered | [archive/docs/BOOK_OUTLINE.md](../archive/docs/BOOK_OUTLINE.md) |
| External validation / model updating | Principles in Ch 9 | TRIPOD+AI; transportability literature |
| Storey *q*-values | BH default; distinction in Ch 13 | `qvalue` Bioconductor if prespecified |
