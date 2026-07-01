# Chapter 8: Uncertainty, Validation, and Reporting

> **Part IV: Evidence Quality and Transparency**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](RECURRING_COHORT.md) |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Methods** | CI, bootstrap, multiplicity, CONSORT/STROBE/TRIPOD, sensitivity, reproducibility |
| **Exercises** | [ch08](../exercises/ch08_exercises.md) |

**Also see:** [Appendix B](../appendix-b-quick-reference.md), [REFERENCES](../REFERENCES.md), Reporting checklists below
## Learning objectives

1. Report estimates with uncertainty, not p-values alone.
2. Use bootstrap when asymptotic CIs are doubtful.
3. Apply the correct reporting guideline for your design.
4. Prespecify sensitivity analyses.
5. Document reproducible analysis workflows in R.

## Prerequisites

Chapters 4-7.

---

## Why this chapter

A correct analysis reported badly is still unusable in a protocol or journal. This chapter is for anyone writing the Methods or Results: CONSORT, STROBE, TRIPOD, intervals instead of “p > 0.05 means no effect.” CASTOR examples show how to report evidence, not just significance.

## Opening question (CASTOR)

*You found p = 0.20 for FEV1 difference between arms. Has the trial "failed," or is that the wrong question?*

This chapter is about **how to report evidence** - intervals, validation, transparency - so CASTOR analyses (and yours) can be trusted and interpreted correctly [@harrell2015rms].

---

## Technique: Confidence interval reporting

### Technique card

| | |
|---|---|
| **Answers** | What range of effect sizes is compatible with the data? |
| **Report with** | Point estimate + 95% CI + n (+ events for binary) |
| **When to use** | Always, for every primary and key secondary analysis |
| **When NOT to use** | CI alone without clinical context (MCID) |
| **Does NOT prove** | No effect if CI includes null - may be underpowered |

### Dual interpretation

**Plain language:** the true mean FEV1 difference might plausibly be anywhere from −0.04 to +0.21 L.

**Precise language:** 95% CI procedure; under repeated sampling, ~95% of such intervals cover the true estimand.

**Clinician read:** is the entire CI below MCID? above MCID? straddling it? That drives interpretation more than p = 0.20 [@cazzola2008mcid].

### Caveats box

| Caveat | Detail |
|--------|--------|
| 95% is convention | Not 95% probability for this one interval (frequentist) |
| Multiple CIs | Do not cherry-pick the narrowest |
| Model-based CI | Assumes model correct |
| Small n | Wald CI for OR can be poor - profile/likelihood or bootstrap [@efron1993bootstrap] |

### In practice

Reviewers will ask for CIs even when you reported p-values. Build tables with estimate, CI, and n from the start: retrofitting intervals before resubmission wastes a week and invites arithmetic errors.

### In practice (CONSORT flow)

For RCTs, the number analysed is often smaller than enrolled. The CONSORT flow is not bureaucracy; it documents who entered the estimand. If FEV1 at week 12 excludes patients who died or withdrew, say so explicitly and link to [Chapter 20](20-missing-data.md).

### In practice (non-inferiority reporting)

Regulatory and device submissions ask: “Did you demonstrate non-inferiority?” A Results paragraph with only “p = 0.08” fails that question. Report the **prespecified margin**, the **90% CI** (or TOST result), and a plain conclusion relative to Δ ([Ch 4 NI template](04-comparing-groups.md#technique-non-inferiority-and-equivalence-trials)).

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | "p > 0.05 therefore no effect" |
| **Do instead** | Report CI; discuss power and MCID |

| | |
|---|---|
| **Mistake** | Report only significant secondary endpoints |
| **Do instead** | Pre-specify or label exploratory |

### Reporting template

**Results:** Mean difference 0.09 L (95% CI −0.04 to 0.21; n = 400). The interval includes no effect and clinically small benefits.

---

## Technique: Bootstrap confidence intervals

### Technique card

| | |
|---|---|
| **Answers** | CI for statistic without formula (complex estimands) |
| **Method** | Resample rows with replacement B times; percentile CI |
| **R** | `replicate` + `quantile` or `boot` package |
| **When to use** | Non-normal statistic; median difference; small n robustness |
| **Does NOT fix** | Bad design or wrong estimand |

```r
B <- 2000
set.seed(1)
boot_diff <- replicate(B, {
  d <- spirometry[sample(nrow(spirometry), replace = TRUE), ]
  diff(tapply(d$fev1, d$group, mean))
})
quantile(boot_diff, c(0.025, 0.975))
```

### Dual interpretation

**Plain language:** if we repeated the study many times, the mean difference would fall in this range about 95% of the time (percentile bootstrap interpretation) [@efron1993bootstrap].

### Caveats

Clustered data need cluster bootstrap ([Ch 18](18-longitudinal-mixed-models.md)). Percentile bootstrap can fail for skewed ORs - consider BCa.

### Wrong analysis ⚠

Bootstrap on 15 patients and treat as definitive → report wide CI honestly.

---

## Technique: Multiplicity control

### Technique card

| | |
|---|---|
| **Answers** | How to control false positives across many tests? |
| **Methods** | Prespecify primary endpoint; Holm; Bonferroni; gatekeeping [@benjamini1995fdr] |
| **CASTOR context** | FEV1, FVC, symptoms, exacerbations - pick one primary |
| **Does NOT mean** | Never run secondary analyses |

### Caveats

Bonferroni conservative; Holm less conservative. Exploratory analyses must be labelled.

### Wrong analysis ⚠

Test 20 biomarkers at α = 0.05; publish the three "significant" ones without correction.

### Reporting template

**Methods:** The primary endpoint was 12-week FEV1. Secondary endpoints were pre-specified with Holm adjustment. Exploratory biomarker analyses were unadjusted and hypothesis-generating.

---

## Technique: Reporting guidelines (CONSORT / STROBE / TRIPOD)

### Technique card

| Guideline | Design | Key items | Reference |
|-----------|--------|-----------|-----------|
| **CONSORT** | RCT | Flow diagram, randomisation, primary outcome | [@schulz2010consort] |
| **STROBE** | Observational | Eligibility, confounding, missing data | [@vonelm2007strobe] |
| **TRIPOD** | Prediction | Validation, calibration, model specification | [@moons2015tripod] |

### Dual interpretation

**Plain language:** checklists help reviewers and readers see what you did and what you might have hidden.

**Statistician read:** not a substitute for correct analysis - you can follow CONSORT and still misuse ANCOVA.

### Caveats

Checklists evolve - cite version/year. Supplementary materials for full protocol.

### Wrong analysis ⚠

Report CONSORT flow diagram but change primary endpoint post hoc without disclosure.

### Reporting template

**Methods:** We followed CONSORT 2010 guidelines [@schulz2010consort]. The analysis plan was prespecified before unblinding (supplementary protocol).

---

## Technique: Reproducible reporting

### Technique card

| | |
|---|---|
| **Minimum** | R version, key packages, seed, analysis script path |
| **Better** | Quarto/R Markdown compiling Tables and Figures |
| **CASTOR** | `source("R/run_all_examples.R")` reproduces book outputs |

```r
sessionInfo()
```

### Caveats

`sessionInfo()` alone insufficient without shared data and script. Proprietary GUI-only steps not reproducible.

### Wrong analysis ⚠

"Data available on request" with no code → not reproducible science.

---

## Technique: Sensitivity analysis

### Technique card

| | |
|---|---|
| **Answers** | Are conclusions robust to reasonable analysis choices? |
| **Examples** | Complete-case vs MI; Welch vs Mann-Whitney; logistic vs Firth |
| **Rule** | **Prespecify** in protocol when possible |
| **Does NOT mean** | Run analyses until one is significant |

### CASTOR examples

| Primary | Sensitivity |
|---------|-------------|
| Welch t on FEV1 | Mann-Whitney; ANCOVA with baseline |
| Logistic OR smoking | Firth; log-binomial RR |
| Poisson counts | Negative binomial |

### Wrong analysis ⚠

Run 12 models; report only the one with p < 0.05.

### Reporting template

**Results:** Primary analysis … Sensitivity analyses using [method] yielded similar conclusions (Table S2).

---

## CASTOR worked example: interpreting "non-significant" trial

**Primary:** Welch t, mean FEV1 difference 0.09 L (95% CI −0.04 to 0.21), p = 0.20.

**Interpretation:**

- **Statistician:** compatible with null and with effects up to ~0.21 L.  
- **Clinician:** if MCID = 0.10 L, CI includes values above MCID - inconclusive, not negative [@cazzola2008mcid].  
- **Wrong:** "trial failed" / "no benefit."

**Sensitivity:** permutation p; bootstrap CI; ANCOVA on `spirometry_trial.csv`.

---

## Catalog of wrong analyses (reporting chapter)

| Wrong | Right |
|-------|-------|
| p-value only | Estimate + CI + n |
| Post hoc primary endpoint | Prespecified + protocol |
| No flow diagram (RCT) | CONSORT |
| Hide missing n | Report attrition |
| No code/data | Reproducible script |

---


## R lab

```r
source("R/00_setup.R")
library(tidyverse)
s <- read_csv("data/spirometry.csv", show_col_types = FALSE)
t.test(fev1 ~ group, data = s)$conf.int
# Bootstrap - see bootstrap section
sessionInfo()
```

---

## Alternatives & extensions (evidence quality toolkit)

### Uncertainty intervals beyond the default

| Option | When to use | Note |
|---|---|---|
| **BCa bootstrap CI** | skewed statistics; boundary effects | more stable than percentile in some settings |
| **Profile likelihood CI** | logistic ORs; small samples | often better than Wald CI |
| **Bayesian credible intervals** | prior information; small samples | requires explicit prior; optional extensions |

### Multiplicity beyond Bonferroni/Holm

| Option | When to use | Note |
|---|---|---|
| **FDR control** | many biomarkers/omics | report method and q-values [@benjamini1995fdr] |
| **Gatekeeping** | trials with endpoint hierarchy | prespecify family structure |

### Validation options

| Context | Option | Why / note |
|---|---|---|
| Prediction models | optimism correction / bootstrap validation | complements single split |
| Clustering / PCA | stability + external replication | Ch 10-11 |

### Non-inferiority and equivalence reporting

| Element | Report |
|---|---|
| **Margin Δ** | Prespecified clinical margin (e.g. −0.10 L FEV1) |
| **Hypothesis** | NI: H0: difference ≤ Δ vs Ha: difference > Δ (example for continuous) |
| **Interval** | 90% CI for NI (convention) or two one-sided tests |
| **Conclusion** | NI demonstrated / not demonstrated. **not** “no difference” from *p* > 0.05 |
| **Power** | NI trials must be powered for the margin, not superiority |

**Methods sentence (template):**

> Non-inferiority of [intervention] vs [control] on [endpoint] was tested with prespecified margin Δ = …. We used [TOST / CI against margin] at one-sided α = 0.025.

**Results sentence (template):**

> The estimated difference was … (90% CI …). Because the CI [was / was not] entirely above Δ, non-inferiority [was / was not] demonstrated.

Full technique card: [Chapter 4](04-comparing-groups.md#technique-non-inferiority-and-equivalence-trials).

### Missing data ([Ch 20](20-missing-data.md))

Multiple imputation (MICE) is the default modern sensitivity tool when missingness is plausibly MAR. [Ch 20](20-missing-data.md) introduces patterns and sensitivity; production analyses should use `mice` with pooled estimates.

## Chapter summary

- Intervals over dichotomous significance [@harrell2015rms].
- Bootstrap and sensitivity analyses support robust conclusions [@efron1993bootstrap].
- Match reporting guideline to design [@schulz2010consort; @vonelm2007strobe; @moons2015tripod]; document reproducibility.

## Where this chapter leads

**Next:** Prediction workflows → [Chapter 9](09-prediction-vs-inference.md). Discovery on marker panels → [Chapters 10–12](10-dimensionality-reduction.md). Omics → [Chapter 13](13-differential-analysis-fdr.md).

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]  
- Efron & Tibshirani, *An Introduction to the Bootstrap* [@efron1993bootstrap]  
- Steyerberg, *Clinical Prediction Models* [@steyerberg2019clinical]

## Exercises ([Solutions](../solutions/ch08_solutions.md))

**Next:** [Chapter 9](09-prediction-vs-inference.md)
