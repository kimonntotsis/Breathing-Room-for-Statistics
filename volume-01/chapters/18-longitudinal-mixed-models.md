# Chapter 18: Longitudinal data and mixed models

> **Part VIII: Longitudinal, survival, and causal inference**

## At a glance

| | |
|---|---|
| **Recurring dataset** | `data/longitudinal_spirometry.csv` ([CASTOR extension](../RECURRING_COHORT.md)) |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Question** | How does FEV1 change over time, and does treatment modify that trajectory? |
| **Core methods** | spaghetti plots, linear mixed models (`lmer`), random intercepts, GEE pointer |
| **R** | `R/examples/ch18_longitudinal_mixed_models.R` |
| **Figures** | spaghetti (`ch18_spaghetti_fev1.png`), fitted trajectories (`ch18_mixed_model_fitted.png`) |
| **Exercises** | [Chapter 18 exercises](../exercises/ch18_exercises.md) |

**Also see:** [Ch 4](04-comparing-groups.md) (independence), [Ch 20](20-missing-data.md) (dropout), [Ch 12 Case E](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation)

---

## In this chapter

You do not need this entire chapter on first pass. Read in order:

1. [Clinical and biostatistics notes](#clinical-and-biostatistics-notes): level vs slope estimand; missed visits
2. [The longitudinal workflow](#the-longitudinal-workflow): prespecify what you are estimating
3. [Method choice at a glance](#method-choice-at-a-glance): mixed model vs shortcuts
4. [Technique: Linear mixed model (random intercept)](#technique-linear-mixed-model-random-intercept): Practice read and MCID
5. [Reporting template](#reporting-template): participant *n*, visits, and fixed effects
6. [Catalog of wrong analyses](#catalog-of-wrong-analyses-longitudinal-fev1): pooled visits and pseudo-replication

**Analyst read:** mixed model details, GEE comparison, R lab, and extensions below.

---

## Method choice at a glance

| Method | When to use | Why |
|--------|-------------|-----|
| **Linear mixed model (random intercept)** | Repeated continuous FEV1; ≥2 visits per patient | Accounts for within-person correlation; uses all visits |
| **Random intercept + slope** | Heterogeneous decline rates across patients | Allows individual trajectories; needs enough visits |
| **GEE** | Population-averaged marginal effects; robust SE focus | Alternative estimand to subject-specific mixed model |
| **Cross-sectional *t* at one visit** | Prespecified single timepoint only (e.g. week 52) | Simpler but discards other visits; prespecify in SAP |
| **`lm()` on stacked visits** | Never as primary analysis | Pseudo-replication; SEs too small |
| **ANCOVA with baseline** | One follow-up visit + baseline FEV1 | Alternative to change score when one post-randomisation visit |
| **Spline in time** | Non-linear decline suspected | Prespecify; avoid post hoc curvature hunting ([Ch 7](07-model-building.md)) |
| **Cluster-robust SE / `(1 \| centre)`** | Multi-centre trials | Patients nested in sites |

**Extensions** (LOCF, per-visit ANOVA): [Alternatives & extensions](#alternatives--extensions) at chapter end.

---

## Learning objectives

1. Recognise when repeated measures violate independence (Ch 4–5).
2. State the estimand for a longitudinal trial (level, slope, or both).
3. Fit a random-intercept mixed model for FEV1 trajectories and read the coefficient table.
4. Interpret `weeks × group` interaction as differential change over time.
5. Compare mixed models to cross-sectional shortcuts and explain SE differences.
6. Report participant-level *n*, visit structure, and sensitivity to missing visits.

## Prerequisites

Chapters 4–5 (group comparisons, linear models); Ch 8 (reporting).

---

*The CRA exports 640 rows from 160 patients and suggests a week-52 t-test “because that is the protocol visit.” You notice four visits per patient in the same file. **This chapter** is why stacking visits without a mixed model overstates precision.*

## Why this chapter

Repeated FEV1 visits carry more information than a single timepoint; a week-52 *t*-test discards most of that structure. This chapter is for extension trials and observational spirometry trajectories where the same patient appears more than once.

## Opening question (CASTOR extension)

*Does intervention slow FEV1 decline compared with standard care when each patient contributes four visits at weeks 0, 12, 24, and 52?*

A Welch *t*-test on week-52 FEV1 alone **throws away** within-person information and treats visits as independent. Mixed models keep all visits while accounting for correlation within patient [@harrell2015rms].

The CASTOR extension cohort has **160 participants** and **640 visits** (four scheduled time points). That structure is typical of COPD and asthma trials where spirometry is repeated but not every week.

---

## Clinical and biostatistics notes

**Clinical:** Prespecify whether the estimand is **week-52 level**, **slope**, or **change from baseline**; they answer different trial questions. Missed visits and inability to perform manoeuvres are clinical missingness ([Ch 20](20-missing-data.md)).

**Biostatistics:** **Random intercept** is the minimum for repeated FEV1. A significant `weeks:group` term means **differential slope**, not automatically week-52 benefit. Stacking visits in `lm()` or Welch *t* inflates precision; compare to Ch 4 only for prespecified single-visit snapshots.

**Clinical nuance:** population fitted lines are **average trajectories**, not individual forecasts for clinic.

**Biostat nuance:** CASTOR teaching output: intervention × time coefficient ≈ **+0.00054 L/week** (95% CI roughly −0.00015 to +0.00122); modelled week-52 separation is modest; illustrate workflow, not a powered trial result.

---

## The longitudinal workflow

Every repeated-measures analysis should follow these steps:

1. **Estimand**: mean difference at week 52? difference in **slope**? area under the curve?
2. **Visit map**: prespecified times; define time origin (randomisation vs first dose).
3. **Plot**: spaghetti or profile plot; check dropout pattern by arm.
4. **Model**: mixed model or GEE matched to estimand; random intercept at minimum.
5. **Sensitivity**: cross-sectional shortcut, complete-case visits, dropout discussion (Ch 20).
6. **Report**: participant *n*, visits per person, fixed effects with CI, not only visit *n*.

---

## When independence fails

| Design | Rows in data | Correct unit of inference | Wrong approach |
|--------|--------------|----------------------------|----------------|
| One FEV1 per patient | 160 | Patient | (none needed) |
| Four visits per patient | 640 | Patient | *t*-test on 640 rows |
| Two centres, 20 patients each | 640 | Patient (centre in model if needed) | Ignore centre |
| Bronchodilator pre/post same day | 2 per patient | Patient (paired) | Two independent groups |

**Rule:** if the same `patient_id` appears more than once, rows are **correlated**. Standard errors from ordinary `lm()` on stacked visits are often **too small** because the model treats each visit as a new person.

---

## Technique: Linear mixed model (random intercept)

### Technique card

| | |
|---|---|
| **Answers** | Mean trajectory over time; group differences in level or slope |
| **Outcome** | Repeated continuous FEV1 (litres) |
| **Unit of inference** | Participants (*n* patients); visits are correlated |
| **Design** | Randomised or observational with ≥2 visits per person |
| **Data required** | `patient_id`, visit time, outcome, optional covariates |
| **Assumptions** | Linear trend in time (or splines); random intercepts ~ Normal; MAR for dropout (discuss) |
| **Effect measure** | Fixed-effect β for `weeks`, `group`, `weeks:group` (litres or litres per week) |
| **R** | `lme4::lmer(fev1 ~ weeks * group + covariates + (1 \| patient_id), data)` |
| **When to use** | Repeated continuous outcomes; interest in change over time |
| **When NOT to use** | One visit per person (use Ch 4–5); survival/censoring primary (Ch 19) |
| **Does NOT prove** | Causal treatment effect without randomisation, adherence, and missing-data audit |

### Dual interpretation

**Plain language:** after accounting for each patient's baseline, the intervention arm had a different average FEV1 trajectory over one year.

**Precise language:** we model FEV1 as a linear function of time and treatment with patient-specific random intercepts; the `weeks:group` interaction estimates differential mean change per week between arms, conditional on covariates.

**Practice read:** is the modelled gap at 52 weeks clinically meaningful (MCID ~0.1 L in many COPD contexts)? Trajectory matters more than a single visit snapshot [@cazzola2008mcid].

### Worked example (CASTOR extension)

After `source("R/examples/ch18_longitudinal_mixed_models.R")`, the mixed model reports approximately:

| Term | Estimate (L or L/week) | Plain read |
|------|------------------------|------------|
| `weeks` | −0.0018 per week | Both arms decline slightly on average |
| `groupintervention` | −0.066 at week 0 | Level shift at baseline (should be ~0 in well-randomised trials) |
| `weeks:groupintervention` | +0.00054 per week | Intervention associated with **less decline** per week |
| `(1 \| patient_id)` | random intercept | Each patient has their own baseline FEV1 |

The **interaction** is the prespecified treatment effect when the estimand is *differential slope*. Over 52 weeks, the modelled extra gain is roughly \(0.00054 \times 52 \approx 0.03\) L: small in this synthetic run; always compare to MCID and CI, not only the point estimate.

**Sensitivity:** a cross-sectional `lm()` at week 52 alone gives a similar point estimate for the intervention effect (−0.051 L) but the **logic** differs: the mixed model uses all visits and models correlation. See `ch18_sensitivity_mixed_vs_fixed.csv`. If the cross-sectional SE were much smaller than the mixed-model SE, that would be a red flag for pseudo-replication; here they are similar because visit count is balanced.

```r
long <- readr::read_csv("data/longitudinal_spirometry.csv")
library(lme4)
fit <- lmer(
 fev1 ~ weeks * group + age + sex + smoking + (1 | patient_id),
 data = long
)
summary(fit)
```

### Technique: Random intercept and slope (extension)

| | |
|---|---|
| **Model** | `(weeks \| patient_id)` or `(1 + weeks \| patient_id)` |
| **When to add random slope** | Substantial heterogeneity in individual decline rates |
| **Cost** | More parameters; may not converge with few visits per person |
| **CASTOR note** | Four visits per patient is usually enough for random intercept only |

Use random slopes when biology suggests patients **differ in rate of decline**, not only baseline. With only four time points, start with random intercept; add slope only if prespecified and convergence is stable.

### Technique: GEE (population-averaged alternative)

| | |
|---|---|
| **Answers** | Marginal (population-average) effect of treatment on mean FEV1 trajectory |
| **R** | `geepack::geeglm(fev1 ~ weeks * group, id = patient_id, corstr = "exchangeable")` |
| **Contrast with mixed model** | Mixed model = conditional (subject-specific); GEE = marginal |
| **When to prefer GEE** | Robust SE focus; many subjects, few visits; explicit population estimand |

Both are valid; **do not mix estimands** in the same paper without stating which you target.

### Caveats box

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| Dropout / informative missingness | Sicker patients skip visits; complete-case trajectories can bias treatment effects |
| Unequal visit spacing | Irregular spirometry schedules need time variables in appropriate units |
| Learning / training effects | First post-baseline visit can differ from steady state |
| Non-linear decline | FEV1 decline may accelerate; consider splines (Ch 7) |
| Clustered centres | Patients nested in hospitals need centre random effects or robust SEs |
| Cross-sectional shortcut | Week-52 *t*-test ignores baseline and correlation |

### In practice

Week-52 t-tests on last observation carried forward still appear in extension studies. Mixed models or principled missing-data methods (Ch 20) are the defensible default when visits are scheduled.

### In practice (GEE vs mixed)

One analyst proposes GEE; another fits `lmer`. Both can be correct; they answer **slightly different estimands**. Ask: do we want **subject-specific** trajectories (mixed model) or **population-averaged** marginal effects (GEE)? For most COPD trial reports, either is acceptable if prespecified; do not swap after seeing results ([technique card below](#technique-mixed-models-vs-gee)).

### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| *t*-test at one visit only | Discards information; wrong SEs | Mixed model on all visits |
| Pooled visits as independent rows | Pseudo-replication | `(1 \| patient_id)` random intercept |
| Change score without baseline adjustment | Noisy; regression to mean | Mixed model or ANCOVA with baseline |
| Ignore dropout pattern | Biased if missingness relates to health | Compare attenders; Ch 20 sensitivity |
| Claim causal effect from observational trajectories | Confounding by indication | State associational estimand; Ch 21 |

### Catalog of wrong analyses (longitudinal FEV1)

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **Last observation carried forward** for dropouts | Fabricates stability | Model available data; discuss bias direction |
| **Per-visit ANOVA without patient** | Inflated *n* | Mixed model / GEE with patient cluster |
| **Plot spaghetti only, no model** | Descriptive only | Participant *n* + modelled trajectories |
| **Spline hunting** without prespecification | Overfit | Prespecify linear vs spline in protocol |

### Reporting template

> Longitudinal FEV1 (litres) was analysed in *n* = … participants contributing … visits (weeks 0, 12, 24, 52). We fitted a linear mixed model with random intercepts for patient: FEV1 ~ time × treatment + age + sex + smoking + (1\|patient). The estimated difference in slope (intervention − standard) was … L per week (95% CI …). Sensitivity analysis compared a cross-sectional model at week 52 only. Missing visits were …%.

**Results (CASTOR extension):** Among 160 participants (640 visits), mean FEV1 declined by approximately 0.0018 L per week in the standard arm (fixed effect for `weeks`). The intervention × time interaction was **0.00054 L per week** (95% CI −0.00015 to 0.00122), corresponding to a modelled **≈0.028 L** separation at week 52 under linearity. Spaghetti plots showed heterogeneous trajectories; population-level fitted means are in Figure.

---

## Decision table: which longitudinal method?

*Quick lookup. For **when** and **why**, see [Method choice at a glance](#method-choice-at-a-glance) above.*

| Situation | Primary method | Chapter |
|-----------|----------------|---------|
| RCT, continuous FEV1, 2+ visits | Mixed model, random intercept | This chapter |
| Population-average estimand explicit | GEE | This chapter §GEE |
| Single post-baseline visit only | ANCOVA with baseline FEV1 | Ch 5 |
| Time to first exacerbation | Survival model | Ch 19 |
| Informative dropout suspected | Mixed model + missing-data sensitivity | Ch 20 |
| Non-linear decline prespecified | Splines in `weeks` | Ch 7 |

---


## R lab

```r
source("R/00_setup.R")
source("R/examples/ch18_longitudinal_mixed_models.R")
```

![Ridge plot: FEV1 by visit week](../figures/ch18_fev1_ridge.png)

![Spaghetti plot: FEV1 trajectories by participant](../figures/ch18_spaghetti_fev1.png)

Each line is one participant. Use this plot to spot outliers, dropout, and whether a linear trend is plausible before trusting the mixed model.

### Figure hygiene: week-52 snapshot vs full trajectories

![Right vs wrong: longitudinal FEV1](../figures/viz_pair_ch18_longitudinal.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Boxplot at week 52 only | Earlier visits, dropout, heterogeneous slopes |
| **Right** | Spaghetti across scheduled visits |: (motivates mixed model / GEE) |

**Practice read:** a week-52 *t*-test figure should not be your only longitudinal slide if the estimand is change over time.

![Mixed model fitted population trajectories](../figures/ch18_mixed_model_fitted.png)

Fitted lines are **population-level** predictions (random effects set to zero), not individual patient forecasts.

**Tables:** `ch18_mixed_model_coefficients.csv`, `ch18_visit_counts_by_group.csv`, `ch18_sensitivity_mixed_vs_fixed.csv`

### Mini-lab: read the interaction

```r
coefs <- readr::read_csv(
 "volume-01/tables/ch18_mixed_model_coefficients.csv"
)
coefs %>% filter(term == "weeks:groupintervention")
```

Ask: if the interaction is positive, does intervention **slow** or **accelerate** decline relative to standard care?

### Mini-lab: week-52 shortcut vs mixed model

```r
sens <- readr::read_csv(
 "volume-01/tables/ch18_sensitivity_mixed_vs_fixed.csv"
)
sens
```

Compare `std.error` for `groupintervention` across models. Smaller SE in the cross-sectional model with stacked visits would suggest pseudo-replication.

---

## Technique: Mixed models vs GEE {#technique-mixed-models-vs-gee}

| | **Mixed model (random effects)** | **GEE** |
|---|---|---|
| **Answers** | Subject-specific trajectory; variance components | Population-averaged (marginal) effect |
| **Outcome** | Continuous FEV1 (Gaussian mixed); extensions for binary/count | Continuous, binary, count with working correlation |
| **Design** | Repeated measures; optional `(1 \| centre)` for multi-centre |
| **Assumptions** | Random effects distribution; MAR for likelihood-based inference | Mean model correct; robust SE with sandwich estimator |
| **Effect measure** | Fixed effect for time × treatment (conditional on random effects) | Same regression coefficients interpreted marginally |
| **R** | `lme4::lmer(fev1 ~ weeks * group + (1 \| patient_id))` | `geepack::geeglm(..., id = patient_id, corstr = "exchangeable")` |
| **Report** | Participant *n*, visits, random-effect structure, fixed effects + CI | Correlation structure chosen; robust SE; same estimand language |
| **Prefer mixed when** | Random slopes clinically meaningful; small number of clusters with random centre effects | |
| **Prefer GEE when** | Robustness to correlation misspecification matters; marginal estimand is target | Few clusters; need simple marginal interpretation |

**Plain language:** mixed models let each patient have their own baseline FEV1; GEE averages over patients with a chosen correlation pattern.

**Precise language:** mixed models are **conditional** (subject-specific); GEE coefficients are **marginal** (population-averaged); they can differ when the link is non-identity [@harrell2015rms].

**Practice read:** for a parallel-group trial with linear FEV1 trends, both usually give **similar direction**; prespecify one primary approach in the SAP.

#### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Stack visits in `lm()` without patient | Pseudo-replication | `(1 \| patient_id)` or GEE with `id` |
| Report only week-52 *t*-test | Discards visits | Mixed / GEE on all scheduled times |
| Switch from mixed to GEE after NS interaction | Analysis shopping | Prespecify; report sensitivity |

CASTOR script fits mixed models: `R/examples/ch18_longitudinal_mixed_models.R`. GEE sensitivity can use `geepack` on the same `longitudinal_spirometry.csv`.

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Marginal estimand, robust SE | **GEE** | [Mixed vs GEE](#technique-mixed-models-vs-gee) |
| Non-linear FEV1 decline | Splines in `weeks` | Prespecify knots |
| Clustered centres | `(1 \| centre)` or GEE | Multi-centre trials |
| Binary event over time | Survival model | [Ch 19](19-survival-analysis.md) |
| Informative dropout | Joint model / sensitivity | [Ch 20](20-missing-data.md) |

---

## Exercises ([Solutions](../solutions/ch18_solutions.md))

**E18.1** Why is independence violated with repeated FEV1?

**E18.2** What does `(1|patient_id)` represent?

**E18.3** When is a week-52 *t*-test misleading compared with a mixed model?

**E18.4** If `weeks:groupintervention` is positive, how do you describe the intervention effect on **slope**?

**E18.5** Mixed model vs GEE: which estimand is population-averaged?

**Applied**

1. Run `source("R/examples/ch18_longitudinal_mixed_models.R")`.
2. Interpret `weeks:groupintervention` from the coefficient table.
3. Compare `ch18_sensitivity_mixed_vs_fixed.csv`; which SE is smaller, and why is that suspicious?
4. From the spaghetti plot, would you prespecify a random slope? Why or why not?
5. Draft one Results sentence using the reporting template.

**Capstone:** [Case E in Ch 12](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation).

---

## Where this chapter leads

**Next:** [Chapter 19](19-survival-analysis.md) for time-to-exacerbation; [Chapter 20](20-missing-data.md) when dropout is informative.

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Fitzmaurice, Laird & Ware, *Applied Longitudinal Analysis* (mixed models / GEE)
