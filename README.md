# Breathing Room for Statistics

**A statistical handbook for respiratory research: from trials to omics and prediction**

*With reproducible R examples*

**Repository:** [github.com/kimonntotsis/Breathing-Room-for-Statistics](https://github.com/kimonntotsis/Breathing-Room-for-Statistics)  
Chapters, appendices, datasets, and R scripts live here. The PDF is distributed separately; links inside the PDF point to these source files on GitHub.

A single-volume handbook for investigators and analysts (Ch 0–21): classical statistics, prediction, dimension reduction and clustering, high-dimensional omics, and longitudinal/causal methods.

## Handbook navigation

| Start here | File |
|------------|------|
| **Preface → Welcome tour** | [Preface](volume-01/chapters/00-preface.md) → [Welcome](volume-01/index.md) |
| **Investigator path (without R)** | [Appendix H](volume-01/appendix-h-clinicians-route.md) |
| **Full chapter & file index** | [Appendix G](volume-01/appendix-g-handbook-navigation.md) |
| **How to use the book** | [volume-01/HANDBOOK_GUIDE.md](volume-01/HANDBOOK_GUIDE.md) |
| **Which test / which model** | [Appendix B](volume-01/appendix-b-quick-reference.md) |
| **Install R and run code** | [volume-01/appendix-a-r-setup.md](volume-01/appendix-a-r-setup.md) |
| **Full method inventory** | [volume-01/METHOD_MAP.md](volume-01/METHOD_MAP.md) |
| **All figures** | [volume-01/FIGURE_INDEX.md](volume-01/FIGURE_INDEX.md) |
| **Glossary** | [volume-01/appendix-c-glossary.md](volume-01/appendix-c-glossary.md) |
| **Instructor pack** | [volume-01/INSTRUCTOR_PACK.md](volume-01/INSTRUCTOR_PACK.md), exercises in PDF Appendix F |
| **Reviewer rubric** | [volume-01/REVIEWER_RUBRIC.md](volume-01/REVIEWER_RUBRIC.md) |
| **Cite this handbook** | [Preface: Cite this book](volume-01/chapters/00-preface.md#cite-this-book) (APA 7th ed.) |
| **References** | [volume-01/REFERENCES.md](volume-01/REFERENCES.md) |

## Project layout

```
volume-01/          Book chapters + handbook navigation (Ch 0–21)
R/                  Runnable scripts and data generation
data/               Exported CSV datasets for readers
references.bib      Bibliography (35+ entries)
```

## Quick start

```bash
git clone https://github.com/kimonntotsis/Breathing-Room-for-Statistics.git
cd Breathing-Room-for-Statistics
```

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
quarto render --to pdf      # → _book/Breathing-Room-for-Statistics.pdf
```

PDF output:

- **Repository root:** `Breathing-Room-for-Statistics.pdf` (via `./build-handbook-pdf.sh`)
- **Quarto build dir:** `volume-01/_book/`

```bash
./build-handbook-pdf.sh          # render + copy to repo root
# or:
cd volume-01 && quarto render --to pdf
```

## Scope (one volume)

| Part | Focus |
|------|-------|
| **I–IV** | Foundations, comparisons, regression, validation |
| **V–VII** | Discovery, omics/flow/screens, CASTOR-HD capstone |
| **VIII** | Longitudinal mixed models, survival, missing data, causal inference |

## License

Text and code: CC BY 4.0 (suggested). Confirm license text before distributing a tagged release.
