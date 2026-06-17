---
number-sections: false
---

# Preface {.unnumbered}

Respiratory research generates an unusual breadth of data: spirometry and lung function, symptom scores, exacerbation counts, imaging features, biomarker panels, trial endpoints, and intensive-care time series. The statistical methods available are equally broad. The gap is not a shortage of techniques. It is a shortage of **clear connections** between clinical questions, valid analysis, and reproducible implementation.

This book was written to fill that gap.

## Why question-first?

In practice, analysts often learn methods in reverse: they know how to run a t-test or fit a logistic model before they have articulated what is being estimated, for whom, and under what assumptions. That order produces technically correct code and scientifically weak conclusions.

We reverse it.

Before any formula appears, we ask:

- What would change in clinical or scientific practice if we knew the answer?
- What quantity are we estimating or comparing?
- What data structure do we actually have?
- What could bias the result?

This mirrors good applied biostatistics. We make it explicit and repeatable.

## Accessibility and validity

These are not opposites. A method explained well is not a method explained loosely. Throughout the book, we use layered exposition:

- a plain-language statement of the idea
- a precise statistical statement nearby
- assumptions stated openly
- respiratory examples where things go wrong in real studies

We avoid jargon without definition. We also avoid replacing assumptions with metaphors that mislead.

## R as a teaching tool

R is used here not as a software manual but as a **proof of understanding**. If you can simulate data, fit a model, check assumptions, and report an estimand with code, you understand the method at a level that reading alone cannot provide.

We use the tidyverse for readability. Where base R is clearer, we use base R.

## What this book is not

- Not a catalogue of every test
- Not a machine-learning hype volume
- Not a substitute for protocol design, ethics approval, or clinical judgment
- Not a copy of existing textbooks with lung disease examples pasted in

## Acknowledgements

Replace this section with your own acknowledgements before publication. Review by a biostatistician and a respiratory clinician is strongly recommended.

## How to use this handbook

| Resource | Purpose |
|----------|---------|
| [HANDBOOK_GUIDE.md](../HANDBOOK_GUIDE.md) | Reader paths and workflow |
| [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) | **Which test / which model** (open first) |
| [METHOD_MAP.md](../METHOD_MAP.md) | Full technique inventory |
| [FIGURE_INDEX.md](../FIGURE_INDEX.md) | All plots and decision figures |
| [REFERENCES.md](../REFERENCES.md) | Citations and reporting guidelines |

You do not need to read cover-to-cover. Most analysts open **QUICK_REFERENCE**, jump to one chapter, run the R script, and copy the reporting template.

## “Alternatives & extensions” boxes (how to use them)

Each chapter includes an **Alternatives & extensions** section. This is where you’ll find:

- method variants that apply when assumptions break (non-normality, sparse events, overdispersion)
- modern alternatives used in respiratory papers (penalization, bootstrap validation, supervised reduction)
- pointers to [Ch 18–21](chapters/18-longitudinal-mixed-models.md) when the data structure requires them (longitudinal, survival, missing data, causal)

These sections are not an invitation to “try everything until something is significant.” They are a **menu** for defensible method choice: pick one primary analysis and prespecify a small number of sensitivity analyses.

## About the data

All examples use simulated data with realistic structure. This keeps the book fully reproducible. When you apply the methods, replace synthetic datasets with your study data and revisit every assumption.
