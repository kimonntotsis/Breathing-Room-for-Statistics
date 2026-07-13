---
number-sections: false
bibliography: ../references.bib
link-citations: true
---

# Appendix K: In the room — short stories {.unnumbered}

> **All names and trials below are invented.** The situations match patterns that appear repeatedly in respiratory and clinical research: wrong test for the outcome type, prediction sold as causation, training-set AUC without calibration, and mixed columns treated as one “dataset problem.” Journal guidance for respiratory prediction studies stresses that **prediction is not causal inference** and needs validation discipline [@moons2015tripod; @steyerberg2019clinical]. Reviews of clinical papers still report **tests chosen for the wrong variable type** and **linear models on binary or count outcomes** [@harrell2015rms].

These stories explain **why this handbook exists**: not because people are careless, but because spreadsheets, grants, and deadlines push you toward software-first choices before the estimand is written.

**How to use this appendix:** read one story that matches your week, then open the linked chapter. Full investigator path: [Appendix J](appendix-j-investigator-minimum-path.md).

---

## Story 1 — One export, every column gets a t-test

**Who:** Dr Okonkwo, pulmonology attending; Amira, MSc student (first R project).  
**Setting:** Multi-centre CLD registry export, Monday morning lab meeting.

The CSV has twelve columns: `fev1_l`, `fvc_l`, `cat_score`, `mmrc`, `exacerbation_yn`, `exac_count_12m`, `smoking`, `therapy_line`, `age`, `sex`, `eosinophils`, `site_id`.

Amira’s script loops `t.test()` over every numeric column by smoking status. The slide shows six *p*-values; three are “significant.” Dr Okonkwo asks: *“So smoking affects everything?”*

**What went wrong**

| Column | True outcome type | What they ran | Why it fails |
|--------|-------------------|---------------|--------------|
| `fev1_l` | Continuous | Welch *t* | OK **if** estimand is mean difference |
| `exacerbation_yn` | Binary | Welch *t* on 0/1 | Wrong family; use proportions / logistic |
| `exac_count_12m` | Count | Welch *t* | Skewed, bounded at 0; use Poisson/NB |
| `mmrc` | Ordinal 0–4 | Pearson *r* with FEV1 | Treating ranks as interval distance |
| `site_id` | Cluster | Ignored | Patients nested in sites; SEs too optimistic |

**The hallway fix:** stop at one sentence: *“Is smoking associated with ≥1 exacerbation in 12 months?”* → binary outcome → [Ch 4](chapters/04-comparing-groups.md) / [Ch 6](chapters/06-generalized-linear-models.md). Other columns become **secondary** or **covariates**, not six parallel primaries.

**Handbook doors:** [Ch 2 routing table](chapters/02-respiratory-data.md#outcome-types-the-master-routing-table), [Appendix B Step 1](appendix-b-quick-reference.md), [Story 3](#story-3--the-excel-lm-on-01-exacerbation) below.

---

## Story 2 — “Just run random forest — it handles mixed data”

**Who:** Jonas, translational postdoc; external “data science” webinar certificate.  
**Setting:** Asthma clinic cohort, 214 patients, 9 baseline predictors (mixed types), binary outcome `steroid_burst_12m`.

Jonas imports everything into a single matrix, one-hot encodes therapy, and trains **random forest** because the tutorial said tree methods “do not need assumptions.” Validation is a single 70/30 split. Test AUC = 0.81. The abstract draft says: *“Machine learning identifies a steroid-burst signature.”*

The statistician on the author list (added late) asks two questions:

1. *“What probability of burst for a patient with FEV1 62% and three prior bursts?”* → Jonas has AUC, no calibration plot.  
2. *“Is ICS/LABA **causing** lower burst risk, or is this prediction?”* → The model cannot answer causation without a design for it.

**What went wrong**

- **Goal not stated:** prediction (risk for new patients) vs association (ICS effect).  
- **Sparse events:** ~29 bursts → unstable split; need bootstrap or nested CV ([Ch 9](chapters/09-prediction-vs-inference.md)).  
- **Leakage risk:** `prior_burst_count` must be defined at baseline only.  
- **Reporting:** respiratory journal editors expect TRIPOD-style discrimination **and** calibration on held-out data [@moons2015tripod].

**The hallway fix:** write the estimand: *“12-month steroid-burst risk from baseline covariates.”* Start with logistic regression + calibration; add RF as sensitivity if prespecified.

**Handbook doors:** [Ch 9](chapters/09-prediction-vs-inference.md), [Ch 1 inference vs prediction](chapters/01-statistical-thinking.md#inference-vs-prediction), [Ch 8 TRIPOD](chapters/08-validation-reporting.md).

---

## Story 3 — The Excel `lm()` on 0/1 exacerbation

**Who:** Clinical fellow; biostatistician consulted **after** submission.  
**Setting:** Observational COPD cohort, 348 patients, 24 exacerbation events.

The fellow “knows regression” from a statistics elective. In Excel exported to R:

```r
lm(exacerbation_12m ~ smoking + age + fev1_pct, data = cohort)
```

Coefficients look interpretable; smoking “effect” = −0.04. The fellow reports: *“Smoking reduces exacerbation risk (p = 0.03).”*

**What went wrong**

- `lm()` on a binary outcome is the wrong model family; predictions can fall outside [0, 1].  
- With 24 events, adjusted logistic regression is already fragile; EPV rule matters ([Ch 6](chapters/06-generalized-linear-models.md)).  
- **Sign flipped / scaled wrong:** the linear coefficient is not an odds ratio.  
- Literature: misspecified models on binary outcomes produce misleading coefficients; with sparse events, the problem is worse [@harrell2015rms; @hosmer2013applied].

**The hallway fix:** `glm(..., family = binomial)`; report OR + 95% CI + event table; associative language (STROBE).

**Handbook doors:** [Ch 6 logistic](chapters/06-generalized-linear-models.md), [Ch 12 Case B](chapters/12-case-studies.md#case-study-b-observational-cohort-exacerbation-risk).

---

## Story 4 — Training-set AUC for the ICU board slide

**Who:** Critical care fellow; industry-sponsored biomarker substudy (ARDS pattern).  
**Setting:** 89 patients, 17 deaths at 90 days, 20 ICU variables + two protein assays.

A contractor returns an **XGBoost** model with **AUC = 0.94** on the **same rows used to train**. The slide goes to the ICU governance board with “AI mortality prediction.”

An external reviewer later writes: *“Where is internal validation? Calibration? Event count per fold?”* The team cannot reproduce the pipeline; hyperparameters were tuned on the full set.

**What went wrong**

- **Training AUC ≠ clinical utility** — mirrors published ARDS mortality ML work where discrimination was high but external validation and calibration matter for deployment [@moons2015tripod].  
- **Tiny event count:** 17 deaths → any split is unstable; bootstrap optimism correction or penalised logistic baseline ([Ch 9](chapters/09-prediction-vs-inference.md)).  
- **Prediction ≠ treatment effect:** even a perfect risk score does not prove the biomarker is modifiable.

**The hallway fix:** prespecify train/validate split or nested CV; report calibration plot + Brier; label “development cohort only.”

**Handbook doors:** [Ch 9](chapters/09-prediction-vs-inference.md), [Part IV vignette](parts/part-04-validation-prediction.md), [Appendix I calibration figures](appendix-i-figure-hygiene.md).

---

## Story 5 — “Can we predict endotype AND prove the biologic works?”

**Who:** PI + translational co-PI; phase II asthma biologic substudy.  
**Setting:** 120 patients, baseline proteomics (920 proteins), week-12 FEV1 primary, post hoc clustering.

Week 1: CRO email — 41 proteins with *p* < 0.05, no batch column.  
Week 4: k-means on PCA → “Cluster B = T2-high.”  
Week 8: manuscript Discussion merges cluster membership with treatment benefit language.

**What went wrong**

- **Three questions collapsed:** discovery (proteins), description (clusters), confirmatory treatment effect (FEV1).  
- **Batch unknown:** cannot audit plate effects ([Ch 14](chapters/14-batch-effects.md)).  
- **Unsupervised labels used as if randomised strata** without prespecification ([Ch 11](chapters/11-clustering.md)).  
- **No bioinformatics on the thread:** PI signs heatmaps because they look convincing ([Preface](chapters/00-preface.md#without-a-dedicated-bioinformatics-collaborator)).

**The hallway fix:** three paragraphs, three limitation blocks; proteomics exploratory with FDR; FEV1 primary unchanged.

**Handbook doors:** [Ch 13](chapters/13-differential-analysis-fdr.md), [Ch 12 Case D](chapters/12-case-studies.md#case-study-d-castor-hd-discovery-bridge-ch-1317), [APATE](APATE_VIGNETTE.md).

---

## Story 6 — Prediction model quoted as “the smoking effect”

**Who:** Journal club, mixed cardiology/pulmonary audience.  
**Setting:** Published observational COPD paper (fictionalised composite).

The abstract reports **LASSO-selected predictors** for hospitalisation with **AUC 0.79**. In the discussion, the authors write: *“Smoking was the strongest risk factor, confirming causation.”*

A fellow asks: *“Was this a prediction model or a causal model?”* Silence.

**What went wrong**

- LASSO **prediction** prioritises discrimination; coefficients are not causal effects [@shmueli2010predict].  
- Confounders, colliders, and selection bias untouched ([Ch 21](chapters/21-causal-inference.md)).  
- **Language drift:** “risk factor” in a risk model ≠ “causes hospitalisation.”

**The hallway fix:** separate sentences: *“Smoking increased predicted admission risk in a derivation cohort”* vs *“We did not estimate a causal effect.”*

**Handbook doors:** [Ch 1](chapters/01-statistical-thinking.md), [Ch 9 vs Ch 6 table](chapters/09-prediction-vs-inference.md#inference-vs-prediction-choose-your-lane), [Ch 21](chapters/21-causal-inference.md).

---

## From stories to workflow

| If you recognised… | Open first |
|--------------------|------------|
| Many columns, one loop of tests | [Ch 2](chapters/02-respiratory-data.md) + [Appendix B](appendix-b-quick-reference.md) |
| AUC without calibration | [Ch 9](chapters/09-prediction-vs-inference.md) |
| `lm()` on yes/no | [Ch 6](chapters/06-generalized-linear-models.md) |
| Counts analysed as means | [Ch 6 Poisson](chapters/06-generalized-linear-models.md) |
| Omics + primary endpoint in one claim | [Ch 12](chapters/12-case-studies.md), [Ch 13](chapters/13-differential-analysis-fdr.md) |
| “ML proves treatment works” | [Ch 1](chapters/01-statistical-thinking.md), [Ch 21](chapters/21-causal-inference.md) |

Then run the CASTOR pipeline: [Ch 1 — What CASTOR means](chapters/01-statistical-thinking.md#what-castor-means).

---

## Further reading

- TRIPOD prediction reporting [@moons2015tripod]  
- Inference vs prediction [@shmueli2010predict]  
- Clinical prediction models [@steyerberg2019clinical]
