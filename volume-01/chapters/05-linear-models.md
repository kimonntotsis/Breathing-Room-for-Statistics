# Chapter 5: Linear Models for Continuous Respiratory Outcomes

> **Part III: Regression for Continuous Outcomes**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](../RECURRING_COHORT.md) - `data/spirometry.csv` |
| **Question type** | How is FEV1 associated with predictors, adjusted for others? |
| **Key methods** | SLR, MLR, interactions, ANCOVA, diagnostics, VIF |
| **R scripts** | `R/examples/ch05_linear_models.R` |
| **Figures** | residual diagnostics (`ch05_residual_diagnostics.png`), adjusted means (`ch05_fev1_by_smoking_adjusted.png`) |
| **Exercises** | [ch05](../exercises/ch05_exercises.md) |

**Also see:** [Appendix B § Step 5](../appendix-b-quick-reference.md), When *t*-test vs regression: [Ch 4 master table](../chapters/04-comparing-groups.md#master-decision-table)
---

## Learning objectives

1. Specify a linear model that matches the scientific question and estimand.
2. Interpret coefficients as adjusted mean differences or slopes.
3. Use dummy coding and interactions correctly.
4. Diagnose violations with residual plots, VIF, and influence.
5. Distinguish association from causation in observational spirometry data.
6. Write Methods and Results sentences for a regression paper.

## Prerequisites

Chapters 3-4.

---

## Why this chapter

Trials rarely stop at a raw mean difference; they adjust for baseline FEV1, centre, or stratification factors. Linear models are the workhorse for continuous lung function and for ANCOVA-style trial analysis. You need this chapter before interpreting “adjusted” results in papers.

## Opening question (CASTOR cohort)

*Among adults in the CASTOR cohort, is FEV1 lower in smokers after adjusting for age, sex, and height?*

A t-test compares smokers vs non-smokers on FEV1 alone. Regression estimates the **smoking effect while holding other factors fixed** - the estimand is an adjusted mean difference [@harrell2015rms].

---

## When linear regression is the right tool

| You have | You want | Use |
|----------|----------|-----|
| Continuous outcome (FEV1, FVC, 6MWD) | Adjusted association | Multiple linear regression |
| Continuous outcome + baseline | Trial follow-up comparison | ANCOVA |
| Continuous outcome, 2 groups, no covariates | Unadjusted comparison | t-test (Ch 4) - regression equivalent |
| Binary/count outcome | - | GLM (Ch 6) - **not** linear regression on 0/1 |

---

## Technique: Multiple linear regression (MLR)

### Technique card

| | |
|---|---|
| **Answers** | What is the adjusted association between predictors and mean continuous outcome? |
| **Outcome** | Continuous (FEV1 litres, change in FEV1, symptom score) |
| **Design** | Cross-sectional, trial follow-up (with care), cohort |
| **Data required** | Outcome + predictors; complete cases or planned imputation |
| **Assumptions** | Linear in parameters; independent errors; homoscedasticity; approximate normality of residuals (small n) [@harrell2015rms] |
| **Effect measure** | β = mean difference or slope; 95% CI |
| **R** | `lm(fev1 ~ smoking + age + sex + height_cm, data = spirometry)` |
| **When to use** | Multiple confounders; adjusted comparison; continuous outcome |
| **When NOT to use** | Binary/count outcome; repeated measures without extension; causal claims from observational data without design |
| **Does NOT prove** | Causal effect of smoking; prediction accuracy (use Ch 9); mechanism |

### Dual interpretation

**Plain language:** after accounting for age, sex, and height, smokers have lower average FEV1 by about 0.39 L.

**Precise language:** the coefficient for smoking is the expected difference in mean FEV1 between smokers and non-smokers with other covariates held fixed; inference assumes linear model and independent homoscedastic errors.

**Practice read:** is ~0.4 L a meaningful gap given MCID (~0.1 L in many COPD contexts)? Possibly - but this is observational; unmeasured confounding may remain [@cazzola2008mcid].

### Caveats box: MLR for FEV1

| Caveat | Why it matters |
|--------|----------------|
| **Association ≠ causation** | Smokers differ in many unmeasured ways |
| **Linearity** | FEV1 vs age is not always linear - consider splines |
| **Collinearity** | FEV1 and FVC together inflate SEs |
| **Extrapolation** | Do not predict outside observed age/height range |
| **One time point** | Cross-sectional model ≠ longitudinal decline | [Ch 18](18-longitudinal-mixed-models.md) |
| **% predicted vs litres** | Mixing units confounds interpretation |

### In practice

“Adjust for baseline FEV1” usually means ANCOVA, not change scores unless prespecified. Check whether baseline was measured pre-randomisation and whether missing baseline rows are excluded silently.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | `lm(exacerbation_12m ~ smoking)` on 0/1 outcome |
| **Why wrong** | Predictions outside [0,1]; wrong variance model |
| **Do instead** | Logistic regression (Ch 6) |

| | |
|---|---|
| **Mistake** | Drop non-significant covariates after fitting (stepwise) |
| **Why wrong** | Inflates type I error; biased coefficients for confirmatory inference |
| **Do instead** | Prespecify confounders (Ch 7) |

| | |
|---|---|
| **Mistake** | Say "smoking **causes** lower FEV1" from cross-sectional data |
| **Why wrong** | Design does not support causal language |
| **Do instead** | "Smoking was **associated with** lower FEV1 after adjustment…" |

### Reporting template

**Methods:**

> FEV1 (litres) was modelled with multiple linear regression adjusting for age (years), sex, and height (cm). Smoking was coded yes/no. We report regression coefficients with 95% confidence intervals. Residual diagnostics were examined. Analysis used R 4.x (lm).

**Results:**

> In 400 participants, smoking was associated with 0.39 L lower mean FEV1 (95% CI −0.47 to −0.32; p < 0.001) after adjustment for age, sex, and height. Residuals showed no major departures from linear model assumptions.

**Do not say:** "Smoking reduced FEV1" (causal); "$R^2 = 0.68$ proves good model" ($R^2$ is not primary evidence).

### R lab

```r
source("R/00_setup.R")
library(tidyverse)
library(broom)

spirometry <- read_csv("data/spirometry.csv", show_col_types = FALSE)
fit <- lm(fev1 ~ smoking + age + sex + height_cm, data = spirometry)
tidy(fit, conf.int = TRUE)
par(mfrow = c(2, 2)); plot(fit); par(mfrow = c(1, 1))
```

**Sensitivity:** log(FEV1) if distribution heavily skewed; spline on age:

```r
lm(
  fev1 ~ smoking + splines::ns(age, df = 3) + sex + height_cm,
  data = spirometry
)
```

---

## Technique: Simple linear regression (SLR)

One continuous predictor: `lm(fev1 ~ age, data = spirometry)`.

**β_age:** mean change in FEV1 per additional year.

Use SLR for bivariate exploration; prefer MLR when confounders matter (almost always in respiratory epidemiology).

---

## Dummy coding and reference categories

R default treatment contrasts: first level alphabetically is reference.

```r
spirometry$sex <- factor(spirometry$sex)  # reference: female
# sexmale coefficient = mean difference male vs female
```

**Always state reference category** in tables and text.

---

## Interactions

`fev1 ~ smoking * age` - smoking effect **varies by age**.

**Plain language:** the FEV1 gap between smokers and non-smokers may be larger in older patients.

**Report:** stratified coefficients or marginal effects - not only the interaction p-value.

```r
fit_int <- lm(fev1 ~ smoking * age + sex + height_cm, data = spirometry)
anova(
  lm(fev1 ~ smoking + age + sex + height_cm, data = spirometry),
  fit_int
)
```

---

## ANCOVA: follow-up FEV1 adjusting baseline

See [Chapter 4](04-comparing-groups.md) for trial context.

```r
trial <- read_csv("data/spirometry_trial.csv", show_col_types = FALSE)
lm(fev1_followup ~ group + fev1_baseline + age + sex, data = trial)
```

**Estimand choice:** follow-up adjusted for baseline vs change score - prespecify in protocol.

### Caveats: ANCOVA

| Caveat | Detail |
|--------|--------|
| Regression to the mean | Extreme baseline values pull follow-up toward mean |
| Balanced RCT | ANCOVA adds precision; unadjusted comparison also valid if prespecified |
| Same spirometry protocol | Pre/post BD must match |

---

## Model diagnostics (required)

| Plot / test | Checks |
|-------------|--------|
| Residuals vs fitted | Linearity, homoscedasticity |
| Q-Q plot | Normality of residuals |
| Scale-location | Heteroscedasticity |
| Cook's distance | Influential points |

```r
plot(cooks.distance(fit), type = "h", main = "Cook's distance")
```

Investigate data errors before removing points. One patient with FEV1 = 0.1 L may be entry error.

---

## Multicollinearity (VIF)

When predictors correlate strongly (FEV1 model with FVC and FEV1/FVC):

```r
car::vif(fit)  # values > 5–10 warrant attention
```

**Fix:** drop redundant predictors, combine, or use ridge (prediction context, Ch 7).

---

## CASTOR worked example: full narrative

**Question:** Is smoking associated with lower FEV1 after adjustment?

**Steps:**

1. Table 1 by smoking (Ch 3)  
2. Fit `lm(fev1 ~ smoking + age + sex + height_cm)`  
3. Check residuals  
4. Report β_smoking with CI  
5. Contextualize with MCID  

**Three-reader summary:**

- **Statistician:** adjusted mean difference −0.39 L (95% CI −0.47 to −0.32); model assumptions reasonable.  
- **Practice:** ~400 mL lower FEV1 in smokers - clinically substantial if causal; observational design limits causal claim.  
- **General reader:** smokers in this dataset have notably lower lung function even after accounting for age, sex, and height.

---

## What linear regression does NOT do

- Model binary exacerbations (Ch 6)  
- Handle repeated FEV1 visits ([Ch 18](18-longitudinal-mixed-models.md) mixed models)  
- Prove smoking **caused** lower FEV1 in observational data  
- Automatically select important predictors (Ch 7 - prespecification)

---


## R lab

```r
source("R/examples/ch05_linear_models.R")
```

---

## Alternatives & extensions (choose by data)

Linear regression (Gaussian errors) is the default for continuous outcomes, but many respiratory endpoints push you to variants.

### Continuous outcome but strong skew (e.g., biomarker concentration)

| Option | When to use | Note |
|---|---|---|
| **Transform outcome** (log) | Multiplicative variability; positive skew | Changes estimand; report on original scale if needed |
| **Gamma regression** (GLM) | Positive continuous with mean-variance link | Often better than forcing normality |
| **Quantile regression** | Median (or other quantiles) is the estimand | Robust to outliers; different interpretation |

### Outliers or heavy tails

| Option | When to use | Note |
|---|---|---|
| **Robust regression** | Outliers expected; want slope resistant to leverage | Sensitivity, not a magic fix |
| **Winsorization / trimming** | Clear artefacts; documented rule | Must be prespecified for confirmatory work |

### Clear nonlinearity

| Option | When to use | Note |
|---|---|---|
| **Splines / GAM** | Curvature in age-FEV1 or exposure-response | Prespecify df/smoothness; avoid p-hacking |

### Design requires Ch 18–19

| Feature | Why lm() fails | What to use |
|---|---|---|
| Repeated FEV1 visits | correlated residuals | [Ch 18](18-longitudinal-mixed-models.md) mixed models / GEE |
| Multi-centre clustering | SEs too small if ignored | [Ch 18](18-longitudinal-mixed-models.md) cluster-robust / mixed |

## Chapter summary

- Linear regression answers **adjusted** questions about continuous outcomes [@harrell2015rms].
- Every coefficient needs a reference category or unit definition.
- Diagnostics and caveats are part of the analysis, not optional extras.
- Report coefficients + CI; avoid causal language without design support.

## Where this chapter leads

**Next:** Non-Gaussian outcomes → [Chapter 6](06-generalized-linear-models.md). Model selection and penalization → [Chapter 7](07-model-building.md). Reporting → [Chapter 8](08-validation-reporting.md).

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]  
- Venables & Ripley, *Modern Applied Statistics with S* [@venables2002modern]

## Exercises ([Solutions](../solutions/ch05_solutions.md))

**Next:** [Chapter 6 - GLMs](06-generalized-linear-models.md)
