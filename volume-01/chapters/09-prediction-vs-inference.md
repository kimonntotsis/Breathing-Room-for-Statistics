# Chapter 9: From Explanation to Prediction

> **Part V: Prediction and Machine Learning (Foundations)**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](RECURRING_COHORT.md) - `data/exacerbation.csv` |
| **Question type** | What is this patient's 12-month exacerbation risk? |
| **Methods** | Logistic, LASSO, rpart, RF, AUC, Brier, calibration |
| **R** | `R/examples/ch09_prediction.R` |
| **Figures** | [ch09_calibration_logistic](../figures/ch09_calibration_logistic.png) |
| **Navigation** | [QUICK_REFERENCE § Step 6](../QUICK_REFERENCE.md) · [REFERENCES](../REFERENCES.md) · Inference vs prediction: [Ch 1](01-statistical-thinking.md#inference-vs-prediction) |
| **Exercises** | [ch09](../exercises/ch09_exercises.md) |

---

## Learning objectives

1. State whether the goal is inference or prediction before modelling.
2. Compare models on the **same** held-out data.
3. Report discrimination (AUC) and calibration together.
4. Explain sensitivity, specificity, PPV, NPV at a chosen threshold.
5. Identify data leakage in respiratory prediction studies.
6. Write TRIPOD-aligned prediction methods and results text.

## Prerequisites

Chapters 6-8.

---

## Opening question (CASTOR cohort)

*Can we predict which CASTOR participants will have ≥1 exacerbation in 12 months using baseline smoking, age, FEV1 % predicted, and prior exacerbation history?*

That is a **prediction** question. The answer is a **risk score**, not an odds ratio paragraph [@shmueli2010predict; @steyerberg2019clinical].

---

## Inference vs prediction: choose your lane

| | Inference (Ch 6) | Prediction (this chapter) |
|---|------------------|---------------------------|
| **Question** | Is X associated with Y? | What is Y for a new patient? |
| **Output** | OR, CI, p-value | Probability or class |
| **Success metric** | Valid CI, prespecified model | Calibration + discrimination on new data |
| **Complexity** | Parsimony often preferred | Flexible models OK if validated |
| **CASTOR example** | "Smoking OR for exacerbation" | "Predicted 12-month risk 8%" |

**You can use logistic regression for both - but evaluation differs** [@hosmer2013applied; @shmueli2010predict].

---

## Technique: Binary prediction model (general)

### Technique card

| | |
|---|---|
| **Answers** | What is P(exacerbation in 12 months \| baseline predictors)? |
| **Outcome** | Binary within prespecified horizon |
| **Predictors** | Measured **before** outcome window |
| **Design** | Cohort with follow-up; case-control only with care |
| **Evaluation** | Train/test or CV; AUC + calibration on held-out data [@steyerberg2019clinical] |
| **R** | `glm(..., family=binomial)` + `predict(..., type="response")` |
| **When to use** | Risk stratification, screening tools, ML comparison |
| **When NOT to use** | Causal treatment effects; tiny event count without regularization |
| **Does NOT prove** | Causal impact of predictors; clinical utility without decision analysis |

### Caveats box: prediction in respiratory research

| Caveat | Why it matters |
|--------|----------------|
| **Small event count** | CASTOR has ~18 events / 350 - models overfit easily |
| **EPV rule** | Aim ≥10-15 events per predictor; be skeptical with low EPV [@harrell2015rms] |
| **Leakage** | Post-exacerbation labs must not enter baseline model |
| **AUC alone** | High AUC with poor calibration misleads clinicians [@steyerberg2019clinical] |
| **Prevalence** | PPV/NPV change when you apply model to new populations |
| **Transportability** | Model trained in one clinic may fail in another |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Report training AUC as model performance |
| **Why wrong** | Overoptimistic; model memorized training noise |
| **Do instead** | Test-set or cross-validated AUC |

| | |
|---|---|
| **Mistake** | Select predictors using full dataset, then split train/test |
| **Why wrong** | Information from test set leaked into feature selection |
| **Do instead** | Feature selection **inside** training folds only |

| | |
|---|---|
| **Mistake** | "Random forest **discovered** exacerbation drivers" |
| **Why wrong** | Prediction ≠ causal inference; black-box importance ≠ mechanism |
| **Do instead** | "RF achieved AUC X for 12-month exacerbation prediction" |

| | |
|---|---|
| **Mistake** | Use OR from logistic model as if it were individual risk without calibration check |
| **Why wrong** | Rankings may be OK while absolute risks are wrong |
| **Do instead** | Calibration plot on held-out data |

---

## TRIPOD-aligned workflow (CASTOR)

Follow TRIPOD for transparent prediction reporting [@moons2015tripod]:

1. **Population:** CASTOR synthetic COPD-style cohort  
2. **Outcome:** `exacerbation_12m` within 12 months  
3. **Predictors:** smoking, age, FEV1 % predicted, prior exacerbations - all baseline  
4. **Split:** 70% train / 30% test (prespecified seed)  
5. **Metrics:** AUC, Brier, calibration deciles  
6. **Report:** n, events, EPV, software  

---

## Model shootout: four models, one split

| Model | Role | CASTOR script output |
|-------|------|----------------------|
| **Logistic** | Interpretable baseline | AUC, Brier |
| **LASSO** | Penalized selection | AUC, Brier |
| **rpart tree** | Nonlinear rules | AUC, Brier |
| **Random forest** | Ensemble | AUC, Brier [@breiman2001rf] |

```r
source("R/examples/ch09_prediction.R")
```

**Rule:** same `train`/`test` indices for all models. Differences in AUC are often modest with small event counts - report uncertainty (bootstrap CV in extensions).

---

## Technique: Discrimination (AUC / ROC)

### Technique card

| | |
|---|---|
| **Answers** | How well does the model **rank** cases above non-cases? |
| **Metric** | AUC = P(score_case > score_noncase) |
| **Interpretation** | 0.5 random; 1.0 perfect ranking |
| **R** | `pROC::roc(y, pred); pROC::auc(roc)` |
| **Does NOT tell you** | Absolute risk accuracy (need calibration) |

### Dual interpretation

**Plain language:** if you pick one patient who exacerbated and one who did not, the model assigns higher risk to the right patient 93% of the time (example AUC).

**Precise language:** AUC is rank correlation between scores and outcomes; threshold-independent [@steyerberg2019clinical].

**Clinician read:** good for triage ordering; not enough to trust the exact percentage shown to patients.

---

## Technique: Calibration

### Technique card

| | |
|---|---|
| **Answers** | Do predicted probabilities match observed event rates? |
| **Method** | Group by risk decile; plot mean predicted vs observed |
| **Perfect** | Points on 45° line |
| **Figure** | `volume-01/figures/ch09_calibration_logistic.png` |

**Brier score:** mean((y − p)²). Lower is better. Penalizes both discrimination and calibration [@steyerberg2019clinical].

```r
mean((test$exacerbation_12m - test$pred_log)^2)
```

---

## Classification metrics at a threshold

Default 0.5 is often **not** clinical optimum. Choose threshold by cost of false positives vs false negatives.

| Metric | Formula | Respiratory note |
|--------|---------|------------------|
| Sensitivity | TP/(TP+FN) | Catch exacerbations |
| Specificity | TN/(TN+FP) | Avoid false alarms |
| PPV | TP/(TP+FP) | Low when events rare |
| NPV | TN/(TN+FN) | High when events rare |

```r
# See ch09_prediction.R - class_metrics() helper
```

---

## Cross-validation

Single split is noisy. **k-fold CV** or **bootstrap** for stable performance estimates.

For LASSO: `cv.glmnet` selects λ using CV - **never** use test set for tuning [@james2023ISL].

---

## CASTOR worked example: full narrative

**Goal:** Predict 12-month exacerbation.

**Train logistic model on 70% of CASTOR.** Evaluate on 30%.

**Results template:**

> Among 105 test-set patients (11 events), logistic regression achieved AUC 0.93 and Brier score 0.04. Calibration by decile showed reasonable agreement except in the highest-risk bin where event count was sparse. Prior exacerbations and FEV1 % predicted contributed most in the penalized and tree models. Given low event numbers, external validation would be required before clinical use.

**What this does NOT prove:** that lowering FEV1 will prevent exacerbations (causal); that RF "found" biological pathways.

---

## Reporting template (TRIPOD-style)

**Methods:**

> We developed prediction models for 12-month exacerbation (yes/no) using baseline smoking, age, FEV1 % predicted, and prior exacerbation count. The cohort was split 70/30 into training and test sets (seed 42). We fitted logistic regression, LASSO (10-fold CV for λ), classification trees, and random forests (500 trees). Performance was assessed on the held-out test set using AUC, Brier score, and calibration by predicted risk decile [@moons2015tripod].

**Results:**

> The test set included n = … patients with … events. Logistic regression AUC = … (95% CI …); Brier = …. Calibration plot showed …. At threshold 0.5, sensitivity = …, specificity = …, PPV = …, NPV = ….

**Do not say:** "AI model proves exacerbation risk factors"; "validated biomarker panel" without external cohort.

---

## When ML adds value: and when it does not

**Adds value:** many weak predictors; unknown nonlinearities; explicit risk tool after validation.

**Does not add value:** 18 events and 4 predictors (CASTOR) - logistic often sufficient [@harrell2015rms]; causal questions; deployment without calibration check.

---

## R lab

```r
source("R/examples/ch09_prediction.R")
```

---

## Alternatives & extensions (prediction reporting and validation)

These are common in modern respiratory prediction papers; use them when the goal is deployment-quality prediction rather than a classroom example.

### Calibration beyond one plot

| Option | When to use | Note |
|---|---|---|
| Calibration intercept/slope | detect systematic under/overprediction | complements decile plot |
| Recalibration | applying model to new clinic/population | must report transportability limits |

### Clinical usefulness

| Option | When to use | Note |
|---|---|---|
| Decision curve analysis | threshold-based clinical decisions | separates AUC from utility |
| Net benefit | screening/triage policies | requires explicit harm/benefit |

### Validation designs

| Validation | When to use | Note |
|---|---|---|
| Temporal validation | later cohort in same site | mimics future deployment |
| Geographic validation | different centres | key for respiratory multi-centre generalization |
| External validation | independent cohort | required for clinical claims [@moons2015tripod] |

### Model families (when logistic may be insufficient)

| Situation | Alternative | Note |
|---|---|---|
| Many weak predictors | penalized GLM / gradient boosting | must validate; avoid leakage |
| Nonlinear interactions expected | tree ensembles | interpretability trade-off |

## Chapter summary

- Prediction needs held-out evaluation, calibration, and clear predictor timing [@moons2015tripod; @steyerberg2019clinical].
- Compare models fairly; report AUC **and** Brier/calibration.
- Avoid leakage and causal overinterpretation of ML output [@shmueli2010predict].

## Further reading

- Moons et al., TRIPOD statement [@moons2015tripod]  
- Steyerberg, *Clinical Prediction Models* [@steyerberg2019clinical]  
- Shmueli, "To explain or to predict?" [@shmueli2010predict]  
- James et al., *An Introduction to Statistical Learning* [@james2023ISL]  
- Breiman, random forests [@breiman2001rf]

## Exercises · [Solutions](../solutions/ch09_solutions.md)

**Next:** [Chapter 10 - PCA](10-dimensionality-reduction.md)
