# Chapter 8: Uncertainty, Validation, and Reporting

> **Part IV: Evidence Quality and Transparency**

## Opening scene: the manuscript deadline

CONSORT checklist on one monitor, CASTOR Results on the other. Reviewer 2 will ask for confidence intervals, flow counts, and what the trial **did not** prove. Rivera drafts *"trend toward benefit"*; Mei replaces it with the CI against MCID and a Limits paragraph.

Sign-off discipline: reporting frameworks, intervals, multiplicity, and honest language.

---

## Why this chapter

Correct analysis that is reported badly still misleads clinicians. CASTOR Case A's publishable narrative lives here. CONSORT-aligned tables, estimand-first sentences, and what to say when the primary is inconclusive.

---

## Technique: Confidence interval reporting

Every primary and key secondary analysis needs **point estimate + 95% CI + *n*** (and events for binary outcomes). The CI answers clinical questions better than *p* alone: does the interval exclude the MCID? straddle it? include only null? [@cazzola2008mcid]

For CASTOR, mean difference 0.09 L (95% CI −0.04 to 0.21). The interval includes no effect and clinically small benefits; *p* = 0.20 is secondary to that sentence.

Reviewers will ask for CIs even when you reported *p*-values. For RCTs, the CONSORT flow documents who entered the estimand, if week-12 FEV₁ excludes dropouts, say so in Methods and link to missing-data sensitivity. For non-inferiority submissions, report the **prespecified margin** and CI against Δ, not *p* alone.

**Common mistakes:** *"p* > 0.05 therefore no effect"*; reporting only significant secondaries.

**Results template:** Mean difference 0.09 L (95% CI −0.04 to 0.21; *n* = 400). The interval includes no effect and clinically small benefits.

---

## Technique: Bootstrap confidence intervals

Resample at the **correct unit**: patients for repeated measures (or cluster bootstrap for clustered designs), not visits stacked as independent rows. **Percentile** bootstrap CIs are simple; **BCa** can help with skewed statistics. With small *n* or rare events, bootstrap intervals may be unstable—wide CIs are honest. **Do not** bootstrap across imputation draws without Rubin pooling rules (Ch 20).

```r
B <- 2000
set.seed(1)
boot_diff <- replicate(B, {
 d <- spirometry[sample(nrow(spirometry), replace = TRUE), ]
 diff(tapply(d$fev1, d$group, mean))
})
quantile(boot_diff, c(0.025, 0.975))
```

Clustered data need cluster bootstrap. With *n* = 15, a wide bootstrap CI is honest, not a failure.

---

## Technique: Multiplicity control

One **prespecified primary** endpoint; secondaries in a **family** with Holm or gatekeeping; omics in a **separate** FDR family (Part VI). A steering deck with four lung endpoints each at α = 0.05 invites false positives.

| Structure | Example | Rule |
|-----------|---------|------|
| **Primary** | Week-12 FEV₁ | Powers the trial |
| **Key secondaries** | FVC, CAT, exacerbation proportion | Prespecified order + Holm within clinical family |
| **Exploratory** | Post hoc subgroup | Label hypothesis-generating |
| **Omics** | ~1000 proteins | BH FDR, separate from FEV₁ |

**Methods template:** The primary endpoint was 12-week FEV₁ (unadjusted mean difference). Secondaries (FVC, CAT, exacerbation proportion) were tested in prespecified order with Holm adjustment within the clinical family.

---

## Technique: Reporting guidelines (CONSORT / STROBE / TRIPOD)

| Guideline | Design | Key items |
|-----------|--------|-----------|
| **CONSORT** | RCT | Flow diagram, randomisation, primary outcome [@schulz2010consort; @consort2025] |
| **STROBE** | Observational | Eligibility, confounding, missing data [@vonelm2007strobe] |
| **TRIPOD** | Prediction | Validation, calibration, model specification [@moons2015tripod; @collins2024tripodai] |

Checklists improve transparency; they do not replace correct analysis. Cite checklist version/year; full protocol in supplement.

**Methods snippet:** We followed CONSORT 2025 reporting guidance [@consort2025] (supersedes CONSORT 2010 [@schulz2010consort]). The analysis plan was prespecified before unblinding (supplementary protocol). Prediction models follow TRIPOD+AI 2024 where applicable [@collins2024tripodai].

---

## Technique: Reproducible reporting

Minimum: R version, key packages, seed, analysis script path. Better: Quarto/R Markdown compiling Tables and Figures. CASTOR: `source("R/run_all_examples.R")` reproduces book outputs. `sessionInfo()` alone is insufficient without shared data and script.

---

## Technique: Sensitivity analysis

**Prespecified** alternatives when the primary is contested: complete-case vs MI; Welch vs Mann–Whitney; logistic vs Firth; Poisson vs NB. Not twelve models until one hits *p* < 0.05.

| Primary | Sensitivity |
|---------|-------------|
| Welch *t* on FEV₁ | Mann–Whitney; ANCOVA with baseline |
| Logistic OR smoking | Firth; log-binomial RR |
| Poisson counts | Negative binomial |

**Results template:** Primary analysis … Sensitivity analyses using [method] yielded similar conclusions (Table S2).

---

## CASTOR worked example: interpreting "non-significant" trial

**Primary:** Welch t, mean FEV1 difference 0.09 L (95% CI −0.04 to 0.21), p = 0.20.

**Interpretation:**

- **Statistician:** compatible with null and with effects up to ~0.21 L.
- **Practice:** if MCID = 0.10 L, CI includes values above MCID - inconclusive, not negative [@cazzola2008mcid].
- **Wrong:** "trial failed" / "no benefit."

**Sensitivity:** permutation p; bootstrap CI; ANCOVA on `spirometry_trial.csv`.

### Wrong analysis ⚠

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| *p*-value only in Results | Hides compatible effect sizes | Estimate + 95% CI + *n* | CI vs MCID for FEV₁ |
| "Non-significant → no benefit" | Inconclusive ≠ null | Compatible-effects language | Limits paragraph |

> **Extended catalogue:** [Appendix R — Chapter 8](../appendix-r-wrong-analysis-catalog.md#chapter-8).

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
| Prediction models (small *n*, few events) | Bootstrap or **nested/repeated CV** using all observations | May **replace** a random train/test split for **internal** validation; use **nested** CV when tuning hyperparameters |
| Prediction models (adequate *n*) | Hold-out test set **or** resampling | Hold-out is one design; resampling can be equally valid internally |
| All prediction models | External validation in independent cohort | **Required** for deployment claims; never substitute internal resampling alone [@moons2015tripod] |
| Clustering / PCA | stability + external replication | Ch 10-11 |

### Non-inferiority and equivalence reporting

| Element | Report |
|---|---|
| **Margin Δ** | Prespecified clinical margin (e.g. −0.10 L FEV1) |
| **Hypothesis (NI)** | H₀: difference ≤ Δ vs Hₐ: difference > Δ (example for continuous, new − control) |
| **Interval (NI)** | **Match CI level to one-sided α:** α = 0.025 → **95% two-sided CI**; α = 0.05 → **90% two-sided CI**. Compare the **relevant bound** to Δ (lower bound for NI when worse = lower). |
| **Equivalence** | Two prespecified margins; **TOST** (two one-sided tests) or equivalent CI entirely within bounds |
| **Conclusion** | NI demonstrated / not demonstrated. **not** “no difference” from *p* > 0.05 |
| **Power** | NI trials must be powered for the margin, not superiority |

**Methods sentence (template, NI at α = 0.025):**

> Non-inferiority of [intervention] vs [control] on [endpoint] was tested with prespecified margin Δ = …. We compared the **lower bound of the two-sided 95% CI** to Δ at one-sided α = 0.025.

**Results sentence (template, NI at α = 0.025):**

> The estimated difference was … (95% CI …). Because the **lower bound** [was / was not] greater than Δ, non-inferiority [was / was not] demonstrated.

Full NI/equivalence templates: [Appendix O](../appendix-o-ch04-comparison-extensions.md#technique-non-inferiority-and-equivalence-trials).

### Missing data

Multiple imputation (MICE) is the default modern sensitivity tool when missingness is plausibly MAR. Chapter 20 introduces patterns and sensitivity; production analyses should use `mice` with pooled estimates.

---

## Quick reference: methods in this chapter

| Method / framework | When to use | Why |
|-------------------|-------------|-----|
| **95% confidence interval** | Any primary estimate | Shows precision; preferred over “NS” |
| **Bootstrap CI** | Small *n*; skew; nonstandard estimators | Resampling when formulas are doubtful |
| **CONSORT flow + checklist** | Randomised trials | Standard for enrolment, follow-up, analysis sets |
| **STROBE** | Observational cohorts and case-control | Transparency on selection, confounding, missingness |
| **TRIPOD** | Prediction model papers | Discrimination, calibration, validation stated |
| **Multiplicity adjustment** | Secondary endpoints; omics screens | Controls false positives across families of tests |
| **Prespecified sensitivity analyses** | MAR, batch, model form | Shows stability; not post hoc rescue |
| **REMARK / omics reporting** | Biomarker discovery lists | Effect size + q + validation plan |

**Extensions:** [Alternatives & extensions](#alternatives--extensions-evidence-quality-toolkit) at chapter end.

---

## Where we go next

**Next:** Prediction workflows → [Chapter 9](09-prediction-vs-inference.md). Discovery on marker panels → [Chapters 10–12](10-dimensionality-reduction.md). Omics → [Chapter 13](13-differential-analysis-fdr.md).

{{< include ../_includes/chapter-see-also.md >}}

**Near neighbors:** Ch [9](chapters/09-prediction-vs-inference.md) · [Appendix O](../appendix-o-ch04-comparison-extensions.md) (NI reporting)

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Efron & Tibshirani, *An Introduction to the Bootstrap* [@efron1993bootstrap]
- Steyerberg, *Clinical Prediction Models* [@steyerberg2019clinical]

## Exercises ([Solutions](../solutions/ch08_solutions.md))
