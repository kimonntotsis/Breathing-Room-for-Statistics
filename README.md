# Statistical Methods for Respiratory Research

A single-volume, question-driven **handbook** for statistics, modelling, and machine learning in respiratory science — with reproducible R code (Ch 0–21).

## Handbook navigation

| Start here | File |
|------------|------|
| **Home / chapter list** | [volume-01/index.md](volume-01/index.md) |
| **How to use the book** | [volume-01/HANDBOOK_GUIDE.md](volume-01/HANDBOOK_GUIDE.md) |
| **Which test / which model** | [volume-01/QUICK_REFERENCE.md](volume-01/QUICK_REFERENCE.md) |
| **Full method inventory** | [volume-01/METHOD_MAP.md](volume-01/METHOD_MAP.md) |
| **All figures** | [volume-01/FIGURE_INDEX.md](volume-01/FIGURE_INDEX.md) |
| **References** | [volume-01/REFERENCES.md](volume-01/REFERENCES.md) |

## Project layout

```
volume-01/          Book chapters + handbook navigation (Ch 0–21)
R/                  Runnable scripts and data generation
data/               Exported CSV datasets for readers
references.bib      Bibliography (35+ entries)
```

## Quick start

```r
# From the project root in R:
source("R/00_setup.R")
source("R/generate_data.R")
source("R/examples/generate_figures.R")  # decision tree + chapter plots
source("R/run_all_examples.R")           # all chapter scripts
```

## Rendering (Quarto book)

Chapters are Markdown (`.md`); the bibliography appendix is [`volume-01/references.qmd`](volume-01/references.qmd).

```bash
cd volume-01
quarto render --to html     # → _book/index.html
quarto render --to pdf      # → _book/Statistical-Methods-for-Respiratory-Research.pdf
```

PDF output: **`volume-01/_book/Statistical-Methods-for-Respiratory-Research.pdf`**. Requires LaTeX (TeX Live).

## Scope (one volume)

| Part | Focus |
|------|-------|
| **I–IV** | Foundations, comparisons, regression, validation |
| **V–VII** | Discovery, omics/flow/screens, CASTOR-HD capstone |
| **VIII** | Longitudinal mixed models, survival, missing data, causal inference |

## License

Text and code: CC BY 4.0 (suggested). Adjust before formal publication.
