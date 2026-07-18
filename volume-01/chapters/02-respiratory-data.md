# Chapter 2: Data in Respiratory Research

> **Part I: Foundations**

## Opening scene: the data dictionary meeting

Mei spreads a printout across Dr Rivera's desk. CASTOR's first clean export: patient ID, age, sex, smoking, therapy line, FEV₁, FVC, exacerbation yes/no, exacerbation counts, visit week. The protocol mentions a primary endpoint; the spreadsheet mentions twelve other columns that could become "exploratory primaries" if someone is tired on a Friday.

*"Which column is the outcome?"* Rivera asks. *"All of them,"* Mei says, *"until we decide which one answers the protocol. That's today."*

Classify outcome type, unit of analysis, and design **before** any test name.

---

## Why this chapter

The wrong method usually starts with the wrong **outcome type**, not the wrong R function. When you finish here, you can complete the pre-analysis checklist at chapter end and route to the right technique chapter; not to a menu of tests.

---

## The cohort you are classifying

**CASTOR** is the synthetic COPD-oriented trial cohort in `data/*.csv`, clean **on purpose** so you can learn routing. **CASTOR-HD** adds omics files for Part VI. **POLLUX** is the messy-registry counterpart: narrative in [POLLUX_VIGNETTE](../POLLUX_VIGNETTE.md) plus executable export `data/pollux_registry_messy.csv` and cleaning script `R/examples/pollux_clean_registry.R`.

CASTOR’s disease labels say COPD; the routing logic applies across **chronic lung disease** and asthma programmes whenever endpoints and design match, FEV₁ arms, binary or count exacerbations, survival, omics.

**Asthma example (same routing, different estimand):** *Among adults with severe eosinophilic asthma on ICS/LABA, what is the mean difference in post-BD FEV₁ (L) at week 12, biologic vs placebo, ITT?* Pick **one** primary before unblinding; route exacerbation secondaries to count or survival chapters, not a parallel primary.

---

## The data classification workflow

1. **Name the estimand** in one sentence (Ch 1).
2. **Identify the outcome** column and its type (continuous, binary, count, …).
3. **Identify the unit of analysis** (patient, visit, cell, protein).
4. **Map design**: cross-sectional, paired, longitudinal, clustered, survival.
5. **List roles**: exposure, confounders, mediators (do not fish).
6. **QC**: ranges, IDs, missingness, units.
7. **Route** to the right chapter (Handbook resources).

---

## Worked vignette: one spreadsheet, three different questions

Same CASTOR columns (`patient_id`, `age`, `sex`, `smoking`, `therapy`, `fev1`): three valid analyses, three method paths:

| Question | Outcome | Unit | Route |
|----------|---------|------|-------|
| Mean FEV1 by smoking? | `fev1` (continuous) | Patient | Welch *t*-test Ch 4 |
| 12-month exacerbation by smoking? | `exacerbation_12m` (binary) | Patient | Logistic Ch 6 |
| FEV1 trajectory on therapy? | `fev1` at each visit | Patient (repeated) | Mixed model Ch 18 |

**Wrong:** run all three and report whichever has the smallest *p*-value.

### POLLUX contrast: same questions, messy export

CASTOR teaches routing on clean files. **POLLUX** (`data/pollux_registry_messy.csv`) adds site IDs, slipped visit weeks, spirometry QC flags, and MNAR-leaning missing FEV1. Before any model, run the cleaning script and read the flow table:

```r
source("R/examples/pollux_clean_registry.R")
readr::read_csv("volume-01/tables/pollux_enrollment_flow.csv")
```

| Step | What to check | POLLUX teaching habit |
|------|---------------|------------------------|
| Enrolled *n* vs analysed *n* | QC failures, missing FEV1 | Report both in Methods |
| Visit week | Scheduled vs observed window | Do not treat −6 as week 0 |
| Site | `site_id` counts | Cluster-robust SE or random effect |
| GOLD stage | Missingness by severity | MNAR sensitivity (Ch 20) |

Output: `data/pollux_registry_clean.csv` is **analysis-ready for one prespecified snapshot**, not a substitute for full registry governance.

**Related story:** Appendix K, Stories 1 and 3 (Handbook resources).

---

## Variables: outcome, exposure, covariate

Every column has a **role** that depends on the question. The **outcome** is what you measure as the result, FEV1, exacerbation, death, hospitalisation. The **exposure/predictor** is the factor hypothesised to influence it, treatment, smoking, biomarker, air pollution. A **covariate/confounder** is what you account for so the exposure–outcome link is not distorted, age, sex, height, severity, centre.

The same variable **changes role by question**. *Therapy* is an **exposure** in a treatment-effect analysis and a **covariate** when studying biomarkers on a background of standard care. In `exacerbation.csv`, `smoking` may be exposure when predicting `exacerbation_12m`, but a **confounder** when studying a biomarker's association with FEV1 if smoking affects both.

Know which column is the "answer" and which might distort the link. Causal diagrams (Ch 21) formalise which variables must be adjusted; earlier chapters use subject-matter knowledge and protocol [@harrell2015rms]. If you adjust for a variable **caused by** the exposure (a mediator), you may hide a real effect, discuss with your analyst.

### In practice

Real spreadsheets mix litres and millilitres, duplicate IDs, and “exacerbation” columns defined differently across sites. Run the quality checks in this chapter **before** you fit models, not after the output looks interesting.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Treat every column as a predictor in a fishing expedition |
| **Do instead** | Prespecify outcome, exposure, prespecified confounders |

---

## Outcome types: the master routing table

Choosing the wrong outcome type - treating a **count** as **binary**, or a **binary** endpoint as **continuous** - is among the most common errors in applied work [@stoltzfus2019biostatistics].

| Type | Examples | Handbook methods | Chapter |
|------|----------|------------------|---------|
| **Continuous** | FEV1 (L), FVC, 6MWD, scores | Mean, *t*-test, linear regression | Ch 3–5 |
| **Binary** | ≥1 exacerbation Y/N; died Y/N | Proportions, Fisher, logistic | Ch 4, 6 |
| **Count** | Exacerbations per year | Poisson, negative binomial | Ch 6 |
| **Proportion** | % with response (large *n*) | Logistic or linear | Ch 4 |
| **Ordinal (individual items)** | mMRC item 0–4; CAT item scores | Ordinal logistic on **ordered items** | Ch 6 |
| **Continuous (summary scores)** | CAT total, SGRQ total | Often treated as **continuous** in trials (prespecify); banded ordinal is a separate estimand | Ch 5–6 |
| **Time-to-event** | Time to first exacerbation | Kaplan-Meier, Cox | Ch 19 |
| **High-dimensional** | Proteomics, transcriptomics | PCA, clustering, penalized ML | Ch 10–17 |
| **Proportions (bounded)** | Flow cell-type % | Participant-level models | Ch 15 |

![Method decision tree - start from outcome type](../figures/method_decision_tree.png)

Start at the outcome node, not at “we always use a t-test”: the tree routes to the chapter that matches your estimand.

### Other respiratory settings

CASTOR is a **COPD-oriented** teaching cohort (FEV1, exacerbations, smoking, triple therapy). The routing table still applies elsewhere if you relabel the outcome:

- **Asthma trials** often prioritise exacerbation counts, oral steroid bursts, or ordinal symptom scores (ACQ, mMRC) alongside FEV1. Prespecify the primary endpoint before unblinding.
- **TB programme research** more often uses microbiological conversion, treatment completion, or mortality at fixed follow-up. Use the same chapter routes (proportions, counts, survival in Ch 4, 6, 19); FEV1 is rarely primary.

One estimand per analysis. Do not swap endpoints after seeing the tables.

### Practice check

If the protocol defines exacerbations as a **count** but the analyst runs a *t*-test on raw counts, the p-value may be wrong and the effect size uninterpretable → insist on Poisson/NB models (Ch 6).

---

## Data structures

| Structure | Definition | Unit of analysis | Handbook note |
|-----------|------------|------------------|---------------|
| **Cross-sectional** | One row per person, one time point | Patient | Independence assumed in Ch 4-6 |
| **Longitudinal** | Repeated measures per person | Patient-visit | Mixed models (Ch 18) |
| **Survival** | Time to event with censoring | Patient | Kaplan-Meier, Cox (Ch 19) |
| **Clustered** | Units nested (patients in hospitals) | Patient (with cluster adjustment) | Cluster-robust SE / mixed models (Ch 18) |
| **Case-control** | Sample enriched for cases | Case or control | OR natural; incidence not estimable [@agresti2018introduction] |
| **Paired** | Two measurements same subject | Patient | Paired *t*, McNemar (Ch 4) |
| **Per-cell omics/flow** | Many rows per person | **Not** independent patients | Summarise to participant first (Ch 15) |

### Dual interpretation

Repeated FEV1 on the same patients is **not** the same as two independent groups of people.

Formally: longitudinal and clustered data violate independence assumptions of standard *t*-tests and GLMs unless extended [@harrell2015rms].

---

## Respiratory-specific data domains

| Domain | Common variables | Pitfalls | Reference |
|--------|------------------|----------|-----------|
| **Spirometry** | FEV1, FVC, FEV1/FVC, % predicted | Pre- vs post-bronchodilator; quality grades | [@graham2019spirometry] |
| **Symptoms** | CAT, SGRQ, ACT | Patient-reported missingness; ordinal nature | |
| **Exacerbations** | Binary, count, severity | Definition varies by trial | [@hurst2010exacerbation] |
| **Imaging** | Emphysema fraction, airway wall area | High dimensionality; segmentation error | |
| **Omics** | Thousands of markers | *p* >> *n*; batch effects | [@mcshane2011biomarker] |
| **ICU / ventilation** | Waveforms, ventilator settings | Missing not at random; high frequency | |

Always document **definitions** in Methods. An exacerbation in one COPD trial is not necessarily the same in another [@hurst2010exacerbation].

**Spirometry essentials:** always specify pre- or post-bronchodilator timing, the reference equation for % predicted, and quality flags [@graham2019spirometry]. Mixing pre-BD in one arm and post-BD in another is a common trial failure. Use **% predicted** when comparing across age, sex, and height; use **litres** for within-trial mean differences when eligibility is narrow.

---

## Data quality checks (pre-analysis)

Before any model:

| Check | Action | Example failure |
|-------|--------|-----------------|
| **Range** | Plausible min/max | FEV1 < 0; FEV1/FVC > 1 |
| **Consistency** | Age, sex, height vs lung function | Adult with FEV1 6 L and height 150 cm |
| **IDs** | One row per estimand unit | Duplicate patient_id |
| **Missingness** | Pattern and amount | 40% missing FEV1 in one arm only |
| **Units** | Litres vs mL; pack-years definition | Mixed units in one column |
| **Protocol** | BD timing, visit windows | Visit 2 spirometry outside window |

### Reporting template

**Methods (data):**

> Spirometry was performed according to ATS/ERS standards [@graham2019spirometry]. Pre-bronchodilator FEV1 (litres) was the primary lung function outcome. Exacerbations were defined as [prespecified definition] [@hurst2010exacerbation]. Data quality checks included range validation and duplicate ID review.

---

## From question to data checklist

Complete **before** choosing a model:

| # | Question | If unclear → |
|---|----------|--------------|
| 1 | What is the **outcome** variable and its **type**? | Re-read protocol |
| 2 | What is the **unit of analysis** (patient, visit, cluster)? | Ch 2 §2.3 |
| 3 | Are observations **independent**, **paired**, or **clustered**? | Ch 4 design row |
| 4 | Was **randomisation** used? | Limits causal language |
| 5 | What **confounders** are available and justified? | prespecify in SAP |
| 6 | How much **missing data** and what pattern? | Ch 20 |
| 7 | What is the **estimand** in one sentence? | Ch 1 |

---

## CASTOR datasets: outcome type map

| File | Key variables | Outcome type | Primary chapter |
|------|---------------|--------------|-----------------|
| `spirometry.csv` | fev1, group, smoking | Continuous | Ch 3–5 |
| `spirometry_trial.csv` | baseline, follow-up FEV1 | Continuous (ANCOVA) | Ch 4–5 |
| `bronchodilator_paired.csv` | fev1_pre, fev1_post | Continuous, paired | Ch 4 |
| `exacerbation.csv` | exacerbation_12m | Binary | Ch 6 |
| `exacerbation_counts.csv` | exacerbations_12m, person_years | Count | Ch 6 |
| `marker_panel.csv` | M1–M30, processing_batch | High-dimensional | Ch 10–11 |
| `longitudinal_spirometry.csv` | fev1 by visit, group | Continuous, repeated | Ch 18 |
| `time_to_exacerbation.csv` | time_days, event | Time-to-event | Ch 19 |

---

## CASTOR-HD datasets (high-dimensional biology preview)

These files are designed for later "advanced discovery" chapters in a single-volume book. They illustrate recurring problems: \(p \gg n\), batch/plate/run effects, censored/missing values, multiplicity (FDR), and honest validation.

| File | What it represents | Key teaching points |
|------|---------------------|---------------------|
| `proteomics_olink_like.csv` | Olink-like protein panel (~1000 proteins) | LOD missingness, batch effects, DE, FDR |
| `rnaseq_counts.csv` | RNA-seq gene counts (~1200 genes) | Library size, NB models, DE, FDR |
| `flowcytometry_summary.csv` | Per-subject flow summaries | Proportions, drift, group comparisons |
| `flowcytometry_cells_toy.csv` | Small per-cell toy dataset | Gating vs clustering |
| `antibody_screen.csv` | Screening signals (replicates) | Hit calling, ranking stability |
| `antibody_confirmation.csv` | Confirmation assay (KD + positives) | PPV, confirmation discipline |

Reporting templates for these analyses are in HIGH_DIM_REPORTING_TEMPLATES.

---

## Catalog of wrong analyses (data chapter)

| Wrong | Why it fails | Right |
|-------|--------------|-------|
| *t*-test on binary exacerbation Y/N | Wrong outcome type | Fisher / logistic [Ch 4, 6] |
| *t*-test on exacerbation **counts** | Count, skewed, bounded | Poisson / NB [Ch 6] |
| `lm()` on 0/1 outcome | Predictions outside [0,1] | Logistic [Ch 6] |
| Ignore pairing in pre/post BD | Inflated false positives | Paired *t* [Ch 4] |
| Analyse repeated FEV1 as independent | Wrong SEs | Mixed models Ch 18 |
| Analyse survival as 12-month binary only | Loses timing | Ch 19 |
| Pool flow cells as n | Pseudo-replication | Ch 15 |
| Cluster on markers + FEV1, then "predict" FEV1 | Circular | Cluster on markers only [Ch 11] |
| Omics heatmap without batch check | Technical artefacts | Ch 14 |

---

## Alternatives & extensions (data structures that change the method)

If any of these apply, the “default” methods in Vol I need an extension.

| Data feature | What breaks | What to do |
|---|---|---|
| Repeated FEV1 over time | independence | Ch 18: mixed models / GEE |
| Time to exacerbation | censoring | Ch 19: survival analysis |
| Multi-centre clustering | SEs too small | Ch 18: cluster-robust / mixed |
| High-dimensional omics p>>n | unstable estimates | Ch 7, 10, 13–17 |
| Routine EHR data | selection/measurement bias | RECORD-style reporting [@benchimol2015record] + sensitivity |

---


## R lab: inspect CASTOR data

```r
source("R/00_setup.R")
source("R/generate_data.R")
library(tidyverse)

spirometry <- read_csv(
 file.path(paths$data, "spirometry.csv"),
 show_col_types = FALSE
)
exacerbation <- read_csv(
 file.path(paths$data, "exacerbation.csv"),
 show_col_types = FALSE
)
counts <- read_csv(
 file.path(paths$data, "exacerbation_counts.csv"),
 show_col_types = FALSE
)

glimpse(spirometry)
summary(spirometry$fev1)

# Quality summary
spirometry %>%
 summarise(
 n = n(),
 pct_missing_fev1 = mean(is.na(fev1)),
 min_fev1 = min(fev1),
 max_fev1 = max(fev1)
 )

# Outcome type routing
message("fev1: continuous → Ch 4–5")
message("exacerbation_12m: binary → Ch 6 logistic")
message("exacerbations_12m: count → Ch 6 Poisson/NB")
```

---

## Quick reference: route by outcome and structure

| Outcome / structure | When you see it | Route to |
|--------------------|-----------------|----------|
| **Continuous FEV₁** | Spirometry litres; one visit | [Ch 4](04-comparing-groups.md), [Ch 5](05-linear-models.md) |
| **Binary exacerbation** | Any vs none in follow-up | [Ch 4](04-comparing-groups.md), [Ch 6](06-generalized-linear-models.md) |
| **Count exacerbations** | Events per person-time | [Ch 6](06-generalized-linear-models.md) |
| **Repeated FEV₁ visits** | Same patient, multiple rows | [Ch 18](18-longitudinal-mixed-models.md) |
| **Time to first event** | Dates + censoring | [Ch 19](19-survival-analysis.md) |
| **Proteomics / RNA / flow** | Thousands of features | [Ch 13](13-differential-analysis-fdr.md)–[17](17-integrated-castor-hd.md) |

## Where we go next

**Next:** [Chapter 3](03-descriptive-analysis.md) describes the cohort before [Chapter 4](04-comparing-groups.md) compares groups. If you already know you need survival or mixed models, skim [Ch 18–19](18-longitudinal-mixed-models.md) after the checklist here.

## Related chapters

| Chapter | When to open it |
|---------|------------------|
| [Chapter 1: Statistical thinking](01-statistical-thinking.md) | Estimand, PICO, CASTOR workflow |
| [Chapter 3: Descriptive analysis](03-descriptive-analysis.md) | Table 1, plots, distribution checks |
| [Chapter 4: Comparing groups](04-comparing-groups.md) | Welch *t*, proportions, group comparisons |
| [Chapter 6: GLMs](06-generalized-linear-models.md) | Logistic, Poisson, count and binary outcomes |
| [Chapter 7: Model building](07-model-building.md) | Covariate choice, LASSO, prespecification |
| [Chapter 13: Differential analysis & FDR](13-differential-analysis-fdr.md) | Omics discovery, BH-FDR |
| [Chapter 14: Batch effects](14-batch-effects.md) | Technical confounding before DE |
| [Chapter 15: Flow cytometry](15-flow-cytometry.md) | Immune summaries at participant level |
| [Chapter 18: Longitudinal mixed models](18-longitudinal-mixed-models.md) | Repeated FEV₁, slopes, clustering |
| [Chapter 19: Survival analysis](19-survival-analysis.md) | Time to exacerbation, censoring |
| [Chapter 20: Missing data](20-missing-data.md) | MAR/MNAR, MICE, sensitivity analyses |
| [Chapter 21: Causal inference](21-causal-inference.md) | Confounding, IPW, DAGs |

## Handbook resources

| Resource | When to use it |
|----------|----------------|
| [Appendix B: Quick reference](../appendix-b-quick-reference.md) | Choose a test or model by outcome and design |
| [Appendix K: In the room, short stories](../appendix-k-in-the-room-stories.md#story-1--one-export-every-column-gets-a-t-test) | Story 1: one export, every column gets a *t*-test |
| [Appendix K: Story 3](../appendix-k-in-the-room-stories.md#story-3--the-excel-lm-on-01-exacerbation) | Story 3: `lm()` on 0/1 exacerbation |
| [RECURRING_COHORT](../RECURRING_COHORT.md) | CASTOR dataset glossary and narrative spine |
| [POLLUX vignette](../POLLUX_VIGNETTE.md) | Messy registry narrative + `pollux_registry_messy.csv` cleaning drill |
| [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md) | Copy-paste Results paragraphs for omics chapters |

## Further reading

- ATS/ERS spirometry standardisation [@graham2019spirometry]
- COPD exacerbation impact [@hurst2010exacerbation]
- Stoltzfus, *Biostatistics for Health and Biological Science Users of R* [@stoltzfus2019biostatistics]

## Exercises ([Solutions](../solutions/ch02_solutions.md))

**E2.1** Classify FEV1, exacerbation Y/N, and exacerbations/year.

**E2.2** Same variable `therapy` as exposure vs confounder: give scenarios.

**E2.3** What is the unit of analysis for `longitudinal_spirometry.csv`?

**E2.4** Route `time_to_exacerbation.csv` to the correct handbook chapter.

**Applied**

1. Run the R lab below on `spirometry.csv` and `exacerbation.csv`.
2. Complete the seven-item checklist for a hypothetical smoking–FEV1 question.
3. For each CASTOR file in the outcome map, state outcome type in one word.

