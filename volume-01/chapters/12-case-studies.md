# Chapter 12: Integrated Case Studies

> **Part V: Discovery (core CASTOR capstone)**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](RECURRING_COHORT.md) - full workflow |
| **Format** | End-to-end narratives with caveats, wrong analyses, reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Cases** | A: RCT FEV1 · B: Exacerbation logistic · C: PCA + clustering · D: CASTOR-HD (Ch 13–17) · **E: Longitudinal + survival (Ch 18–19)** |
| **R** | `R/examples/ch12_case_*.R` |
| **Navigation** | [HANDBOOK_GUIDE](../HANDBOOK_GUIDE.md) · [QUICK_REFERENCE](../QUICK_REFERENCE.md) · [METHOD_MAP](../METHOD_MAP.md) · [REFERENCES](../REFERENCES.md) |

---

## Learning objectives

1. Execute the full analysis pipeline from question to report.
2. Apply the [METHOD_MAP](../METHOD_MAP.md) to real CASTOR scenarios.
3. Write integrated Methods/Results paragraphs with appropriate citations.
4. Identify wrong analyses in published-style scenarios.

## Prerequisites

Chapters 1-11.

---

## Opening question

*How do the CASTOR analyses from Chapters 3-11 fit together in three publishable-style case reports?*

This chapter is the **capstone**: same workflow as [HANDBOOK_GUIDE](../HANDBOOK_GUIDE.md), three complete narratives, and explicit limits on what each analysis proves.

---

## Master workflow (every CASTOR analysis)

| Step | Action | Chapter |
|------|--------|---------|
| 1 | Clinical question (one sentence) | 1 |
| 2 | Estimand + population | 1-2 |
| 3 | Describe sample (Table 1, plots) | 3 |
| 4 | Choose method via [QUICK_REFERENCE](../QUICK_REFERENCE.md) | 4-11 |
| 5 | Fit model / test with R script | R/examples |
| 6 | Diagnostics + sensitivity | 7-8 |
| 7 | Report estimate + CI + limitations | 8 |
| 8 | State what was **not** proven | All |

Reporting frameworks by design: CONSORT (RCT) [@schulz2010consort]; STROBE (cohort) [@vonelm2007strobe]; TRIPOD (prediction) [@moons2015tripod]; biomarker discovery [@mcshane2011biomarker].

---

# Case study A: Randomised trial: FEV1 comparison

## Clinical question

Does intervention improve mean FEV1 at 12 weeks compared with standard care in CASTOR?

## Estimand

Difference in mean FEV1 (litres) at 12 weeks: intervention − standard care, intention-to-treat population.

## Design

Parallel RCT; independent groups; continuous outcome [@schulz2010consort].

## Analysis path

| Step | Done |
|------|------|
| Table 1 by `group` | Ch 3 |
| Histogram / QQ FEV1 | Ch 3 |
| Welch t-test (prespecified primary) | Ch 4 [@welch1947t] |
| ANCOVA sensitivity (`spirometry_trial.csv`) | Ch 4-5 |
| Bootstrap CI | Ch 8 [@efron1993bootstrap] |
| Power note (if negative) | Ch 4, 8 |

```r
source("R/examples/ch12_case_a_trial.R")
```

## Results template

> Among 400 participants, mean FEV1 was 3.85 L (SD 0.64) in intervention and 3.76 L (SD 0.64) in standard care. The mean difference was 0.09 L (95% CI −0.04 to 0.21; Welch t, p = 0.20). Results are inconclusive with respect to a prespecified MCID of 0.10 L [@cazzola2008mcid].

## Three-reader interpretation

| Reader | Takeaway |
|--------|----------|
| **Statistician** | CI includes null; non-significant p does not prove equivalence [@harrell2015rms] |
| **Clinician** | Cannot claim benefit or futility without MCID/power context |
| **General** | Trial did not show clear average improvement; more data or larger effect needed |

## Caveats

Single time point; CASTOR synthetic; no site clustering modelled. Spirometry per ATS/ERS standards [@graham2019spirometry].

## Wrong analysis ⚠ (Case A)

| Mistake | Correct |
|---------|---------|
| "No significant difference → treatments equal" | CI + equivalence margin if that is goal |
| Compare post-BD FEV1 one arm, pre-BD other | Same spirometry protocol [@graham2019spirometry] |
| Skip Table 1 | Always describe first [@schulz2010consort] |

## What Case A does NOT prove

Causal effect in broader population; long-term FEV1 decline; symptom benefit.

---

# Case study B: Observational cohort: exacerbation risk

## Clinical question

Is smoking associated with ≥1 exacerbation in 12 months after adjusting for age, FEV1 % predicted, and prior exacerbations?

## Estimand

Adjusted odds ratio for smoking (binary exposure).

## Design

Observational cohort; binary outcome; logistic regression [@vonelm2007strobe; @hosmer2013applied].

## Analysis path

| Step | Done |
|------|------|
| Event count / EPV check (~18/350) | Ch 6 [@harrell2015rms] |
| Logistic regression (prespecified covariates) | Ch 6 |
| Marginal risks (`emmeans`) | Ch 6 |
| Firth sensitivity if sparse | Ch 6 [@firth1993bias] |
| No stepwise selection | Ch 7 |

```r
source("R/examples/ch12_case_b_exacerbation.R")
```

## Results template

> In 350 patients (18 exacerbation events), prior exacerbation count was associated with higher odds of a new event (OR 1.70, 95% CI 1.12 to 2.59). FEV1 % predicted OR 0.95 per 1% (95% CI 0.91 to 0.99). Smoking OR was imprecise (95% CI included 1.0). Low event count limits precision; Firth sensitivity similar (supplementary).

## Three-reader interpretation

| Reader | Takeaway |
|--------|----------|
| **Statistician** | EPV low; wide CIs; associative not causal [@vonelm2007strobe] |
| **Clinician** | Prior history matters most; smoking signal uncertain here |
| **General** | Past flare-ups predict future ones; smoking link not confirmed in this sample |

## Caveats

Unmeasured confounding (adherence, SES); exacerbation definition [@hurst2010exacerbation]; low events.

## Wrong analysis ⚠ (Case B)

| Mistake | Correct |
|---------|---------|
| `lm` on 0/1 outcome | Logistic [@hosmer2013applied] |
| OR reported as "30% higher risk" | Marginal RD or RR model |
| Stepwise 20 predictors, 18 events | Prespecified model [@harrell2015rms] |
| "Smoking causes exacerbation" | "Associated with" |

## What Case B does NOT prove

Causal effect of smoking; prediction model performance (see Case C / Ch 9).

---

# Case study C: Multi-marker panel: PCA + clustering

## Clinical question

Is there exploratory evidence of patient subgroups in a 30-marker panel?

## Estimand

None confirmatory - descriptive structure only.

## Design

Cross-sectional marker panel; unsupervised methods [@jolliffe2016pca; @hennig2007cluster].

## Analysis path

| Step | Done |
|------|------|
| Scale markers | Ch 10 |
| PCA scree + PC1/PC2 plot | Ch 10 |
| k-means k = 2, silhouette | Ch 11 |
| Bootstrap stability + batch check | Ch 11 |
| Compare to `true_phenotype` (teaching only) | Ch 11 |
| Plan external validation | Ch 11 |

```r
source("R/examples/ch12_case_c_phenotypes.R")
```

## Results template

> PCA: PC1 explained 27% of variance; loadings highest on M1-M5 [@jolliffe2016pca]. k-means (*k* = 2) yielded clusters with silhouette 0.25. Cluster profiles differed on marker weights (Figure). Analysis was exploratory; clusters were not validated in an independent cohort or against clinical outcomes [@mcshane2011biomarker; @wenzel2012asthma].

## Three-reader interpretation

| Reader | Takeaway |
|--------|----------|
| **Statistician** | Hypothesis-generating; multiplicity uncontrolled |
| **Clinician** | Do not change care based on these clusters |
| **General** | Possible groups in data - needs replication |

## Caveats

p >> n risk in real omics; batch effects [@mcshane2011biomarker]; CASTOR has simulated structure.

## Wrong analysis ⚠ (Case C)

| Mistake | Correct |
|---------|---------|
| "Two validated endotypes" | Exploratory clusters [@wenzel2012asthma] |
| Test 30 markers individually then cluster | Pre-specify discovery framework |
| Use outcome to pick k | Unsupervised k selection + stability [@hennig2007cluster] |
| PCA on unscaled markers | Scale |

## What Case C does NOT prove

Biological subtypes; treatment response groups; diagnostic categories.

---

# Case study D: CASTOR-HD discovery bridge (Ch 13–17)

## Clinical question

In the CASTOR-HD extension, which molecular and immune readouts support a coherent discovery story from proteomics through confirmation assays?

## Estimand

Not a single causal estimand — this is a **staged discovery pipeline**: (1) controlled false discovery among proteins; (2) batch-robust shortlist; (3) participant-level immune phenotypes; (4) confirmed antibody binding among screen hits.

## Design

Observational case–control with multi-plate proteomics, RNA-seq, flow summaries, and replicate antibody screens [@mcshane2011biomarker].

## Analysis path

| Step | Chapter | Done |
|------|---------|------|
| Per-protein DE + BH FDR | 13 | Top table, volcano |
| Batch PCA + sensitivity | 14 | Overlap check, discovery count with/without batch |
| Flow proportions (participant n) | 15 | Batch-adjusted cell-type effects |
| Screen hits → PPV + tiers | 16 | Prespecified threshold, Tier 1 clones |
| Integrated narrative + optional elastic net | 17 | `ch17_integrated_castor_hd.R` |

```r
source("R/00_setup.R")
source("R/examples/ch17_integrated_castor_hd.R")
```

## Results template

> We tested ~1000 proteins (linear models with batch/plate covariates; BH FDR). Batch overlap was assessed by PCA and group × batch tables (Figure). After batch adjustment, *N* proteins had q < 0.05; rankings were compared with and without batch covariates. Participant-level flow cytometry (*n* = …) showed … Monocyte proportions differed … (batch-adjusted). Antibody screen hits at prespecified threshold … had PPV … among confirmation assays; Tier 1 clones (3/3 replicate rankings) were … Analysis was discovery-stage; external validation is required [@mcshane2011biomarker].

## Three-reader interpretation

| Reader | Takeaway |
|--------|----------|
| **Statistician** | Multiplicity controlled per modality; batch and stability audited |
| **Clinician** | No diagnostic or treatment claims from this pipeline alone |
| **General** | Hypothesis list for targeted follow-up — not a validated signature |

## Wrong analysis ⚠ (Case D)

| Mistake | Correct |
|---------|---------|
| "Proteomics signature validates endotype" | Separate discovery from confirmation; external cohort |
| Ignore batch because FDR "fixes" it | FDR does not fix confounding (Ch 14) |
| Report cell-level p-values as n = cells | Participant-level inference (Ch 15) |
| Screen threshold chosen after seeing PPV | Prespecify threshold; report sensitivity curve |

## What Case D does NOT prove

Causal mechanisms; clinical utility; transportability; antibody therapeutic potential.

**Continue:** [Ch 17 integrated pipeline](17-integrated-castor-hd.md) · [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md)

---

# Case study E: Longitudinal FEV1 + time to exacerbation

## Clinical question

In the CASTOR extension cohort, (1) does intervention improve the **FEV1 trajectory** over 52 weeks, and (2) is smoking associated with **shorter time to first exacerbation** under one-year follow-up?

## Estimands

1. **Longitudinal:** difference in mean FEV1 trajectory (intervention vs standard), weeks 0–52, randomised extension population — slope and level from mixed model.
2. **Survival:** hazard of first exacerbation comparing smokers vs non-smokers, adjusted for FEV1 % predicted, therapy, and age (associational cohort estimand).

## Design

- **Part 1:** parallel-group trial extension with four scheduled spirometry visits per participant (`longitudinal_spirometry.csv`).
- **Part 2:** observational time-to-event cohort with administrative censoring at 365 days (`time_to_exacerbation.csv`) [@vonelm2007strobe].

## Analysis path

| Step | Chapter | Done |
|------|---------|------|
| Spaghetti plot + visit counts | 18 | QC trajectory data |
| Mixed model `fev1 ~ weeks * group + (1\|patient_id)` | 18 | Coefficient table + fitted means |
| Sensitivity: week-52 cross-section vs mixed | 18 | `ch18_sensitivity_mixed_vs_fixed.csv` |
| Kaplan–Meier by smoking + log-rank | 19 | `ch19_km_by_smoking.png` |
| Cox PH + Schoenfeld check | 19 | HR table + PH test |
| Integrated Case E summary | 12 | `ch12_case_e_summary.csv` |

```r
source("R/00_setup.R")
source("R/examples/ch12_case_e_longitudinal_survival.R")
```

## Results template

> **Longitudinal (RCT extension):** Among *n* = … participants (… visits), FEV1 trajectories differed by treatment (Figure). A linear mixed model with random intercepts estimated a week × intervention interaction of … L per week (95% CI …). A sensitivity analysis using only week-52 FEV1 yielded a different standard error, illustrating pseudo-replication risk. **Survival (cohort):** During 365 days of follow-up, … exacerbations occurred. Kaplan–Meier curves separated by smoking (log-rank *p* = …). The adjusted Cox hazard ratio for smoking was … (95% CI …). Proportional hazards diagnostics: … [@harrell2015rms; @vonelm2007strobe].

## Three-reader interpretation

| Reader | Takeaway |
|--------|----------|
| **Statistician** | Correct units: patients for trajectories; events + censoring for survival |
| **Clinician** | Trajectory answers “lung function over time”; survival answers “how soon exacerbation” |
| **General** | Two related but distinct questions — do not merge into one headline |

## Wrong analysis ⚠ (Case E)

| Mistake | Correct |
|---------|---------|
| Pool all FEV1 visits as independent *n* | Mixed model with patient random effect |
| Use binary 12-month exacerbation only | Time-to-event with censoring |
| Claim smoking “causes” faster exacerbation without design | Associational Cox + confounding discussion (Ch 21) |
| Report HR without event counts | Table of events, censored, person-time |

## What Case E does NOT prove

That improving FEV1 trajectory prevents exacerbations (different endpoints); causal effect of smoking; transportability to other healthcare systems.

**Continue:** [Ch 20 missing data](20-missing-data.md) · [Ch 21 causal inference](21-causal-inference.md)

---

## Cross-case comparison

| Case | Question type | Method | Inference? | Key reference |
|------|---------------|--------|------------|---------------|
| A | Treatment effect | Welch t / ANCOVA | Yes (RCT) | [@schulz2010consort] |
| B | Risk factor | Logistic | Associational | [@vonelm2007strobe] |
| C | Structure | PCA + k-means | Exploratory only | [@mcshane2011biomarker] |
| D | Multi-omics discovery | DE + batch + flow + screen | Discovery only | [@mcshane2011biomarker] |
| E | Trajectory + time-to-event | Mixed model + Cox | RCT part + associational survival | [@harrell2015rms; @vonelm2007strobe] |

---

## Handbook synthesis checklist

Before submitting any respiratory paper, verify:

- [ ] Clinical question and estimand stated  
- [ ] Table 1 and missingness [@schulz2010consort; @vonelm2007strobe]  
- [ ] Method matches outcome type ([QUICK_REFERENCE](../QUICK_REFERENCE.md))  
- [ ] Effect size + 95% CI [@harrell2015rms]  
- [ ] Event count / n  
- [ ] Sensitivity analysis or limitation noted  
- [ ] No causal overclaim from observational/exploratory work  
- [ ] Reproducible R script  

---

## Extended methods (now in this handbook)

- Longitudinal FEV1 → [Ch 18](18-longitudinal-mixed-models.md)  
- Time-to-exacerbation → [Ch 19](19-survival-analysis.md)  
- Missing data / MICE → [Ch 20](20-missing-data.md)  
- Causal inference → [Ch 21](21-causal-inference.md)

---

## Closing

The **core path (Ch 1–12)** is complete when you can run the CASTOR pipeline yourself — including **Case E** (longitudinal + survival). The **advanced discovery path (Ch 13–17)** extends CASTOR-HD; **Part VIII (Ch 18–21)** completes the single-volume handbook for repeated measures, time-to-event, missing data, and causal framing [@harrell2015rms; @shmueli2010predict].

Replace author details, swap CASTOR for your cohort, and obtain statistical and clinical review before publication.

---

## Alternatives & extensions (how these cases would change)

| If your real study has… | Case change | Where it’s covered |
|---|---|---|
| Multiple follow-up visits | Case A → Case E longitudinal | [Ch 18](18-longitudinal-mixed-models.md), Case E |
| Time to first exacerbation | Case B → Case E survival | [Ch 19](19-survival-analysis.md), Case E |
| Many more predictors (omics) | Case C/D: penalization + validation | Ch 7, 9–11, 13–17 |
| Clustered multi-centre design | SEs must account for centre | [Ch 18](18-longitudinal-mixed-models.md) |
| Clinical decision thresholds | Add decision-curve / net benefit | Ch 9 extensions |
| Proteomics + flow + screens | Case D → Ch 17 pipeline | Ch 13–17 |

## Further reading

- Full bibliography: [REFERENCES.md](../REFERENCES.md) and `references.bib`  
- Harrell, *Regression Modeling Strategies* [@harrell2015rms]  
- CONSORT / STROBE / TRIPOD reporting [@schulz2010consort; @vonelm2007strobe; @moons2015tripod]

## Exercises · [Solutions](../solutions/ch12_solutions.md)

**End of core path (Ch 1–12)** — continue with [Ch 13](13-differential-analysis-fdr.md) (CASTOR-HD) or [Ch 18](18-longitudinal-mixed-models.md) (longitudinal/survival).
