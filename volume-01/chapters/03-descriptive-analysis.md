# Chapter 3: Descriptive Analysis and Visualization

> **Part II: Description Before Inference**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](RECURRING_COHORT.md) - `data/spirometry.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **R** | `R/examples/ch03_descriptive.R` |
| **Figures** | [FIGURE_INDEX](../FIGURE_INDEX.md) - `ch03_*.png` |
| **Exercises** | [ch03](../exercises/ch03_exercises.md) |

**Also see:** [QUICK_REFERENCE](../QUICK_REFERENCE.md), Describe before infer: [Ch 4-6](04-comparing-groups.md)
## Learning objectives

1. Choose summaries matched to variable type and distribution.
2. Build Table 1 before any inferential analysis.
3. Create diagnostic plots that inform method choice (Ch 4-6).
4. Report missingness and n transparently.
5. Write descriptive Methods/Results text for a respiratory paper.

## Prerequisites

Chapters 1-2.

---

## Why this chapter

Reviewers and clinicians meet your study in Table 1 and the first figure. Description is not “preliminary”; it is where missingness, skew, and protocol quirks become visible. CASTOR starts here so you see the same patients before any test is run.

## Opening question (CASTOR)

*Before comparing FEV1 between trial arms - who is in the CASTOR cohort, and are groups similar at baseline?*

Description is not optional preamble. It is how you catch errors and justify the methods that follow [@harrell2015rms; @stoltzfus2019biostatistics].

---

## The descriptive workflow

1. **Inventory** - n, variables, types, missingness  
2. **Summarise** - Table 1 by exposure/arm  
3. **Visualise** - distributions and relationships  
4. **Decide** - symmetric → mean/t-test path; skewed → median/nonparametric  
5. **Report** - before primary analysis  

---

## Technique: Table 1 (baseline characteristics)

### Technique card

| | |
|---|---|
| **Answers** | What does the study sample look like? Are groups balanced? |
| **Outcome** | None - purely descriptive |
| **Design** | Any; essential for RCT and cohort papers |
| **Data required** | Demographics, key clinical vars, stratification factor |
| **R** | `gtsummary::tbl_summary(by = group)` |
| **When to use** | Always before primary inference [@schulz2010consort; @vonelm2007strobe] |
| **When NOT to use** | As primary evidence of treatment effect |
| **Does NOT prove** | Causation; that adjustment is unnecessary |

### Dual interpretation

**Plain language:** Table 1 shows age, sex, smoking, and lung function in each group.

**Precise language:** descriptive frequencies and summaries; between-group p-values are optional and not substitute for prespecified primary analysis.

**Clinician read:** are groups similar enough that unadjusted comparison is plausible? Large imbalances → need adjustment (Ch 5-6).

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Table 1 p-values | Not primary endpoint in RCT; can mislead [@schulz2010consort] |
| Missing data | Different n across rows hides attrition |
| Collapsed categories | Hides severity spectrum (GOLD, mMRC) |
| Single time point | Baseline only - not longitudinal status |
| Synthetic vs real | CASTOR is simulated - replace with your cohort |

### In practice

Table 1 is often drafted by a junior author while the statistician is busy elsewhere. Agree on variable definitions and missingness rules first; otherwise Table 1 and the model use different populations.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Skip Table 1; jump to p-value on outcome |
| **Do instead** | Describe first; state n and missingness |

| | |
|---|---|
| **Mistake** | "Baseline p < 0.05 proves groups differ on outcome" |
| **Why wrong** | Table 1 tests are not the trial primary analysis |
| **Do instead** | Prespecified outcome model (Ch 4-6) |

### Reporting template

**Methods:** Baseline characteristics were summarised by treatment arm. Continuous variables are mean (SD); categorical variables n (%). Analyses used R (gtsummary).

**Results:** Table 1 shows 400 participants (198 intervention, 202 standard). Mean age 58.7 years; 33% smokers; mean FEV1 3.80 L. Groups were similar on observed baseline variables.

### R lab

```r
source("R/examples/ch03_descriptive.R")
```

---

## Technique: Summary statistics (mean, median, SD, IQR)

### Technique card

| | |
|---|---|
| **Answers** | What is typical and how variable is this measure? |
| **Continuous symmetric** | Mean (SD) |
| **Continuous skewed** | Median [IQR] |
| **Binary** | n (%) |
| **Does NOT prove** | Normality (use QQ plot) |

### Caveats: FEV1 specifically

| Caveat | Detail |
|--------|--------|
| Mean hides bimodality | Mixed asthma+COPD cohorts |
| SD ≠ CI | SD describes patients; SE/CI describes mean uncertainty |
| Units | Litres vs % predicted - label clearly [@graham2019spirometry] |

### Wrong analysis ⚠

Report mean (SD) for ICU length-of-stay with extreme outliers → use median [IQR].

---

## Technique: Histogram and density plot

### Technique card

| | |
|---|---|
| **Answers** | What is the shape of the distribution? |
| **Use** | Continuous outcomes before t-test |
| **R** | `ggplot(aes(x=fev1)) + geom_histogram + geom_density` |
| **CASTOR figure** | `volume-01/figures/ch03_fev1_histogram.png` |

### Dual interpretation

**Plain language:** where do most patients' FEV1 values fall?

**Clinician read:** bimodal or floor effects (severe obstruction cluster) suggest mean alone may mislead.

### Caveats

Overlapping histograms by group need clear colours; bin width affects appearance.

### Wrong analysis ⚠

Use bar chart with only mean ± SE for n < 30 without showing raw data.

---

## Technique: Boxplot and violin plot

### Technique card

| | |
|---|---|
| **Answers** | Compare distribution between groups |
| **Boxplot** | Median, IQR, outliers |
| **Violin** | Full density shape |
| **R** | `geom_boxplot()` + `geom_jitter()`; `geom_violin()` |
| **Figure** | `ch03_fev1_violin.png` |

### Caveats

Outliers may be real severe patients - investigate before deleting. Jitter reveals sample size visually.

---

## Technique: QQ plot (normality check)

### Technique card

| | |
|---|---|
| **Answers** | Are data roughly normal for mean-based methods? |
| **Use before** | t-test, ANOVA on small/m moderate n |
| **R** | `stat_qq() + stat_qq_line()` |
| **Figure** | `ch03_fev1_qq.png` |

### Dual interpretation

**Plain language:** do points follow the diagonal line?

**Precise language:** visual check of agreement with normal distribution; Shapiro test often overpowers large n [@harrell2015rms].

### Caveats

Mild tail deviation may be acceptable with large n (CLT) [@harrell2015rms]. QQ on **residuals** after regression more relevant than on raw FEV1 alone.

### Wrong analysis ⚠

Reject t-test solely because Shapiro p < 0.05 with n = 500 - consider Welch t and effect size.

---

## Technique: Scatterplot and correlation

### Technique card

| | |
|---|---|
| **Answers** | Is FEV1 associated with age (linearly)? |
| **Pearson r** | Linear association |
| **Spearman ρ** | Monotonic, robust |
| **R** | `ggplot + geom_point + geom_smooth`; `cor()` |
| **Figure** | `ch03_fev1_scatter.png` |

### Caveats

Correlation ≠ causation. Influential points drive r. Smoking colour on scatter can reveal confounding structure.

### Wrong analysis ⚠

Correlate binary smoking (0/1) with FEV1 and call it "effect" - use regression (Ch 5) for adjusted statement.

---

## Missing data in descriptives

Report n for each variable. Note if complete-case n drops. Missing FEV1 in spirometry trials often informative (sicker patients skip test) - see [Ch 20](20-missing-data.md).

---

## CASTOR worked example

**Step 1:** Table 1 by `group`.  
**Step 2:** Histogram and violin of FEV1.  
**Step 3:** QQ plot → roughly symmetric → Welch t reasonable (Ch 4) [@welch1947t].  
**Step 4:** Scatter FEV1 vs age, coloured by smoking → motivates adjusted regression (Ch 5).

---

## Catalog of wrong analyses (descriptive chapter)

| Wrong | Right |
|-------|-------|
| Hide missing n | Report n per variable |
| Table 1 p as primary result | Prespecified outcome analysis |
| Mean for heavy skew | Median [IQR] |
| No units on axes | FEV1 (L), age (years) |
| Skip plots | Plot before test |

---


## R lab

```r
source("R/examples/ch03_descriptive.R")
```

---

## Chapter summary

- Describe before you infer [@harrell2015rms].
- Table 1 + distribution plots drive method choice.
- Every summary needs n, units, and missingness note.

---

## Alternatives & extensions (choose by data)

Descriptives are where you decide what later methods are plausible. Use these alternatives when the data demand it.

### Technique: Standardized mean differences (SMD) instead of Table 1 p-values

| | |
|---|---|
| **Use when** | You want to describe baseline balance without hypothesis testing |
| **Why** | SMD is scale-free; p-values depend heavily on n |
| **Common R** | `cobalt` package; or compute SMD directly |

### Technique: Robust summaries for skew/outliers

| Data pattern | Prefer |
|---|---|
| Heavy right tail (LOS, ICU days) | Median [IQR], trimmed mean |
| Outliers likely | Median absolute deviation (MAD), winsorized summaries |

### Technique: Missingness visualization

| | |
|---|---|
| **Use when** | Many variables with missing data; patterns may be informative |
| **Common R** | `naniar::vis_miss()`, `mice::md.pattern()` (Vol II expands MI) |

### Technique: Distributional comparison plots

| Plot | Use when |
|---|---|
| ECDF | Compare full distributions across groups |
| Ridgeline density | Many groups; need compact distribution comparison |

### Technique: Transformations (for later modelling)

| | |
|---|---|
| **Use when** | Positive skewed outcomes; multiplicative variability |
| **Examples** | log-transform biomarkers; log(1+y) for counts *only descriptively* |
| **Caution** | Transformation changes estimand; report scale clearly |

## Where this chapter leads

**Next:** [Chapter 4](04-comparing-groups.md) is the comparison reference. Bring your Table 1 insights (skew, missingness, n per arm) into every test choice.

## Further reading

- Harrell, *Regression Modeling Strategies* - descriptive summaries before modelling [@harrell2015rms]  
- Stoltzfus, *Biostatistics for Health and Biological Science Users of R* [@stoltzfus2019biostatistics]  
- Wickham, *ggplot2* [@wickham2016ggplot2]  
- CONSORT / STROBE baseline reporting [@schulz2010consort; @vonelm2007strobe]

## Exercises ([Solutions](../solutions/ch03_solutions.md))

**Next:** [Chapter 4](04-comparing-groups.md)
