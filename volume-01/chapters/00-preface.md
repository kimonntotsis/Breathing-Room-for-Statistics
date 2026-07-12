---
number-sections: false
---

# Preface {.unnumbered}

Respiratory research rests on incompatible data shapes in the same programme: spirometry and symptom scores, exacerbation counts, imaging, biomarker panels, trial endpoints, ICU trajectories, and omics tables with more variables than patients. Textbooks and courses teach methods in isolation. Manuscripts still fail for recurring reasons: the wrong estimand, the wrong outcome family, missingness handled as an afterthought, discovery claims without multiplicity or batch discipline, prediction metrics without calibration. This handbook connects question, method, reporting, and reproducible R on one synthetic cohort so each step is visible in code you can rerun.

## Who this book is for

**Investigators** and **analysts** who need to match a research question to a defensible analysis. Investigators can use estimand sections, technique cards, and reporting templates without running R; analysts follow the same workflow with reproducible R on CASTOR. **CASTOR** is a single **COPD-oriented** synthetic cohort (spirometry, exacerbations, smoking, therapy) so examples stay comparable from Table 1 through survival and omics; the same methods apply to asthma trials, ICU studies, and programme research when the outcome type and design match.

## Cite this book {#cite-this-book}

**APA (7th ed.)**

> Ntotsis, K. (2026). *Breathing room for statistics: A statistical handbook for respiratory research: from trials to omics and prediction* [Open handbook]. *With reproducible R examples.* Retrieved June 28, 2026, from https://github.com/kimonntotsis/Breathing-Room-for-Statistics

**Source (chapters, appendices, R code, data):** [github.com/kimonntotsis/Breathing-Room-for-Statistics](https://github.com/kimonntotsis/Breathing-Room-for-Statistics)

**In-text:** (Ntotsis, 2026)

For a fixed edition, cite a tagged release URL rather than the default branch. Edition and living-document notes: [HANDBOOK_STATUS](../HANDBOOK_STATUS.md).

## Why question-first?

Most training still runs software-first: a test is chosen, then justified. The result can be numerically correct and scientifically beside the point. Every chapter here assumes the reverse order. State what would change in practice if you knew the answer; name the estimand and the population it targets; describe the data you actually have (design, visits, missingness, confounding); only then select a method and prespecify what would falsify your conclusion.

## Accessibility and validity

Precision and readability are not trade-offs. Each chapter pairs plain language with a formal statement, lists assumptions explicitly, and shows where respiratory studies commonly misstep. Terms are defined in [Appendix C](../appendix-c-glossary.md); use the plain-language column as a lookup, not a memorisation exercise.

## R as a teaching tool

R is used here as a **proof of understanding**, not as a software manual. If you can simulate data, fit a model, check assumptions, and report an estimand in code, you understand the method at a level reading alone rarely reaches.

We use the tidyverse for readability. Where base R is clearer, we use base R.

**New to R?** See [Appendix A](../appendix-a-r-setup.md). You do not need it before Chapter 1 if you are only reading the statistical content.

## What this book is not

- Not a catalogue of every test
- Not a machine-learning hype volume
- Not a substitute for protocol design, ethics approval, or clinical judgment
- Not a copy of existing textbooks with lung disease examples pasted in

## Acknowledgements

Contributors who reviewed draft chapters using [REVIEWER_RUBRIC.md](../REVIEWER_RUBRIC.md) will be named in a later edition. If you use this handbook in teaching or trial work and spot a clinical or statistical error, open an issue or pull request on the [GitHub repository](https://github.com/kimonntotsis/Breathing-Room-for-Statistics).

## How to use this handbook

Use it by outcome and design, not by page order. [Appendix B](../appendix-b-quick-reference.md) routes a question to a chapter; [Appendix G](../appendix-g-handbook-navigation.md) lists datasets, files, and topics; [Appendix J](../appendix-j-investigator-minimum-path.md) is the **shortest investigator path (~2 h)**; [Appendix H](../appendix-h-clinicians-route.md) expands endpoint routing without R. In the PDF, appendices appear in **reader-importance order** (G → J → H → I → B → …); letters stay fixed for citations. The [Welcome](../index.md) page summarises the eight parts. Each method chapter follows the same skeleton ([CHAPTER_TEMPLATE.md](../CHAPTER_TEMPLATE.md)): question, technique card, plain and precise interpretation, **Practice read**, caveats, common errors, reporting template, code.

**Signposts in the chapters:** **Why this chapter** (the mistake it prevents), **Investigator path (≈20 min)** (layered read without the full chapter), **Method choice at a glance** (Method | When | Why), **Figure hygiene** (right vs wrong plots on the same data; [Appendix I](../appendix-i-figure-hygiene.md)), **In practice** (sponsor or manuscript reality), **Before you open R** (estimand and one sensitivity), **Where this chapter leads**, **Practice read** (what would change the decision), and **Alternatives & extensions** for edge cases only.

## What CASTOR means {#what-castor-means}

**CASTOR** is the analysis sequence used throughout the book: **C**linical question, **A**ssess design and data, **S**elect method, **T**est and fit, **O**utput estimand, **R**eport limits. The letters are unpacked in [Chapter 1](01-statistical-thinking.md) with an eight-step pipeline figure and a method decision tree at the selection step.

**CASTOR** also names a **synthetic COPD-oriented cohort** (spirometry, exacerbations, smoking, therapy) reused from descriptive tables through omics capstones; **CASTOR-HD** extends the same patients to high-dimensional biology. The workflow is fixed; only the data file changes.

## About the data

All examples use simulated data with realistic structure. This keeps the book fully reproducible. When you apply the methods, replace synthetic datasets with your study data and revisit every assumption.
