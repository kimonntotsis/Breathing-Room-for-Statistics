# Standard Operating Procedure: Getting Started with R and Posit Desktop

**Document ID:** SOP-R-001  
**Version:** 1.0  
**Effective date:** July 2026  
**Audience:** New analysts, fellows, and investigators learning R for respiratory research  
**Companion handbook:** *Breathing Room for Statistics* — [Appendix A](appendix-a-r-setup.md) (project-specific setup)

---

## 1. Purpose

This SOP walks a complete beginner from **zero** to a working R environment: install software, learn the interface, import and export data, run basic commands, and follow safe habits for reproducible analysis. It is written for clinical and translational researchers who will use R with this handbook and similar projects.

**By the end of this SOP you should be able to:**

1. Install R and Posit Desktop (formerly RStudio Desktop) on your computer.
2. Open a project, navigate the four main panes, and run code.
3. Load data from CSV/Excel files and save results back to disk.
4. Use essential R syntax: objects, functions, vectors, data frames, and the pipe.
5. Install packages and troubleshoot the most common first-week errors.

---

## 2. Scope

| In scope | Out of scope |
|----------|--------------|
| R ≥ 4.2 and Posit Desktop installation (Windows, macOS, Linux) | Advanced programming, package development, Shiny apps |
| Interface navigation and keyboard shortcuts | Server/cloud deployment (Posit Workbench, Posit Cloud) |
| Reading/writing CSV, Excel, RDS; exporting plots and tables | Database connections (SQL servers) |
| Core tidyverse workflow (`readr`, `dplyr`, `ggplot2`) | Bioconductor omics pipelines (see [Appendix L](appendix-l-omics-analyst-track.md)) |
| First-session setup for this handbook repository | Full statistical methods (see handbook chapters) |

---

## 3. Definitions

| Term | Meaning |
|------|---------|
| **R** | The statistical programming language (the engine that runs your code). |
| **Posit Desktop** | Free desktop application for writing and running R code. Formerly called **RStudio Desktop**. |
| **CRAN** | Comprehensive R Archive Network — the main repository for R and R packages. |
| **Console** | The pane where R executes commands line by line. |
| **Script / Source** | A `.R` file where you write and save code before running it. |
| **Working directory** | The folder R treats as "home" for relative file paths (e.g. `data/spirometry.csv`). |
| **Project** | A folder with an `.Rproj` file; opening it sets the working directory automatically. |
| **Package** | Add-on code library (e.g. `ggplot2` for graphics, `dplyr` for data wrangling). |
| **tidyverse** | A bundle of packages sharing a consistent data-science style. |

---

## 4. Prerequisites

Before you begin, confirm:

- [ ] You have administrator rights on your computer (or IT can install software for you).
- [ ] You have at least **2 GB free disk space** and a stable internet connection.
- [ ] You know where you will store project files (e.g. `~/Projects/` or `Documents/Research/`).
- [ ] **Install R first, then Posit Desktop.** Posit Desktop is only an editor; it needs R installed separately.

---

## 5. Procedure: Install R and Posit Desktop

### 5.1 Install R (all platforms)

**Official download:** [https://cran.r-project.org](https://cran.r-project.org)

| Step | Action |
|------|--------|
| 1 | Open [https://cran.r-project.org](https://cran.r-project.org). |
| 2 | Under **Download and Install R**, click the link for your operating system. |
| 3 | If asked to choose a **CRAN mirror**, pick one near you, or use [https://cloud.r-project.org](https://cloud.r-project.org) (works globally). |
| 4 | Download the **latest stable** release (R 4.x; ≥ 4.2 recommended for this handbook). |
| 5 | Run the installer. Accept defaults unless your IT department specifies otherwise. |
| 6 | **Verification:** Open R once from Applications (macOS) or Start menu (Windows). A plain console window with `>` prompt should appear. Type `R.version.string` and press Enter. You should see a version string. Close R — you will use Posit Desktop from here on. |

#### Windows-specific

1. On the CRAN Windows page, click **base**.
2. Download **R-4.x.x for Windows** (`.exe`).
3. Run the installer → Next through all steps → Finish.
4. **Optional but recommended:** Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) if packages fail to compile later. Match the Rtools version to your R version (see the Rtools download page).

#### macOS-specific

1. On the CRAN macOS page, under **Latest release**, download the `.pkg` for your chip:
   - **Apple Silicon (M1/M2/M3/M4):** `arm64` build.
   - **Intel Mac:** `x86_64` build.
2. Double-click the `.pkg` and follow the installer.
3. **Optional:** If package compilation fails later, run in Terminal: `xcode-select --install` (installs Xcode Command Line Tools).

#### Linux-specific

Use your distribution's package manager or download a `.deb`/`.rpm` from CRAN. Example (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install r-base r-base-dev
```

---

### 5.2 Install Posit Desktop (all platforms)

**Official download:** [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)

| Step | Action |
|------|--------|
| 1 | Open the Posit download page. The site usually detects your OS. |
| 2 | Click **Download Posit Desktop** (free, open-source edition). |
| 3 | Run the installer (`.exe` on Windows, `.dmg` on macOS, `.deb`/`.rpm` on Linux). |
| 4 | Launch Posit Desktop. On first start, it should detect the R you installed. If prompted, select that R installation. |
| 5 | **Verification:** You should see four panes (see Section 6). In the Console, type `1 + 1` and press Enter. Output should be `[1] 2`. |

> **Note:** Posit also offers **Positron** (a newer IDE based on VS Code). This SOP and most R tutorials assume **Posit Desktop**. Beginners should start with Posit Desktop.

---

### 5.3 Recommended first-run settings

In Posit Desktop:

| Setting | Path | Recommendation |
|---------|------|----------------|
| **Global options** | Tools → Global Options… (Windows/Linux) or Posit Desktop → Settings… (macOS) | Set **Default working directory** to a folder you control (not Desktop). |
| **Save workspace** | General → Workspace | Uncheck **Restore .RData into workspace at startup** and **Save workspace to .RData on exit**. Scripts, not hidden workspace files, should hold your work. |
| **Code display** | Code → Display | Enable **Show line numbers** in scripts. |
| **Soft-wrap** | Code → Editing | Enable **Soft-wrap long lines** for readability. |

---

## 6. Procedure: Learn the Posit Desktop interface

### 6.1 The four panes

When you open Posit Desktop, you typically see **four quadrants**:

```
┌─────────────────────┬─────────────────────┐
│  SOURCE (Scripts)   │  CONSOLE            │
│  Edit .R files here │  R runs here        │
├─────────────────────┼─────────────────────┤
│  ENVIRONMENT        │  FILES / PLOTS /    │
│  Objects in memory  │  PACKAGES / HELP    │
└─────────────────────┴─────────────────────┘
```

| Pane | What it does | Your habit |
|------|--------------|------------|
| **Source** | Write and save `.R` scripts | Open scripts from `R/examples/`; run lines with keyboard shortcut |
| **Console** | Interactive R; shows output and errors | Run `source("R/00_setup.R")` here at the start of each session |
| **Environment** | Lists data objects currently in memory (`spirometry`, `fit`, etc.) | After **Session → Restart R**, the list should be empty until you re-run setup |
| **Files** | File browser for your project folder | Confirm you see `R/`, `data/`, `volume-01/` at the top level |
| **Plots** | Graphics produced by your code | Use Export → Save as PNG/PDF for slides and manuscripts |
| **Packages** | Installed packages; install button | Use Console `install.packages()` for reproducibility |
| **Help** | Documentation for functions | Type `?mean` in Console to open help for `mean()` |

### 6.2 Essential menu items

| Menu | Common use |
|------|------------|
| **File → New File → R Script** | Start a new analysis script |
| **File → Open Project…** | Open the handbook repository as a project (sets working directory) |
| **Session → Restart R** | Clear memory after package updates or when things behave oddly |
| **Session → Set Working Directory → To Source File Location** | Quick fix when paths break (project open is better) |
| **Tools → Global Options** | Editor font, appearance, default paths |

### 6.3 Essential keyboard shortcuts

| Action | Windows / Linux | macOS |
|--------|-----------------|-------|
| Run current line or selection | `Ctrl + Enter` | `Cmd + Enter` |
| Run entire script | `Ctrl + Shift + Enter` | `Cmd + Shift + Enter` |
| Comment / uncomment lines | `Ctrl + Shift + C` | `Cmd + Shift + C` |
| Find file in project | `Ctrl + .` | `Cmd + .` |
| Save script | `Ctrl + S` | `Cmd + S` |
| Auto-complete function name | `Tab` | `Tab` |
| Open help for function under cursor | `F1` (with cursor on name) | `F1` |

**Cheat sheets (print or keep open):** [Posit cheat sheets](https://posit.co/resources/cheatsheets/) — especially **RStudio IDE**, **ggplot2**, **dplyr**, **Data Import**.

---

## 7. Procedure: Set up this handbook repository

### 7.1 Get the project files

**Option A — Git (recommended):**

```bash
git clone https://github.com/kimonntotsis/Breathing-Room-for-Statistics.git
cd Breathing-Room-for-Statistics
```

**Option B — ZIP download:**

1. Go to [https://github.com/kimonntotsis/Breathing-Room-for-Statistics](https://github.com/kimonntotsis/Breathing-Room-for-Statistics).
2. Click **Code → Download ZIP**.
3. Unzip to a permanent location (e.g. `~/Projects/Breathing-Room-for-Statistics`).

### 7.2 Open as a project

| Step | Action |
|------|--------|
| 1 | In Posit Desktop: **File → Open Project…** |
| 2 | Select the **repository root** — the folder that directly contains `R/`, `data/`, and `volume-01/`. |
| 3 | Do **not** open only `volume-01/` or a subfolder. |
| 4 | **Verification:** In the **Files** pane, you should see `R/`, `data/`, `volume-01/` at the top level. |

### 7.3 Install required packages (one time)

Paste into the **Console**:

```r
install.packages(c(
  "tidyverse", "broom", "patchwork", "survival", "lme4",
  "glmnet", "randomForest", "cluster", "factoextra"
))
```

Install additional packages when a chapter script requests them:

```r
install.packages(c("pwr", "logistf", "mice", "emmeans", "gtsummary"))
```

**Alternative (GUI):** Packages pane → **Install** → Repository: CRAN → type package names → Install.

### 7.4 First session checklist (every time you work)

```r
source("R/00_setup.R")                          # paths + package check
source("R/generate_data.R")                     # rebuild teaching CSVs in data/
source("R/examples/ch03_descriptive.R")         # descriptive analysis example
```

**Expected result:** Console prints `Project root: ...` and scripts create figures under `volume-01/figures/`.

---

## 8. Procedure: Import and export data

### 8.1 Understand file paths

R needs to know **where** files live. Two approaches:

| Approach | Example | When to use |
|----------|---------|-------------|
| **Relative path** (project open) | `read_csv("data/spirometry.csv")` | Default for this handbook |
| **Absolute path** | `read_csv("/Users/you/Projects/.../data/spirometry.csv")` | One-off files outside the project |
| **Project helper** (handbook) | `read_csv(file.path(paths$data, "spirometry.csv"))` | Chapter scripts — portable across machines |

**Check your working directory:**

```r
getwd()                    # should be the repository root when project is open
list.files("data")         # should list CSV files
```

### 8.2 Import CSV files (most common)

```r
library(tidyverse)

# Handbook teaching data
spirometry <- read_csv("data/spirometry.csv", show_col_types = FALSE)

# Peek at the data
glimpse(spirometry)        # column types and first rows
head(spirometry)           # first 6 rows
summary(spirometry)        # quick numeric summaries
```

**`show_col_types = FALSE`** suppresses column-type messages on load (handbook convention).

### 8.3 Import Excel files

Excel is common in hospitals and registries. Use the **readxl** package (included in tidyverse):

```r
library(readxl)

# First sheet
clinic <- read_excel("data/my_registry.xlsx")

# Named sheet
clinic <- read_excel("data/my_registry.xlsx", sheet = "Baseline")
```

If you do not have readxl: `install.packages("readxl")`.

### 8.4 Import other formats

| Format | Function | Package |
|--------|----------|---------|
| Tab-separated (`.tsv`) | `read_tsv("file.tsv")` | readr (tidyverse) |
| SPSS (`.sav`) | `read_sav("file.sav")` | haven |
| Stata (`.dta`) | `read_dta("file.dta")` | haven |
| SAS (`.sas7bdat`) | `read_sas("file.sas7bdat")` | haven |
| R native (`.rds`) | `readRDS("file.rds")` | base R |

```r
install.packages("haven")   # if you need SPSS/Stata/SAS
```

### 8.5 "Upload" data into R (practical workflows)

| Scenario | What to do |
|----------|------------|
| **File already on your computer** | Copy/move it into the project `data/` folder (via Finder/Explorer or **Files** pane → Upload). Then `read_csv("data/yourfile.csv")`. |
| **Drag into project folder** | Drop the file into `data/` in the Files pane or OS file manager. Refresh Files pane if needed. |
| **Posit Desktop Upload button** | In **Files** pane, navigate to `data/`, click **Upload**, select file. |
| **Import Dataset wizard** | **Environment** pane → **Import Dataset** → From Text/Excel — useful for first exploration; switch to script for reproducibility. |
| **Clipboard** | `dat <- read.table("clipboard", header = TRUE)` — quick look only; do not rely on this for analysis. |

**Rule:** For any analysis you might repeat, put the file in `data/` and load it with code in a script — not manual clicks alone.

### 8.6 Export / "download" data and results

| Output | Code | Notes |
|--------|------|-------|
| **CSV** | `write_csv(spirometry, "data/spirometry_clean.csv")` | Preferred for tables |
| **Excel** | `writexl::write_xlsx(list("Sheet1" = spirometry), "data/out.xlsx")` | `install.packages("writexl")` |
| **R object** | `saveRDS(model_fit, "data/model_fit.rds")` | Preserves R types exactly |
| **Multiple objects** | `save(spirometry, model_fit, file = "data/session.RData")` | Legacy style |

**Export a plot:**

```r
ggsave("volume-01/figures/my_plot.png", width = 8, height = 5, dpi = 300)
```

Or use the **Plots** pane → **Export → Save as Image**.

**Export Console output:** Copy from Console, or redirect to file:

```r
sink("volume-01/tables/model_output.txt")
print(summary(model_fit))
sink()   # stop redirecting
```

---

## 9. Procedure: Core R concepts and functions

### 9.1 How R thinks (5-minute mental model)

1. **You create objects** with `<-` (assign): `age <- 65`
2. **You call functions** on objects: `mean(age_vector)`
3. **Functions take arguments**: `mean(x, na.rm = TRUE)`
4. **Everything is a vector** (even a single number): `length(5)` is 1
5. **Data frames are tables** — rows = observations, columns = variables

### 9.2 Assignment and basic arithmetic

```r
x <- 10
y <- 3
x + y          # 13
x / y          # 3.33
sqrt(x)        # 3.16
log(x)         # natural log
exp(1)         # e^1
```

**Use `<-` for assignment** (not `=` — `=` works but `<-` is the R convention).

### 9.3 Vectors and recycling

```r
fev1 <- c(2.1, 2.5, 1.8, 3.0)    # c() combines values
length(fev1)
mean(fev1)
sd(fev1)
median(fev1)
min(fev1); max(fev1)
sum(fev1)

# Logical conditions
fev1 > 2.0                      # TRUE FALSE FALSE TRUE
sum(fev1 > 2.0)                 # count how many TRUE
```

### 9.4 Missing data (`NA`)

```r
x <- c(1, 2, NA, 4)
mean(x)              # NA — propagates missingness
mean(x, na.rm = TRUE)   # 2.33 — excludes NA
is.na(x)             # FALSE FALSE TRUE FALSE
```

**Never ignore NA silently.** Always check `summary()` or `colSums(is.na(df))`.

### 9.5 Data frames and tibbles

```r
library(tidyverse)
spirometry <- read_csv("data/spirometry.csv", show_col_types = FALSE)

# Base R indexing
spirometry$fev1                    # one column
spirometry[1:5, c("age", "fev1")]  # rows and columns

# dplyr style (preferred in this handbook)
spirometry %>%
  select(age, fev1, group) %>%
  filter(fev1 > 2) %>%
  arrange(desc(age))
```

### 9.6 The pipe (`%>%`)

Read `%>%` as **"then"**:

```r
spirometry %>%
  filter(sex == "female") %>%    # keep females
  group_by(group) %>%            # then group by trial arm
  summarise(
    n = n(),
    mean_fev1 = mean(fev1),
    .groups = "drop"
  )
```

Modern R also supports `|>` (native pipe). This handbook uses `%>%` from **magrittr** (loaded with tidyverse).

### 9.7 Essential functions cheat sheet

#### Data inspection

| Function | Purpose |
|----------|---------|
| `glimpse(df)` | Column types + sample values |
| `head(df)`, `tail(df)` | First/last rows |
| `nrow(df)`, `ncol(df)` | Dimensions |
| `names(df)` | Column names |
| `str(df)` | Structure (base R) |
| `summary(df)` | Quick summaries |

#### Wrangling (dplyr)

| Function | Purpose |
|----------|---------|
| `select()` | Keep columns |
| `filter()` | Keep rows matching condition |
| `mutate()` | Create or modify columns |
| `arrange()` | Sort rows |
| `group_by()` + `summarise()` | Grouped summaries (Table 1) |
| `left_join()` | Merge two tables by key column |
| `rename()` | Rename columns |

#### Statistics (base R)

| Function | Purpose |
|----------|---------|
| `mean()`, `median()`, `sd()`, `var()` | Continuous summaries |
| `table()`, `prop.table()` | Frequencies and proportions |
| `cor(x, y)` | Correlation |
| `t.test()`, `wilcox.test()` | Two-group comparisons |
| `aov()`, `lm()` | ANOVA and linear regression |
| `glm()` | Logistic/Poisson regression |

#### Graphics (ggplot2)

```r
ggplot(spirometry, aes(x = group, y = fev1, fill = group)) +
  geom_boxplot() +
  labs(title = "FEV1 by arm", x = NULL, y = "FEV1 (L)") +
  theme_minimal()
```

| Function | Purpose |
|----------|---------|
| `ggplot()` | Start a plot |
| `aes()` | Map variables to x, y, colour, fill |
| `geom_histogram()`, `geom_density()` | Distributions |
| `geom_boxplot()`, `geom_violin()` | Group comparisons |
| `geom_point()`, `geom_smooth()` | Scatter / trend |
| `facet_wrap()` | Small multiples |
| `ggsave()` | Save to file |

### 9.8 Comments and reproducibility

```r
# This is a comment — R ignores it

# Good script structure:
# 1. Load packages
# 2. Load data
# 3. Transform
# 4. Analyse
# 5. Export figures/tables
```

**Guidelines:**

- One script per analysis aim (e.g. `table1_baseline.R`, `primary_endpoint.R`).
- First lines: `source("R/00_setup.R")` when working in this handbook.
- No manual edits to data files without documenting them in code.
- Set a seed for random steps: `set.seed(2026)`.

---

## 10. Procedure: Install and manage packages

### 10.1 Install from CRAN

```r
install.packages("survival")           # one package
install.packages(c("survival", "mice"))  # several at once
```

### 10.2 Load packages

```r
library(tidyverse)    # attaches dplyr, ggplot2, readr, etc.
library(survival)     # must run each new session
```

`install.packages()` is once per machine; `library()` is once per session.

### 10.3 Update packages

```r
update.packages(ask = FALSE)   # update all CRAN packages
```

After updating: **Session → Restart R**, then re-run your setup script.

### 10.4 If a package fails to install

| Error hint | Fix |
|------------|-----|
| `compilation failed` (Windows) | Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/) matching your R version |
| `compilation failed` (macOS) | `xcode-select --install` in Terminal |
| `package not found` | Check spelling; search [https://cran.r-project.org](https://cran.r-project.org) |
| `version X required` | Update R itself from CRAN |
| Locked library | Close other R sessions; restart Posit Desktop |

---

## 11. Procedure: Getting help

| Method | Example |
|--------|---------|
| **R help** | `?mean` or `help(lm)` |
| **Vignette** | `vignette("ggplot2")` |
| **Search help** | `??"logistic regression"` |
| **Function args** | `args(read_csv)` |
| **Posit Community** | [https://forum.posit.co](https://forum.posit.co) |
| **Stack Overflow** | Tag `[r]` — search before posting |

**How to ask a good question:** include `sessionInfo()`, the exact error message, a minimal reproducible example (`dput(head(mydata))`), and what you expected.

---

## 12. Learning path: from beginner to handbook-ready

### Week 1 — Environment and data

| Day | Task | Resource |
|-----|------|----------|
| 1 | Install R + Posit Desktop; run `1+1` | This SOP §5–6 |
| 2 | Open handbook project; run `source("R/00_setup.R")` | [Appendix A](appendix-a-r-setup.md) |
| 3 | Load `spirometry.csv`; `glimpse`, `summary` | This SOP §8 |
| 4 | Make one ggplot (boxplot of FEV1 by group) | [ggplot2 cheat sheet](https://posit.co/resources/cheatsheets/) |
| 5 | `filter` and `group_by` + `summarise` | [dplyr cheat sheet](https://posit.co/resources/cheatsheets/) |

### Week 2 — Reproducible workflow

| Day | Task |
|-----|------|
| 1 | Run `R/examples/ch03_descriptive.R` end-to-end |
| 2 | Run `R/examples/ch04_comparing_groups.R` |
| 3 | Change one plot title; re-run; find output in `volume-01/figures/` |
| 4 | Export a table to CSV with `write_csv()` |
| 5 | Read [R for Data Science](https://r4ds.hadley.nz/) Chapters 1–3 |

### Week 3 — Connect to respiratory research

| Task | Handbook link |
|------|---------------|
| Table 1 and distributions | [Chapter 3](chapters/03-descriptive-analysis.md) |
| Group comparisons | [Chapter 4](chapters/04-comparing-groups.md) |
| Linear models (FEV1) | [Chapter 5](chapters/05-linear-models.md) |
| Method choice lookup | [Appendix B](appendix-b-quick-reference.md) |
| Exercises | [Appendix F](appendix-f-exercises.md) |

**Recommended external courses (free):**

- [Posit Primers](https://posit.cloud/learn/primers) — short interactive lessons
- [R for Data Science](https://r4ds.hadley.nz/) — definitive tidyverse book (free online)
- [STAT 545](https://stat545.com/) — data science conventions

---

## 13. Troubleshooting (common first-month errors)

| Error message | Likely cause | Fix |
|---------------|--------------|-----|
| `cannot open file 'R/00_setup.R'` | Wrong working directory | **File → Open Project…** → select repository root |
| `there is no package called 'tidyverse'` | Packages not installed | Run `install.packages("tidyverse")` |
| `Install missing packages: ...` | Handbook setup stop message | Install the listed packages; re-run `source("R/00_setup.R")` |
| `object 'spirometry' not found` | Data not loaded yet | Run `read_csv(...)` or re-run chapter script from top |
| `could not find function "%>%"` | tidyverse not loaded | `library(tidyverse)` |
| `Error in library(foo) : there is no package called 'foo'` | Typo or not installed | `install.packages("foo")` then `library(foo)` |
| `NAs introduced by coercion` | Wrong column type (text in numeric column) | `glimpse(df)`; clean with `mutate()` and `as.numeric()` |
| Plot appears in Plots pane but not saved | No `ggsave()` | Add `ggsave("path.png", width=8, height=5, dpi=300)` |
| Script works yesterday, fails today | Stale environment or package update | **Session → Restart R** → re-run setup and full script |
| `%>%` vs `|>` confusion | Mixed pipe styles | Stick to `%>%` in this handbook |

---

## 14. Quality checklist (sign-off)

Before you analyse real study data, confirm:

- [ ] R and Posit Desktop open without errors.
- [ ] Handbook project opens with `R/`, `data/`, `volume-01/` visible in Files pane.
- [ ] `source("R/00_setup.R")` prints project root and does not stop on missing packages.
- [ ] You can load `data/spirometry.csv` and see > 0 rows with `nrow()`.
- [ ] You can save a plot with `ggsave()` and open the PNG outside R.
- [ ] You know how to restart R and re-run setup.
- [ ] Your analysis steps live in a saved `.R` script, not only Console history.

**Completed by:** _________________________ **Date:** _____________

---

## 15. Quick reference card (print this page)

```
SESSION START
  source("R/00_setup.R")

LOAD DATA
  library(tidyverse)
  dat <- read_csv("data/spirometry.csv", show_col_types = FALSE)

WRANGLE
  dat %>% filter(age > 40) %>% group_by(group) %>% summarise(n = n(), mean_fev1 = mean(fev1))

PLOT
  ggplot(dat, aes(group, fev1, fill = group)) + geom_boxplot() + theme_minimal()

SAVE
  ggsave("volume-01/figures/plot.png", width = 8, height = 5, dpi = 300)
  write_csv(results, "volume-01/tables/results.csv")

HELP
  ?function_name    Session → Restart R    Ctrl/Cmd + Enter to run line
```

---

## 16. Related documents

| Document | Use when |
|----------|----------|
| [Appendix A: R environment](appendix-a-r-setup.md) | Short handbook-specific setup |
| [Appendix G: Handbook navigation](appendix-g-handbook-navigation.md) | Find chapters, datasets, scripts |
| [Appendix B: Quick reference](appendix-b-quick-reference.md) | Choose statistical method |
| [INSTRUCTOR_PACK.md](INSTRUCTOR_PACK.md) | Teaching schedule and labs |
| [RECURRING_COHORT.md](RECURRING_COHORT.md) | CASTOR teaching datasets |

---

## 17. Document history

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | July 2026 | Initial release: install, interface, data I/O, core R, learning path |

---

## 18. Exporting this SOP to Microsoft Word

To produce a Word document for printing or LMS upload:

**Option A — Pandoc (if installed):**

```bash
cd volume-01
pandoc R_GETTING_STARTED_SOP.md -o R_GETTING_STARTED_SOP.docx --toc --number-sections
```

**Option B — Posit Desktop / Word:**

1. Open this `.md` file in Posit Desktop or VS Code.
2. Copy sections into Word, or use **File → Knit/Render** if you have a Quarto setup.
3. Apply your institution's SOP template (logo, approval block, page numbers).

**Option C — Quarto render:**

```bash
quarto render volume-01/R_GETTING_STARTED_SOP.md --to docx
```

---

*End of SOP-R-001*
