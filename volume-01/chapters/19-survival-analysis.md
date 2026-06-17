# Chapter 19: Survival analysis and time-to-event outcomes

> **Part VIII: Longitudinal, survival, and causal inference**

## At a glance

| | |
|---|---|
| **Recurring dataset** | `data/time_to_exacerbation.csv` ([CASTOR extension](../RECURRING_COHORT.md)) |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Question** | Who reaches first exacerbation sooner, accounting for censoring? |
| **Core methods** | Kaplan–Meier, log-rank test, Cox proportional hazards |
| **R** | `R/examples/ch19_survival_analysis.R` |
| **Capstone link** | [Ch 12 Case E](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation) |

## Learning objectives

1. Define event, time origin, and censoring for respiratory endpoints.
2. Plot and compare survival curves (Kaplan–Meier) with log-rank tests.
3. Fit and interpret Cox hazard ratios with 95% CI and check proportional hazards.
4. Avoid treating censored patients as permanently event-free.

## Prerequisites

Chapters 4, 6 (rates and GLM intuition); Ch 8 (reporting).

---

## Opening question (CASTOR extension)

*Among adults with COPD-style risk profiles, does smoking shorten time to **first** exacerbation within one year of follow-up?*

Binary “any exacerbation Y/N” at 12 months discards **when** events occur and how follow-up differs. Survival methods use all follow-up time until event or censoring [@harrell2015rms].

---

## Technique: Kaplan–Meier and Cox proportional hazards

### Technique card (Kaplan–Meier)

| | |
|---|---|
| **Answers** | What fraction remain event-free over time, by group? |
| **Outcome** | `Surv(time, event)` — time to first exacerbation |
| **Effect measure** | Survival probabilities at prespecified times; median survival (if estimable) |
| **R** | `survival::survfit(Surv(time_days, event) ~ smoking, data)` |
| **Comparison** | Log-rank test (`survdiff`) |
| **Does NOT prove** | Causation; adjusted confounding control |

### Technique card (Cox PH)

| | |
|---|---|
| **Answers** | Instantaneous hazard of first exacerbation, adjusted for covariates |
| **Outcome** | `Surv(time_days, event)` |
| **Effect measure** | Hazard ratio (HR) with 95% CI |
| **R** | `coxph(Surv(time_days, event) ~ smoking + fev1_pct + therapy + age, data)` |
| **Assumptions** | Proportional hazards (test with `cox.zph`); independent censoring |
| **When to use** | Time-to-first-event with right censoring |
| **When NOT to use** | Competing events (death) without competing-risks model |
| **Does NOT prove** | Causation; absolute risk without extra reporting |

### Dual interpretation

**Plain language:** smokers tended to reach their first exacerbation sooner during follow-up; the adjusted hazard was higher for smokers.

**Precise language:** the Cox model estimates hazard ratios as multiplicative shifts in the instantaneous event rate, holding other covariates fixed, under proportional hazards and independent censoring.

**Clinician read:** HR > 1 for smoking means higher **rate** of first exacerbation, not necessarily a specific absolute risk difference — report events and person-time.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Censoring assumed independent | Informative dropout biases HRs |
| Proportional hazards | HR interpretation fails if hazards cross |
| Sparse events | HRs unstable; report event counts |
| Competing risk of death | First exacerbation model mis-specified |
| Calendar time vs study time | Define time origin clearly (enrolment vs diagnosis) |
| HR ≠ risk difference | Common with frequent events |

### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Logistic regression ignoring follow-up time | Discards when events occur | Cox or KM |
| Treat censored subjects as “no event ever” | Understates event rate | Censor at last follow-up |
| HR reported without events / *n* | Uninterpretable precision | Events per arm + person-time |
| Ignore PH assumption | Misleading adjusted HRs | `cox.zph` diagnostic |
| Use survival for recurrent events without extension | Multiple events per patient | Recurrent-event models (advanced) |

### Catalog of wrong analyses (time-to-exacerbation)

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **Fixed 12-month binary endpoint only** | Loses timing information | KM + Cox on time-to-event |
| **Exclude early censoring** | Selection bias | Intention-to-follow-up population |
| **Unadjusted KM in RCT** | Ignores randomisation balance | Pre-specified covariate adjustment in Cox |
| **Present HR as “% risk reduction”** without context | Misleading with frequent events | HR + absolute risks or NNT if appropriate |

### Reporting template

> The primary endpoint was time to first moderate-to-severe exacerbation. Patients were followed from enrolment to event or administrative censoring at 365 days. Kaplan–Meier curves compared smokers and non-smokers (log-rank *p* = …). A Cox proportional hazards model adjusted for FEV1 % predicted, therapy class, and age. The adjusted hazard ratio for smoking was … (95% CI …). There were *n* events among *N* patients (…% censored). Proportional hazards was assessed with Schoenfeld residuals (*p* = …).

---

## R lab

```r
source("R/00_setup.R")
source("R/examples/ch19_survival_analysis.R")
```

![Kaplan–Meier curves by smoking status](../figures/ch19_km_by_smoking.png)

![Cox model hazard ratios](../figures/ch19_cox_forest.png)

**Tables:** `ch19_events_by_smoking.csv`, `ch19_cox_hazard_ratios.csv`, `ch19_cox_ph_test.csv`

### Mini-lab: absolute risk at 12 months

After fitting KM, extract survival at 365 days for each smoking group and report absolute risk difference alongside HR — clinicians often need both.

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Competing risk (death) | Fine–Gray subdistribution | Future expansion |
| Recurrent exacerbations | Andersen–Gill / PWP | Not first-event Cox |
| Non-proportional hazards | Stratified Cox, splines | Check `cox.zph` |
| Discrete time | Complementary log-log | Links to Ch 6 |

---

## Exercises · [Solutions](../solutions/ch19_solutions.md)

**E19.1** What does censoring mean at 365 days without an event?

**E19.2** When is a hazard ratio misleading for clinicians?

**E19.3** What does a log-rank test compare?

**Applied**

1. Run `source("R/examples/ch19_survival_analysis.R")`.
2. Report smoking HR from `ch19_cox_hazard_ratios.csv`.
3. Read `ch19_cox_ph_test.csv` — is proportional hazards plausible in this teaching run?

**Capstone:** [Case E in Ch 12](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation).

---

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Therneau & Grambsch, *Modeling Survival Data* (Cox models, diagnostics)
