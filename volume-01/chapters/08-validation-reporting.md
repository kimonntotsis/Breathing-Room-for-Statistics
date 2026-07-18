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

Resample rows with replacement when the statistic has no closed-form CI (median difference, complex estimands). Complements parametric CIs; does not fix wrong design.

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
| **CONSORT** | RCT | Flow diagram, randomisation, primary outcome [@schulz2010consort] |
| **STROBE** | Observational | Eligibility, confounding, missing data [@vonelm2007strobe] |
| **TRIPOD** | Prediction | Validation, calibration, model specification [@moons2015tripod] |

Checklists improve transparency; they do not replace correct analysis. Cite checklist version/year; full protocol in supplement.

**Methods snippet:** We followed CONSORT 2010 guidelines [@schulz2010consort]. The analysis plan was prespecified before unblinding (supplementary protocol).

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

## Related chapters

| Chapter | When to open it |
|---------|------------------|
| [Chapter 3: Descriptive analysis](03-descriptive-analysis.md#plot-choice-by-estimand) | Table 1, plots, distribution checks |
| [Appendix O: Ch 4 comparison extensions](../appendix-o-ch04-comparison-extensions.md#technique-non-inferiority-and-equivalence-trials) | Non-inferiority, equivalence, clustered designs |
| [Chapter 9: Prediction vs inference](09-prediction-vs-inference.md) | AUC, calibration, nested CV |
| [Chapter 13: Differential analysis & FDR](13-differential-analysis-fdr.md) | Omics discovery, BH-FDR |
| [Chapter 18: Longitudinal mixed models](18-longitudinal-mixed-models.md) | Repeated FEV₁, slopes, clustering |
| [Chapter 20: Missing data](20-missing-data.md) | MAR/MNAR, MICE, sensitivity analyses |

## Handbook resources

| Resource | When to use it |
|----------|----------------|
| [Appendix B: Quick reference](../appendix-b-quick-reference.md) | Choose a test or model by outcome and design |
| [Appendix I: Figure hygiene](../appendix-i-figure-hygiene.md) | Right vs wrong plot pairs for slides and papers |

## Further reading

- Harrell, *Regression Modeling Strategies* [@harrell2015rms]
- Efron & Tibshirani, *An Introduction to the Bootstrap* [@efron1993bootstrap]
- Steyerberg, *Clinical Prediction Models* [@steyerberg2019clinical]

## Exercises ([Solutions](../solutions/ch08_solutions.md))

