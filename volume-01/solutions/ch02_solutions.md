# Chapter 2 — Solutions

## E2.1
FEV1: **continuous**. Exacerbation count: **count**. GOLD stage: **ordinal**. Time to death: **time-to-event** (Vol II).

## E2.2
Same patient contributes correlated visits; independence assumption of standard *t*-tests fails → [Ch 18](chapters/18-longitudinal-mixed-models.md) [@harrell2015rms].

## E2.3
Examples: range check (FEV1 > 0); pre- vs post-BD consistency [@graham2019spirometry]; duplicate IDs; missingness pattern.

## E2.4
**Exposure:** effect of therapy line on exacerbations. **Confounder:** adjust for therapy when studying biomarker–FEV1 association.

## E2.5
**Chapter 6** — logistic regression for binary exacerbation with covariate adjustment.

## Applied
```r
source("R/00_setup.R")
library(tidyverse)
s <- read_csv("data/spirometry.csv", show_col_types = FALSE)
```
**Outcome type:** continuous (`fev1`). **Unit:** one row per patient. **Pitfall:** analysing without age/sex adjustment when comparing groups — use regression ([Ch 5](../chapters/05-linear-models.md)) or descriptives by group ([Ch 3](../chapters/03-descriptive-analysis.md)).

Route table: [QUICK_REFERENCE.md](../QUICK_REFERENCE.md).
