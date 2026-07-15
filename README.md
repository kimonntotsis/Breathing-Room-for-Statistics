# Breathing Room for Statistics

**A statistical handbook for respiratory research: from trials to omics and prediction**

*With reproducible R examples*

**Repository:** [github.com/kimonntotsis/Breathing-Room-for-Statistics](https://github.com/kimonntotsis/Breathing-Room-for-Statistics)
**Latest release (PDF):** [v1.1.0-review](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.1.0-review) (feedback edition) · [v1.0.0](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/releases/tag/v1.0.0)
Chapters, appendices, datasets, and R scripts live here. The PDF is attached to GitHub releases; links inside the PDF point to these source files on GitHub.

A single-volume handbook for **early- and mid-career** respiratory investigators and analysts, and **senior clinicians** who want statistics and R **on purpose**, not as a second degree in math or computer science.

**Aim:** match your question to a defensible method; know alternatives, assumptions, reporting, and limits: especially when high-dimensional data arrives **without** a bioinformatics collaborator. [Preface: Why I wrote this](volume-01/chapters/00-preface.md#why-i-wrote-this).

## Start here (by role)

| Role | Open first |
|------|------------|
| **Investigator (no R)** | [Preface](volume-01/chapters/00-preface.md) → [Welcome](volume-01/chapters/00-welcome.md) → [Appendix J ](volume-01/appendix-j-investigator-minimum-path.md) → [Appendix K (one story)](volume-01/appendix-k-in-the-room-stories.md) → [Appendix H](volume-01/appendix-h-clinicians-route.md) |
| **Analyst (R)** | [Appendix A](volume-01/appendix-a-r-setup.md) → [Appendix B](volume-01/appendix-b-quick-reference.md) → outcome chapter |
| **Anyone lost** | [Appendix G: navigation](volume-01/appendix-g-handbook-navigation.md) |

**Teaching names:** **CASTOR** = workflow + COPD-flavoured synthetic CSV cohorts (**CASTOR-HD** for omics); **POLLUX** = Castor's twin, messy-registry vignette ([POLLUX_VIGNETTE](volume-01/POLLUX_VIGNETTE.md); optional `data/pollux_registry_messy.csv` for missingness drills). *CASTOR is where you learn the method; POLLUX is where you learn what the method must survive.* **Appendix K** = six fictional “in the room” stories ([appendix-k-in-the-room-stories.md](volume-01/appendix-k-in-the-room-stories.md)).

## Handbook navigation

| Start here | File |
|------------|------|
| **Preface → Welcome tour** | [Preface](volume-01/chapters/00-preface.md) → [Welcome](volume-01/chapters/00-welcome.md) |
| **Appendix index (read order)** | [Appendix G](volume-01/appendix-g-handbook-navigation.md) |
| **Short read (without R)** | [Appendix J](volume-01/appendix-j-investigator-minimum-path.md) |
| **In the room: short stories** | [Appendix K](volume-01/appendix-k-in-the-room-stories.md) |
| **Reviewing without R** | [Appendix H](volume-01/appendix-h-clinicians-route.md) |
| **Figure hygiene (right vs wrong)** | [Appendix I](volume-01/appendix-i-figure-hygiene.md) |
| **Which test / which model** | [Appendix B](volume-01/appendix-b-quick-reference.md) |
| **Install R and run code** | [Appendix A](volume-01/appendix-a-r-setup.md) |
| **How to use the book** | [volume-01/HANDBOOK_GUIDE.md](volume-01/HANDBOOK_GUIDE.md) |
| **Full method inventory** | [volume-01/METHOD_MAP.md](volume-01/METHOD_MAP.md) |
| **All figures** | [volume-01/FIGURE_INDEX.md](volume-01/FIGURE_INDEX.md) |
| **Glossary** | [volume-01/appendix-c-glossary.md](volume-01/appendix-c-glossary.md) |
| **POLLUX vignette** | [volume-01/POLLUX_VIGNETTE.md](volume-01/POLLUX_VIGNETTE.md) (+ optional `data/pollux_registry_messy.csv`) |
| **Edition / citation** | [volume-01/HANDBOOK_STATUS.md](volume-01/HANDBOOK_STATUS.md) |
| **Instructor pack** | [volume-01/INSTRUCTOR_PACK.md](volume-01/INSTRUCTOR_PACK.md), exercises in Appendix F |
| **Reviewer rubric** | [volume-01/REVIEWER_RUBRIC.md](volume-01/REVIEWER_RUBRIC.md) |
| **External review request** | [REVIEW_REQUEST.md](REVIEW_REQUEST.md) |
| **Cite this handbook** | [Preface: Cite this book](volume-01/chapters/00-preface.md#cite-this-book) (APA 7th ed.) |
| **References** | [volume-01/REFERENCES.md](volume-01/REFERENCES.md) |

### Appendix order in the PDF

Letters are **citation IDs** (always say “Appendix B” for the method router). The built book orders appendices by **reader importance**: **G → J → H → I → B → A → C → D → F → References** (see [Appendix G](volume-01/appendix-g-handbook-navigation.md)).

## Project layout

Only these folders matter for readers and the PDF build. Author drafts and one-off tooling live in `archive/` (see [archive/README.md](archive/README.md)).

```
volume-01/
  chapters/          Main text (Ch 0–22)
  appendix-*.md      Back matter (letters = citation IDs; PDF order in Appendix G)
  exercises/         Per-chapter exercises (Appendix F links here)
  solutions/         Instructor solutions
  parts/             Part divider pages
  figures/           Chapter figures + book-cover-pearl-streams.png
  _quarto.yml        Book build config
  scripts/           CI + cover prep only (verify_*.py, prepare_cover_assets.py)
R/                   Runnable scripts and data generation
data/                Exported CSV datasets for readers
archive/             Unused design drafts, fallbacks, editorial scripts (local)
references.bib       Bibliography
```

**Ignored locally (not on GitHub):** `archive/figures/` (large binaries), `archive/data/*.RData`, cover upscale intermediates, built PDF in `_book/` and repo root.

## Quick start

```bash
git clone https://github.com/kimonntotsis/Breathing-Room-for-Statistics.git
cd Breathing-Room-for-Statistics
```

```r
# From the project root in R:
source("R/00_setup.R")
source("R/generate_data.R")
source("R/examples/generate_figures.R") # navigation + chapter + viz pairs
source("R/run_all_examples.R") # all chapter scripts
```

## Rendering (Quarto book)

Chapters are Markdown (`.md`); the bibliography appendix is [`volume-01/references.qmd`](volume-01/references.qmd).

```bash
cd volume-01
quarto render --to html # → _book/index.html
quarto render --to pdf # → _book/Breathing-Room-for-Statistics.pdf
```

PDF output:

- **Repository root:** `Breathing-Room-for-Statistics.pdf` (via `./build-handbook-pdf.sh`)
- **Ch 4 extensions (cluster, NI, crossover):** [Appendix O](volume-01/appendix-o-ch04-comparison-extensions.md) — split from core Ch 4 for shorter first pass
- **Quarto build dir:** `volume-01/_book/`

```bash
./build-handbook-pdf.sh # render + copy to repo root
python3 volume-01/scripts/verify_figure_markdown.py
pip install pypdf && python3 volume-01/scripts/verify_pdf_build.py
# or:
cd volume-01 && quarto render --to pdf
```

CI runs the same checks on every push to `main` (see [`.github/workflows/handbook-pdf.yml`](.github/workflows/handbook-pdf.yml)).

## Scope (one volume)

| Part | Focus |
|------|-------|
| **I–IV** | Foundations, comparisons, regression, validation |
| **V–VII** | Discovery, omics/flow/screens, CASTOR-HD capstone |
| **VIII** | Longitudinal mixed models, survival, missing data, causal inference |

## License

Text and code: [CC BY 4.0](LICENSE). Synthetic CASTOR data are for teaching only.
