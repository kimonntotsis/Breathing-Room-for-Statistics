# Chapter 20: Missing data and sensitivity analysis

> **Part VIII: Longitudinal, survival, and causal inference**

## At a glance

| | |
|---|---|
| **Recurring dataset** | `data/spirometry.csv` (MAR-like missingness induced in script) |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Question** | How does missing FEV1 affect regression coefficients — and what should we report? |
| **Core methods** | MCAR/MAR/MNAR framing, complete-case analysis, single imputation contrast, MICE overview |
| **R** | `R/examples/ch20_missing_data.R` |
| **Links** | [Ch 8 reporting](08-validation-reporting.md) · [Ch 18 dropout](18-longitudinal-mixed-models.md) |

## Learning objectives

1. Distinguish MCAR, MAR, and MNAR in plain language with respiratory examples.
2. Report *n* enrolled vs *n* analysed vs missingness by variable.
3. Run complete-case vs imputation sensitivity and interpret bias direction.
4. Know when multiple imputation (MICE) is the production default.

## Prerequisites

Chapters 3, 5, 8 (reporting); Ch 18 (informative dropout context).

---

## Opening question (CASTOR)

*Among CASTOR participants, FEV1 is missing more often in severe obstruction. If we drop those rows, does the smoking–FEV1 association change — and is that change a feature or a bug?*

Missing data is not a technical footnote. In spirometry trials and cohorts, **missing lung function often tracks disease severity**, therapy intolerance, or inability to perform the manoeuvre [@harrell2015rms].

---

## Technique: Missing data analysis and multiple imputation (overview)

### Technique card

| | |
|---|---|
| **Answers** | Estimates under explicit missingness assumptions; sensitivity to those assumptions |
| **Outcome** | Any (here: continuous FEV1 in `lm`) |
| **Key quantities** | % missing per variable; enrolled *n*; analysed *n* |
| **MCAR** | Missingness unrelated to observed or unobserved values |
| **MAR** | Missingness depends on observed data only (given a rich enough model) |
| **MNAR** | Missingness depends on the unobserved value itself |
| **Teaching script** | Complete-case `lm` vs median imputation |
| **Production default** | MICE (`mice` package) + pooled estimates (Rubin's rules) when MAR is plausible |
| **R (teaching)** | `R/examples/ch20_missing_data.R` |
| **When to use** | Any non-trivial missingness in Table 1 or outcomes |
| **When NOT to use** | Single imputation without sensitivity when MNAR is plausible |
| **Does NOT prove** | That MAR holds — sensitivity and design discussion required |

### Dual interpretation

**Plain language:** we compared results using only participants with observed FEV1 versus filling missing FEV1 with a typical value; if conclusions change, missingness matters.

**Precise language:** under MAR, valid inference requires either a correctly specified likelihood/model integrating missingness or multiple imputation from a model predicting missing values from observed covariates; complete-case analysis is unbiased only under stronger assumptions (often MCAR or MAR with missingness independent of outcome given covariates in the analysis model).

**Clinician read:** if sicker patients are missing spirometry, "complete-case FEV1" may describe **healthier** subsets — not the enrolled trial population.

### Caveats box

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| Informative spirometry missingness | Severe dyspnoea, exacerbation, poor effort tests |
| MAR is untestable | You defend it with subject-matter reasoning + sensitivity |
| Median imputation | Shrinks variance; SEs wrong if treated as observed |
| Imputing then splitting train/test | Leakage in prediction workflows (Ch 9, 17) |
| LOCF for FEV1 trajectories | Can create false stability (Ch 18) |
| MNAR for death/discontinuation | Requires dedicated models, not silent deletion |

### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Drop missing without table | Hides selection | Report missing % by arm/severity |
| Listwise deletion as default | Biased under MAR/MNAR | MI or principled model |
| Single imputation, ignore uncertainty | SEs too small | MICE + Rubin pooling |
| Impute using future/outcome information | Leakage | Imputation model uses only past/ baseline covariates per protocol |
| "No missing data" when LOCF used | Hidden imputation | State imputation rule explicitly |

### Catalog of wrong analyses (missing data)

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **Per-protocol deletion of missed visits** without estimand | Changes population | Align with ITT or prespecified estimand |
| **Replace missing FEV1 with 0** | Meaningless scale abuse | Model missingness or impute within plausible range |
| **Complete-case ML with 40% missing predictors** | Biased + overfit | MI inside CV folds |
| **"Sensitivity analysis: repeat without missing"** only | One-direction sensitivity | Multiple plausible MNAR scenarios |

### Reporting template

> Of *N* = … participants enrolled, *n* = … had observed FEV1 at the analysis visit (…% missing). Missingness differed by obstruction severity (Figure). The primary model used … (complete-case / multiple imputation with *m* = … imputations). Variables in the imputation model were …. Pooled estimates for smoking were … (95% CI …). Results were similar / materially changed in complete-case analysis (Table).

---

## R lab

```r
source("R/00_setup.R")
source("R/examples/ch20_missing_data.R")
```

![Missing FEV1 fraction by obstruction severity](../figures/ch20_missingness_pattern.png)

![Smoking coefficient: complete-case vs median imputation](../figures/ch20_smoking_coef_sensitivity.png)

**Tables:** `ch20_enrollment_flow.csv`, `ch20_missingness_by_diagnosis.csv`, `ch20_smoking_coef_sensitivity.csv`

### Mini-lab: MICE pointer (production)

```r
# After install.packages("mice"):
# imp <- mice::mice(spirometry_miss, m = 20, maxit = 5, seed = 1)
# fit_mice <- with(imp, lm(fev1_obs ~ smoking + age + sex))
# pool::pool(fit_mice)
```

Use an imputation model that includes predictors of missingness (e.g. diagnosis, baseline FEV1) but avoid outcome leakage per study protocol.

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Longitudinal dropout | Mixed model / joint model | Ch 18 + sensitivity |
| MNAR for spirometry | Pattern-mixture / selection models | Expert sensitivity |
| Prediction with missing predictors | MI inside resampling | Ch 9, 17 |
| Single missing covariate, few missing | Firth / exact methods | Ch 6 sparse events |

---

## Exercises · [Solutions](../solutions/ch20_solutions.md)

**E20.1** Define MAR in one sentence.

**E20.2** Why is complete-case analysis risky when missingness relates to obstruction severity?

**E20.3** Why is median imputation inadequate as a final analysis?

**Applied**

1. Run `source("R/examples/ch20_missing_data.R")`.
2. Report enrolled vs analysed *n* from `ch20_enrollment_flow.csv`.
3. Compare smoking coefficients in `ch20_smoking_coef_sensitivity.csv`.

---

## Further reading

- Harrell, *Regression Modeling Strategies* (missing data chapter) [@harrell2015rms]
- van Buuren, *Flexible Imputation of Missing Data* (MICE)
