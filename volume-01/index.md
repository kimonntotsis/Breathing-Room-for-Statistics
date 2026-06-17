---
number-sections: false
---

# Welcome {.unnumbered}

A **working handbook** for respiratory research statistics: question first, method second, reproducible R code.

> **New here?** Read [HANDBOOK_GUIDE.md](HANDBOOK_GUIDE.md) · **Choosing a method?** Open [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

## Handbook navigation (start here)

| I need to… | Open |
|------------|------|
| **Choose a test or model** | [QUICK_REFERENCE.md](QUICK_REFERENCE.md) → [method decision tree](figures/method_decision_tree.png) |
| **See all methods by chapter** | [METHOD_MAP.md](METHOD_MAP.md) |
| **Find a figure** | [FIGURE_INDEX.md](FIGURE_INDEX.md) |
| **Look up a term** | [GLOSSARY.md](GLOSSARY.md) |
| **Cite a guideline or textbook** | [REFERENCES.md](REFERENCES.md) · [references.qmd](references.qmd) (Quarto appendix) |
| **Follow CASTOR examples** | [RECURRING_COHORT.md](RECURRING_COHORT.md) |
| **Practice** | [exercises/](exercises/) · [solutions/](solutions/) |

---

## Reader paths

| Path | Chapters | Best for |
|------|----------|----------|
| **Core path** | 1–12 | Trials, regression, prediction, CASTOR capstone (Cases A–C) |
| **Advanced discovery** | 13–17 | Omics DE/FDR, batch, flow, antibody screens, integrated CASTOR-HD |
| **Longitudinal & causal** | 18–21 | Repeated FEV1, time-to-event, missing data, IPW/DAGs |

| Role | Path |
|------|------|
| **Clinician / trialist** | [QUICK_REFERENCE](QUICK_REFERENCE.md) → relevant chapter technique card → Reporting template |
| **Analyst** | [Ch 2](chapters/02-respiratory-data.md) → [Ch 3](chapters/03-descriptive-analysis.md) → [METHOD_MAP](METHOD_MAP.md) |
| **Course instructor** | [Preface](chapters/00-preface.md) → Core 1–12 + [exercises](exercises/README.md); optional 13–21 blocks |
| **Writing a paper** | [QUICK_REFERENCE](QUICK_REFERENCE.md) → [Ch 8 reporting](chapters/08-validation-reporting.md) → [REFERENCES](REFERENCES.md) |
| **Omics / discovery** | [Ch 13](chapters/13-differential-analysis-fdr.md) → [Ch 14 batch](chapters/14-batch-effects.md) → [Ch 17 pipeline](chapters/17-integrated-castor-hd.md) |

---

## Eight parts

| Part | Chapters | Content |
|------|----------|---------|
| **I Foundations** | 0–2 | Preface, statistical thinking, data types |
| **II Describe & compare** | 3–4 | Summaries, *t*-tests, ANOVA, proportions |
| **III Regression** | 5–7 | Linear models, GLMs, model building |
| **IV Validate & predict** | 8–9 | Reporting, bootstrap, ML metrics |
| **V Discovery (core)** | 10–12 | Dimension reduction, clustering, CASTOR cases |
| **VI High-dimensional biology** | 13–16 | DE/FDR, batch, flow, antibody screens |
| **VII Integrated capstone** | 17 | End-to-end CASTOR-HD + elastic net |
| **VIII Longitudinal & causal** | 18–21 | Mixed models, survival, missing data, causality |

---

## Chapters

| Ch | Title | Key navigation |
|----|-------|----------------|
| 0 | [Preface](chapters/00-preface.md) | How to use this handbook |
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
| 12 | [Case studies](chapters/12-case-studies.md) | End-to-end CASTOR (Cases A–D) |
| 13 | [Differential analysis + FDR](chapters/13-differential-analysis-fdr.md) | Omics DE, volcano, BH |
| 14 | [Batch effects](chapters/14-batch-effects.md) | PCA, overlap, sensitivity |
| 15 | [Flow cytometry](chapters/15-flow-cytometry.md) | Proportions, pseudo-replication |
| 16 | [Antibody discovery](chapters/16-antibody-discovery.md) | Screens, PPV, stability tiers |
| 17 | [Integrated CASTOR-HD](chapters/17-integrated-castor-hd.md) | Full pipeline + elastic net |
| 18 | [Longitudinal mixed models](chapters/18-longitudinal-mixed-models.md) | Repeated FEV1 |
| 19 | [Survival analysis](chapters/19-survival-analysis.md) | Time to exacerbation |
| 20 | [Missing data](chapters/20-missing-data.md) | MAR, imputation sensitivity |
| 21 | [Causal inference](chapters/21-causal-inference.md) | Confounding, toy IPW |

---

## CASTOR core datasets (Ch 3–12)

| File | Use |
|------|-----|
| `data/spirometry.csv` | FEV1, trials, ANOVA |
| `data/exacerbation.csv` | Logistic regression |
| `data/exacerbation_counts.csv` | Poisson / NB |
| `data/bronchodilator_paired.csv` | Paired *t*-test |
| `data/spirometry_trial.csv` | ANCOVA |
| `data/marker_panel.csv` | PCA, clustering |

---

## CASTOR extensions (Ch 18–19, Case E)

| File | Use |
|------|-----|
| `data/longitudinal_spirometry.csv` | Mixed models, trajectories |
| `data/time_to_exacerbation.csv` | Kaplan–Meier, Cox |

---

## CASTOR-HD datasets (Ch 13–17)

| File | Use |
|------|-----|
| `data/proteomics_olink_like.csv` | DE, batch, elastic net |
| `data/rnaseq_counts.csv` | NB differential expression |
| `data/flowcytometry_summary.csv` | Participant-level proportions |
| `data/antibody_screen.csv` | Hit calling, PPV |
| `data/antibody_confirmation.csv` | Confirmation assays |

---

## R setup

```r
setwd("/path/to/respiratory-research-methods")
source("R/00_setup.R")
source("R/generate_data.R")
source("R/examples/generate_figures.R")  # all handbook figures
source("R/run_all_examples.R")           # full chapter scripts
```

---

## Datasets

See [RECURRING_COHORT.md](RECURRING_COHORT.md) for full CASTOR / CASTOR-HD map.

---

## Figures

Decision tree and chapter plots: [FIGURE_INDEX.md](FIGURE_INDEX.md). Regenerate anytime with `source("R/examples/generate_figures.R")`.

![Method decision tree](figures/method_decision_tree.png)

---

**Edition:** Single-volume handbook (Ch 0–21) with unified navigation, reproducible figures, and CASTOR + CASTOR-HD datasets. See [CHAPTER_TEMPLATE.md](CHAPTER_TEMPLATE.md).

**PDF build:** `quarto render --to pdf` → `_book/Statistical-Methods-for-Respiratory-Research.pdf`
