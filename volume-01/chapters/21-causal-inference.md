# Chapter 21: Causal inference, confounding and IPW

> **Part VIII: Longitudinal, survival, and causal inference**

## At a glance

| | |
|---|---|
| **Recurring dataset** | `data/exacerbation.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Question** | When can we interpret an adjusted association as closer to a causal effect? |
| **Core methods** | confounding diagram, target trial, associational vs causal estimands, introductory IPW |
| **R** | `R/examples/ch21_causal_inference.R` |
| **Figures** | covariate balance (`ch21_covariate_balance.png`), naive vs IPW OR (`ch21_or_naive_vs_ipw.png`); **figure hygiene:** `viz_pair_ch21_causal.png` |
| **Links** | [Ch 6 logistic](06-generalized-linear-models.md), [Ch 12 Case B](12-case-studies.md) |
| **Exercises** | [Chapter 21 exercises](../exercises/ch21_exercises.md) |

---

## In this chapter

1. [Clinical and biostatistics notes](#clinical-and-biostatistics-notes): association ≠ causation
2. [Method choice at a glance](#method-choice-at-a-glance): IPW vs adjusted regression
3. [Technique: IPW](#technique-inverse-probability-weighting-ipw-toy): balance and weights
4. [Reporting template](#reporting-template): associational vs causal wording
5. [Alternatives & extensions](#alternatives--extensions)

**Analyst read:** DAGs, R lab below.

---

## Method choice at a glance

| Method | When to use | Why |
|--------|-------------|-----|
| **Adjusted logistic / Cox (associational)** | Observational; report adjusted OR/HR | Controls measured confounders; still not RCT |
| **IPW (propensity weights)** | Treatment/exposure imbalance; overlap adequate | Reweights to pseudo-population with balance |
| **Propensity score matching** | Want comparable treated/untreated pairs | Visual overlap; reduces model dependence |
| **Target trial emulation** | Framing observational analysis | Aligns time zero, eligibility, treatment strategies |
| **DAG + confounder set** | Planning adjustment | Separates confounders from mediators/colliders |
| **E-value / sensitivity** | Unmeasured confounding concern | Quantifies how strong hidden bias would need to be |
| **No causal adjustment** | RCT primary analysis | Randomisation supports causal contrast ([Case A](12-case-studies.md)) |
| **Do not adjust mediators** | Total effect estimand | Blocks part of causal path |
| **Mediation analysis** | Mechanism through measured mediator prespecified | Total vs direct decomposition ([Ch 22](22-mediation-analysis.md)) |

**Extensions:** MSM, matching details in [Alternatives & extensions](#alternatives--extensions).

---

## Learning objectives

1. State the difference between association and causation in observational respiratory studies.
2. Draw a simple confounding structure (smoking, FEV1, exacerbation).
3. Distinguish confounders, mediators, and colliders in a respiratory DAG.
4. Run a toy IPW sensitivity for smoking exposure and compare to naive logistic regression.
5. Describe target trial emulation in plain language.
6. List requirements for causal language (design, assumptions, diagnostics, sensitivity).

## Prerequisites

Chapters 1 (estimands), 6–7 (logistic regression), 8 (STROBE reporting).

---

## Why this chapter

Observational smoking and therapy comparisons invite causal language. This chapter separates associational estimands from causal claims, introduces IPW as sensitivity (not proof), and points back to randomised Case A when you need real causal evidence.

## Opening question (CASTOR)

*Does smoking **cause** higher 12-month exacerbation risk, or is low FEV1 a common consequence of smoking and severe disease that also drives exacerbations?*

Standard logistic regression adjusts for measured covariates, but **which** covariates belong in the model is a causal question, not a significance question [@harrell2015rms].

Case B in [Chapter 12](12-case-studies.md) fits an associational logistic model. This chapter makes the **estimand explicit** and introduces inverse probability weighting as a sensitivity analysis, not a magic causal proof.

---

## The causal workflow

1. **Estimand**: total effect? direct effect? risk difference at 12 months?
2. **DAG / subject-matter map**: what causes what; what must not be adjusted for?
3. **Design**: RCT (Case A) vs observational (Case B, this chapter).
4. **Analysis**: regression, IPW, matching aligned to estimand.
5. **Diagnostics**: balance, positivity, weight distribution.
6. **Humility**: unmeasured confounding sensitivity; avoid causal verbs unless justified.

---

## Association vs causation (respiratory)

| Claim type | Example sentence | Supported by observational logistic? |
|------------|------------------|--------------------------------------|
| **Association** | Smoking is associated with higher exacerbation odds after adjusting for FEV1 | Yes, with STROBE limits |
| **Prediction** | Smoking improves risk model AUC | Ch 9 framing |
| **Causation** | Smoking **causes** excess exacerbations | Needs design + assumptions |

Randomised trials (Case A) support causal **treatment** claims for the randomised factor. Observational smoking studies do not, without stronger design and sensitivity.

---

## Confounding structure (CASTOR)

**Smoking** → lower **FEV1** and higher **exacerbation** risk. FEV1 is also on the causal path from smoking to exacerbation (partial mediator) and a **confounder** if other factors affect both FEV1 and exacerbation.

```
Smoking -----> Exacerbation (12m)
 | ^
 v |
 FEV1 ---------------+
```

**Adjust for FEV1** when the estimand is the association of smoking **not explained by** measured lung function (or when FEV1 is a confounder per protocol). **Do not adjust** for FEV1 when the **total effect** of smoking including its impact via FEV1 is the target, unless using a mediation framework prespecified in advance.

---

## Confounder, mediator, collider (quick reference)

| Variable role | Adjust? | Respiratory trap |
|---------------|---------|------------------|
| **Confounder** | Yes (if measured) | Omitting prior exacerbation history |
| **Mediator** | Only for direct effect estimand | Adjusting FEV1 when total smoking effect wanted |
| **Collider** | **No** | Adjusting for hospitalisation that is caused by both smoking and exacerbation |
| **Instrument** | Special methods | Rare in basic COPD cohorts |

---

## Technique: Associational vs causal estimands; introductory IPW

### Technique card (associational)

| | |
|---|---|
| **Answers** | Is smoking associated with exacerbation after adjusting for measured covariates? |
| **Estimand** | Conditional odds ratio (logistic) (**associational**) |
| **R** | `glm(exacerbation_12m ~ smoking + fev1_pct, family = binomial)` |
| **When to use** | Hypothesis generation; STROBE cohort descriptions |
| **Does NOT prove** | Smoking causes exacerbations |

### Technique card (IPW, introductory)

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

**Practice read:** "Adjusted OR" and "IPW OR" still describe **observational** data; randomised trials (Case A) remain the gold standard for causal treatment effects.

### Worked example (CASTOR)

From `ch21_smoking_or_naive_vs_ipw.csv` (teaching run):

| Model | Smoking OR (95% CI) |
|-------|----------------------|
| Naive logistic | 1.89 (0.64 to 6.30) |
| IPW-weighted | 1.84 (0.88 to 4.08) |

ORs are similar here because the toy weighting scheme is crude. The lesson is **process**: check balance, weights, and overlap before interpreting either OR causally. Wide CIs reflect sparse events.

```r
source("R/examples/ch21_causal_inference.R")
or_tbl <- readr::read_csv(
 "volume-01/tables/ch21_smoking_or_naive_vs_ipw.csv"
)
wt <- readr::read_csv("volume-01/tables/ch21_ipw_weight_summary.csv")
```

### Target trial (concept)

Ask: *What randomized experiment would answer this question?* Then emulate its eligibility, treatment strategies, assignment, follow-up, and outcomes using observational data. Misalignment at any step introduces bias.

| Target trial component | CASTOR observational analogue |
|------------------------|------------------------------|
| Eligibility | COPD cohort inclusion criteria |
| Treatment strategies | Smoker vs non-smoker (not well-defined intervention) |
| Assignment | Not random → confounding |
| Follow-up | 12 months |
| Outcome | `exacerbation_12m` |

Smoking is **not** a randomised exposure in CASTOR; causal language is especially fragile.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Unmeasured confounding | Adherence, SES, exacerbation history incompletely captured |
| Collider adjustment | Conditioning on post-exposure variables (e.g. antibiotics) opens bias |
| Mediator adjustment | Adjusting for variables on causal path blocks total effect |
| Positivity / extreme weights | Sparse cells → unstable weights; trim and report ESS |
| Overlap | No empirical overlap → estimand not supported in data |
| Transportability | CASTOR-like synthetic cohort ≠ your clinic population |

### In practice

“Adjusted for confounders” in an abstract is not causal language. Match verbs to design: randomised trial → effect; observational cohort → association unless prespecified causal framework and sensitivity are in place.

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

---

## RCT vs observational (when to say "cause")

| Design | Causal treatment claim | Key chapter |
|--------|------------------------|-------------|
| RCT (Case A) | Supported for randomised factor | Ch 12 Case A |
| Observational cohort (Case B) | Associational only | Ch 12 Case B, this chapter |
| IPW / propensity | Sensitivity; not proof | This chapter |

---


## R lab

```r
source("R/00_setup.R")
source("R/examples/ch21_causal_inference.R")
```

![Covariate balance slopegraph: before vs after IPW](../figures/ch21_covariate_balance.png)

Check whether FEV1 % means are closer across smoking groups after weighting. Poor balance after weighting → revisit exposure model or overlap.

### Figure hygiene: naive OR vs balance check

![Right vs wrong: observational smoking effect](../figures/viz_pair_ch21_causal.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Adjusted OR bar (causal wording) | Covariate overlap, weight diagnostics |
| **Right** | Balance before vs after IPW | Whether weighting achieved exchangeability |

![Smoking OR: naive vs IPW](../figures/ch21_or_naive_vs_ipw.png)

Material movement between naive and IPW-adjusted ORs is a sensitivity flag, not proof of a causal smoking effect.

**Tables:** `ch21_smoking_or_naive_vs_ipw.csv`, `ch21_balance_before_after_ipw.csv`, `ch21_ipw_weight_summary.csv`

### Mini-lab: propensity score pointer

Full propensity score workflow: estimate `e(X) = P(smoking=1|X)`, check overlap, weight or match, then outcome model. Packages: `WeightIt`, `MatchIt`. Always report balance diagnostics (standardised mean differences).

```r
# Illustrative only, not the teaching script:
# library(WeightIt)
# w <- weightit(
# smoking ~ fev1_percent_predicted + age,
# data = exac,
# method = "ps"
# )
# summary(w)
```

### Mini-lab: E-value pointer

When unmeasured confounding is plausible, E-values quantify how strong an unmeasured confounder would need to be to explain away the observed association (advanced; see Hernán & Robins).

---

## Alternatives & extensions

| Situation | Method | Note |
|-----------|--------|------|
| Binary treatment, many covariates | Propensity matching / weighting | Overlap plots |
| Time-varying treatment | Marginal structural models | Advanced |
| Unmeasured confounding | Sensitivity analysis (E-values) | Report bounds |
| RCT subgroup | No causal adjustment needed for randomisation | Case A |
| Mechanism through FEV1 % | Mediation (total / direct / indirect) | [Chapter 22](22-mediation-analysis.md) |

---

## Exercises ([Solutions](../solutions/ch21_solutions.md))

**E21.1** Name one confounder on the smoking → exacerbation path in CASTOR.

**E21.2** What does the "no unmeasured confounding" assumption mean?

**E21.3** Why check weight distributions after IPW?

**E21.4** Is FEV1 a confounder, mediator, or both? Why does it matter?

**E21.5** What is one component of a target trial emulation?

**Applied**

1. Run `source("R/examples/ch21_causal_inference.R")`.
2. Compare naive vs IPW OR in `ch21_smoking_or_naive_vs_ipw.csv`.
3. Read `ch21_ipw_weight_summary.csv`: any extreme weights?
4. From the balance plot, did IPW improve FEV1 balance in this toy run?
5. Rewrite a causal-sounding sentence as an associational sentence suitable for STROBE.

**Capstone link:** [Case B](12-case-studies.md) (associational logistic) vs this chapter (explicit causal framing).

---

## Where this chapter leads

When FEV1 sits on the smoking → exacerbation path and reviewers ask *how much goes through lung function*, continue to [Chapter 22: Mediation analysis](22-mediation-analysis.md). Otherwise return to [Chapter 12](12-case-studies.md) for integrated discussions or [Appendix B](../appendix-b-quick-reference.md) for day-to-day method choice.

## Further reading

- Hernán & Robins, *Causal Inference: What If* (free online)
- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- STROBE reporting for observational studies [@vonelm2007strobe]
