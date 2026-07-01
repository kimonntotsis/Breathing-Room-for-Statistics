---
number-sections: false
bibliography: ../references.bib
link-citations: true
---

# Appendix C: Glossary {.unnumbered}

Plain-language and precise definitions for terms used across Chapters 0–21. For method choice, see [Appendix B](appendix-b-quick-reference.md).

```{=latex}
\footnotesize
```

---

## For readers without R: how to use this glossary

When you see an unfamiliar word:

1. **Read the middle column first** (“Plain language”). That is the everyday meaning used in the chapters.
2. **Use the third column only if you are writing Methods** or reviewing analysis with a statistician.
3. **Ask three questions** (same habit as Chapter 1):
   - What number are they actually estimating?
   - Who is in the population?
   - What would I **not** conclude from this term alone?

Every major technique in the main chapters also has a **Practice read** line in the technique card. Use this appendix when the word appears outside that chapter: in someone else’s abstract, a steering-committee deck, or an omics email.

**If you are not running R:** skip [Appendix A](appendix-a-r-setup.md); you can still use this glossary and the statistical content in Chapters 1–21.

---

## Words that often mislead

These appear constantly in respiratory papers and meetings. The plain-language column states what people *think* they mean; the third column states the safer interpretation.

| Term | What people often think | Safer read |
|------|-------------------------|------------|
| **Statistically significant** | The treatment works / the biomarker is real | The data are incompatible with “no effect” under a chosen model; effect **size** and CI still matter |
| **Not significant** | No effect / treatments are equal | Data are inconclusive; equivalence needs a prespecified margin and power |
| **Trend** | Benefit is probably there | Unless a **prespecified** trend test was planned, avoid the word |
| **Adjusted** | Confounding removed; causal effect | Association conditional on measured covariates; unmeasured confounding may remain |
| **Multivariate** | Many variables in one model | Often misused; in papers, check whether they mean **multivariable** (several predictors, one outcome) |
| **AI / machine learning** | Objective, deployable tool | Often a fitted model needing validation, calibration, and governance; see Ch 9 |
| **Signature** | Validated biomarker panel ready for clinic | Usually a **discovery list** needing replication and batch QC (Ch 13–17) |
| **Real-world evidence** | Truth about routine care | Observational data; useful but rarely substitutes for randomisation for causal claims |
| **Exploratory** | Less important | Still must be labelled honestly; not a licence to ignore multiplicity |

---

## Commonly heard elsewhere (not central to this book)

Short entries for terms you may hear in respiratory research even when this handbook does not teach the full method. For depth, see the reading list in [References](references.qmd).

| Term | Plain language | Precise definition / caveat |
|------|----------------|----------------------------|
| **NNT (number needed to treat)** | How many patients you need to treat for one extra benefit | NNT = 1 / absolute risk reduction; depends on baseline risk and follow-up |
| **Per-protocol analysis** | Only patients who adhered to treatment | Estimand differs from ITT; can bias treatment comparison if adherence is outcome-related |
| **Non-inferiority / equivalence** | New treatment is not worse than standard by more than a margin | Requires prespecified margin, sample size, and different testing logic than superiority |
| **Meta-analysis** | Combine results from several studies | Weighted summary of published estimates; sensitive to publication bias and heterogeneity |
| **Bayesian analysis** | Update beliefs with data using prior + likelihood | Produces posterior distributions; not “more objective”: priors and model matter |
| **Frequentist** | Inference without explicit prior distributions | p-values, CIs, and long-run error rates (this handbook’s default framing) |
| **Propensity score** | Balance groups on observed covariates | Summary of treatment probability given covariates; matching/weighting tool; not in main CASTOR path (see IPW in Ch 21) |
| **Fragility index** | How many outcome flips change significance | Sensitivity of p-value to binary misclassification; low index = fragile result |
| **Standard error (SE)** | Uncertainty of an **estimate** (e.g. mean) | SD of the sampling distribution of a statistic; **not** the same as patient-to-patient SD |
| **Standard deviation (SD)** | Spread of values **in the sample** | Typical distance from the mean; describes patients, not uncertainty of the mean |
| **Heterogeneity** | Studies or sites differ beyond chance | In meta-analysis or multi-centre trials; may need random effects or stratification |
| **Interaction** | Effect of treatment differs by subgroup | Requires prespecification; often underpowered; distinguish from post-hoc subgroup fishing |
| **Mediator** | Variable on the causal path between exposure and outcome | Adjusting for a mediator can block part of the effect you care about |
| **Collider** | Variable caused by both exposure and outcome | Conditioning on it can **induce** spurious association (DAG reasoning; Ch 21) |
| **Registry / pre-registration** | Analysis plan recorded before seeing results | Reduces HARKing; does not guarantee correct methods |

---

## Core statistical concepts

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **Estimand** | The target number your analysis should estimate | A precise numerical summary defined for a specific population under a stated treatment or exposure condition |
| **Parameter** | Unknown truth in the population | Fixed quantity in a statistical model (e.g. beta in regression) |
| **Statistic** | Number computed from your sample | Function of observed data (e.g. sample mean, test statistic) |
| **p-value** | How surprising the data would be if there were truly no effect | Probability, under the null model, of data at least as extreme as observed |
| **Confidence interval (CI)** | Range of plausible values for the effect | Interval procedure with stated long-run coverage probability (e.g. 95%) |
| **Type I error** | False alarm: declaring an effect when none exists | Rejecting a true null hypothesis |
| **Type II error** | Miss: failing to detect a real effect | Not rejecting a false null hypothesis |
| **Power** | Chance of detecting an effect if it exists | 1 − P(Type II error) under a specified alternative |
| **Null hypothesis** | “No effect” reference for a test | Model or parameter value representing no association or no difference (context-specific) |
| **Effect size** | How big the difference is, not just whether it is “significant” | Magnitude on the scale of the estimand (mean difference, OR, HR, etc.) with CI |
| **Sensitivity analysis** | Check whether the conclusion survives reasonable alternatives | Repeat analysis under alternate defensible assumptions or methods |
| **Multiplicity** | Many tests inflate false positives | Multiple-comparison problem; requires prespecification or adjustment (e.g. FDR) |

---

## Study design and reporting

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **RCT** | Patients randomly assigned to treatment | Randomised controlled trial; supports causal effect under stated estimand (ITT, etc.) |
| **Cohort** | Follow a group forward in time | Observational design measuring exposure then outcome; association, not automatic causation |
| **Case–control** | Start from outcome, look back at exposure | Retrospective design; odds ratios natural; incidence rates not directly estimable |
| **Intention-to-treat (ITT)** | Analyse as randomised, regardless of adherence | Estimand: effect of assignment policy, not only those who took all doses |
| **ANCOVA** | Compare groups while adjusting for baseline | Linear model with outcome and baseline (and covariates); common for trial FEV1 |
| **Confounding** | Another factor distorts the exposure–outcome link | Common cause of exposure and outcome, or selection inducing spurious association |
| **Selection bias** | Sample is not representative of target population | Systematic difference between analysed sample and inferential population |
| **CONSORT** | Reporting checklist for RCTs | Consolidated Standards of Reporting Trials [@schulz2010consort] |
| **STROBE** | Reporting checklist for observational studies | Strengthening the Reporting of Observational Studies [@vonelm2007strobe] |
| **TRIPOD** | Reporting checklist for prediction models | Transparent Reporting of multivariable Prediction models [@moons2015tripod] |
| **MCID** | Smallest change patients and trial teams care about | Minimum clinically important difference |

---

## Regression and GLMs

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **Linear regression** | Model mean of continuous outcome from predictors | Y = X*beta + error; Gaussian errors (diagnostics required) |
| **GLM** | One framework for non-Gaussian outcomes | Generalised linear model: exponential family + link function + linear predictor |
| **Link function** | Connects mean outcome to predictors | Monotonic g with g(mu) = X*beta in GLMs |
| **Logistic regression** | Model probability of a yes/no outcome | Binomial GLM with logit link; coefficients are log-odds |
| **Odds ratio (OR)** | Multiplicative change in odds | exp(beta) in logistic regression; approximates RR only when outcome is rare |
| **Risk ratio (RR)** | Multiplicative change in risk | Ratio of probabilities; may need log-binomial or modified Poisson when common |
| **Poisson regression** | Model event counts | GLM for counts with log link; assumes mean = variance unless extended |
| **Negative binomial (NB)** | Count model when variance exceeds mean | Overdispersed count GLM; default sensitivity when Poisson residuals are too small |
| **Offset** | Fixed adjustment for exposure time | Known component of linear predictor with coefficient fixed at 1 (e.g. log person-years) |
| **Overdispersion** | Count data more variable than Poisson expects | Variance > mean in count outcomes |
| **Rate ratio** | Multiplicative change in expected count rate | exp(beta) in log-link count models with appropriate offset |
| **Firth penalisation** | Stabilise logistic regression when events are sparse | Penalised likelihood reducing separation bias in sparse binary outcomes |
| **LASSO / elastic net** | Shrink many predictors toward zero | Penalised regression; useful for prediction with many features; requires proper resampling |

---

## Prediction, validation, and discovery

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **Inference** | Estimate an association or treatment effect | Focus on interpretable coefficients, CIs, and prespecified estimands |
| **Prediction** | Forecast outcomes for new patients | Focus on calibration, discrimination, and transportability |
| **Overfitting** | Model memorises this dataset | Low error on training data but poor generalisation to new data |
| **Calibration** | Predicted risks match observed rates | Agreement between predicted probabilities and empirical outcome frequencies |
| **Discrimination** | Model ranks high-risk above low-risk | Ability to separate cases from non-cases (e.g. AUC, C-statistic) |
| **AUC** | Area under ROC curve | Probability a random case has higher predicted risk than a random non-case |
| **Cross-validation** | Estimate performance on held-out data | Resampling to reduce optimism; nested CV when tuning hyperparameters |
| **Data leakage** | Test information entered training | Inflated performance; includes preprocessing before split, batch correction on full data |
| **Bootstrap** | Resample data to estimate uncertainty | Nonparametric simulation of sampling distribution by resampling with replacement |
| **PCA** | Find weighted combinations capturing variance | Orthogonal linear combinations from eigen decomposition of covariance/correlation matrix |
| **Clustering** | Group similar patients | Unsupervised partition or hierarchy by dissimilarity; not confirmatory without validation |
| **Endotype** | Proposed disease subgroup | Hypothesis-generating label; requires stability, replication, and often prognostic validation |

---

## High-dimensional biology and omics

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **Differential expression / abundance (DE/DA)** | Which features differ between groups | Per-feature model comparing groups with multiplicity control |
| **FDR (false discovery rate)** | Expected fraction of “hits” that are false | Benjamini–Hochberg (BH) q-value: adjusted significance across many tests |
| **q-value** | FDR-adjusted significance for one feature | Threshold on q (e.g. 0.10) controls expected false discovery proportion |
| **Volcano plot** | Effect size vs significance for many features | Scatter of log-fold-change vs −log10(p); descriptive; inference is per-feature model + FDR |
| **Batch effect** | Technical variation from lab/run/site | Systematic measurement difference not due to biology; can mimic or hide group effects |
| **LOD (limit of detection)** | Protein below measurable level | Missing or censored low abundance in proteomics; must not be silently imputed as zero |
| **Library size (RNA-seq)** | Total reads per sample | Confounds gene counts; handled via offset or normalisation in count models |
| **Pseudo-replication** | Treating correlated units as independent | e.g. pooling cells as if each cell were a patient; inflates significance |
| **Compositional data** | Parts that sum to a whole (e.g. cell %) | Proportions bounded and correlated; interpret at participant level; specialised methods optional |
| **PPV (positive predictive value)** | Among screen hits, fraction truly positive | Confirmation assay yield; central to antibody and biomarker triage |
| **Stability tier** | Replicate consistency of ranked hits | e.g. overlap of top-*K* lists across technical replicates |

---

## Longitudinal, survival, and missing data

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **Mixed model** | Fixed effects + random effects for clustered/repeated data | Hierarchical model (e.g. `lmer`) with population-level and cluster-specific components |
| **Random intercept** | Each patient has their own baseline level | Random effect allowing cluster-specific intercept in mixed models |
| **GEE** | Population-averaged model for repeated measures | Generalised estimating equations; robust SEs; alternative to mixed models |
| **Time-to-event** | Time until exacerbation, death, etc. | Outcome is duration; censoring must be modelled |
| **Censoring** | Follow-up ends before event | Observation contributes time up to censoring; event indicator = 0 |
| **Kaplan–Meier** | Nonparametric survival curve | Step function estimating survival with censored observations |
| **Hazard ratio (HR)** | Instantaneous event rate ratio | Multiplicative change in hazard at time *t* (Cox model); not a risk difference |
| **Proportional hazards** | Relative hazard constant over time | Cox assumption; check with Schoenfeld residuals or time-varying terms |
| **MAR** | Missingness explainable by observed data | Missing at random; conditional on observed covariates and outcomes in model |
| **MNAR** | Missingness related to unobserved values | Missing not at random; sensitivity analyses required |
| **Complete-case analysis** | Drop rows with any missing | Simple but biased if missingness is informative |
| **Structural missingness** | Absent by design or eligibility | Do not impute into full cohort; separate denominator |
| **Intermittent missingness** | Gap at one visit, later data exist | Common in longitudinal spirometry |
| **IPW** | Reweight to balance exposed groups | Inverse probability weighting; sensitivity for confounding in observational data, not proof of causation |
| **DAG** | Diagram of causal paths | Directed acyclic graph for confounder, mediator, and collider reasoning |

---

## Respiratory research terms (brief)

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **FEV1** | Forced expiratory volume in 1 second | Primary spirometry outcome (litres); often % predicted for adjustment |
| **FVC** | Forced vital capacity | Total exhaled volume; used with FEV1 for obstruction patterns |
| **Post-bronchodilator (post-BD)** | Spirometry after bronchodilator | Different measurement condition from pre-BD; must match across arms |
| **Exacerbation** | Worsening episode requiring treatment | Endpoint may be binary (any Y/N), count (number per year), or time-to-first |
| **6MWD** | Six-minute walk distance | Continuous functional outcome (metres) |
| **mMRC** | Dyspnoea scale 0–4 | Ordinal symptom measure |
| **COPD** | Chronic obstructive pulmonary disease | Obstructive lung disease context for many CASTOR examples |
| **CASTOR** | Analysis workflow (**C**linical question → **A**ssess → **S**elect → **T**est → **O**utput → **R**eport limits) and synthetic teaching cohort | Mnemonic for question-first analysis; spelled out in [Preface](chapters/00-preface.md#what-castor-means) and [Ch 1](chapters/01-statistical-thinking.md); data in [RECURRING_COHORT](RECURRING_COHORT.md) |
| **CASTOR-HD** | Synthetic omics extension | Proteomics, RNA, flow, and antibody teaching datasets (Ch 13–17) |

---

