# Chapter 7: Model Building and Selection

> **Part IV: Building Defensible Models**

## Opening scene: the variable-selection workshop

The CRO proposes "let the data tell us" which covariates belong in the FEV₁ model. Twelve baseline variables, stepwise AIC, one hour before the abstract deadline. Mei opens the prespecified SAP: age, sex, smoking, baseline FEV₁ — full stop.

*"The data can suggest sensitivity analyses,"* she says. *"It cannot rewrite the primary model after unblinding."*

---

## Why this chapter

Model building is where good studies leak degrees of freedom. This chapter separates prespecification from exploration — and gives you language for the meeting when someone wants "just one more predictor."

---

## Three model-building modes (choose first)

| Mode | Variable selection | Evaluation | CASTOR example |
|------|-------------------|------------|----------------|
| **Confirmatory inference** | Prespecified confounders | CI, LRT for prespecified extras | Smoking + age + FEV1% + prior exac |
| **Exploratory** | Flexible | Generate hypotheses only | Subgroup scans - label exploratory |
| **Prediction** | CV / LASSO / RF | AUC, calibration on held-out data | Ch 9 shootout [@james2023ISL] |

**Never mix modes without labelling which is which** [@shmueli2010predict].

---

## Technique: Prespecified confounder adjustment

Choose covariates from a causal DAG, clinical knowledge, and protocol — **not** from p < 0.20 screening. Use for observational COPD studies and secondary adjusted RCT analyses. Do **not** "shop" covariates until the exposure turns significant; prespecification reduces confounding only when confounders are measured — it does **not** prove causation.

**Plain language:** adjust for factors that could distort the smoking–exacerbation link. **Precise language:** conditional association given measured covariates; unmeasured confounding may remain.

Watch for: adjusting **colliders** or **mediators**; **overadjustment** on the causal path; the Table 2 fallacy (adding variables without theory); MRC/GOLD severity as mediators depending on the question.

**Common mistake:** univariate screen keeping vars with p < 0.2 — data-driven and inflates false positives. Prespecify a minimal sufficient adjustment set. If variables were not in the SAP, label the model exploratory.

**Methods:** The primary model adjusted for age, FEV1 % predicted, and prior exacerbation count, prespecified in the analysis plan. Smoking was the exposure of interest.

---

## Technique: Nested model comparison (LRT / F-test)

**Likelihood ratio tests** (GLM: `anova(m_small, m_big, test = "Chisq")`) and **F-tests** (linear: `anova(m_small, m_big)`) ask whether adding predictors improves fit — only for **nested** models and **prespecified** hypotheses (e.g. an interaction term). They do **not** prove added variables are causal.

```r
reduced <- glm(
 exacerbation_12m ~ smoking + age,
 data = exac,
 family = binomial
)
full <- glm(
 exacerbation_12m ~ smoking + age +
 fev1_percent_predicted + prior_exacerbations,
 data = exac,
 family = binomial
)
anova(reduced, full, test = "Chisq")
```

Multiple LRTs without multiplicity control inflate error; LRT after stepwise is invalid. For non-nested models, use AIC or CV instead.

---

## Technique: AIC / BIC

**AIC** and **BIC** rank models by in-sample fit penalized for complexity — lower is preferred with caution. Use for exploratory comparison and prediction prototyping; **avoid** for confirmatory p-values or causal inference. AIC favours prediction; BIC penalizes complexity more. Neither replaces prespecification in trials.

---

## Technique: LASSO (penalized regression)

**LASSO** (`glmnet::cv.glmnet(..., alpha = 1)`) applies an L1 penalty so some coefficients shrink to zero — useful when *p* is large relative to *n* and the goal is **prediction** [@james2023ISL]. Do **not** use for confirmatory inference on a prespecified OR; selected variables are not causal importance.

**Plain language:** LASSO picks a sparse predictor set that predicts exacerbation in cross-validation. **Precise language:** penalized logistic regression with λ chosen by CV; coefficients are biased but prediction may improve.

CASTOR has ~18 events — LASSO is unstable here (mostly teaching). Tune λ only on training folds; bootstrap stability helps. **Common mistake:** report unpenalized p-values from a LASSO-selected model — report prediction metrics (Ch 9) or debiased methods instead.

```r
source("R/examples/ch07_model_building.R")
```

---

## Technique: Splines for nonlinearity

Natural splines test whether the age–FEV1 relationship is linear: `lm(fev1 ~ smoking + splines::ns(age, df = 3) + sex, data = spirometry)`. Use when curvature is clear and *n* is adequate. Prespecify df; overfitting is a risk with small *n*. **Common mistake:** pick df to minimize p-value without prespecification.

---

## Technique: Why NOT stepwise selection

Forward, backward, and stepAIC selection inflate type I error, bias coefficients, and overfit [@harrell2015rms] — avoid for confirmatory trials and primary publications. Prefer prespecification for inference; LASSO for prediction [@james2023ISL].

**Signature example:** stepwise logistic on 30 variables with 18 events → a "significant" OR for exposure. **Instead:** prespecify four confounders; report OR with CI; label exploratory scans separately.

---

## Missing data (introductory)

Complete-case analysis drops rows with any missing covariate - may bias if missing not random.

**Report:** n analysed vs n enrolled. **Missing data:** Ch 20 (multiple imputation).

### Caveats

Missing FEV1 often sicker patients - MNAR. Do not silently complete-case without note.

---

## CASTOR worked example: model building path

**Inference path (prespecified):**

```
exacerbation_12m ~ smoking + age +
 fev1_percent_predicted + prior_exacerbations
```

**Sensitivity:** add therapy class if not on causal path; Firth if separation.

**Prediction path (Ch 9):** same predictors → train/test → LASSO λ by CV - evaluate AUC, not stepwise p.

---

## Catalog of wrong analyses

| Wrong | Right |
|-------|-------|
| Stepwise for primary endpoint | Prespecified model |
| Tune on test set | CV on training only |
| 30 predictors, 18 events | Reduce predictors / penalize |
| Adjust for collider | DAG-informed adjustment |
| Report AIC-min model as confirmatory | Label exploratory |

---

## Reporting template

**Methods:** Confounders (age, FEV1 % predicted, prior exacerbations) were prespecified. Nested models compared with likelihood ratio tests where stated. No stepwise selection was used for primary inference.

---


## R lab

```r
source("R/examples/ch07_model_building.R")
```

### Figure hygiene: stepwise AIC vs prespecification

![Right vs wrong: model building](../figures/viz_pair_ch07_model_building.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Lowest-AIC model from stepwise shopping | Optimism, invalid confirmatory CIs |
| **Right** | Prespecified covariate set | One SAP-aligned model |

---

## Alternatives & extensions (model building menus)

### Penalization family (prediction-focused)

| Method | When to use | Note |
|---|---|---|
| **Ridge** | many correlated predictors; keep all | stabilizes coefficients; less sparse |
| **Elastic net** | correlated blocks; want some sparsity | between ridge and LASSO |
| **Stability selection** | want reproducible feature set | still needs external validation |

### Uncertainty about model form

| Option | When to use | Note |
|---|---|---|
| **Bootstrap model averaging** | avoid single “best” exploratory model | report as exploratory |
| **Pre-registered analysis plan** | confirmatory inference | reduces researcher degrees of freedom |

### Causal selection (Ch 21)

| Concept | Why it matters | Chapter |
|---|---|---|
| DAG-informed adjustment | avoid colliders/mediators | Ch 21 |

---

## Quick reference: methods in this chapter

| Method | When to use | Why |
|--------|-------------|-----|
| **Prespecified covariate set** | Confirmatory trial or observational inference | Subject-matter confounders; avoids p-hacking |
| **Likelihood ratio test (nested)** | Prespecified extra term | Valid comparison of nested models |
| **AIC / BIC** | Exploratory ranking; prediction focus | In-sample; not for confirmatory p-values |
| **LASSO / ridge / elastic net** | Many predictors; prediction goal ([Ch 9](09-prediction-vs-inference.md)) | Penalisation; use with CV |
| **Splines for age/FEV1** | Non-linearity prespecified | Flexible; limit df to avoid overfit |
| **Stepwise selection** | Avoid in confirmatory work | Inflates optimism; invalid CIs |
| **Complete-case vs MI** | Predictors have missing values | MI inside resampling for prediction ([Ch 20](20-missing-data.md)) |
| **EPV rule (events per variable)** | Logistic with few events | &lt;10–15 events per coefficient is fragile |


## Where we go next

Rivera signs the covariate list Mei defended. The first full manuscript draft goes to internal review — CONSORT flow, limits paragraphs, and whether a burst-risk model belongs in the same paper as the primary FEV₁ result. That is **Part IV**, not another tweak to tonight's `glm()` output.

## Related chapters

| Chapter | When to open it |
|---------|------------------|
| [Chapter 8: Validation & reporting](08-validation-reporting.md) | CONSORT, CIs, limits, calibration |
| [Chapter 20: Missing data](20-missing-data.md) | MAR/MNAR, MICE, sensitivity analyses |
| [Chapter 21: Causal inference](21-causal-inference.md) | Confounding, IPW, DAGs |

## Handbook resources

| Resource | When to use it |
|----------|----------------|
| [Appendix B: Quick reference](../appendix-b-quick-reference.md) | Choose a test or model by outcome and design |

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- James et al., *An Introduction to Statistical Learning* [@james2023ISL]
- Shmueli, "To explain or to predict?" [@shmueli2010predict]

## Exercises ([Solutions](../solutions/ch07_solutions.md))

