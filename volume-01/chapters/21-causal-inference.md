# Chapter 21: Causal inference — confounding and IPW

> **Part VIII: Longitudinal, survival, and causal inference**

## At a glance

| | |
|---|---|
| **Recurring dataset** | `data/exacerbation.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Question** | When can we interpret an adjusted association as closer to a causal effect? |
| **Core methods** | confounding diagram, target trial, associational vs causal estimands, introductory IPW |
| **R** | `R/examples/ch21_causal_inference.R` |
| **Links** | [Ch 6 logistic](06-generalized-linear-models.md) · [Ch 12 Case B](12-case-studies.md) |

## Learning objectives

1. State the difference between association and causation in observational respiratory studies.
2. Draw a simple confounding structure (smoking, FEV1, exacerbation).
3. Run a toy IPW sensitivity for smoking exposure and compare to naive logistic regression.
4. List requirements for causal language (design, assumptions, diagnostics, sensitivity).

## Prerequisites

Chapters 1 (estimands), 6–7 (logistic regression), 8 (STROBE reporting).

---

## Opening question (CASTOR)

*Does smoking **cause** higher 12-month exacerbation risk — or is low FEV1 a common consequence of smoking and severe disease that also drives exacerbations?*

Standard logistic regression adjusts for measured covariates, but **which** covariates belong in the model is a causal question, not a significance question [@harrell2015rms].

---

## Technique: Associational vs causal estimands; introductory IPW

### Technique card (associational)

| | |
|---|---|
| **Answers** | Is smoking associated with exacerbation after adjusting for measured covariates? |
| **Estimand** | Conditional odds ratio (logistic) — **associational** |
| **R** | `glm(exacerbation_12m ~ smoking + fev1_pct, family = binomial)` |
| **When to use** | Hypothesis generation; STROBE cohort descriptions |
| **Does NOT prove** | Smoking causes exacerbations |

### Technique card (IPW — introductory)

| | |
|---|---|
| **Answers** | Weighted pseudo-population where exposure is balanced on measured confounders (toy) |
| **Steps** | Model exposure ~ confounders → weights = 1/P(exposure\|confounders) → weighted outcome model |
| **Teaching script** | IPW for smoking using FEV1 tertile marginal weights |
| **Assumptions** | No unmeasured confounding; positivity (all exposure levels possible within confounder strata); correct exposure model |
| **R** | `R/examples/ch21_causal_inference.R` |
| **When to use** | Sensitivity to covariate adjustment; motivation for propensity methods |
| **When NOT to use** | As automatic proof of causation; with extreme weights untrimmed |
| **Does NOT prove** | Causation without design + unmeasured confounding sensitivity |

### Dual interpretation

**Plain language:** we reweighted patients so smoking groups looked more comparable on FEV1 strata, then re-estimated the smoking–exacerbation association.

**Precise language:** IPW estimates a marginal or appropriately weighted estimand under a structural model where conditioning on measured confounders blocks back-door paths; residual confounding remains if unmeasured common causes exist.

**Clinician read:** "Adjusted OR" and "IPW OR" still describe **observational** data — randomised trials (Case A) remain the gold standard for causal treatment effects.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Unmeasured confounding | Adherence, SES, exacerbation history incompletely captured |
| Collider adjustment | Conditioning on post-exposure variables (e.g. antibiotics) opens bias |
| Mediator adjustment | Adjusting for variables on causal path blocks total effect |
| Positivity / extreme weights | Sparse cells → unstable weights; trim and report ESS |
| Overlap | No empirical overlap → estimand not supported in data |
| Transportability | CASTOR-like synthetic cohort ≠ your clinic population |

### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| "Adjusted OR proves smoking causes exacerbations" | Observational; model-dependent | State associational estimand; Ch 12 Case B limits |
| Throw all predictors into propensity model | Overfitting; bias | DAG / subject-matter covariate set |
| IPW without checking weights | Extreme weights dominate | Summary of weight distribution; trimming |
| Adjust for mediators when total effect is target | Blocks part of effect | Prespecify estimand (total vs direct) |
| Causal language from IPW alone | Untestable assumptions | Sensitivity + design discussion |

### Catalog of wrong analyses (causal claims)

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **Significant covariate → include in PS model** | Data-driven confounding control | Prespecified adjustment set |
| **Compare IPW and OLS, pick "better" p-value** | Multiplicity / fishing | Pre-register estimand and method |
| **Ignore immortal time bias** in therapy cohorts | Misaligned time zero | Target trial emulation |
| **Use future FEV1 as confounder** | Post-baseline leakage | Baseline covariates only unless clear protocol |

### Reporting template

> We estimated the association between smoking and 12-month exacerbation in an observational cohort (*n* = …). The naive logistic model adjusting for FEV1 % predicted yielded OR = … (95% CI …). As a sensitivity analysis, we applied inverse probability weights for smoking based on … (weight range …; mean …). The IPW OR was … (95% CI …). These analyses assume no unmeasured confounding and sufficient overlap of smokers and non-smokers within confounder strata. Causal interpretation is not claimed; findings are associational [@vonelm2007strobe].

### Target trial (concept)

Ask: *What randomized experiment would answer this question?* Then emulate its eligibility, treatment strategies, assignment, follow-up, and outcomes using observational data — misalignment at any step introduces bias.

---

## R lab

```r
source("R/00_setup.R")
source("R/examples/ch21_causal_inference.R")
```

![FEV1 balance before vs after IPW (toy)](../figures/ch21_covariate_balance.png)

![Smoking OR: naive vs IPW](../figures/ch21_or_naive_vs_ipw.png)

**Tables:** `ch21_smoking_or_naive_vs_ipw.csv`, `ch21_balance_before_after_ipw.csv`, `ch21_ipw_weight_summary.csv`

### Mini-lab: propensity score pointer

Full propensity score workflow: estimate `e(X) = P(smoking=1|X)`, check overlap, weight or match, then outcome model. Packages: `WeightIt`, `MatchIt`. Always report balance diagnostics (standardised mean differences).

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Binary treatment, many covariates | Propensity matching / weighting | Overlap plots |
| Time-varying treatment | Marginal structural models | Advanced |
| Unmeasured confounding | Sensitivity analysis (E-values) | Report bounds |
| RCT subgroup | No causal adjustment needed for randomisation | Case A |

---

## Exercises · [Solutions](../solutions/ch21_solutions.md)

**E21.1** Name one confounder on the smoking → exacerbation path in CASTOR.

**E21.2** What does the "no unmeasured confounding" assumption mean?

**E21.3** Why check weight distributions after IPW?

**Applied**

1. Run `source("R/examples/ch21_causal_inference.R")`.
2. Compare naive vs IPW OR in `ch21_smoking_or_naive_vs_ipw.csv`.
3. Read `ch21_ipw_weight_summary.csv` — any extreme weights?

**Capstone link:** [Case B](12-case-studies.md) (associational logistic) vs this chapter (explicit causal framing).

---

## Further reading

- Hernán & Robins, *Causal Inference: What If* (free online)
- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- STROBE reporting for observational studies [@vonelm2007strobe]
