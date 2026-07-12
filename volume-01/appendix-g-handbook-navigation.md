---
number-sections: false
---

# Appendix G: Handbook navigation {.unnumbered}

Reference index for the PDF and web edition: where to find tools, chapters, datasets, and R commands. For a narrative tour of the volume, start with the [Welcome](index.md) page; for philosophy and CASTOR, see the [Preface](chapters/00-preface.md).

## Quick links

| I need to… | Open |
|------------|------|
| **Install R and run scripts** | [Appendix A](appendix-a-r-setup.md) |
| **Choose a test or model** | [Appendix B](appendix-b-quick-reference.md) |
| **See all methods by chapter** | [METHOD_MAP](METHOD_MAP.md) |
| **Find a figure** | [FIGURE_INDEX](FIGURE_INDEX.md) |
| **Right vs wrong plots (slides)** | [Appendix I](appendix-i-figure-hygiene.md) |
| **Investigator minimum path (~2 h)** | [Appendix J](appendix-j-investigator-minimum-path.md) |
| **APATE vignette (messy registry, no data)** | [APATE_VIGNETTE](APATE_VIGNETTE.md) |
| **Edition / citation status** | [HANDBOOK_STATUS](HANDBOOK_STATUS.md) |
| **Look up a term** | [Appendix C](appendix-c-glossary.md) |
| **Cite this handbook** | [Preface: Cite this book](chapters/00-preface.md#cite-this-book) |
| **Cite a guideline or textbook** | [REFERENCES](REFERENCES.md), [references.qmd](references.qmd) |
| **Follow CASTOR examples** | [RECURRING_COHORT](RECURRING_COHORT.md) |
| **Follow a narrative path (Cases A–E)** | [Welcome: reading paths](index.md), [Ch 12 capstone](chapters/12-case-studies.md) |
| **Practice** | [Appendix F](appendix-f-exercises.md), [exercises/](exercises/), [solutions/](solutions/) |
| **How to use the book** | [HANDBOOK_GUIDE](HANDBOOK_GUIDE.md) |

## Appendices in this volume

**Letters are stable IDs** (cite “Appendix B” anywhere). **PDF order** follows reader importance below, not A→Z.

| Read order | Appendix | Content | Primary audience |
|:----------:|:--------:|---------|------------------|
| 1 | **G** | [Handbook navigation](appendix-g-handbook-navigation.md) (this index) | Everyone |
| 2 | **J** | [Investigator minimum path (~2 h)](appendix-j-investigator-minimum-path.md) | Investigator |
| 3 | **H** | [Investigator path (without R)](appendix-h-clinicians-route.md) | Investigator |
| 4 | **I** | [Figure hygiene (right vs wrong)](appendix-i-figure-hygiene.md) | Investigator, slides |
| 5 | **B** | [Quick reference](appendix-b-quick-reference.md) | Everyone |
| 6 | **A** | [R environment](appendix-a-r-setup.md) | Analyst |
| 7 | **C** | [Glossary](appendix-c-glossary.md) | Lookup |
| 8 | **D** | [Missing data checklists](appendix-d-missing-data-checklists.md) | Analyst, DMC |
| 9 | **F** | [Exercises](appendix-f-exercises.md) | Fellow, instructor |
| — | **Refs** | [Bibliography](references.qmd) | Citation |

**Analyst fast path:** G → A → B → (chapters) → F. **Investigator fast path:** G → J → H → I → B → Ch 12 Case A.

Related (not lettered appendices): [APATE_VIGNETTE](APATE_VIGNETTE.md), [HANDBOOK_STATUS](HANDBOOK_STATUS.md), [RECURRING_COHORT](RECURRING_COHORT.md).

## Reader paths

| Path | Chapters | Best for |
|------|----------|----------|
| **Core path** | 1–12 | Trials, regression, prediction, CASTOR capstone (Cases A–E) |
| **Advanced discovery** | 13–17 | Omics DE/FDR, batch, flow, antibody screens, integrated CASTOR-HD |
| **Longitudinal & causal** | 18–21 | Repeated FEV1, time-to-event, missing data, IPW/DAGs |

### Narrative spine (Chapter 12)

Technique chapters are meant to be opened by outcome. If you want one continuous read on the same COPD-oriented CASTOR cohort, use these routes and finish in [Chapter 12](chapters/12-case-studies.md):

| Role | Read first | Then | Capstone case |
|------|------------|------|---------------|
| **Investigator** | [Ch 1–2](chapters/01-statistical-thinking.md), [Ch 3–4](chapters/03-descriptive-analysis.md), [Ch 8](chapters/08-validation-reporting.md) | [Appendix B](appendix-b-quick-reference.md) for prespecification | [Case A](chapters/12-case-studies.md); [Case E](chapters/12-case-studies.md) if visits or survival are in the SAP |
| **Analyst** | [Ch 1–3](chapters/01-statistical-thinking.md), [Appendix B](appendix-b-quick-reference.md), [Ch 4–7](chapters/04-comparing-groups.md) as needed | [Ch 8–9](chapters/08-validation-reporting.md) if reporting or prediction | [Cases A & B](chapters/12-case-studies.md); [Ch 18–19](chapters/18-longitudinal-mixed-models.md) + Case E for trajectories |
| **Omics / discovery** | [Ch 1–2](chapters/01-statistical-thinking.md), [Ch 10–11](chapters/10-dimensionality-reduction.md), [Ch 13–16](chapters/13-differential-analysis-fdr.md) | [Ch 17](chapters/17-integrated-castor-hd.md) integrated pipeline | [Cases C & D](chapters/12-case-studies.md) |

| Goal | Path |
|------|------|
| **Investigator (without R)** | [Appendix H](appendix-h-clinicians-route.md) → [Appendix B](appendix-b-quick-reference.md) → chapter technique card |
| **Analyst (run R)** | [Ch 2](chapters/02-respiratory-data.md) → [Ch 3](chapters/03-descriptive-analysis.md) → [METHOD_MAP](METHOD_MAP.md) |
| **Teach or self-study** | [Preface](chapters/00-preface.md) → Core 1–12 + [exercises](exercises/README.md); optional 13–21 blocks |
| **Write a manuscript** | [Appendix B](appendix-b-quick-reference.md) → [Ch 8 reporting](chapters/08-validation-reporting.md) → [REFERENCES](REFERENCES.md) |
| **Omics / discovery** | [Ch 13](chapters/13-differential-analysis-fdr.md) → [Ch 14 batch](chapters/14-batch-effects.md) → [Ch 17 pipeline](chapters/17-integrated-castor-hd.md) |

## Eight parts

| Part | Chapters | Content |
|------|----------|---------|
| **I Foundations** | 0–2 | Preface, statistical thinking, data types |
| **II Describe and compare** | 3–4 | Summaries, *t*-tests, ANOVA, proportions |
| **III Regression** | 5–7 | Linear models, GLMs, model building |
| **IV Validate and predict** | 8–9 | Reporting, bootstrap, ML metrics |
| **V Discovery (core)** | 10–12 | Dimension reduction, clustering, CASTOR cases |
| **VI High-dimensional biology** | 13–16 | DE/FDR, batch, flow, antibody screens |
| **VII Integrated capstone** | 17 | End-to-end CASTOR-HD + elastic net |
| **VIII Longitudinal and causal** | 18–21 | Mixed models, survival, missing data, causality |

## Chapters

| Ch | Title | Key navigation |
|----|-------|----------------|
| 0 | [Preface](chapters/00-preface.md) | How to use this handbook; CASTOR workflow |
| 1 | [Statistical thinking](chapters/01-statistical-thinking.md) | Estimands, PICO, inference vs prediction |
| 2 | [Respiratory data](chapters/02-respiratory-data.md) | Outcome types → method routing |
| 3 | [Descriptive analysis](chapters/03-descriptive-analysis.md) | Table 1, plots |
| 4 | [Comparing groups](chapters/04-comparing-groups.md) | *t*-test vs Wilcoxon vs chi-square |
| 5 | [Linear models](chapters/05-linear-models.md) | Gaussian / `lm()` |
| 6 | [GLMs](chapters/06-generalized-linear-models.md) | Logistic, Poisson, NB |
| 7 | [Model building](chapters/07-model-building.md) | Selection, LASSO |
| 8 | [Validation & reporting](chapters/08-validation-reporting.md) | CONSORT, STROBE, TRIPOD |
| 9 | [Prediction vs inference](chapters/09-prediction-vs-inference.md) | AUC, calibration |
| 10 | [Dimensionality reduction](chapters/10-dimensionality-reduction.md) | PCA + alternatives menu |
| 11 | [Clustering](chapters/11-clustering.md) | Phenotype discovery |
| 12 | [Case studies](chapters/12-case-studies.md) | End-to-end CASTOR (Cases A–E) |
| 13 | [Differential analysis + FDR](chapters/13-differential-analysis-fdr.md) | Omics DE, volcano, BH |
| 14 | [Batch effects](chapters/14-batch-effects.md) | PCA, overlap, sensitivity |
| 15 | [Flow cytometry](chapters/15-flow-cytometry.md) | Proportions, pseudo-replication |
| 16 | [Antibody discovery](chapters/16-antibody-discovery.md) | Screens, PPV, stability tiers |
| 17 | [Integrated CASTOR-HD](chapters/17-integrated-castor-hd.md) | Full pipeline + elastic net |
| 18 | [Longitudinal mixed models](chapters/18-longitudinal-mixed-models.md) | Repeated FEV1 |
| 19 | [Survival analysis](chapters/19-survival-analysis.md) | Time to exacerbation |
| 20 | [Missing data](chapters/20-missing-data.md) | MAR, imputation sensitivity |
| 21 | [Causal inference](chapters/21-causal-inference.md) | Confounding, toy IPW |

## Topics A–Z {#topics-a-z}

Alphabetical guide to **where** topics appear. For definitions see [Appendix C](appendix-c-glossary.md); for method choice see [Appendix B](appendix-b-quick-reference.md).

| Topic | Primary location |
|-------|------------------|
| ANCOVA | [Ch 4](chapters/04-comparing-groups.md), [Ch 5](chapters/05-linear-models.md) |
| Antibody screen / PPV | [Ch 16](chapters/16-antibody-discovery.md) |
| AUC / discrimination | [Ch 9](chapters/09-prediction-vs-inference.md) |
| Batch effects | [Ch 14](chapters/14-batch-effects.md) |
| Bayesian (brief) | [Appendix C](appendix-c-glossary.md) |
| Bootstrap | [Ch 8](chapters/08-validation-reporting.md) |
| Calibration | [Ch 9](chapters/09-prediction-vs-inference.md) |
| CASTOR cohort | [Ch 2](chapters/02-respiratory-data.md), [RECURRING_COHORT](RECURRING_COHORT.md) |
| CASTOR-HD pipeline | [Ch 17](chapters/17-integrated-castor-hd.md) |
| Censoring / survival | [Ch 19](chapters/19-survival-analysis.md) |
| Clustering / endotypes | [Ch 11](chapters/11-clustering.md) |
| Cluster randomised / ICU nesting | [Ch 4](chapters/04-comparing-groups.md), [Ch 18](chapters/18-longitudinal-mixed-models.md) |
| Competing risk (death vs exacerbation) | [Ch 19](chapters/19-survival-analysis.md#technique-competing-risks-death-vs-exacerbation) |
| CONSORT reporting | [Ch 8](chapters/08-validation-reporting.md) |
| Confounding | [Ch 1](chapters/01-statistical-thinking.md), [Ch 21](chapters/21-causal-inference.md) |
| Cox model / hazard ratio | [Ch 19](chapters/19-survival-analysis.md) |
| Differential expression / FDR | [Ch 13](chapters/13-differential-analysis-fdr.md) |
| Elastic net / prediction omics | [Ch 17](chapters/17-integrated-castor-hd.md) |
| Estimand | [Ch 1](chapters/01-statistical-thinking.md) |
| Exacerbation (binary/count) | [Ch 4](chapters/04-comparing-groups.md), [Ch 6](chapters/06-generalized-linear-models.md) |
| FEV1 / spirometry | [Ch 2](chapters/02-respiratory-data.md), [Ch 4](chapters/04-comparing-groups.md) |
| Fine–Gray / competing risk | [Ch 19](chapters/19-survival-analysis.md#technique-competing-risks-death-vs-exacerbation) |
| Fisher / chi-square | [Ch 4](chapters/04-comparing-groups.md) |
| Flow cytometry | [Ch 15](chapters/15-flow-cytometry.md) |
| Firth logistic | [Ch 6](chapters/06-generalized-linear-models.md) |
| GEE (population-averaged) | [Ch 18](chapters/18-longitudinal-mixed-models.md#technique-mixed-models-vs-gee) |
| IPW | [Ch 21](chapters/21-causal-inference.md) |
| Kaplan–Meier | [Ch 19](chapters/19-survival-analysis.md) |
| LASSO | [Ch 7](chapters/07-model-building.md) |
| Linear regression | [Ch 5](chapters/05-linear-models.md) |
| LOD / proteomics missing | [Ch 13](chapters/13-differential-analysis-fdr.md), [Ch 20](chapters/20-missing-data.md) |
| Logistic regression | [Ch 6](chapters/06-generalized-linear-models.md) |
| Longitudinal / mixed models | [Ch 18](chapters/18-longitudinal-mixed-models.md) |
| MCID | [Ch 4](chapters/04-comparing-groups.md), [Appendix C](appendix-c-glossary.md) |
| MICE / multiple imputation | [Ch 20](chapters/20-missing-data.md), [Appendix D](appendix-d-missing-data-checklists.md) |
| Missing data checklists | [Appendix D](appendix-d-missing-data-checklists.md) |
| Model building / selection | [Ch 7](chapters/07-model-building.md) |
| Multiplicity / FDR | [Ch 8](chapters/08-validation-reporting.md), [Ch 13](chapters/13-differential-analysis-fdr.md) |
| Negative binomial | [Ch 6](chapters/06-generalized-linear-models.md) |
| Non-inferiority / equivalence | [Ch 4](chapters/04-comparing-groups.md#technique-non-inferiority-and-equivalence-trials), [Ch 8](chapters/08-validation-reporting.md) |
| Nonparametric tests | [Ch 4](chapters/04-comparing-groups.md) |
| Odds ratio vs risk ratio | [Ch 6](chapters/06-generalized-linear-models.md) |
| Ordinal logistic (mMRC/CAT) | [Ch 6](chapters/06-generalized-linear-models.md#technique-ordinal-logistic-regression-mmrccat) |
| PCA | [Ch 10](chapters/10-dimensionality-reduction.md) |
| Poisson regression | [Ch 6](chapters/06-generalized-linear-models.md) |
| Prediction vs inference | [Ch 1](chapters/01-statistical-thinking.md), [Ch 9](chapters/09-prediction-vs-inference.md) |
| Prediction / ML workflow (Ch 9) | [Ch 9](chapters/09-prediction-vs-inference.md) |
| Gradient boosting (XGBoost) | [Ch 9](chapters/09-prediction-vs-inference.md#technique-gradient-boosting-xgboost) |
| Pseudo-replication (flow) | [Ch 15](chapters/15-flow-cytometry.md) |
| R environment setup | [Appendix A](appendix-a-r-setup.md) |
| Reporting templates | All method chapters; [Ch 8](chapters/08-validation-reporting.md) |
| STROBE | [Ch 8](chapters/08-validation-reporting.md) |
| Structural missingness | [Ch 20](chapters/20-missing-data.md) |
| t-tests / ANOVA | [Ch 4](chapters/04-comparing-groups.md) |
| TRIPOD | [Ch 8](chapters/08-validation-reporting.md), [Ch 9](chapters/09-prediction-vs-inference.md) |
| Volcano plot | [Ch 13](chapters/13-differential-analysis-fdr.md) |
| Welch t-test | [Ch 4](chapters/04-comparing-groups.md) |
| Wrong analysis panels | Technique chapters; [CHAPTER_TEMPLATE](CHAPTER_TEMPLATE.md) |

**Case studies (end-to-end):** [Ch 12](chapters/12-case-studies.md) Cases A–E. **Exercises:** [Appendix F](appendix-f-exercises.md).

## CASTOR core datasets (Ch 3–12)

| File | Use |
|------|-----|
| `data/spirometry.csv` | FEV1, trials, ANOVA |
| `data/exacerbation.csv` | Logistic regression |
| `data/exacerbation_counts.csv` | Poisson / NB |
| `data/bronchodilator_paired.csv` | Paired *t*-test |
| `data/spirometry_trial.csv` | ANCOVA |
| `data/marker_panel.csv` | PCA, clustering |

## CASTOR extensions (Ch 18–19, Case E)

| File | Use |
|------|-----|
| `data/longitudinal_spirometry.csv` | Mixed models, trajectories |
| `data/time_to_exacerbation.csv` | Kaplan-Meier, Cox |

## CASTOR-HD datasets (Ch 13–17)

| File | Use |
|------|-----|
| `data/proteomics_olink_like.csv` | DE, batch, elastic net |
| `data/rnaseq_counts.csv` | NB differential expression |
| `data/flowcytometry_summary.csv` | Participant-level proportions |
| `data/antibody_screen.csv` | Hit calling, PPV |
| `data/antibody_confirmation.csv` | Confirmation assays |

See [RECURRING_COHORT](RECURRING_COHORT.md) for cohort description text and scientific questions across chapters.

## R setup

Full install guide: **[Appendix A](appendix-a-r-setup.md)**. Minimal first session:

```r
setwd("/path/to/Breathing-Room-for-Statistics")
# or open as Posit project
source("R/00_setup.R")
source("R/generate_data.R")
source("R/examples/generate_figures.R")  # all handbook figures
source("R/run_all_examples.R")           # full chapter scripts
```

## Figures

Decision tree and chapter plots: [FIGURE_INDEX](FIGURE_INDEX.md). Regenerate anytime with `source("R/examples/generate_figures.R")`.

## Edition notes

Single-volume handbook (Ch 0–21) with unified navigation, reproducible figures, and CASTOR + CASTOR-HD datasets. Chapter template: [CHAPTER_TEMPLATE](CHAPTER_TEMPLATE.md). PDF build: `quarto render --to pdf` in `volume-01/` → `_book/Breathing-Room-for-Statistics.pdf`, or `./build-handbook-pdf.sh` at repo root.
