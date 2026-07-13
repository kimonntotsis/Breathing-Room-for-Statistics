# Chapter 6: Generalized Linear Models

> **Part III: Regression for Non-Continuous Outcomes**

## At a glance

| | |
|---|---|
| **Question type** | What factors are associated with binary/count outcomes? |
| **Recurring cohort** | [CASTOR](../RECURRING_COHORT.md) |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Key methods** | Logistic, Firth, log-binomial, Poisson, NB, zero-inflated, offset |
| **R scripts** | `R/examples/ch06_glm.R` |
| **Figures** | logistic forest (`ch06_logistic_forest.png`), Poisson RR (`ch06_poisson_rate_ratio.png`); **figure hygiene:** `viz_pair_ch06_forest.png` |
| **Exercises** | [Chapter 6 exercises](../exercises/ch06_exercises.md) |

**Also see:** [Appendix B § Step 3-5](../appendix-b-quick-reference.md), [Decision table](#decision-table-which-glm)

> **Sounds like your lab?** [Story 3](../appendix-k-in-the-room-stories.md#story-3--the-excel-lm-on-01-exacerbation) (`lm()` on 0/1 exacerbation) → [Binary outcomes: logistic regression](#binary-outcomes-logistic-regression).

---

## Investigator path (≈20 min)

You do not need this entire chapter on first pass. Read in order:

1. [Clinical and biostatistics notes](#clinical-and-biostatistics-notes) — OR vs RR, binary vs count, varying follow-up
2. [Opening question](#opening-question) — confirm the outcome is binary or count, not continuous
3. [Method choice at a glance](#method-choice-at-a-glance) — pick logistic, Poisson, or NB
4. [Worked example: exacerbation logistic model](#worked-example-exacerbation-logistic-model) — Practice read and reporting pattern
5. [Catalog of wrong analyses](#catalog-of-wrong-analyses-glm-chapter) — especially `lm()` on 0/1 outcomes

**Analyst read:** technique cards, GLM framework, R lab, and extensions in the sections below.

---

## Method choice at a glance

| Method | When to use | Why |
|--------|-------------|-----|
| **Logistic regression** | Binary outcome (exacerbation Y/N); adjust covariates | Correct variance for 0/1; OR or predicted risks + CI |
| **Firth penalized logistic** | Sparse events; separation (coefficients → ∞) | Stabilises MLE when tables are sparse |
| **Log-binomial / modified Poisson** | Common binary outcome; want **risk ratio** | OR overstates when events are frequent |
| **Poisson GLM** | Count exacerbations; equal follow-up | Models event counts; check overdispersion |
| **Poisson + offset(log person-time)** | Count outcomes; **varying** follow-up | Converts counts to rates; required when exposure time differs |
| **Negative binomial** | Count data; variance >> mean (overdispersion) | Default sensitivity to Poisson |
| **Zero-inflated Poisson/NB** | Excess zeros beyond sampling | Separates “structural zero” from count process |
| **Ordinal logistic** | Ordered categories (mMRC 0–4, CAT bands) | Respects ordering; not `lm()` on 0–4 |
| **GEE / mixed logistic** | Clustered binary (centres, wards) | Correlated outcomes need cluster-aware SEs ([Ch 18](18-longitudinal-mixed-models.md)) |

**Extensions** (hurdle models, complementary log-log): [Alternatives & extensions](#alternatives--extensions-choose-by-outcome-nuance) at chapter end.

---

## Learning objectives

1. Explain the three components of a GLM (distribution, link, linear predictor).
2. Fit and interpret logistic regression for binary respiratory endpoints.
3. Distinguish odds ratios from risk ratios and when each matters.
4. Model exacerbation counts with Poisson and negative binomial regression.
5. Use offsets for varying follow-up time.
6. Compute adjusted predictions and recognize separation/overdispersion issues.

## Prerequisites

- [Chapter 4](04-comparing-groups.md) - comparing proportions
- [Chapter 5](05-linear-models.md) - linear predictor, confounding

---

## Why this chapter

Exacerbation yes/no, exacerbation counts, and ordinal symptoms do not belong on a Gaussian model. GLMs are where CASTOR’s binary and count endpoints live. If your outcome is 0/1 or a small non-negative integer, you are in this chapter.

## Opening question

*Among COPD patients, is smoking associated with at least one exacerbation in 12 months after adjusting for age, lung function, and prior history?*

The outcome is **binary**. Fitting `lm(exacerbation ~ ...)` predicts values outside [0,1] and wrong variance structure. We need a **GLM** [@hosmer2013applied].

We continue with **[CASTOR](../RECURRING_COHORT.md)** - `data/exacerbation.csv`.

---

## Clinical and biostatistics notes

**Clinical:** **Odds ratios** mislead when exacerbations are common: prefer risk difference, RR, or predicted risks. Prior exacerbation history is clinically dominant. Observational smoking associations are not causal without design.

**Biostatistics:** Check **events per variable** in logistic models. Default to **negative binomial** when Poisson shows overdispersion. Use **offset(log person-time)** when follow-up varies. Use **Firth** when separation or sparse events destabilise MLE.

**Clinical nuance:** "any exacerbation" (binary) and "exacerbations per year" (count) answer different questions: do not swap models for convenience.

**Biostat nuance:** `glm(..., family = binomial)` is the minimum correct model for 0/1 outcomes; `lm()` on binary Y remains a common submission error.

---

## GLM framework

A GLM assumes:

$$
g(\mu) = \eta = \beta_0 + \beta_1 X_1 + \cdots + \beta_p X_p
$$

where $\mu = E(Y)$ and $g$ is the **link function**.

| Component | Role |
|-----------|------|
| **Random component** | Distribution of Y (binomial, Poisson, …) |
| **Systematic component** | Linear predictor η |
| **Link** | Connects μ to η |

Estimation: **maximum likelihood** (iteratively reweighted least squares for many GLMs) [@venables2002modern].

---

## Binary outcomes: logistic regression

### Technique: Logistic regression

| | |
|---|---|
| **Answers** | How is binary outcome associated with predictors on log-odds scale? |
| **Outcome** | Binary (0/1, TRUE/FALSE) |
| **Link** | logit: log(p/(1−p)) |
| **Effect measure** | Odds ratio = exp(β) |
| **R** | `glm(y ~ x, family = binomial)` |
| **Report** | OR, 95% CI, n, number of events |
| **Avoid when** | Outcome is count; data clustered; interpreting OR as RR when outcome common |

**Plain language:** smoking multiplies the odds of exacerbation by exp(β), holding other variables fixed.

**Precise language:** under the model, a one-unit increase in X adds β to the log-odds of Y=1 [@hosmer2013applied].

```r
logit_fit <- glm(
  exacerbation_12m ~ smoking + age +
    fev1_percent_predicted + prior_exacerbations,
  data = exac,
  family = binomial
)
broom::tidy(logit_fit, conf.int = TRUE, exponentiate = TRUE)
```

#### Dual interpretation (CASTOR)

**Plain language:** after adjusting for age, lung function, and past flare-ups, prior exacerbations are linked to higher odds of another event in 12 months.

**Precise language:** adjusted odds ratio for prior_exacerbations = exp(β); conditions on other linear predictors; assumes logit link and independent observations.

**Practice read:** history of exacerbations is among the strongest predictors - consistent with clinical practice. OR is not the same as "X% more likely" unless events are rare.

#### Caveats box: logistic regression

| Caveat | Why it matters |
|--------|----------------|
| **OR ≠ RR** when events common | Overstates relative risk |
| **Low events (CASTOR ~18/350)** | Unstable estimates; wide CIs; consider Firth [@firth1993bias] |
| **EPV** | ~18/4 ≈ 4.5 events per variable - below ideal 10-15 |
| **Observational** | Smoking-exacerbation not causal without design |
| **No clustering** | Patients at same centre may correlate |
| **Linear on logit scale** | May miss nonlinear age effects - splines |

### In practice

Exacerbation counts of 0, 1, 2, 3 dominate COPD cohorts. Poisson will look fine in R and fail on overdispersion. Always check observed vs fitted counts and consider negative binomial before trusting the rate ratio.

### In practice (ordinal symptoms)

mMRC dyspnoea (0–4) and CAT scores are **ordered categories**, not continuous measurements. A coefficient from `lm(mMRC ~ treatment)` implies equal spacing between “slightly breathless” and “housebound.” Use ordinal logistic regression ([technique below](#technique-ordinal-logistic-regression-mmrccat)) or report medians with ordinal-aware comparisons.

### In practice (common events)

When exacerbation rates exceed ~10–15%, odds ratios from logistic regression exaggerate relative to risk ratios. Ask for **risk differences** or log-binomial **rate ratios** for the practice read.

### Other respiratory settings

Logistic and Poisson models in CASTOR target **COPD exacerbations**. The model family follows the outcome type; the event definition follows the protocol:

- **Asthma:** Severe exacerbations (steroid bursts, ED visits) are often **counts**; mMRC and ACQ need **ordinal** methods (above), not linear regression on 0–4 scores.
- **TB:** Culture conversion, smear clearance, or death during treatment are typical endpoints. Use Ch 6 count models or Ch 19 survival with those definitions; spirometry is usually secondary.

Report absolute risks or rate differences when events are common.

#### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | `lm(exacerbation_12m ~ smoking)` |
| **Why wrong** | Linear model for binary Y |
| **Do instead** | `glm(..., family = binomial)` |

| | |
|---|---|
| **Mistake** | Report OR as "smokers have 30% higher risk" |
| **Why wrong** | OR ≠ risk difference; misstates scale |
| **Do instead** | Marginal predicted risks via `emmeans`; or log-binomial RR |

| | |
|---|---|
| **Mistake** | Stepwise selection of 20 predictors with 18 events |
| **Why wrong** | Massive overfitting; invalid p-values |
| **Do instead** | Prespecify confounders; penalized methods for prediction |

#### Reporting template

**Methods:** Logistic regression modelled 12-month exacerbation (yes/no) adjusting for smoking, age, FEV1 % predicted, and prior exacerbation count. We report odds ratios with 95% CIs (Wald). Model fit assessed by event count and residual deviance.

**Results:** Among 350 patients (18 events), prior exacerbations were associated with higher odds of a new event (OR 1.70, 95% CI 1.12 to 2.59). FEV1 % predicted OR 0.95 per 1% (95% CI 0.91 to 0.99). Smoking OR imprecise (95% CI included 1).

**Do not say:** "Smoking causes exacerbation" (observational); "logistic proved prediction model" (use Ch 9 metrics).

### Odds vs risk

| | Odds ratio | Risk ratio |
|---|------------|------------|
| **Scale** | Odds | Probability |
| **Common in** | Case-control, logistic output | Cohort, trials |
| **Approximation** | OR ≈ RR when outcome rare (<10%) | Exact for cohort |

When events are common, OR exaggerates RR. Consider log-binomial or reporting **marginal** adjusted risks (`marginaleffects`, `emmeans`).

```r
# Adjusted predicted probabilities by smoking (conceptual)
if (requireNamespace("emmeans", quietly = TRUE)) {
  emmeans::emmeans(logit_fit, ~ smoking, type = "response")
}
```

---

## Separation and sparse data: Firth penalized logistic

### Technique: Firth penalized logistic

| | |
|---|---|
| **Answers** | Stable OR estimates when MLE diverges (separation, sparse events) |
| **CASTOR trigger** | ~18 events / 350 - wide CIs; separation possible in subgroups |
| **R** | `logistf::logistf(...)` |
| **Effect measure** | OR (penalized) |
| **When to use** | Complete/quasi separation; small event counts |
| **Does NOT prove** | Stronger evidence - estimates are biased low |

When a predictor perfectly predicts outcome in a category (**complete separation**), MLE coefficients diverge.

```r
logistf::logistf(
  exacerbation_12m ~ smoking + age +
    fev1_percent_predicted + prior_exacerbations,
  data = exac
)
```

#### Dual interpretation

**Plain language:** Firth gives finite ORs when ordinary logistic "blows up."

**Precise language:** Jeffreys-prior penalized likelihood; reduces bias in small samples at cost of slight shrinkage.

#### Caveats box

| Caveat | Detail |
|--------|--------|
| Penalization | State in Methods |
| Still low EPV | Does not create information from 18 events |
| Not for prediction | Use calibration/AUC separately (Ch 9) |

#### Wrong analysis ⚠

Report Firth OR with narrow causal language and no event count.

#### Reporting template

**Methods:** Firth penalized logistic regression was used due to sparse events (n events = …).

---

## Log-binomial regression: direct risk ratios

### Technique: Log-binomial GLM

| | |
|---|---|
| **Answers** | Adjusted **risk ratio** (not odds ratio) |
| **Link** | log |
| **R** | `glm(y ~ x, family = binomial(link = "log"))` |
| **When to use** | Cohort/trial; outcome common (>10%) |
| **Problem** | Convergence failures → modified Poisson + robust SE |

```r
glm(
  exacerbation_12m ~ smoking + age,
  data = exac,
  family = binomial(link = "log")
)
```

#### Dual interpretation

**Plain language:** smokers have RR × exp(β) times the risk of exacerbation, adjusted.

**Practice read:** RR often closer to "percent increase in risk" than OR when events common.

#### Caveats box

| Caveat | Detail |
|--------|--------|
| Convergence | May need Poisson trick with robust variance |
| Bounded | Predicted risks must stay ≤ 1 |
| vs logistic | OR easier to fit; RR more interpretable |

#### Wrong analysis ⚠

Report logistic OR as RR when 30% event rate → log-binomial or marginal RD.

#### Reporting template

**Results:** Adjusted RR for smoking = … (95% CI …) from log-binomial model.

| Model | Effect measure | When |
|-------|----------------|------|
| Logistic | OR | Rare outcome; case-control |
| Log-binomial | RR | Cohort/trial, common outcome |
| Marginal predictions | RD | Absolute risk for steering committees |

### Technique: Probit regression

| | |
|---|---|
| **Answers** | Same as logistic on latent scale |
| **Link** | probit |
| **R** | `family = binomial(link = "probit")` |
| **Use when** | Field standard; latent variable interpretation |

Probit and logistic usually rank predictors similarly; coefficients not directly comparable across links.

#### Caveats

Interpretation less intuitive than OR for many readers.

---

## Count outcomes: Poisson regression

### Technique: Poisson GLM

| | |
|---|---|
| **Answers** | How do rates of count outcomes change with predictors? |
| **Outcome** | Non-negative integer (exacerbations, ED visits) |
| **Link** | log |
| **Effect measure** | Rate ratio = exp(β) |
| **Assumption** | Mean = variance (equidispersion) |
| **R** | `glm(y ~ x, family = poisson)` |

```r
pois_fit <- glm(exacerbations_12m ~ smoking + ics_adherence,
                data = counts, family = poisson)
broom::tidy(pois_fit, conf.int = TRUE, exponentiate = TRUE)
```

#### Dual interpretation

**Plain language:** each unit increase in ICS adherence is associated with lower expected exacerbation counts (if rate ratio < 1).

**Precise language:** exp(β) multiplies expected count on multiplicative scale; assumes Poisson variance = mean [@cameron2013regression].

#### Caveats box: Poisson regression

| Caveat | Why it matters |
|--------|----------------|
| **Overdispersion** | Exacerbation counts often more variable than Poisson |
| **Equal follow-up** | Without offset, unequal person-time biases rates |
| **Zeros** | Many zero counts → consider ZIP/ZINB |
| **Rate vs count** | Model is for counts; interpret as rates only with offset |
| **Exposure window** | Exacerbation definition must match follow-up |

#### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | t-test on exacerbation counts |
| **Do instead** | Poisson / NB GLM |

| | |
|---|---|
| **Mistake** | Poisson without checking dispersion |
| **Do instead** | Check Pearson $\chi^2$/df; use NB if > 1 |

#### Reporting template

**Results:** In Poisson regression, ICS adherence was associated with lower exacerbation rate (rate ratio 0.28 per unit adherence scale, 95% CI …). Pearson dispersion 1.09 suggested mild overdispersion; negative binomial sensitivity gave similar inference.

![Poisson rate ratios (exacerbation counts)](../figures/ch06_poisson_rate_ratio.png)

Rate ratios belong on a multiplicative scale; pair with dispersion checks before signing off Poisson inference.

### Technique: Poisson offset (person-time)

| | |
|---|---|
| **Answers** | Rate per person-year when follow-up varies |
| **R** | `glm(... + offset(log(person_years)), family = poisson)` |
| **CASTOR data** | `exacerbation_counts.csv` includes `person_years` |
| **Does NOT** | Fix overdispersion alone |

When follow-up varies:

$$
\log(\mu_i) = \log(t_i) + \beta_0 + \beta_1 X_i
$$

```r
glm(
  exacerbations_12m ~ smoking + ics_adherence +
    offset(log(person_years)),
  data = counts,
  family = poisson
)
```

#### Dual interpretation

**Plain language:** models exacerbation **rate** accounting for different follow-up length.

#### Caveats

Offset must be log(person-time); zero follow-up invalid.

#### Wrong analysis ⚠

Compare total counts without standardizing for 6 vs 12 month follow-up.

---

## Overdispersion and alternatives

### Technique: Quasi-Poisson

| | |
|---|---|
| **Answers** | Scale SEs when variance > mean |
| **R** | `family = quasipoisson` |
| **Use** | Quick fix; not full generative model |

### Technique: Negative binomial (NB)

| | |
|---|---|
| **Answers** | Count regression with extra dispersion parameter |
| **R** | `MASS::glm.nb(...)` |
| **When to use** | Overdispersed exacerbation counts (default over Poisson) |
| **Effect measure** | Rate ratio = exp(β) |

```r
MASS::glm.nb(exacerbations_12m ~ smoking + ics_adherence, data = counts)
```

#### Dual interpretation

**Plain language:** allows exacerbation counts to vary more than Poisson expects [@hilbe2011nb].

**Precise language:** gamma mixing distribution adds overdispersion parameter θ.

#### Caveats box

| Caveat | Detail |
|--------|--------|
| Still need offset | If follow-up varies |
| Zeros | NB may still miss excess zeros → ZI models |
| Interpretation | Rate ratios similar to Poisson |

#### Wrong analysis ⚠

Poisson p-values when dispersion = 1.09+ without sensitivity NB → anti-conservative inference.

#### Reporting template

**Results:** NB rate ratio for smoking = … (95% CI …). Poisson sensitivity similar; Pearson dispersion 1.09.

### Technique: Zero-inflated Poisson (ZIP) / ZINB

| | |
|---|---|
| **Answers** | Separate "structural zeros" from count process |
| **R** | `pscl::zeroinfl(count ~ x | x)` |
| **Data** | `exacerbation_zero_inflated.csv` |
| **Use** | Excess zeros beyond Poisson/NB |
| **Does NOT prove** | "Never exacerbator" phenotype without validation |

```r
pscl::zeroinfl(exacerbations_12m ~ smoking | smoking, data = counts_zi)
```

#### Dual interpretation

**Plain language:** some patients never exacerbate (zero-inflation), others follow count model.

#### Caveats

Identifiability problems; exploratory; validate clinically.

#### Wrong analysis ⚠

Label ZIP clusters as validated COPD phenotypes from one dataset.

---

## Model comparison for GLMs

Nested models: **likelihood ratio test**

```r
anova(reduced_model, full_model, test = "Chisq")
```

Non-nested: **AIC/BIC** - predictive/in-sample comparison, not formal test.

---

## Goodness of fit

| Context | Tool |
|---------|------|
| Inference | Residual deviance, Pearson $\chi^2$, careful interpretation |
| Prediction | Calibration plot, Brier score (Ch 9) |
| Count | Check overdispersion; compare Poisson vs NB |

**Hosmer-Lemeshow** for logistic calibration - useful but sensitive to group choice; prefer calibration plots for prediction.

---

## Decision table: which GLM?

*Quick lookup. For **when** and **why**, see [Method choice at a glance](#method-choice-at-a-glance) above.*

| Outcome | First choice | If problem |
|---------|--------------|------------|
| Binary | Logistic | Separation → Firth; common outcome → consider RR model |
| Count, equal follow-up | Poisson | Overdispersion → NB or quasi |
| Count, varying follow-up | Poisson + offset | Overdispersion → NB + offset |
| Ordinal (mMRC 0-4) | Ordinal logistic (Vol II) | - |

See [appendix-b-quick-reference.md](../appendix-b-quick-reference.md) for the full outcome → model table.

![Logistic regression forest plot](../figures/ch06_logistic_forest.png)

Odds ratios above 1 increase odds of the outcome; check CIs that cross 1 and whether OR language matches the clinical estimand (risk vs odds).

### Figure hygiene: forest plot vs OR bars

![Right vs wrong: adjusted odds ratios](../figures/viz_pair_ch06_forest.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | OR point estimates as bars | 95% CI, null at OR = 1, log-scale context |
| **Right** | Forest plot with horizontal CIs | — (matches Methods/Results table) |

**Practice read:** would you rank “strongest predictor” from the wrong panel? Forest plots force uncertainty into the slide.

---

## Worked example: exacerbation logistic model

**Estimand:** Adjusted odds ratio for smoking and 12-month exacerbation.  
**Model:** `exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations`  
**Interpretation template:**

> After adjustment, prior exacerbations were associated with higher odds of a new event (OR 1.70, 95% CI 1.12 to 2.59). A 1-unit increase in prior count is not necessarily one extra event - verify coding. FEV1 % predicted showed association (OR 0.95 per 1% increase). Smoking OR was imprecise in this sample.

Always state **event count and n**.

**Sensitivity analyses to report:**

1. Firth logistic if separation / sparse events  
2. Log-binomial if OR would mislead (common outcome)  
3. NB instead of Poisson if overdispersed  
4. Marginal risks for practice reporting (`emmeans`)

---

## Catalog of wrong analyses (GLM chapter)

| # | Wrong | Right |
|---|-------|-------|
| 1 | Linear regression on 0/1 outcome | Logistic |
| 2 | OR as RR in common outcomes | Log-binomial or marginal RD |
| 3 | Poisson ignoring person-time | Offset log(person-years) |
| 4 | Ignore overdispersion | Quasi-Poisson / NB |
| 5 | Causal claim from adjusted logistic | Associative language + design limits |
| 6 | 50 predictors, 20 events | Penalized / reduce predictors |

---


## R lab

```r
source("R/examples/ch06_glm.R")
```

Covers: logistic, probit, Firth (`logistf`), log-binomial, Poisson with offset, quasi-Poisson, negative binomial, zero-inflated (`pscl`), LRT, emmeans.

---

## Pitfalls

1. OR interpreted as RR when events are common.
2. Poisson without offset when follow-up varies.
3. Ignoring overdispersion → false precision.
4. Causal language from observational logistic models.
5. Reporting model without number of events.

---

## Technique: Ordinal logistic regression (mMRC/CAT) {#technique-ordinal-logistic-regression-mmrccat}

| | |
|---|---|
| **Answers** | Is treatment associated with **higher or lower ordered** symptom category? |
| **Outcome** | Ordinal (mMRC 0–4, CAT bands, Likert scales) |
| **Design** | Cross-sectional or single visit; extensions for repeated ordinal → mixed ordinal (advanced) |
| **Assumptions** | Proportional odds (parallel slopes across categories); check with Brant test / sensitivity |
| **Effect measure** | Odds ratio per unit increase (proportional odds model) or cumulative OR |
| **R** | `MASS::polr(ordered_factor ~ predictors, Hess = TRUE)` or `ordinal` package |
| **Report** | OR + 95% CI; state proportional-odds assumption; median category by arm as descriptive |
| **Avoid when** | Treating 0–4 as continuous (`lm`); collapsing to binary without prespecification |

**Plain language:** mMRC 3 is worse than 2, but not necessarily “one unit” on a lung-function scale; model **order**, not distance.

**Precise language:** proportional odds logistic model estimates cumulative log-odds of being in category *j* or below [@agresti2018introduction].

**Practice read:** “OR 1.4 per mMRC point” is hard to interpret clinically; pair with **proportions in each category** or median shift.

#### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Linear regression on mMRC 0–4 | Equal spacing assumed | Ordinal logistic or nonparametric comparison |
| Collapse mMRC to binary “≥2” without protocol | Changes estimand | Prespecify threshold or use full ordinal model |

#### Reporting template

**Methods:** mMRC (0–4) was modelled as an ordered factor using proportional odds logistic regression, adjusting for … Proportional odds was assessed with …

**Results:** Adjusted OR for treatment = … (95% CI …) per one-category increase in mMRC. Distribution by arm: [table of category counts].

---

## Alternatives & extensions (choose by outcome nuance)

### Binary outcomes: link and estimand alternatives

| Goal / nuance | Alternative | Why / note |
|---|---|---|
| Want **risk ratio** (not OR) | Log-binomial or modified Poisson | OR can mislead when outcome common |
| Need absolute risks | Marginal risks / risk differences | Often easier to interpret than OR alone |
| Complementary hazard-type interpretation | complementary log-log link | [Ch 19](19-survival-analysis.md) |
| Clustered binary outcomes | GEE / mixed logistic | [Ch 18](18-longitudinal-mixed-models.md) |

### Count outcomes: beyond Poisson/NB

| Data pattern | Alternative | Why / note |
|---|---|---|
| Only patients with ≥1 event included | Zero-truncated Poisson/NB | Selection changes likelihood |
| Two processes (any event vs number of events) | Hurdle model | Separates “ever” from “how many” |
| High exposure heterogeneity | Offset + interaction / stratification | Person-time is essential |

### Model family beyond GLM (Ch 18–19)

| Outcome | Why GLM may be wrong | Handbook chapter |
|---|---|---|
| Ordinal (mMRC 0-4) | ordered categories | [Ordinal logistic](#technique-ordinal-logistic-regression-mmrccat) (this chapter) |
| Time-to-event | censoring | [Ch 19](19-survival-analysis.md) survival analysis |
| Repeated counts over time | correlation + time trends | [Ch 18](18-longitudinal-mixed-models.md) mixed models / GEE |

## Chapter summary

- GLMs extend regression to binary and count outcomes via link functions.
- Logistic → odds ratios; Poisson/NB → rate ratios.
- Check overdispersion; use offsets for person-time.
- Separation and sparse events need special handling.

## Exercises

[Chapter 6 exercises](../exercises/ch06_exercises.md); [Solutions](../solutions/ch06_solutions.md)

## Where this chapter leads

**Next:** [Chapter 7](07-model-building.md) for selection and LASSO; [Chapter 8](08-validation-reporting.md) for reporting ORs and rate ratios with intervals. Time-to-event endpoints → [Chapter 19](19-survival-analysis.md).

## Further reading

- Agresti, *An Introduction to Categorical Data Analysis* [@agresti2018introduction]  
- Hosmer, Lemeshow & Sturdivant, *Applied Logistic Regression* [@hosmer2013applied]  
- Hilbe, *Modeling Count Data* [@hilbe2014count]  
- Cameron & Trivedi, *Regression Analysis of Count Data* [@cameron2013regression]
- TRIPOD statement for prediction models using binary outcomes.

**Next:** [Chapter 7 - Model Building](07-model-building.md)
