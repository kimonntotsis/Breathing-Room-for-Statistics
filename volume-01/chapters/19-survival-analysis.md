# Chapter 19: Survival analysis and time-to-event outcomes

> **Part VIII: Longitudinal, survival, and causal inference**

## At a glance

| | |
|---|---|
| **Recurring dataset** | `data/time_to_exacerbation.csv` ([CASTOR extension](../RECURRING_COHORT.md)) |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Question** | Who reaches first exacerbation sooner, accounting for censoring? |
| **Core methods** | Kaplan-Meier, log-rank test, Cox proportional hazards |
| **R** | `R/examples/ch19_survival_analysis.R` |
| **Figures** | KM by smoking (`ch19_km_by_smoking.png`), Cox forest (`ch19_cox_forest.png`) |
| **Exercises** | [Chapter 19 exercises](../exercises/ch19_exercises.md) |

**Also see:** [Ch 6](06-generalized-linear-models.md) (rates), [Ch 18](18-longitudinal-mixed-models.md), [Ch 12 Case E](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation)

---

## In this chapter

1. [Clinical and biostatistics notes](#clinical-and-biostatistics-notes): event, censoring, competing death
2. [Method choice at a glance](#method-choice-at-a-glance): KM vs Cox vs logistic shortcut
3. [Technique: Kaplan-Meier](#technique-kaplan-meier): Practice read on absolute risks
4. [Reporting template](#reporting-template): events, person-time, HR + CI
5. [Catalog of wrong analyses](#catalog-of-wrong-analyses-time-to-exacerbation): censoring treated as cure

**Analyst read:** Cox diagnostics, R lab, competing risks below.

---

## Method choice at a glance

| Method | When to use | Why |
|--------|-------------|-----|
| **Kaplan-Meier + log-rank** | Compare time-to-first-event curves between groups | Uses all follow-up; handles censoring nonparametrically |
| **Cox proportional hazards** | Adjust for covariates; report hazard ratios | Standard for time-to-event with censoring; check PH assumption |
| **Logistic at fixed horizon (12 mo)** | Equal follow-up; only care about event Y/N at one date | Simpler; loses timing information |
| **Fine–Gray / competing risks** | Death prevents future exacerbations; mortality differs by arm | Standard Cox censors death; may overstate event risk |
| **Cause-specific Cox** | Distinct biological processes for competing events | Separates hazard of each event type |
| **Stratified Cox** | Non-proportional hazards across subgroups | When PH fails for a covariate |
| **Andersen-Gill / PWP** | **Recurrent** exacerbations (not first event only) | First-event Cox is wrong for repeats |

**Extensions:** [Alternatives & extensions](#alternatives--extensions) at chapter end.

---

## Learning objectives

1. Define event, time origin, and censoring for respiratory endpoints.
2. Choose survival methods over binary endpoints when timing matters.
3. Plot and compare survival curves (Kaplan-Meier) with log-rank tests.
4. Fit and interpret Cox hazard ratios with 95% CI and check proportional hazards.
5. Report event counts, person-time, and absolute risks alongside HRs.
6. Avoid treating censored patients as permanently event-free.

## Prerequisites

Chapters 4, 6 (rates and GLM intuition); Ch 8 (reporting).

---

*The steering slide shows 12-month exacerbation proportions: 18% vs 22%. A statistician asks for dates of first event and censoring. The export has them. **This chapter** is why “any exacerbation Y/N” and “time to first exacerbation” are different estimands.*

## Why this chapter

Sponsors often ask “exacerbation yes/no at 12 months” when dates of event and censoring are already in the database. Survival methods use follow-up time properly. This chapter also teaches when a hazard ratio is not enough on its own.

### Other respiratory settings

CASTOR uses time to **first COPD exacerbation** with one-year censoring. The same Kaplan-Meier and Cox workflow applies when the event is redefined:

- **Asthma:** Time to first severe exacerbation or first oral steroid course (match the protocol definition).
- **TB:** Time to culture conversion or treatment completion; deaths and loss to follow-up may need competing-risk methods in programme trials.

Report event counts, censoring reasons, and absolute risks at fixed times, not hazard ratios alone.

## Opening question (CASTOR extension)

*Among adults with similar respiratory risk profiles, does smoking shorten time to **first** exacerbation within one year of follow-up?*

Binary “any exacerbation Y/N” at 12 months discards **when** events occur and how follow-up differs. Survival methods use all follow-up time until event or censoring [@harrell2015rms].

In the CASTOR extension cohort, **52 of 320** patients have a first exacerbation within 365 days; the remainder are censored at one year. That event rate is enough to teach the methods but still requires careful reporting (sparse events → wide CIs).

---

## The survival workflow

1. **Define the event**: first moderate-to-severe exacerbation? hospitalisation? death?
2. **Time origin**: randomisation, enrolment, or first maintenance therapy?
3. **Censoring rule**: administrative cut-off (365 d), loss to follow-up, competing events?
4. **Describe follow-up**: KM curves by group; event table with *n* and % censored.
5. **Model**: Cox PH with prespecified covariates; test proportional hazards.
6. **Report**: HR + CI + events per arm + absolute risk at clinically relevant times.

---

## Core definitions (respiratory examples)

| Concept | COPD trial example | Common mistake |
|---------|-------------------|----------------|
| **Event** | First protocol-defined exacerbation | Counting recurrent events in first-event Cox |
| **Time** | Days from randomisation to event | Mixing calendar year with study day |
| **Censoring** | No event by day 365 | Coding censored patients as “no exacerbation ever” |
| **Risk set** | Patients event-free just before time *t* | Including patients after their event |
| **Hazard** | Instantaneous event rate given event-free so far | Calling hazard the same as 12-month risk |

---

## Technique: Kaplan-Meier

### Technique card

| | |
|---|---|
| **Answers** | What fraction remain event-free over time, by group? |
| **Outcome** | `Surv(time, event)`, time to first exacerbation |
| **Effect measure** | Survival probabilities at prespecified times; median survival (if estimable) |
| **R** | `survival::survfit(Surv(time_days, event) ~ smoking, data)` |
| **Comparison** | Log-rank test (`survdiff`) |
| **When to use** | Visual comparison; unadjusted survival curves; absolute risk extraction |
| **When NOT to use** | Adjusted confounding control (use Cox) |
| **Does NOT prove** | Causation; adjusted confounding control |

### Dual interpretation

**Plain language:** the curve shows the fraction of patients who had not yet had a first exacerbation at each day of follow-up.

**Precise language:** Kaplan-Meier estimates the survival function \(S(t) = P(T > t)\) with right-censored data using the product-limit estimator.

**Practice read:** read off event-free probability at 6 and 12 months; compare arms visually before trusting a single *p*-value.

### Worked example (CASTOR extension)

Event table from `ch19_events_by_smoking.csv`:

| Smoking | *n* | Events | Censored |
|---------|-----|--------|----------|
| No | 195 | 24 | 171 |
| Yes | 125 | 28 | 97 |

Smokers have more events in a smaller group → higher event rate. Log-rank *p* ≈ 0.017 in the teaching run. The KM plot y-axis is **zoomed** to the observed range so separation is visible; with ~16% events overall, a full 0–100% axis would look nearly flat.

```r
library(survival)
surv <- readr::read_csv("data/time_to_exacerbation.csv")
fit_km <- survfit(Surv(time_days, event) ~ smoking, data = surv)
summary(fit_km, times = c(180, 365))
```

---

## Technique: Cox proportional hazards

### Technique card

| | |
|---|---|
| **Answers** | Instantaneous hazard of first exacerbation, adjusted for covariates |
| **Outcome** | `Surv(time_days, event)` |
| **Effect measure** | Hazard ratio (HR) with 95% CI |
| **R** | `coxph(Surv(time_days, event) ~ smoking + fev1_pct + therapy + age, data)` |
| **Assumptions** | Proportional hazards (test with `cox.zph`); independent censoring |
| **When to use** | Time-to-first-event with right censoring; adjusted comparisons |
| **When NOT to use** | Competing events (death) without competing-risks model |
| **Does NOT prove** | Causation; absolute risk without extra reporting |

### Dual interpretation

**Plain language:** smokers tended to reach their first exacerbation sooner during follow-up; the adjusted hazard was higher for smokers.

**Precise language:** the Cox model estimates hazard ratios as multiplicative shifts in the instantaneous event rate, holding other covariates fixed, under proportional hazards and independent censoring.

**Practice read:** HR > 1 for smoking means higher **rate** of first exacerbation, not necessarily a specific absolute risk difference. Report events and person-time.

### Worked example (CASTOR extension)

From `ch19_cox_hazard_ratios.csv` (approximate teaching run):

| Covariate | HR (95% CI) | Read |
|-----------|-------------|------|
| Smoking | 1.69 (0.97 to 2.97) | Higher hazard; CI includes 1 |
| FEV1 % pred | 0.98 (0.95 to 1.00) per % | Lower FEV1 → higher hazard (HR < 1 per unit increase) |

The smoking HR is **associational** in this observational extension. Wide CI reflects sparse events. Always pair with the event table above.

```r
fit_cox <- coxph(
 Surv(time_days, event) ~ smoking +
 fev1_percent_predicted + therapy + age,
 data = surv
)
summary(fit_cox)
cox.zph(fit_cox) # proportional hazards check
```

### Kaplan-Meier vs Cox vs logistic

| Method | Uses timing? | Adjusts covariates? | Output |
|--------|--------------|---------------------|--------|
| Logistic (12-month Y/N) | No | Yes | OR |
| Kaplan-Meier | Yes | No (unadjusted curves) | Survival % |
| Cox PH | Yes | Yes | HR |

If follow-up is equal and censoring is independent, a 12-month logistic model and Cox model often agree **directionally**, but Cox uses the full timeline.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Censoring assumed independent | Informative dropout biases HRs |
| Proportional hazards | HR interpretation fails if hazards cross |
| Sparse events | HRs unstable; report event counts |
| Competing risk of death | First exacerbation model mis-specified |
| Calendar time vs study time | Define time origin clearly (enrolment vs diagnosis) |
| HR ≠ risk difference | Common with frequent events |

### In practice

Censored patients are not “event-free forever.” Administrative censoring at 365 days must appear in the Methods; person-time and event counts belong in Results alongside any hazard ratio.

### In practice (competing risk of death)

In severe COPD, **death prevents future exacerbations**. Standard Cox for “first exacerbation” treats death as censored; which can **overstate** exacerbation risk. If mortality differs by arm, discuss competing risk explicitly; consider cause-specific hazard models or Fine–Gray subdistribution hazards for cumulative incidence ([Alternatives below](#technique-competing-risks-death-vs-exacerbation)).

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
| **Cox for first exacerbation; death coded as censored** | Death competes with exacerbation | Competing-risk model or cause-specific Cox ([below](#technique-competing-risks-death-vs-exacerbation)) |

### Reporting template

> The primary endpoint was time to first moderate-to-severe exacerbation. Patients were followed from enrolment to event or administrative censoring at 365 days. Kaplan-Meier curves compared smokers and non-smokers (log-rank *p* = …). A Cox proportional hazards model adjusted for FEV1 % predicted, therapy class, and age. The adjusted hazard ratio for smoking was … (95% CI …). There were *n* events among *N* patients (…% censored). Proportional hazards was assessed with Schoenfeld residuals (*p* = …).

---


## R lab

```r
source("R/00_setup.R")
source("R/examples/ch19_survival_analysis.R")
```

![Kaplan-Meier curves by smoking status](../figures/ch19_km_by_smoking.png)

The y-axis is zoomed to the observed event-free range so curve separation is visible; with only ~50 events in 320 patients a full 0–100% scale would look nearly flat.

### Figure hygiene: event bar vs Kaplan-Meier

![Right vs wrong: time to exacerbation](../figures/viz_pair_ch19_survival.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Bar chart of ever/never event % | When events occur; censored follow-up |
| **Right** | KM curve with time on *x* |: (censoring explicit on step plot) |

**Practice read:** treating censored patients as “no event” inflates the wrong bar; KM keeps them on the risk set until censoring.

![Cox model hazard ratios](../figures/ch19_cox_forest.png)

Hazard ratios compare instantaneous event rates between groups holding covariates fixed; translate to absolute risks if the trial team will act on the result.

**Tables:** `ch19_events_by_smoking.csv`, `ch19_cox_hazard_ratios.csv`, `ch19_cox_ph_test.csv`

### Mini-lab: absolute risk at 12 months

Trial teams often need absolute risks, not only HRs.

```r
library(survival)
surv <- readr::read_csv("data/time_to_exacerbation.csv")
fit <- survfit(Surv(time_days, event) ~ smoking, data = surv)
summary(fit, times = 365)
# Event-free probability at 365 d:
# 1 - S(365) ≈ cumulative event probability
```

Report absolute risk difference between groups at 365 days alongside the smoking HR.

### Mini-lab: proportional hazards

```r
ph <- readr::read_csv("volume-01/tables/ch19_cox_ph_test.csv")
ph
```

If global *p* is small, consider stratified Cox or time-varying coefficients (advanced). In teaching data, PH may hold approximately.

---

## Technique: Competing risks (death vs exacerbation) {#technique-competing-risks-death-vs-exacerbation}

| | |
|---|---|
| **Answers** | What is the cumulative incidence of exacerbation when **death** is a competing event? |
| **Outcome** | Time to first exacerbation **or** death (whichever first) |
| **Design** | Observational cohort or trial with non-negligible mortality |
| **Assumptions** | Competing events defined; censoring independent conditional on covariates |
| **Methods** | **Cause-specific Cox** (hazard of exacerbation among those still alive); **Fine–Gray** subdistribution HR (cumulative incidence); **Cumulative incidence functions (CIF)** by group |
| **R** | `cmprsk` (Fine–Gray); `survival` cause-specific Cox; `riskRegression` (advanced) |
| **Report** | State whether standard Cox or competing-risk framework; CIF plots; event counts by type |
| **Avoid when** | Mortality <1% and balanced; standard Cox may suffice with sensitivity note |

**Plain language:** patients who die cannot have later exacerbations; treating death as “lost to follow-up” distorts exacerbation rates.

**Precise language:** standard Cox estimates **hazard of exacerbation** among survivors; Fine–Gray targets **subdistribution** relevant for prognosis when death competes [@harrell2015rms].

**Practice read:** ask for **cumulative incidence curves** by arm, not only hazard ratios, when death rates differ.

#### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Cox with death = censored | Overstates exacerbation in high-mortality arms | Competing-risk analysis or cause-specific hazard |
| Report HR without event types | Hides competing events | Table: exacerbations, deaths, censoring by arm |

#### Reporting template (competing risk sensitivity)

> Standard Cox models treated death as censoring. In sensitivity analyses accounting for death as a competing event, cumulative incidence of first exacerbation at 365 days was …% (intervention) vs …% (control) (Fine–Gray subdistribution HR …, 95% CI …). Event types are tabulated in Supplementary Table ….

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Competing risk (death) | Fine–Gray; cause-specific Cox; CIF | [Technique above](#technique-competing-risks-death-vs-exacerbation) |
| Recurrent exacerbations | Andersen-Gill / PWP | Not first-event Cox |
| Non-proportional hazards | Stratified Cox, splines | Check `cox.zph` |
| Discrete time | Complementary log-log | Links to [Ch 6](06-generalized-linear-models.md) |
| Equal follow-up, rare censoring | Logistic at fixed horizon | Simpler; loses timing detail |

---

## Exercises ([Solutions](../solutions/ch19_solutions.md))

**E19.1** What does censoring mean at 365 days without an event?

**E19.2** When is a hazard ratio misleading on its own?

**E19.3** What does a log-rank test compare?

**E19.4** Why report events per group in addition to HR?

**E19.5** When would you prefer Cox over 12-month logistic regression?

**Applied**

1. Run `source("R/examples/ch19_survival_analysis.R")`.
2. Report smoking HR from `ch19_cox_hazard_ratios.csv`.
3. Read `ch19_cox_ph_test.csv`: is proportional hazards plausible in this teaching run?
4. From the KM summary at 365 days, estimate absolute event risk by smoking group.
5. Draft a Results paragraph using the reporting template with CASTOR numbers.

**Capstone:** [Case E in Ch 12](12-case-studies.md#case-study-e-longitudinal-fev1--time-to-exacerbation).

---

## Where this chapter leads

**Next:** [Chapter 20](20-missing-data.md) for spirometry missingness; [Chapter 21](21-causal-inference.md) for observational effect language.

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Therneau & Grambsch, *Modeling Survival Data* (Cox models, diagnostics)
