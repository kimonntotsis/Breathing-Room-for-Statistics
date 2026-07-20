---
number-sections: false
---

# Appendix R: Catalogue of wrong analyses {.unnumbered}

> **Searchable reference.** Each chapter keeps the **two highest-risk mistakes** inline. This appendix consolidates the full list in the handbook's standard four-part format.

| Column | Content |
|--------|---------|
| **What went wrong?** | The mistake in one line |
| **Why it matters** | Estimand, bias, or misleading clinical read |
| **Better approach** | Prespecified method or reporting rule |
| **What to report** | Effect + uncertainty + denominators + limits |

---

## Chapter 1 — Statistical thinking {#chapter-1}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Menu-driven statistics on every column | Answers no prespecified question | Estimand-first CASTOR workflow | One primary estimand sentence |
| *p*-value without CI | Hides compatible effect sizes | Estimate + 95% CI + *n* | Mean difference or OR with CI |
| "Trend" without prespecified trend test | Inflates false positives | Pre-specify trend test or label exploratory | Named test or exploratory label |
| Causal language from cohort OR | Design does not support causation | Associational language + STROBE limits | "Associated with," not "causes" |
| Evaluate explanatory model by AUC only | Wrong success metric for inference | CI, prespecified estimand | OR/β with CI, not AUC alone |
| Skip protocol exacerbation definition | Non-comparable events | Cite Hurst/GOLD definition | Definition in Methods |

---

## Chapter 2 — Respiratory data {#chapter-2}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| *t*-test on binary exacerbation Y/N | Wrong outcome family | Fisher / logistic (Ch 4, 6) | Proportions + OR or RD |
| *t*-test on exacerbation counts | Count data ≠ Gaussian | Poisson / NB (Ch 6) | Rate ratio + person-time |
| `lm()` on 0/1 outcome | Predictions outside [0,1] | Logistic (Ch 6) | OR with events per variable |
| Ignore pairing in pre/post BD | Inflated false positives | Paired *t* / Wilcoxon (Ch 4) | Mean change + CI, *n* pairs |
| Repeated FEV₁ as independent rows | SEs too small | Mixed models (Ch 18) | Patient *n*, not visit *n* |
| Survival as 12-month binary only | Loses timing information | Cox / KM (Ch 19) | Events, person-time, HR with CI |
| Pool flow cells as sample size | Pseudoreplication | Participant-level inference (Ch 15) | *n* patients, not *n* cells |
| Cluster on markers + FEV₁ then predict FEV₁ | Circular discovery | Cluster markers only (Ch 11) | Holdout outcomes |
| Omics heatmap without batch check | Technical not biological | Batch QC first (Ch 14) | Batch-coloured PCA before claims |

---

## Chapter 3 — Descriptive analysis {#chapter-3}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Hide missing *n* in Table 1 | Selection bias invisible | Missingness table + flow | *n* analysed vs enrolled |
| Table 1 *p*-values as balance test | Confounds balance with sample size | SMD or descriptive only | SMD thresholds, not *p* |
| Mean ± SD on heavy skew | Misleading centre | Median [IQR] or log scale | Scale choice in caption |
| Axes without units | Uninterpretable figures | Litres, %, events/year | Units on every axis |
| Skip plots; trust test only | Outliers/skew unseen | Histogram/violin before Ch 4 | Figure 1 matches estimand |
| Pearson *r* only for two spirometers | Correlation ≠ agreement | Bland–Altman (this chapter) | Mean bias, limits of agreement |
| Average all manoeuvres without QC | Dilutes lung function | ATS/ERS grade rules | QC exclusions documented |
| Ignore site/equipment effects | Confounded comparisons | Site in model or random effect | Calibration log |

---

## Chapter 4 — Comparing groups {#chapter-4}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| *t*-test on binary exacerbation | Wrong model family | Logistic / compare proportions | RD or OR + CI |
| *t*-test on count exacerbations | Count ≠ continuous | Poisson / NB (Ch 6) | Rate ratio + offset |
| Ignore pairing in pre/post BD | Independence assumed wrongly | Paired *t* / signed-rank | Paired mean difference |
| ANOVA then all pairwise ad hoc | Multiplicity inflation | Prespecified contrasts / Tukey | Adjusted *p* or CI family |
| Claim equivalence from *p* > 0.05 | NS ≠ equivalent | NI margin or TOST (Appendix O) | CI vs Δ |
| Pool sites without clustering | SEs too small | Mixed `(1 \| centre)` (Ch 18) | Cluster-adjusted CI |
| Cluster RCT as patient-level Welch | Wrong unit of inference | Cluster-aware model (Appendix O) | ICC, cluster *n* |
| Label unadjusted test "adjusted" | Misleading Methods | Prespecified covariates in regression | Unadjusted vs adjusted labelled |

---

## Chapter 5 — Linear models {#chapter-5}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| `lm()` on 0/1 exacerbation | Invalid predictions | Logistic (Ch 6) | OR, not β from lm |
| Drop non-significant covariates post hoc | Inflates type I error | Prespecified SAP model | Primary vs sensitivity models |
| Causal language from cross-sectional β | Design limits | "Associated with" | STROBE limits |
| Change score when ANCOVA prespecified | Less efficient estimand | Baseline-adjusted follow-up | ANCOVA β with CI |
| Adjust for post-randomisation FEV₁ | Blocks causal path | Prespecify mediator vs confounder | Estimand label (Ch 21) |
| Report *R²* as primary evidence | Not clinical estimand | β in natural units (mL) | FEV₁ difference + CI |
| Log transform without back-transform | Wrong scale for readers | Report on original or log scale clearly | Scale in Results |
| FEV₁ and FVC both without collinearity check | Unstable coefficients | VIF / choose one | Sensitivity without both |

---

## Chapter 6 — Generalized linear models {#chapter-6}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Linear regression on 0/1 outcome | Predictions unbounded | Logistic | OR + event count |
| OR as RR when events common | Exaggerates risk | Log-binomial / modified Poisson | RR or marginal RD |
| Poisson without person-time offset | Wrong rate estimand | `offset(log(person_years))` | Events per person-year |
| Ignore overdispersion | False precision | NB / quasi-Poisson | Dispersion statistic |
| Causal claim from adjusted logistic | Observational limits | Associational language | STROBE + event *n* |
| 50 predictors, 20 events | Overfitting | Penalize / reduce EPV | Firth if separation |
| Linear model on mMRC 0–4 | Ordinal treated as equal spacing | Ordinal logistic | Proportional odds OR |
| Zero-inflated model for "many zeros" | Unjustified structural zeros | NB first | Justify ZI biologically |
| First-event Cox when rate is SAP | Wrong estimand | NB rate (Ch 6 router) | Rate ratio + person-time |

---

## Chapter 7 — Model building {#chapter-7}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Stepwise for primary endpoint | Data-driven model | Prespecified covariates | SAP model verbatim |
| Tune hyperparameters on test set | Optimistic performance | CV on training only (Ch 9) | Nested CV when tuning |
| 30 predictors, 18 events | Unstable fits | Penalization / fewer predictors | EPV in Methods |
| Adjust for collider | Opens bias | DAG-informed set (Ch 21) | Variables with roles |
| AIC-min model as confirmatory | Exploratory selection | Label exploratory | Pre-specified primary |
| Mix inference and prediction selection | Wrong criteria | Choose purpose first (four modes) | Separate labelled models |
| Shop covariates until exposure significant | P-hacking | Prespecified adjustment | Sensitivity only if post hoc |

---

## Chapter 8 — Validation and reporting {#chapter-8}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| *p*-value only in Results | Hides clinical span | Estimate + CI + *n* | CI vs MCID |
| Post hoc primary endpoint | Inflated false positives | Prespecified SAP | Protocol citation |
| No CONSORT flow (RCT) | Attrition opaque | CONSORT 2025 flow | Enrolled vs analysed *n* |
| Hide missing *n* | Selection bias | Attrition table | Missingness by arm |
| No reproducible script | Not verifiable | `source()` path + seed | Software versions |
| "Non-significant → no benefit" | Inconclusive ≠ null | CI language | Compatible effects |
| Bootstrap at wrong unit | Invalid CI | Patient/cluster resample | Unit stated in Methods |
| Omics and clinical endpoints one α-family | Multiplicity error | Separate FDR family | Two multiplicity rules |

---

## Chapter 9 — Prediction {#chapter-9}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Training AUC in abstract | Optimistic discrimination | Held-out or CV AUC | Test-set events |
| ML wins on 4 test events | Noise, not signal | Prefer simpler model + CI | Bootstrap CI on AUC |
| RF importance as biomarker list | Prediction ≠ mechanism | Separate discovery (Ch 13+) | Internal validation label |
| No calibration figure | Risk percentages untrustworthy | Calibration plot + Brier | Binned predicted vs observed |
| Imputation leakage in CV folds | Inflated performance | Impute inside train (Ch 20) | MI within folds |
| "Validated tool" without external cohort | No transport evidence | External validation (Ch 9) | Geographic/temporal validation plan |
| Threshold optimised on validation set | Overfit threshold | Prespecify clinical threshold | Sensitivity/specificity at fixed cut |
| Deploy without missing-predictor rule | Pipeline breaks in clinic | Locked imputation/scoring | Deployment checklist |

---

## Chapters 10–11 — Structure discovery {#chapter-10-11}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Pick method with best-looking separation | Overfit visual | Stability + external validation | Bootstrap stability |
| PCA including outcome then cluster | Circular | PCA on markers only | Holdout outcomes |
| No scaling before PCA | Dominated by units | Scale prespecified | Scaling rule in Methods |
| Name PC1 "inflammatory axis" immediately | Premature biology | Loadings + replication | Exploratory label |
| Use PCA scores as validated subtypes | No performance metric | Supervised validation if claiming class | AUC on held-out labels |
| Cluster on markers + FEV₁ | Circular with lung function | Markers only | External outcome linkage |
| "Validated endotypes" from one cohort | No replication | Claim ladder (Ch 11) | Rung reached |
| Ignore batch in cluster colour | Technical clusters | Colour by batch first | Batch ARI |
| Choose *k* by outcome separation | Circular | Internal stability metrics | Silhouette + bootstrap |
| Precision medicine claim at *n* = 80 | Unstable clusters | Honest sample size | Stability CIs |

---

## Chapter 12 — Case studies {#appendix-r-chapter-12}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| NS → treatments equal (Case A) | Equivalence needs margin | CI vs MCID | Inconclusive language |
| Mixed BD protocol across arms | Biased FEV₁ contrast | Same spirometry standard | Protocol citation |
| `lm` on 0/1 (Case B) | Wrong family | Logistic | OR + events |
| OR as "% more risk" (Case B) | Non-collapsibility | Marginal RD | Absolute risks |
| "Validated endotypes" (Case C) | Discovery ≠ validation | Exploratory clusters | External cohort plan |
| Test outcome then cluster (Case C) | Circular | Unsupervised then validate | Holdout linkage |
| Proteomics validates endotype (Case D) | Different questions | Separate paragraphs | FDR + replication |
| Cell-level *n* in omics (Case D) | Pseudoreplication | Patient-level | *n* participants |
| Pool all visits (Case E) | Pseudo-replication | Mixed model | Patient *n* |
| HR without event counts (Case E) | HR alone misleading | Events + person-time | KM + table |

---

## Chapters 13–14 — Omics and batch {#chapter-13-14}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Hits without effect sizes | Cannot judge importance | β + CI + q | Effect + FDR |
| Nominal *p* hunting across features | False discovery | BH-FDR entire family | *m* tests, FDR threshold |
| Volcano as proof of biology | Discovery only | Replication plan | q-values + validation |
| Ignore batch entirely | Technical signal | Batch covariate / sensitivity | With vs without batch |
| Adjust when batch == group | Non-identifiable | Redesign / report confounding | Cannot adjust |
| ComBat before train/test split | Leakage | Fit adjustment in train | Nested preprocessing |
| LOD coded as zero | Distorts low abundance | Assay-specific missing rule | Detection limits |
| "No significant hits = no biology" | Honest null is valid | Report QC + power | Transparent null |
| Single-cohort signature claim | Unstable | External validation | Independent cohort |
| "Batch corrected" one-liner in abstract | Hides methods | Full batch workflow | Adjustment method named |

---

## Chapters 15–17 — Flow, screens, integration {#chapter-15-17}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Cell-level tests as patient inference | Pseudoreplication | Mixed model / aggregate | *n* patients |
| UMAP + k-means as new cell types | Unvalidated labels | Expert gating + stability | Gating strategy |
| Screen *p* as final evidence | High false discovery | Confirmation tier | PPV of screen |
| Post hoc hit threshold | Optimistic PPV | Prespecified cut | Threshold frozen |
| Tune λ on full omics matrix | Leakage | Nested CV (Ch 17) | Outer/inner folds |
| Impute before split in prediction | Leakage | MI inside train folds | Pipeline diagram |
| Training AUC for deployment | Optimism | External validation | Transport statement |
| Clinical utility from AUC alone | No threshold decision | DCA / calibration (Ch 9) | Net benefit if claimed |

---

## Chapters 18–19 — Longitudinal and survival {#chapter-18-19}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Week-52 *t*-test with 4 visits/patient | Pseudo-replication | Mixed model | Random effects + CI |
| Pooled visits in `lm()` | SEs too small | `(1 \| patient_id)` | Patient *n* |
| Change score vs prespecified ANCOVA | Less efficient | Baseline-adjusted | SAP estimand |
| Ignore informative dropout | Biased slopes | Sensitivity (Ch 20) | Missingness mechanism |
| 12-month binary only (survival) | Loses timing | Cox if time matters | HR + events |
| Censored = never event | Misleading KM | Censoring definition | Numbers at risk |
| HR without events/person-time | Uninterpretable magnitude | Event table | Absolute risks |
| Death censored in exacerbation Cox | Overstated cumulative risk | Fine–Gray / CIF | Competing events table |
| First-event Cox for recurrent SAP | Wrong estimand | NB rate / Andersen–Gill | Estimand label |
| Non-significant PH test = PH OK | Low power / trivial departures | Schoenfeld plots + RMST | Sensitivity if PH fails |

---

## Chapters 20–22 — Missing data, causal, mediation {#chapter-20-22}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Complete-case default | MNAR/MAR ignored | Primary + sensitivity | *n* complete vs enrolled |
| Single imputation (mean/mode) | Underestimates uncertainty | MICE + pooling | Rubin rules |
| Future info in deployment imputation | Leakage | Train-fold MI only | Locked pipeline |
| LOCF without stating it | Hidden assumption | Label LOCF sensitivity | MNAR discussion |
| Adjusted OR proves smoking causes (Ch 21) | Observational | Associational estimand | STROBE limits |
| All predictors in propensity model | Overfit PS | DAG covariate set | Balance diagnostics |
| IPW without weight inspection | Extreme weights dominate | ESS, truncation sensitivity | Weight summary |
| Adjust mediator for total effect | Blocks pathway | Prespecify estimand | Total vs direct labelled |
| Immortal time bias in therapy cohorts | Misaligned time zero | Target trial emulation | Time zero definition |
| Report smoking OR as total after adjusting FEV₁ (Ch 22) | Direct not total effect | Mediation framework | ACME/ADE on probability scale |
| Baron–Kenny four-step ritual | Outdated inference | Bootstrap natural effects | CIs on indirect effect |

---

## Appendix O — Comparison extensions {#appendix-o}

| What went wrong? | Why it matters | Better approach | What to report |
|------------------|----------------|-----------------|----------------|
| Welch *t* on clustered ICU patients | Wrong independence | Mixed / GEE | Cluster unit |
| Cluster RCT analysed as individual RCT | Wrong SEs | Cluster-aware model | ICC, cluster size |

---

## How to use this appendix

1. During **protocol review**, scan the chapter matching your endpoint type.
2. In **manuscript sign-off**, confirm none of the "What went wrong?" rows appear in your Methods/Results without the "Better approach."
3. In **teaching**, assign trainees to critique a published abstract against one section here.

Related: [Appendix I — Figure hygiene](appendix-i-figure-hygiene.md) · [CHAPTER_TEMPLATE](CHAPTER_TEMPLATE.md)
