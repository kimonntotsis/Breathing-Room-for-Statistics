---
number-sections: false
---

# Appendix A: R environment {.unnumbered}

This appendix is for readers who want to **run the CASTOR scripts** alongside the handbook. It is not a full R course. For dplyr, ggplot2, and workflow fundamentals, see [R for Data Science](https://r4ds.hadley.nz/).

---

## What you need

| Tool | Purpose | Download |
|------|---------|----------|
| **R** (≥ 4.2 recommended) | Language and packages | [https://cran.r-project.org](https://cran.r-project.org) |
| **Posit Desktop** (optional) | Editor, console, plots, project manager | [https://posit.co/download/](https://posit.co/download/) |
| **This repository** | Chapters, `data/`, `R/examples/` | [github.com/kimonntotsis/Breathing-Room-for-Statistics](https://github.com/kimonntotsis/Breathing-Room-for-Statistics) |

Posit Desktop was formerly called RStudio Desktop. Either name is fine; the workflow below is the same.

---

## Get the project on your computer

**Option 1: Git (recommended)**

```bash
git clone https://github.com/kimonntotsis/Breathing-Room-for-Statistics.git
cd Breathing-Room-for-Statistics
```

**Option 2: ZIP**

Download the repository as a ZIP from [GitHub](https://github.com/kimonntotsis/Breathing-Room-for-Statistics/archive/refs/heads/main.zip), unzip, and note the folder path (e.g. `~/Projects/Breathing-Room-for-Statistics`).

**Open as a project (recommended)**

In Posit Desktop: **File → Open Project…** and choose the repository folder (or create a `.Rproj` file in the root if you use one). This sets the working directory automatically and is more reliable than `setwd()`.

---

## Install R packages (once)

Every chapter script expects the packages listed in `R/00_setup.R`. Run this **once** in the R console (from the project root):

```r
install.packages(c(
 "tidyverse", "broom", "patchwork", "survival", "lme4",
 "glmnet", "randomForest", "cluster", "factoextra"
))

# Optional (Chapter 20 MICE demo):
# install.packages("mice")

# Optional (Appendix L omics analyst track — Bioconductor):
# if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
# BiocManager::install(c("DESeq2", "limma", "edgeR", "fgsea", "sva"))
# install.packages(c("ggrepel", "msigdbr"))
```

Some optional packages appear in individual chapters or exercises (`pwr`, `logistf`, `mice`, `emmeans`, `rpart`, `xgboost`, **omics analyst track** in [Appendix L](appendix-l-omics-analyst-track.md)). Install when a script asks for them:

```r
install.packages(c("pwr", "logistf", "mice", "emmeans"))
```

**Windows:** if packages fail to compile, install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) matching your R version.

**macOS:** if compilation fails, install Xcode Command Line Tools (`xcode-select --install` in Terminal).

---

## First session (every time you work)

From the **project root** in R:

```r
source("R/00_setup.R") # paths + package check
source("R/generate_data.R") # rebuild CASTOR CSV files in data/
source("R/examples/generate_figures.R")
# optional: all handbook figures
```

`00_setup.R` finds the project root automatically if you opened the folder as a project. It prints the path and stops with a clear message if a package is missing.

To run **one chapter**:

```r
source("R/00_setup.R")
source("R/examples/ch04_comparing_groups.R") # example
```

To run **all chapter scripts** (smoke test):

```r
source("R/00_setup.R")
source("R/run_all_examples.R")
```

Outputs land in `data/`, `volume-01/figures/`, and `volume-01/tables/` depending on the script.

---

## Posit Desktop shortcuts (essentials)

| Action | Windows / Linux | macOS |
|--------|-----------------|-------|
| Run current line or selection | `Ctrl+Enter` | `Cmd+Enter` |
| Run entire script | `Ctrl+Shift+Enter` | `Cmd+Shift+Enter` |
| Restart R (clear environment) | Session → Restart R | Session → Restart R |
| Go to file | `Ctrl+.` | `Cmd+.` |
| Comment / uncomment lines | `Ctrl+Shift+C` | `Cmd+Shift+C` |

Full cheat sheets: [Posit cheat sheets](https://posit.co/resources/cheatsheets/) (ggplot2, dplyr, etc.).

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---------|--------------|-----|
| `cannot open file 'R/00_setup.R'` | Wrong working directory | Open the repo as a Posit **Project**, or `setwd("/full/path/to/Breathing-Room-for-Statistics")` |
| `Install missing packages: …` | First-time setup | Run `install.packages(...)` block above |
| `volume-01/tables/...` not found | Figures not generated yet | Run the chapter's `R/examples/chXX_*.R` script |
| Script works in Console but not in Quarto | Different working directory | Always `source("R/00_setup.R")` first; use paths from `paths$data` in scripts |
| Package update broke old code | Version drift | Restart R after `update.packages()`; pin versions only if you need exact reproduction for a paper |

---

## Building the PDF (authors only)

Readers do not need this to use the statistics content. To render the book:

```bash
cd volume-01
quarto render --to pdf
```

Requires [Quarto](https://quarto.org/docs/get-started/) and a LaTeX distribution (e.g. TeX Live). From the repository root: `./build-handbook-pdf.sh` copies the PDF to `Breathing-Room-for-Statistics.pdf`.

---

## Where to learn R properly

| Resource | Best for |
|----------|----------|
| [R for Data Science](https://r4ds.hadley.nz/) | tidyverse workflow, ggplot2, wrangling |
| [Posit Primers](https://posit.cloud/learn/primers) | Short interactive lessons |
| [STAT 545](https://stat545.com/) | Data science conventions in R |

Return to the handbook at [Appendix B](appendix-b-quick-reference.md) when you are ready to choose a method.
