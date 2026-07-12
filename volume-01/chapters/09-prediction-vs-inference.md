# Chapter 9: From Explanation to Prediction

> **Part IV: Validation, Reporting, and Prediction**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](../RECURRING_COHORT.md), `data/exacerbation.csv` |
| **Question type** | What is this patient's 12-month exacerbation risk? |
| **Methods** | Logistic, LASSO, rpart, RF, gradient boosting (optional), AUC, Brier, calibration |
| **R** | `R/examples/ch09_prediction.R` |
| **Figures** | ch09_calibration_logistic (`ch09_calibration_logistic.png`); **figure hygiene:** `viz_pair_ch09_prediction.png` |
| **Tables** | [ch09_model_comparison](../tables/ch09_model_comparison.csv) |
| **Exercises** | [ch09](../exercises/ch09_exercises.md) |

**Also see:** [Appendix B § Step 6](../appendix-b-quick-reference.md), Inference vs prediction: [Ch 1](01-statistical-thinking.md), High-dimensional prediction: [Ch 17](17-integrated-castor-hd.md)

---

## Investigator path (≈20 min)

1. [Inference vs prediction: choose your lane](#inference-vs-prediction-choose-your-lane) — pick the goal first
2. [Method choice at a glance](#method-choice-at-a-glance) — logistic, LASSO, trees
3. [Technique: Binary prediction model](#technique-binary-prediction-model-general) — Practice read on calibration
4. [Reporting template](#reporting-template) — TRIPOD-style wording
5. [Catalog of wrong analyses](#catalog-of-wrong-analyses-prediction-chapter) — train AUC in abstract

**Analyst read:** model shootout, R lab, validation extensions below.

---

## Method choice at a glance

| Method | When to use | Why |
|--------|-------------|-----|
| **Logistic regression** | Few predictors; interpretable risk model | Baseline for binary prediction; coefficients have meaning |
| **LASSO / elastic net** | Many predictors; moderate *n* | Penalisation; nested CV when tuning ([Ch 7](07-model-building.md)) |
| **Classification trees (rpart)** | Nonlinear thresholds; explainability | Simple rules; unstable without CV |
| **Random forest / boosting** | Flexible boundaries; prediction focus | Often higher AUC; harder to interpret |
| **Train/test split** | Initial model comparison | Simple; unstable with small event counts |
| **Bootstrap / k-fold CV** | Small *n*; unstable single split | More stable performance estimate |
| **Nested CV** | p ≫ n omics prediction ([Ch 17](17-integrated-castor-hd.md)) | Tuning without leakage |
| **Calibration plot + Brier** | Any risk model for clinical use | Discrimination (AUC) ≠ calibrated probabilities |
| **External validation** | Deployment or multi-site claims | Required by TRIPOD for transportability |

**Extensions:** DCA, recalibration in [Alternatives & extensions](#alternatives--extensions-prediction-reporting-and-validation).

---

## Learning objectives

1. State whether the goal is **inference** or **prediction** before modelling.
2. Follow a prespecified prediction workflow (population → split → tune on train → evaluate on held-out data).
3. Compare models on the **same** test set with AUC, Brier, and calibration.
4. Interpret LASSO, trees, random forests, and gradient boosting with respiratory caveats (EPV, leakage, overinterpretation).
5. Identify data leakage and unstable AUC with sparse events.
6. Write TRIPOD-aligned Methods/Results and list what the model **does not** prove.

## Prerequisites

Chapters 6–8.

---

## Why this chapter

Prediction models are everywhere in respiratory research: admission risk, exacerbation scores, classifier AUCs, but they answer a different question than association. This chapter stops you from reporting an odds ratio when the clinical need is calibrated risk, and stops you from reporting training-set AUC when the clinical need is honest validation.

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
| **Success metric** | Valid CI, prespecified model | Calibration + discrimination on **new** data |
| **Complexity** | Parsimony often preferred | Flexible models OK **if validated** |
| **CASTOR example** | "Smoking OR for exacerbation" | "Predicted 12-month risk 8%" |

**You can use logistic regression for both, but evaluation differs** [@hosmer2013applied; @shmueli2010predict].

---

## How to do prediction / machine learning in respiratory research

Use the same CASTOR habit as [Chapter 1](01-statistical-thinking.md), adapted for risk models:

1. **Clinical question:** Who needs a risk estimate, for what decision, at what time horizon (e.g. 12-month exacerbation)?
2. **Design and data:** Baseline predictors only; define enrolment and follow-up; count **events** in train and test.
3. **Prespecify the workflow:** Train/test split or nested CV; all tuning **inside train**; same test set for every model.
4. **Select model family:** Start with logistic; add LASSO / trees / ensembles only when EPV and biology justify complexity.
5. **Evaluate:** AUC **and** calibration **and** Brier on held-out data; bootstrap CIs when events allow.
6. **Report limits:** No causation, no external validation claim, no clinical deployment without transportability work.

For **p ≫ n** omics prediction (1000+ proteins, few patients), use nested CV as in [Chapter 17](17-integrated-castor-hd.md); not a single 70/30 split on four clinical variables.

!CASTOR analysis pipeline (`analysis_pipeline.png`){width=75%}

*Prediction sits at steps 4–6: method choice, fit with validation discipline, report what you did not prove.*

---

## Technique: Binary prediction model (general)

### Technique card

| | |
|---|---|
| **Answers** | What is P(exacerbation in 12 months \| baseline predictors)? |
| **Outcome** | Binary within prespecified horizon |
| **Predictors** | Measured **before** outcome window |
| **Design** | Cohort with follow-up; case-control only with care |
| **Evaluation** | Train/test or nested CV; AUC + calibration on held-out data [@steyerberg2019clinical] |
| **R** | `glm(..., family=binomial)` + `predict(..., type="response")` |
| **When to use** | Risk stratification, screening tools, ML comparison |
| **When NOT to use** | Causal treatment effects; tiny event count without regularization |
| **Does NOT prove** | Causal impact of predictors; clinical utility without decision analysis |

### Caveats box: prediction in respiratory research

| Caveat | Why it matters |
|--------|----------------|
| **Small event count** | CASTOR has ~18 events / 350; models overfit easily |
| **EPV rule** | Aim ≥10–15 events per predictor; be skeptical below [@harrell2015rms] |
| **Leakage** | Post-exacerbation labs must not enter baseline model |
| **AUC alone** | High AUC with poor calibration misleads decision-makers [@steyerberg2019clinical] |
| **Prevalence shift** | PPV/NPV change when applied to new populations |
| **Transportability** | Model trained in one clinic may fail in another |

### In practice

AUC of 0.85 on four events in the test set is not deployable. Report calibration and event counts; plan external validation before anyone uses the score in clinic.

### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Report **training** AUC | Overoptimistic | Test-set or nested-CV AUC |
| Tune λ or trees on full data, then split | Leakage | Tune **inside train** only |
| "RF **discovered** drivers" | Prediction ≠ causation | "RF achieved AUC X for prediction" |
| Trust OR-based risk without calibration | Wrong absolute risks | Calibration plot on held-out data |

---

## Questions to ask before trusting a model

1. **How many events in the test set?** (Not just total *n*.)
2. **Was calibration shown**, not only AUC?
3. **Were predictors all measured before** the outcome window?
4. **Was feature selection / tuning done without** peeking at the test set?
5. **Would this population match** my clinic or trial?
6. **What does the model explicitly not claim** (cause, cure, regulatory approval)?

If the answer to (2) or (4) is unclear, treat the model as exploratory.

---

## What this machine learning analysis does not prove

State these in every prediction Discussion:

| Claim | Why you usually **cannot** say it |
|-------|-----------------------------------|
| **X causes exacerbation** | Predictors selected for association with outcome, not intervention |
| **Validated clinical tool** | Internal test-set performance ≠ external validation [@moons2015tripod] |
| **Superior biology** from RF importance | Importance reflects prediction, not mechanism |
| **Safe deployment** | Threshold, calibration, and net benefit not established |
| **Better than expert judgment** | No comparator or decision-curve analysis |

---

## TRIPOD-aligned workflow (CASTOR)

Follow TRIPOD for transparent prediction reporting [@moons2015tripod]:

1. **Population:** CASTOR synthetic respiratory cohort  
2. **Outcome:** `exacerbation_12m` within 12 months  
3. **Predictors:** smoking, age, FEV1 % predicted, prior exacerbations; all baseline  
4. **Split:** 70% train / 30% test (seed 42); **same indices for all models**  
5. **Tuning:** LASSO λ by CV on train; tree/RF/boost hyperparameters fit on train only  
6. **Metrics:** AUC (with bootstrap CI when stable), Brier, calibration bins  
7. **Report:** *n*, events in train/test, EPV, software version  

---

## Model shootout: one split, fair comparison

| Model | Role | Tune on train? |
|-------|------|----------------|
| **Logistic** | Interpretable baseline | No |
| **LASSO** | Penalized selection | Yes (`cv.glmnet`, λ~1se) |
| **rpart tree** | Nonlinear rules | Yes (cp, minbucket) |
| **Random forest** | Ensemble | Yes (ntree, mtry defaults) |
| **XGBoost** (optional) | Gradient boosting | Yes (depth, η; package optional) |

```r
source("R/examples/ch09_prediction.R")
```

**Rule:** never compare models tuned on different information or evaluated on training rows. With CASTOR's low EPV (~3.5 events per predictor in the training split), **complex models often tie or lose to logistic**; that is a feature, not a bug.

---

## Technique: LASSO (penalized logistic regression)

### Technique card

| | |
|---|---|
| **Answers** | Which predictors contribute to risk when many candidates exist? |
| **Outcome** | Binary (exacerbation Y/N) |
| **Method** | L1-penalized logistic; `cv.glmnet` chooses λ on **training data only** |
| **R** | `cv.glmnet(x_train, y_train, family="binomial", alpha=1)`; predict at `lambda.1se` |
| **When to use** | Many candidate predictors; need shrinkage |
| **When NOT to use** | Few events (CASTOR n≈14 train events); may shrink everything to null |
| **Does NOT prove** | Selected variables are causal; ORs from selected model are unbiased |

**Plain language:** LASSO pulls weak predictors toward zero to reduce overfitting.

**Precise language:** penalized likelihood with L1 constraint; λ chosen by cross-validation minimizes prediction error on train [@james2023ISL].

**Practice read:** if LASSO drops all predictors, the data may be too sparse for variable selection; trust the simpler logistic model.

#### Wrong analysis ⚠

| Mistake | Do instead |
|---------|------------|
| Run `cv.glmnet` on full dataset before split | Split first; CV inside train |
| Report LASSO ORs as confirmatory biology | Report prediction metrics; label exploratory |

---

## Technique: Classification tree (`rpart`)

### Technique card

| | |
|---|---|
| **Answers** | What simple rules split high- vs low-risk patients? |
| **Outcome** | Binary |
| **Method** | Recursive partitioning; `method="class"` |
| **R** | `rpart::rpart(form, data=train, method="class")` |
| **When to use** | Need interpretable rules; exploratory nonlinear structure |
| **When NOT to use** | Small event count; unstable splits |
| **Does NOT prove** | Split points are clinically optimal thresholds |

**Plain language:** a flowchart of if–then rules (e.g. prior exacerbations ≥ 2 → higher risk).

**Practice read:** one split often dominates; verify stability with bootstrap or larger *n*.

#### Caveats

High variance with sparse events; deep trees overfit. Prefer shallow trees (`cp`, `minbucket`) prespecified in the SAP.

---

## Technique: Random forest

### Technique card

| | |
|---|---|
| **Answers** | Nonlinear risk from an ensemble of trees |
| **Outcome** | Binary |
| **Method** | Bagged trees with random feature subsets [@breiman2001rf] |
| **R** | `randomForest(..., ntree=500)` |
| **When to use** | Moderate *n*, enough events; unknown interactions |
| **When NOT to use** | Very sparse events; need interpretable coefficients |
| **Does NOT prove** | Variable importance = causal drivers |

**Plain language:** many trees vote on risk; often good ranking, opaque mechanism.

**Practice read:** ask for calibration, not "the AI found smoking matters" from importance plots.

#### Wrong analysis ⚠

| Mistake | Do instead |
|---------|------------|
| Cite **variable importance** as biomarker discovery | Report AUC + calibration; validate hits separately |
| Train on test patients indirectly via preprocessing | All preprocessing fit on train |

---

## Technique: Gradient boosting (XGBoost) {#technique-gradient-boosting-xgboost}

### Technique card

| | |
|---|---|
| **Answers** | Sequential tree ensemble often strong for tabular prediction |
| **Outcome** | Binary |
| **Method** | Gradient boosted trees (`xgboost`); shallow trees, tuned on train |
| **R** | `xgboost::xgb.train` on train matrix; evaluate on test (see `ch09_prediction.R`) |
| **When to use** | Many weak predictors; nonlinearities; enough events for tuning |
| **When NOT to use** | CASTOR-scale events (~14 train); often no gain over logistic |
| **Does NOT prove** | "State-of-the-art AI"; still needs calibration and external validation |

**Install (optional):** `install.packages("xgboost")`. Script runs without it and skips this row.

**Plain language:** boosts focus on patients the current model gets wrong; powerful but easy to overfit.

#### Wrong analysis ⚠

| Mistake | Do instead |
|---------|------------|
| Report test AUC after hand-tuning on test | Nested CV or single held-out test with train-only tuning |
| Skip calibration because boosting "is accurate" | Same calibration standards as logistic |

---

## Technique: Discrimination (AUC / ROC)

### Technique card

| | |
|---|---|
| **Answers** | How well does the model **rank** cases above non-cases? |
| **Metric** | AUC = P(score~case~ > score~control~) |
| **R** | `pROC::roc(y, pred); pROC::auc(roc)` |
| **Does NOT tell you** | Absolute risk accuracy (need calibration) |

**Practice read:** good for triage ordering; not enough to trust the percentage shown to patients.

**Sparse events:** bootstrap AUC CIs may be wide or unstable (see `ch09_model_comparison.csv` when test events ≈ 4).

---

## Technique: Calibration

### Technique card

| | |
|---|---|
| **Answers** | Do predicted probabilities match observed event rates? |
| **Method** | Risk bins (3–5 when events sparse); mean predicted vs observed |
| **Figure** | `ch09_calibration_logistic.png` |
| **Pair** | `viz_pair_ch09_prediction.png` (AUC shootout vs calibration) |
| **Metric** | Brier = mean($(y - \hat{p})^2$); lower is better [@steyerberg2019clinical] |

### Figure hygiene: AUC hero vs calibration

!Right vs wrong: prediction performance (`viz_pair_ch09_prediction.png`)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Model AUC bar chart shootout | Whether predicted **risks** match observed event rates |
| **Right** | Calibration plot on test set | Discrimination (AUC) if shown without calibration |

**Practice read:** TRIPOD expects calibration or strong justification when a model informs treatment thresholds [@steyerberg2019clinical]. High AUC alone does not tell a pulmonologist whether “20% risk” means 20% or 5%.

---

## Classification metrics at a threshold

Default 0.5 is often **not** the clinical optimum. With rare events, sensitivity at 0.5 may be zero while specificity is high, report the threshold explicitly.

```r
# See ch09_prediction.R ; class_metrics() helper
```

---

## Cross-validation and nested CV

- **LASSO:** `cv.glmnet` selects λ; never use the test set for λ [@james2023ISL].
- **Single split:** simple but noisy when test events are few.
- **Nested CV (p ≫ n):** outer fold = performance; inner fold = tuning. Required for elastic net on proteomics. [Chapter 17](17-integrated-castor-hd.md).

---

## CASTOR worked example: full narrative

**Goal:** Predict 12-month exacerbation on CASTOR (`seed = 42`, 70/30 split).

**Train:** *n* = 244, **14 events** (EPV ≈ 3.5; below ideal 10–15).  
**Test:** *n* = 106, **4 events**.

Run `source("R/examples/ch09_prediction.R")` and read [ch09_model_comparison.csv](../tables/ch09_model_comparison.csv). Example output:

| Model | AUC (95% boot. CI) | Brier |
|-------|-------------------|-------|
| Logistic | 0.93 (0.88–0.99) | 0.033 |
| LASSO | 0.50 (NA) | 0.037 |
| Tree | 0.50 (NA) | 0.037 |
| Random forest | 0.75 (0.55–0.99) | 0.038 |
| XGBoost (if installed) | ~0.73 | ~0.036 |

**Interpretation:** with so few events, **penalized and tree models may collapse to constant predictions** (AUC = 0.5). Logistic remains the defensible primary model; forest/boost may rank better but with **very wide** bootstrap intervals. This illustrates Harrell's EPV warning better than a synthetic "RF wins" story.

**Calibration:** logistic decile plot (figure (`ch09_calibration_logistic.png`)); inspect highest-risk bin event counts.

**Results paragraph (template filled):**

> Among 106 test-set patients (4 events), logistic regression achieved AUC 0.93 (bootstrap 95% CI 0.88 to 0.99) and Brier score 0.033. LASSO and classification trees did not outperform chance ranking (AUC 0.50), consistent with low EPV in training. Random forest AUC was 0.75 (wide CI 0.55 to 0.99). Calibration by risk group showed sparse events in high-risk bins. **External validation would be required before clinical use.**

**What this does NOT prove:** causal effects of FEV1 or smoking; that RF or XGBoost "discovered" pathways; readiness for deployment.

---

## Reporting template (TRIPOD-style)

**Methods:**

> We developed prediction models for 12-month exacerbation (yes/no) using baseline smoking, age, FEV1 % predicted, and prior exacerbation count. The cohort was split 70/30 (seed 42). Models included logistic regression, LASSO (10-fold CV for λ on the training set), classification trees, random forests (500 trees), and optionally gradient boosting (XGBoost, train-only tuning). Performance was assessed on the held-out test set using AUC with bootstrap 95% CIs, Brier score, and calibration by predicted risk group [@moons2015tripod].

**Results:**

> The training set included *n* = … with … events (EPV = …). The test set included *n* = … with … events. [Primary model] AUC = … (95% CI …); Brier = …. Calibration plot …. At prespecified threshold …, sensitivity = …, specificity = ….

**Do not say:** "AI model proves risk factors"; "validated tool" without external cohort.

---

## When ML adds value, and when it does not

**Adds value:** many weak predictors; unknown nonlinearities; enough events for tuning; explicit risk tool **after** external validation.

**Does not add value:** ~14 training events and four predictors (CASTOR); logistic often sufficient [@harrell2015rms]; causal questions; reporting train AUC; skipping calibration.

---

## R lab

```r
source("R/examples/ch09_prediction.R")
readr::read_csv("volume-01/tables/ch09_model_comparison.csv")
```

Optional: `install.packages("xgboost")` to include gradient boosting in the shootout.

---

## Alternatives & extensions (prediction reporting and validation)

### Calibration and recalibration

| Option | When to use | Note |
|--------|-------------|------|
| Calibration intercept/slope | Systematic under/overprediction | Complements binned plot |
| Recalibration in new site | Transport to new clinic | Report limits; may need local data |

### Clinical usefulness (beyond AUC)

| Option | When to use | Note |
|--------|-------------|------|
| **Decision curve analysis (DCA)** | Threshold-based treat/don't-treat | Separates discrimination from **net benefit** |
| Net benefit | Screening or triage policies | Requires explicit harm/cost of false positives |

**Plain language:** DCA asks whether using the model improves decisions versus treating everyone or no one at a given risk threshold [@steyerberg2019clinical]. You do not need DCA in every teaching exercise, but reviewers increasingly ask for it in deployment claims.

### Validation designs

| Validation | When to use | Note |
|------------|-------------|------|
| Bootstrap / CV on train | Unstable single split | Complement, not replace, held-out test |
| Temporal validation | Later cohort, same protocol | Mimics future deployment |
| Geographic validation | Different centres | Key in multi-centre respiratory research |
| **Nested CV** | p ≫ n, many tunable hyperparameters | [Ch 17](17-integrated-castor-hd.md) elastic net |
| External validation | Independent cohort | Required for clinical deployment claims [@moons2015tripod] |

### Model families (summary)

| Situation | Alternative | Handbook location |
|-----------|-------------|-------------------|
| Few predictors, low EPV | **Logistic** (primary) | This chapter |
| Many predictors, moderate *n* | LASSO / ridge | This chapter; [Ch 7](07-model-building.md) |
| Nonlinear rules | Trees, RF, boosting | This chapter |
| p ≫ n omics | Elastic net + **nested CV** | [Ch 17](17-integrated-castor-hd.md) |

---

## Catalog of wrong analyses (prediction chapter)

| # | Wrong | Right |
|---|-------|-------|
| 1 | Train AUC in abstract | Test or nested-CV AUC |
| 2 | ML beats logistic because AUC 0.01 higher on 4 test events | Report CIs; prefer simpler prespecified model |
| 3 | Importance plot = biomarker hit list | Separate discovery pipeline (Ch 13+) |
| 4 | No calibration figure | Binned plot + Brier |
| 5 | Impute/test leakage in CV folds | Impute inside train folds ([Ch 20](20-missing-data.md)) |
| 6 | Claim deployment-ready without external data | Label internal validation only |

---

## Chapter summary

- Prediction needs held-out evaluation, calibration, and clear predictor timing [@moons2015tripod; @steyerberg2019clinical].
- Compare models fairly on one test set; report AUC **and** Brier/calibration.
- ML complexity does not help when EPV is low. CASTOR demonstrates that honestly.
- Avoid leakage and causal overinterpretation of ML output [@shmueli2010predict].

## Where this chapter leads

**Next:** Unsupervised structure → [Chapters 10–11](10-dimensionality-reduction.md). End-to-end CASTOR stories → [Chapter 12](12-case-studies.md). High-dimensional omics prediction → [Chapter 17](17-integrated-castor-hd.md).

## Further reading

- Moons et al., TRIPOD statement [@moons2015tripod]  
- Steyerberg, *Clinical Prediction Models* [@steyerberg2019clinical]  
- Shmueli, "To explain or to predict?" [@shmueli2010predict]  
- James et al., *An Introduction to Statistical Learning* [@james2023ISL]  
- Breiman, random forests [@breiman2001rf]

## Exercises ([Solutions](../solutions/ch09_solutions.md))

**Next:** [Chapter 10 - PCA](10-dimensionality-reduction.md)
