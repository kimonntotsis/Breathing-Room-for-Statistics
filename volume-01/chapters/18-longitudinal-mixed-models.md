# Chapter 18: Longitudinal data and mixed models

> **Part VIII: Longitudinal, survival, and causal inference**

## At a glance

| | |
|---|---|
| **Recurring dataset** | `data/longitudinal_spirometry.csv` ([CASTOR extension](../RECURRING_COHORT.md)) |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Question** | How does FEV1 change over time, and does treatment modify that trajectory? |
| **Core methods** | spaghetti plots, linear mixed models (`lmer`), random intercepts |
| **R** | `R/examples/ch18_longitudinal_mixed_models.R` |
| **Capstone link** | [Ch 12 Case E](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation) |

## Learning objectives

1. Recognise when repeated measures violate independence (Ch 4–5).
2. Fit a random-intercept mixed model for FEV1 trajectories.
3. Interpret `weeks × group` interaction as differential change over time.
4. Report participant-level *n*, visit structure, and sensitivity to cross-sectional shortcuts.

## Prerequisites

Chapters 4–5 (group comparisons, linear models); Ch 8 (reporting).

---

## Opening question (CASTOR extension)

*Does intervention slow FEV1 decline compared with standard care when each patient contributes four visits at weeks 0, 12, 24, and 52?*

A Welch *t*-test on week-52 FEV1 alone **throws away** within-person information and treats visits as independent. Mixed models keep all visits while accounting for correlation within patient [@harrell2015rms].

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

**Clinician read:** is the modelled gap at 52 weeks clinically meaningful (MCID ~0.1 L in many COPD contexts)? Trajectory matters more than a single visit snapshot.

### Caveats box

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| Dropout / informative missingness | Sicker patients skip visits; complete-case trajectories can bias treatment effects |
| Unequal visit spacing | Irregular spirometry schedules need time variables in appropriate units |
| Learning / training effects | First post-baseline visit can differ from steady state |
| Non-linear decline | FEV1 decline may accelerate; consider splines (Ch 7) |
| Clustered centres | Patients nested in hospitals need centre random effects or robust SEs |
| Cross-sectional shortcut | Week-52 *t*-test ignores baseline and correlation |

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

---

## R lab

```r
source("R/00_setup.R")
source("R/examples/ch18_longitudinal_mixed_models.R")
```

![Spaghetti plot: FEV1 trajectories by participant](../figures/ch18_spaghetti_fev1.png)

![Mixed model fitted population trajectories](../figures/ch18_mixed_model_fitted.png)

**Tables:** `ch18_mixed_model_coefficients.csv`, `ch18_visit_counts_by_group.csv`, `ch18_sensitivity_mixed_vs_fixed.csv`

### Mini-lab: GEE pointer

When the scientific focus is a population-averaged contrast rather than subject-specific trajectories, GEE (`geepack::geeglm`) is a common alternative. Mixed models estimate conditional (subject-specific) slopes; GEE estimates marginal effects — both are valid with different estimands.

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Non-linear FEV1 decline | Splines in `weeks` | Prespecify knots |
| Clustered centres | `(1 \| centre)` or GEE | Multi-centre trials |
| Binary event over time | Survival model | [Ch 19](19-survival-analysis.md) |
| Informative dropout | Joint model / sensitivity | [Ch 20](20-missing-data.md) |

---

## Exercises · [Solutions](../solutions/ch18_solutions.md)

**E18.1** Why is independence violated with repeated FEV1?

**E18.2** What does `(1|patient_id)` represent?

**E18.3** When is a week-52 *t*-test misleading compared with a mixed model?

**Applied**

1. Run `source("R/examples/ch18_longitudinal_mixed_models.R")`.
2. Interpret `weeks:groupintervention` from the coefficient table.
3. Compare `ch18_sensitivity_mixed_vs_fixed.csv` — which SE is smaller, and why is that suspicious?

**Capstone:** [Case E in Ch 12](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation).

---

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Fitzmaurice, Laird & Ware, *Applied Longitudinal Analysis* (mixed models / GEE)
