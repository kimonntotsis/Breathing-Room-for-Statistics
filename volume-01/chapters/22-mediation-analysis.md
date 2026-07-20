# Chapter 22: Mediation analysis

> **Part VIII: Longitudinal, survival, and causal inference**

## Opening scene: "Is it mediated by FEV₁?"

Smoking associates with exacerbation; FEV₁ sits on the path. A PI asks how much is **direct** vs **through** lung function. Mediation decomposes associational paths; not mechanistic proof, when prespecified and interpreted with humility.

---

## Why this chapter

Mediation answers a specific estimand question. CASTOR closes the volume here: total, direct, and indirect language tied to bootstrap CIs, and explicit limits on causal reading. Lower FEV1 % is a plausible **mechanism** linking smoking to exacerbation in COPD, but not the only one (airway inflammation, colonisation, adherence). A mediation analysis quantifies association through **one measured mediator**, not the full biology. Mediation requires **three no-confounding** structures (exposure–mediator, exposure–outcome, mediator–outcome) and correct **temporal ordering**. CASTOR `exacerbation.csv` is a **single time-point teaching snapshot**, treat results as **illustrative**, not as proof that smoking causes exacerbations through FEV1. If the indirect effect is small and the direct path dominates, policy discussion may still focus on total smoking burden rather than lung-function pathways alone.

> **Consult a statistician when:** mediation will support mechanism claims, policy decomposition, or sensitivity to unmeasured mediator–outcome confounding. This chapter teaches **one-mediator bootstrap workflow**; not causal mediation theory in full.

---

## The mediation workflow

1. **Estimand**: total, direct, indirect, or proportion mediated?
2. **DAG**: draw smoking → FEV1 % → exacerbation; list confounders **not** on the path.
3. **Timing**: mediator measured before outcome window (defend in protocol).
4. **Models**: mediator model (M ~ A + C); outcome model (Y ~ A + M + C).
5. **Effects**: bootstrap natural indirect/direct effects on the **probability scale**; treat total vs direct ORs as **descriptive** only (ORs are non-collapsible).
6. **Sensitivity**: unmeasured confounding of mediator–outcome link; avoid causal verbs without design support.

---

## Total vs direct vs indirect (plain language)

### Descriptive, model-based, and causal mediation

| Layer | What it claims | CASTOR teaching |
|-------|----------------|-----------------|
| **Descriptive mediation** | Paths and coefficients describe associations in fitted models | Total vs direct OR contrast (with non-collapsibility warning) |
| **Model-based mediation** | Bootstrap ACME/ADE under stated regression models | `mediation::mediate()` probability-scale effects |
| **Causal mediation** | Interventional decomposition under cross-world assumptions | **Not established** in cross-sectional CASTOR; requires temporal design + sensitivity |

The phrase *“mediation decomposes associational paths”* is safer than claiming mechanism proof. Natural direct and indirect effects depend on **strong identification assumptions** listed below; bootstrapping does **not** fix violations.

| Estimand | Model includes FEV1 %? | Smoking coefficient means | CASTOR teaching OR |
|----------|------------------------|---------------------------|--------------------|
| **Total effect** | No | Combined effect through all paths | **2.11** (0.73 to 7.00) |
| **Direct effect** | Yes | Effect not through measured FEV1 % | **1.33** (0.42 to 4.68) |
| **Indirect effect** | Derived | Effect through FEV1 % path | ACME **0.018** probability difference (bootstrap) |

The shift from total OR (**2.11**) to direct OR (**1.33**) after adjusting FEV1 % is **not** evidence of mediation by itself: odds ratios are **non-collapsible**, so an OR can change after adding covariates even without a mediator on the path [@vanderweele2015explanation]. **Formal** decomposition uses bootstrap **ACME** (natural indirect effect) and **ADE** (natural direct effect) on the **probability scale** when the outcome is logistic [@imai2010identification; @tingley2014mediation]. Report ACME/ADE and CIs; use total vs direct ORs only as **illustrative** contrasts with explicit non-collapsibility warning.

---

## Confounders in mediation models

Adjust the **same prespecified confounder set** in **both** the mediator and outcome models unless the DAG says otherwise.

| Variable | Role in CASTOR path | Include in M and Y models? |
|----------|---------------------|----------------------------|
| **Age** | Confounder | Yes |
| **Sex** | Confounder | Yes |
| **Prior exacerbations** | Confounder (severity) | Yes |
| **FEV1 %** | Mediator | Outcome model only (not mediator model) |
| **Therapy** | Possible confounder / collider | Prespecify; not in teaching script |

**Never** adjust a **collider** or a **mediator–outcome confounder affected by smoking** without DAG guidance (Ch 21).

---

## Technique: Path models and natural effects (CASTOR)

Path models with natural effects ask how much of the smoking–exacerbation association is consistent with a path through FEV1 % predicted. Exposure (A) is smoking; mediator (M) is FEV1 % predicted; outcome (Y) is 12-month exacerbation; confounders (C) are age, sex, and prior exacerbations. Fit a linear mediator model and logistic outcome model, then bootstrap natural effects with `mediation::mediate(..., boot = TRUE)`. Use when a mechanism hypothesis is prespecified and the mediator precedes the outcome; not for exploratory mediator fishing or reverse causation. Does not prove smoking **causes** exacerbation through FEV1; biology is multi-path.

In the teaching run, the **total** smoking OR is **2.11**; adjusting FEV1 % moves the OR to **1.33**; bootstrap **ACME** is **0.018** on the **probability scale** (average difference in predicted P(exacerbation); 95% bootstrap interval **0.001 to 0.044**). Do not report ACME/ADE as log-odds effects when `mediation::mediate()` is used with a logistic outcome. If your steering committee cares about **total public-health burden of smoking**, report the total-effect model. If the scientific question is **lung-function pathway**, prespecify mediation and report ACME/ADE with sensitivity analysis.

### Worked example (CASTOR)

From `ch22_total_vs_direct_or.csv` and `ch22_mediation_effects.csv`:

| Quantity | Estimate | 95% interval | *p* (bootstrap / model) |
|----------|----------|--------------|-------------------------|
| Total OR (no FEV1 %) | 2.11 | 0.73 to 7.00 | 0.19 |
| Direct OR (with FEV1 %) | 1.33 | 0.42 to 4.68 | 0.63 |
| ACME (indirect, probability scale) | 0.018 | 0.001 to 0.044 | 0.02 |
| ADE (direct, probability scale) | 0.011 | −0.024 to 0.046 | 0.63 |
| Total effect (probability scale) | 0.033 | −0.010 to 0.073 | 0.15 |

Path coefficients (`ch22_path_coefficients.csv`): smoking lowers FEV1 % (a path ≈ **−8.5** percentage points); lower FEV1 % raises exacerbation odds (b path OR ≈ **0.95** per 1 % unit on the logistic scale after exponentiation).

### Identification assumptions (must be visible in Methods)

| Assumption | Respiratory example if violated |
|------------|--------------------------------|
| **No unmeasured exposure–outcome confounding** | Residual confounding (adherence, SES) |
| **No unmeasured exposure–mediator confounding** | Factors affecting both smoking and FEV1 |
| **No unmeasured mediator–outcome confounding** | Severity beyond prior exacerbations |
| **No exposure-induced mediator–outcome confounder** | Smoking worsens inflammation that affects both FEV1 and exacerbation |
| **Correct temporal ordering** | Mediator precedes outcome window |
| **Appropriate model specification** | Linear mediator + logistic outcome is a teaching choice |
| **Consistency and positivity** | Well-defined exposure and mediator levels |

Bootstrapping addresses **sampling uncertainty** only; it does not address violated identification assumptions.

### Caveats box

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| **Cross-sectional snapshot** | FEV1 % and 12-month exacerbation in one row do not prove temporal order |
| **Single mediator** | Inflammation, adherence, and infections are unmeasured parallel paths |
| **No unmeasured mediator–outcome confounding** | Severity may affect both FEV1 and exacerbation beyond prior counts |
| **Non-collapsible ORs** | Total vs direct OR difference ≠ proof of mediation | Report bootstrap ACME/ADE on probability scale |
| **Nonlinear GLM** | Product-of-coefficients shortcuts fail; use simulation/bootstrap (`mediate`) |
| **Rare events / separation** | Unstable logistic fits; check events per cell |
| **Proportion mediated** | Can be unstable when total effect is near zero; interpret cautiously |

### Wrong analysis ⚠

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Adjust for FEV1 % and report smoking OR as **total effect** | Conditioning on mediator | Total-effect model without mediator; or `mediate()` | Total vs direct labelled |
| OR change after adding mediator = proof of mediation | Non-collapsible ORs | Bootstrap ACME/ADE on probability scale | ACME CI, not OR shift alone |

### Wrong analysis ⚠ (Baron–Kenny ritual)

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Require all four Baron–Kenny steps significant | Outdated; low power on paths | Bootstrap natural effects | Indirect effect CI |
| Causal mechanism claim from cross-sectional snapshot | Timing not established | Longitudinal design + sensitivity | Associational decomposition only |

> **Extended catalogue:** [Appendix R — Chapters 20–22](../appendix-r-wrong-analysis-catalog.md#chapter-20-22).

### Reporting template

**Methods (mediation paragraph)**

> We prespecified a mediation analysis of smoking on 12-month exacerbation with FEV1 % predicted as mediator and adjustment for age, sex, and prior exacerbations. The mediator model was linear (FEV1 % ~ smoking + covariates). The outcome model was logistic (exacerbation ~ smoking + FEV1 % + covariates). We report the total-effect odds ratio (outcome model without mediator), the direct-effect odds ratio (outcome model with mediator), and bootstrap natural indirect (ACME) and direct (ADE) effects as **average differences in predicted probability** (**2000** bootstrap draws, `set.seed(20260628)`) using the `mediation` package [@tingley2014mediation]. Cross-sectional CASTOR data provide an associational decomposition under stated no-unmeasured-confounding assumptions; causal interpretation requires stronger design.

**Results (one sentence)**

> The total smoking OR was 2.11 (95% CI 0.73 to 7.00); adjusting FEV1 % yielded a direct OR of 1.33 (0.42 to 4.68). The bootstrap natural indirect effect (ACME) was 0.018 on the probability scale (95% CI 0.001 to 0.044).

**Limitations**

> Single-mediator, single-time-point snapshot; unmeasured severity and inflammatory pathways may confound the mediator–outcome relation.

---

## In practice

Sponsor question: *“Does smoking drive exacerbations through lung function?”*
Answer in two sentences: (1) name the estimand (indirect via FEV1 %); (2) show total vs direct ORs **and** bootstrap ACME with CI. Do not upgrade to causal language unless the protocol prespecified mediation and sensitivity analyses.

---

## Before you open R

- **Estimand:** natural indirect and direct effects of smoking on 12-month exacerbation through FEV1 % predicted.
- **Unit:** patient (`exacerbation.csv`).
- **Confounders:** age, sex, prior exacerbations in **both** models.
- **Sensitivity:** compare total vs direct ORs; discuss cross-sectional limits.

---

## R lab

```r
source("R/00_setup.R")
source("R/examples/ch22_mediation.R")
```

### Path diagram

![Mediation path: smoking, FEV1 %, exacerbation](../figures/ch22_mediation_path.png)

### Figure hygiene: total vs direct estimand

![Right vs wrong: mediation estimand](../figures/viz_pair_ch22_mediation.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Direct OR labeled “total smoking effect” | That FEV1 adjustment changed the estimand |
| **Right** | Total vs direct OR comparison | Whether indirect bootstrap CI excludes zero |

### Natural effects and OR comparison

![Natural effects on probability scale](../figures/ch22_mediation_effects.png)

![Total vs direct smoking OR](../figures/ch22_total_vs_direct_or.png)

**Tables:** `ch22_path_coefficients.csv`, `ch22_total_vs_direct_or.csv`, `ch22_mediation_effects.csv`

### Core code (excerpt)

```r
library(tidyverse)
library(mediation)

exac <- readr::read_csv("data/exacerbation.csv") %>%
  mutate(smoking_num = as.integer(smoking), sex = factor(sex))

fit_m <- lm(
  fev1_percent_predicted ~ smoking_num + age + sex + prior_exacerbations,
  data = exac
)

fit_y <- glm(
  exacerbation_12m ~ smoking_num + fev1_percent_predicted +
    age + sex + prior_exacerbations,
  data = exac,
  family = binomial()
)

fit_total <- glm(
  exacerbation_12m ~ smoking_num + age + sex + prior_exacerbations,
  data = exac,
  family = binomial()
)

set.seed(20260628)
med_out <- mediate(
  fit_m, fit_y,
  treat = "smoking_num",
  mediator = "fev1_percent_predicted",
  boot = TRUE, sims = 2000
)
summary(med_out)
```

### Mini-lab: sensitivity pointer

When reviewers worry about unmeasured confounding of the FEV1 % → exacerbation link, report **sensitivity parameters** (how strong an unmeasured confounder would need to be to nullify ACME). See VanderWeele [-@vanderweele2015explanation] and package `mediation` sensitivity functions for advanced workflows.

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Longitudinal mediator | Latent growth or cross-lagged models | Time ordering explicit |
| Time-to-event outcome | Survival mediation extensions | Rare events; specialist software |
| Multiple mediators | Multivariate mediation | Prespecify paths |
| Binary mediator | Logistic mediator model | Different `mediate` setup |
| RCT of smoking cessation | Stronger causal mediation | Randomised exposure helps |
| Observational COPD | Sensitivity analysis | Default for CASTOR teaching |

---

## Quick reference: methods in this chapter

| Method | When to use | Why |
|--------|-------------|-----|
| **Total effect model (omit mediator)** | Policy or exposure effect including all paths | Smoking OR without FEV1 % in the model |
| **Direct effect model (adjust mediator)** | Effect **not through** measured mediator | Smoking OR with FEV1 % in the model |
| **Product-of-coefficients (Baron–Kenny style)** | Teaching decomposition; continuous mediator on linear scale | Quick a×b intuition; fragile with GLMs |
| **Natural effects (`mediate`)** | Prespecified binary exposure, continuous mediator, binary outcome | Bootstrap ACME, ADE, total on **probability scale** (logistic outcome) |
| **Causal mediation with sensitivity** | Reviewer asks about unmeasured mediator–outcome confounding | VanderWeele sensitivity parameters |
| **Do not run mediation** | Cross-sectional snapshot; mediator measured after outcome | Temporal order unclear; estimand not defensible |
| **Do not adjust mediator for total effect** | Total smoking impact is the question | Blocks part of the causal path ([Ch 21](21-causal-inference.md)) |

**Extensions:** longitudinal mediators, competing risks, and time-varying treatments in [Alternatives & extensions](#alternatives--extensions).

---


## Exercises ([Solutions](../solutions/ch22_solutions.md))

**E22.1** What is the difference between total and direct effect of smoking on exacerbation?

**E22.2** Why must age and prior exacerbations appear in **both** mediator and outcome models here?

**E22.3** What does ACME quantify in this chapter's path diagram?

**E22.4** Why is proportion mediated unstable when the total effect is near zero?

**E22.5** Give one reason CASTOR cross-sectional data limit causal mediation claims.

**Applied**

1. Run `source("R/examples/ch22_mediation.R")`.
2. Compare total vs direct ORs in `ch22_total_vs_direct_or.csv`.
3. Read ACME and ADE in `ch22_mediation_effects.csv`.
4. From `ch22_path_coefficients.csv`, interpret the smoking coefficient in the mediator model.
5. Write a one-paragraph Results section using the reporting template.

**Capstone link:** Case B logistic model vs this chapter's explicit decomposition.

---

## Where we go next

You have completed the extended causal path (Ch 18–22). Return to [Chapter 12](12-case-studies.md) for integrated case discussions, [Chapter 21](21-causal-inference.md) for IPW and DAGs without mediation, or Appendix B for day-to-day method choice.

{{< include ../_includes/chapter-see-also.md >}}

**Near neighbors:** Ch [21](chapters/21-causal-inference.md) · Ch [12](chapters/12-case-studies.md)

## Further reading

- VanderWeele, *Explanation in Causal Inference* [@vanderweele2015explanation]
- Imai, Keele, and Tingley on causal mediation [@imai2010identification; @tingley2014mediation]
- Hernán & Robins, *Causal Inference: What If* [@hernan2020whatif]
