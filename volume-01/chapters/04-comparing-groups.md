# Chapter 4: Comparing Groups

> **Part II: Inference for Common Respiratory Outcomes**

## At a glance

| | |
|---|---|
| **Question type** | Are groups different? By how much? |
| **Typical outcomes** | FEV1, FVC, exacerbation Y/N, exacerbation counts |
| **Recurring cohort** | [CASTOR](../RECURRING_COHORT.md) |
| **Key methods** | t-tests, ANOVA, nonparametric, chi-square, Fisher, ANCOVA, permutation, power |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **R scripts** | `R/examples/ch04_comparing_groups.R` |
| **Figures** | ch04_fev1_by_group (`ch04_fev1_by_group.png`), paired BD (`ch04_paired_bronchodilator.png`), comparison panel (`method_comparison_panel.png`) |
| **Exercises** | [Chapter 4 exercises](../exercises/ch04_exercises.md) |

**Also see:** [Appendix B § Step 2-3](../appendix-b-quick-reference.md), [Master table](#master-decision-table)
---

## Learning objectives

After this chapter you should be able to:

1. State the estimand before choosing any test.
2. Select a comparison method based on outcome type, number of groups, and pairing.
3. Explain assumptions and know nonparametric alternatives.
4. Report effect sizes and confidence intervals, not only p-values.
5. Implement comparisons in R and interpret results for clinical audiences.
6. Recognise respiratory-specific pitfalls (spirometry timing, clustering, multiplicity).

## Prerequisites

- [Chapter 1](01-statistical-thinking.md) - estimands and study design
- [Chapter 2](02-respiratory-data.md) - outcome types
- [Chapter 3](03-descriptive-analysis.md) - summaries and plots

---

## Why this chapter

Most respiratory papers still hinge on a comparison: means, proportions, or rates between arms or exposure groups. This is the longest reference chapter because the mistakes are repetitive; wrong pairing, wrong outcome type, p-values without effect sizes. Bookmark it.

## Opening question

A COPD trial asks: *Does mean FEV1 differ between intervention and standard care at 12 weeks?*

A second study asks: *Does the proportion of patients with ≥1 exacerbation differ by therapy line?*

These are both **comparison** questions, but they require **different methods** [@stoltzfus2019biostatistics]. This chapter is the reference for that choice.

We use the **[CASTOR cohort](../RECURRING_COHORT.md)** throughout - same patients you described in Chapters 3 and will model in Chapters 5-9.

---

## Clinical and biostatistics notes

**Clinical:** Pre- vs post-bronchodilator timing must match across arms. FEV1 comparisons should reference **MCID** where relevant. Classify exacerbation endpoints as **proportion vs count** before choosing a test (route to Ch 6).

**Biostatistics:** **Welch *t*** is the default for two independent groups. Always report **mean difference + 95% CI**, not *p* alone. Secondary lung-function endpoints need a **multiplicity** plan. Do not use comparison methods from this chapter on **paired** or **clustered** designs without the paired/cluster rows.

**Clinical nuance:** a non-significant week-12 FEV1 difference does not prove equivalence; equivalence needs a prespecified margin and power (not covered in depth here).

**Biostat nuance:** Wilcoxon compares **ranks**; if mean and median differences disagree, report both and discuss skew/outliers.

---

## The comparison workflow

Every group comparison follows five steps:

1. **Estimand** - mean difference? median difference? risk difference?
2. **Design** - independent, paired, or clustered?
3. **Outcome type** - continuous, binary, count?
4. **Method** - matched to 1-3 with stated assumptions
5. **Report** - effect estimate, 95% CI, n, test/ model, limitations

---

## Continuous outcomes: two independent groups

### Technique: Welch two-sample t-test

| | |
|---|---|
| **Answers** | Is the mean of a continuous outcome different between two independent groups? |
| **Outcome** | Continuous (FEV1, FVC, 6MWD) |
| **Design** | Two independent groups, one measurement per patient |
| **Assumptions** | Independence; approximate normality within groups or large n; Welch does **not** require equal variances |
| **Effect measure** | Mean difference (group A − group B) |
| **R** | `t.test(y ~ group, var.equal = FALSE)` |
| **Report** | Mean difference, 95% CI, n per group, Welch t |
| **Avoid when** | Outcome binary/count; paired measurements; strong skew with small n; clustered data |

**Plain language:** compare average lung function between two groups.

**Precise language:** test $H_0$: $\mu_1 = \mu_2$ with CI for $\mu_1 - \mu_2$; robust to unequal variances (Welch-Satterthwaite df) [@welch1947t].

**Clinical relevance:** ask whether the mean difference exceeds the **MCID** (minimum clinically important difference) for that outcome - literature-based, disease-specific [@cazzola2008mcid].

```r
t.test(fev1 ~ group, data = spirometry, var.equal = FALSE)
```

### Other respiratory settings

CASTOR uses COPD-style FEV1 trials. When you interpret a mean difference or CI:

- **Asthma:** MCID for FEV1 differs from COPD. Biologic trials may prespecify exacerbation reduction even when FEV1 moves modestly. Compare the CI to the margin in your protocol.
- **Mixed airways disease:** Match pre- and post-bronchodilator timing between arms before any group comparison or ANCOVA.

Fix the primary estimand in the SAP before unblinding.

#### Dual interpretation (CASTOR trial arms)

**Plain language:** is average FEV1 higher or lower in the intervention group?

**Precise language:** estimate of μ_intervention − μ_standard with 95% CI; Welch test does not assume equal variances.

**Practice read:** is the mean difference (e.g. 0.09 L) large enough to matter given MCID (~0.10 L in many COPD trials)? The CI answers that as well as p-values [@cazzola2008mcid].

#### Caveats box: Welch t-test

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| Compares **means**, not medians | Skewed FEV1 in severe COPD → consider Mann-Whitney or report median |
| **Independence** assumed | ICU patients in same ward, or repeated FEV1 → wrong test |
| **One time point** | Does not model FEV1 decline over time ([Ch 18](18-longitudinal-mixed-models.md)) |
| **Not causal** in observational data | Group differences may reflect confounding |
| **MCID ≠ p-value** | Non-significant p with CI including MCID is inconclusive, not "no effect" |
| **Spirometry protocol** | Pre- vs post-bronchodilator must match between groups [@graham2019spirometry] |

### In practice

The protocol says “compare FEV1 at week 12.” The data have baseline visits, dropouts, and one site that measured post-bronchodilator values only. Map protocol → estimand → test before opening `t.test()`, and document deviations in the SAP.

### In practice (multiplicity)

The steering committee wants FEV1, FVC, symptom score, and exacerbation rate on one slide. Unless the protocol prespecified a hierarchy, label secondary endpoints as exploratory and report CIs; not five primary *p*-values.

### In practice (non-inferiority)

A device trial protocol says “non-inferior to standard inhaler on FEV1.” That is **not** a superiority *t*-test with *p* > 0.05 interpreted as “similar.” Prespecify a margin (e.g. −0.10 L), power for NI, and a TOST or CI-against-margin analysis ([reporting template below](#technique-non-inferiority-and-equivalence-trials)).

#### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Welch t-test on **exacerbation counts** (0, 1, 2, 3…) |
| **Why wrong** | Count data, skewed, bounded at zero; mean difference hard to interpret |
| **Do instead** | Poisson / negative binomial (Ch 6) |

| | |
|---|---|
| **Mistake** | Compare post-BD FEV1 in one arm vs pre-BD in another |
| **Why wrong** | Confounds treatment with bronchodilator response |
| **Do instead** | Same BD protocol in both arms; prespecify pre or post |

| | |
|---|---|
| **Mistake** | "No significant difference → treatments equivalent" |
| **Why wrong** | Underpowered studies cannot prove equivalence |
| **Do instead** | Report CI; equivalence needs prespecified margin (TOST) |

#### Reporting template

**Methods:** FEV1 (L) at 12 weeks was compared between intervention and standard care using Welch's t-test (two-sided α = 0.05). The primary estimand was the mean difference (intervention − standard).

**Results:** Mean FEV1 was 3.85 L (SD 0.64) in intervention (n = 198) and 3.76 L (SD 0.64) in standard care (n = 202). Mean difference 0.09 L (95% CI −0.04 to 0.21; p = 0.20).

**Do not say:** "No effect of intervention"; "trend toward benefit" without prespecified trend test.

### Technique: Pooled two-sample t-test

Assumes **equal variances** in both groups. Rarely needed; Welch is the default. Use pooled version only with strong domain reason and Levene test supporting equality.

```r
t.test(fev1 ~ group, data = spirometry, var.equal = TRUE)
```

### Technique: Mann–Whitney U (Wilcoxon rank-sum)

| | |
|---|---|
| **Answers** | Do two independent groups differ in location/distribution? |
| **Use when** | Continuous outcome, small n, clear skew, normality doubtful |
| **Effect measure** | Difference in medians (descriptive); rank-based test statistic |
| **R** | `wilcox.test(y ~ group, exact = FALSE)` |
| **Caution** | Tests a different null than t-test; does not compare means |

```r
wilcox.test(fev1 ~ group, data = spirometry)
```

#### Dual interpretation

**Plain language:** do smokers and non-smokers differ in typical FEV1 (rank-based)?

**Precise language:** tests whether distributions differ; null differs from equal means unless distributions are symmetric shifts [@mann1947test].

**Practice read:** if t-test and Mann-Whitney disagree, report both estimates (mean diff and median diff).

#### Caveats box

| Caveat | Detail |
|--------|--------|
| Not a mean test | Median interpretation; tie handling affects results |
| Loses power | If data actually normal, t-test more powerful |
| Ties common | FEV1 tied values - use exact=FALSE carefully |

#### Wrong analysis ⚠

Use Mann-Whitney then report mean difference only → report median [IQR] or both.

#### Reporting template

**Results:** Mann-Whitney p = 0.30; median FEV1 3.82 L (IQR …) vs 3.75 L (IQR …).

---

## Continuous outcomes: one sample

### Technique: One-sample t-test

| | |
|---|---|
| **Answers** | Is mean outcome different from a reference value $\mu_0$? |
| **CASTOR use** | Compare cohort mean FEV1 to protocol benchmark (with caution) |
| **R** | `t.test(fev1, mu = 2.5)` |
| **Does NOT prove** | That reference is clinically appropriate for this population |

```r
t.test(spirometry$fev1, mu = 3.0)
```

#### Caveats

Reference equations for FEV1 % predicted are population-specific. One-sample tests on subgroups need clear estimand.

#### Wrong analysis ⚠

Compare clinic mean to textbook "normal" FEV1 without age/sex/height standardization → use % predicted or regression.

---

## Continuous outcomes: paired measurements

### Technique: Paired t-test

| | |
|---|---|
| **Answers** | Is mean change (or paired difference) ≠ 0? |
| **Design** | Same patient, two measurements |
| **CASTOR example** | Pre/post bronchodilator FEV1 (`bronchodilator_paired.csv`) |
| **R** | `t.test(pre, post, paired = TRUE)` |
| **Avoid when** | Order effects in crossover; independent groups |

```r
bronchodilator <- read_csv(
  "data/bronchodilator_paired.csv",
  show_col_types = FALSE
)
t.test(bronchodilator$fev1_pre, bronchodilator$fev1_post, paired = TRUE)
```

#### Dual interpretation

**Plain language:** did bronchodilator increase FEV1 on average?

**Precise language:** tests mean of pairwise differences; assumes approximate normality of differences.

**Practice read:** mean change ~0.25 L - compare to MCID for bronchodilator response in relevant disease [@cazzola2008mcid].

#### Caveats box

| Caveat | Detail |
|--------|--------|
| BD protocol | Must be standardised (200-400 mcg salbutamol etc.) [@graham2019spirometry] |
| Carryover | Not for crossover without washout |
| One visit | Learning/spirometry effort may affect 2nd blow |

#### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Welch t on pre vs post as independent groups |
| **Do instead** | Paired t or Wilcoxon signed-rank |

#### Reporting template

**Results:** Mean FEV1 increased 0.25 L post-bronchodilator (95% CI 0.24 to 0.27; paired t, p < 0.001; n = 80).

### Technique: Wilcoxon signed-rank (paired)

For skewed paired differences: `wilcox.test(pre, post, paired = TRUE)`.

---

## Continuous outcomes: three or more groups

### Technique: One-way ANOVA

| | |
|---|---|
| **Answers** | Do any group means differ? |
| **CASTOR example** | FEV1 by `diagnosis` (no/moderate/severe obstruction) |
| **$H_0$** | All group means equal |
| **R** | `aov(fev1 ~ diagnosis)` + `TukeyHSD` |
| **Follow-up** | Prespecified contrasts only |

```r
fit_aov <- aov(fev1 ~ diagnosis, data = spirometry)
summary(fit_aov)
TukeyHSD(fit_aov)
```

#### Dual interpretation

**Plain language:** does lung function differ across severity categories?

**Precise language:** omnibus F-test; does not say which pairs differ without contrasts.

#### Caveats box

| Caveat | Detail |
|--------|--------|
| Omnibus only | Significant F → need post-hoc/contrasts |
| Multiplicity | Many pairwise comparisons inflate error |
| Ordinal diagnosis | Categories ordered - trend tests alternative |
| Imbalanced n | ANOVA robust with moderate imbalance |

#### Wrong analysis ⚠

ANOVA significant → test all pairs without adjustment → Tukey or prespecified contrasts.

#### Reporting template

**Results:** FEV1 differed by diagnosis (ANOVA F = 49.6, p < 0.001). Tukey: no obstruction vs moderate mean diff 1.52 L (95% CI …).

### Technique: Kruskal-Wallis

| | |
|---|---|
| **Answers** | Do ≥3 groups differ in distribution (nonparametric)? |
| **R** | `kruskal.test(fev1 ~ diagnosis, data = spirometry)` |
| **Use when** | Skew, outliers, ordinal severity |

#### Caveats

Does not locate which groups differ - use Dunn post-hoc if needed.

---

## Adjusting for baseline: ANCOVA preview

When groups differ at baseline (observational) or you want greater precision (RCT with baseline covariate):

**Question:** Is FEV1 at follow-up different between groups **after adjusting for baseline FEV1 and prespecified covariates**?

```r
# If follow-up FEV1 available:
# lm(fev1_followup ~ group + fev1_baseline + age + sex, data = dat)
```

Full treatment in [Chapter 5](05-linear-models.md). ANCOVA is **not** a substitute for randomisation in causal claims.

---

## Binary outcomes: comparing proportions

### Technique: Chi-square test of independence

| | |
|---|---|
| **Answers** | Are row and column categories independent? |
| **CASTOR example** | Therapy class × exacerbation |
| **R** | `chisq.test(table(therapy, exacerbation_12m))` |
| **Requires** | Expected counts ≥ ~5 per cell (rule of thumb) [@agresti2018introduction] |

```r
tab <- table(exacerbation$therapy, exacerbation$exacerbation_12m)
chisq.test(tab)
```

#### Caveats box

| Caveat | Detail |
|--------|--------|
| Sparse tables | Chi-square p invalid → Fisher |
| Unadjusted | Confounding by severity |
| Large samples | Tiny effects become "significant" |

#### Wrong analysis ⚠

Chi-square only without RD/RR/OR → always add effect measure with CI.

### Technique: Fisher's exact test

For small samples or sparse tables:

```r
fisher.test(tab, simulate.p.value = TRUE, B = 10000)  # large tables
```

#### Dual interpretation (CASTOR smoking × exacerbation)

**Plain language:** is the exacerbation rate different in smokers?

**Precise language:** tests independence in 2×2 table; Fisher exact valid for small expected counts [@agresti2018introduction].

**Practice read:** report **risk difference** (absolute %) alongside p-value - "2.9% more events" is clearer than p alone.

#### Caveats box: Fisher / chi-square for binary outcomes

| Caveat | Why it matters |
|--------|----------------|
| **Unadjusted** | Table ignores age, FEV1, prior history → confounding |
| **OR ≠ RR** when common | High exacerbation rate → OR overstates RR |
| **Sparse cells** | Chi-square invalid; use Fisher or exact methods |
| **Multiple therapies** | 3+ level tables need careful contrast specification |
| **Not paired** | Same patient before/after needs McNemar |

#### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Chi-square only, no effect size |
| **Do instead** | RD, RR, or OR with 95% CI; logistic for adjustment (Ch 6) |

| | |
|---|---|
| **Mistake** | Report OR from unadjusted 2×2 as "adjusted effect" |
| **Why wrong** | No covariates in table |
| **Do instead** | Logistic with prespecified confounders |

#### Reporting template

**Results:** Exacerbation occurred in 13/171 smokers (7.6%) and 5/179 non-smokers (2.8%). Fisher exact p = 0.05; unadjusted odds ratio 2.86 (95% CI 0.93 to 10.5). Confounders not adjusted.

### Effect measures for binary outcomes

| Measure | Meaning | R (concept) |
|---------|---------|-------------|
| **Risk difference** | Absolute difference in proportions | `prop.test`, `riskdifference` packages |
| **Risk ratio** | Relative proportion | log-binomial or `epiR` |
| **Odds ratio** | Ratio of odds | `glm(..., family = binomial)` |

**Plain language:** risk difference tells you how many more patients per 100 experience the event.

**Precise language:** RD = $p_1 - p_2$; RR = $p_1/p_2$; OR = $[p_1/(1-p_1)] / [p_2/(1-p_2)]$, where $p_1$ and $p_2$ are event risks in the two groups.

```r
prop.test(
  x = c(sum(exacerbation$exacerbation_12m[exacerbation$smoking]),
        sum(!exacerbation$exacerbation_12m[exacerbation$smoking])),
  n = c(sum(exacerbation$smoking), sum(!exacerbation$smoking))
)
```

### Technique: McNemar test (paired binary)

| | |
|---|---|
| **Answers** | Did paired binary outcome change in same patients? |
| **Design** | Before/after on same patient |
| **Example** | Sputum culture positive before vs after therapy |
| **R** | `mcnemar.test(matrix(c(a,b,c,d), nrow=2))` |
| **Does NOT** | Compare independent groups |

```r
# Example structure: rows=before, cols=after
# mcnemar.test(table(before, after))
```

#### Dual interpretation

**Plain language:** did the proportion with positive culture change after treatment?

**Precise language:** tests marginal homogeneity in 2×2 paired table; uses discordant pairs only.

#### Caveats

Requires true pairing; missing one time point drops patient.

#### Wrong analysis ⚠

Chi-square on stacked before/after as independent groups → McNemar.

#### Reporting template

**Results:** McNemar test p = …; 12 patients improved, 3 worsened among discordant pairs (n = …).

---

## Count outcomes: comparing rates

For **exacerbation counts** between groups, Poisson or negative binomial regression is preferred over t-tests on raw counts. See [Chapter 6](06-generalized-linear-models.md).

Quick two-group comparison (equal follow-up):

```r
counts <- read_csv(
  "data/exacerbation_counts.csv",
  show_col_types = FALSE
)
wilcox.test(
  exacerbations_12m ~ factor(smoking),
  data = counts
)  # descriptive
# Inferential: Poisson GLM (Ch 6)
```

---

## Effect sizes

### Cohen's d (two groups)

$$
d = \frac{\bar{x}_1 - \bar{x}_2}{s_p}
$$

where $s_p$ is pooled SD.

```r
cohen_d <- function(x, g) {
  stats <- tapply(x, g, function(v) {
    c(mean = mean(v), sd = sd(v), n = length(v))
  })
  m1 <- stats[[1]]["mean"]; m2 <- stats[[2]]["mean"]
  s1 <- stats[[1]]["sd"];  s2 <- stats[[2]]["sd"]
  n1 <- stats[[1]]["n"];   n2 <- stats[[2]]["n"]
  sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
  (m1 - m2) / sp
}
cohen_d(spirometry$fev1, spirometry$group)
```

Rule-of-thumb (Cohen): |d| ≈ 0.2 small, 0.5 medium, 0.8 large - context matters more in clinical research.

---

**Do not:** run many tests and report only significant ones.

---

## ANCOVA: comparing groups with baseline adjustment

### Technique: ANCOVA (analysis of covariance)

| | |
|---|---|
| **Answers** | Is follow-up FEV1 different between groups after adjusting baseline FEV1 and prespecified covariates? |
| **Outcome** | Continuous follow-up (e.g. FEV1 at 12 weeks) |
| **Key covariate** | Baseline measure of same outcome |
| **R** | `lm(fev1_followup ~ group + fev1_baseline + age + sex)` |
| **Report** | Adjusted mean difference for `group`, 95% CI |
| **Caution** | Not a substitute for randomisation; regression to the mean; define estimand (change vs follow-up) |

**Plain language:** compare lung function at end of study while accounting for where patients started.

**Precise language:** test group effect in linear model with baseline and covariates; estimand should be prespecified (analysis of follow-up vs analysis of change scores - they differ unless balanced RCT).

```r
trial <- read_csv("data/spirometry_trial.csv", show_col_types = FALSE)
lm(fev1_followup ~ group + fev1_baseline + age + sex, data = trial)
```

#### Dual interpretation

**Plain language:** after accounting for starting FEV1, is follow-up lung function different by arm?

**Practice read:** often increases precision in RCT; does not replace intention-to-treat primary unless prespecified.

#### Caveats box

| Caveat | Detail |
|--------|--------|
| Estimand choice | Follow-up adjusted vs change score |
| Regression to mean | Extreme baselines regress |
| Same BD protocol | Mandatory |
| Not causal fix | In observational data |

#### Wrong analysis ⚠

Use change scores without checking correlation baseline-follow-up → ANCOVA often more efficient in RCT.

#### Reporting template

**Methods:** Follow-up FEV1 analysed with ANCOVA adjusting for baseline FEV1, age, and sex.

**Results:** Adjusted mean difference intervention vs standard = … L (95% CI …).

**Respiratory note:** common in COPD/asthma trials. See also [Chapter 5](05-linear-models.md).

---

## Permutation (randomisation) tests

### Technique card

| | |
|---|---|
| **Answers** | Is observed mean difference extreme under label exchangeability? |
| **Use** | Small n; skew; robustness check for Welch t |
| **R** | Resample group labels (see script) |
| **Does NOT** | Replace prespecification or MCID reasoning |

When distributional assumptions are doubtful or as a **robustness check**, permutation tests simulate the null by shuffling group labels.

**Idea:** if groups were exchangeable under $H_0$, relabelling should not produce larger differences than observed.

```r
set.seed(101)
obs_diff <- diff(tapply(spirometry$fev1, spirometry$group, mean))
perm_diff <- replicate(5000, {
  g <- sample(spirometry$group)
  diff(tapply(spirometry$fev1, g, mean))
})
mean(abs(perm_diff) >= abs(obs_diff))  # two-sided permutation p-value
```

**When to use:** small n, skewed outcomes, or to complement parametric tests.

#### Caveats

Computationally intensive; ties and small n need sufficient permutations.

#### Wrong analysis ⚠

Permutation p < 0.05 but CI includes MCID → still report CI and clinical context.

---

## Sample size and power (design stage)

### Technique card

| | |
|---|---|
| **Answers** | How many patients needed to detect effect size δ with power 1−β? |
| **Inputs** | MCID or Cohen's d, α, power, design |
| **R** | `pwr::pwr.t.test(...)` |
| **When** | **Before** data collection - not post hoc unless labeled exploratory |

Power analysis belongs **before** data collection.

**Inputs:** expected effect size (e.g. MCID for FEV1), α, desired power (often 80%), design (two-sample, paired).

**Cohen's d** links mean difference to standardized effect for power formulas.

```r
# install.packages("pwr")
pwr::pwr.t.test(
  d = 0.25,
  power = 0.8,
  sig.level = 0.05,
  type = "two.sample"
)
```

**Plain language:** how many patients per arm to have a fair chance of detecting a clinically meaningful difference?

**Precise language:** under specified alternative $d$, probability of rejecting $H_0$ at level $\alpha$.

**Respiratory trials:** anchor d or mean difference on published MCID, not only statistical tradition [@cazzola2008mcid; @harrell2015rms].

---

## Multiplicity

Testing FEV1, FVC, symptoms, and exacerbations without adjustment inflates false positives [@benjamini1995fdr].

**Strategies:**

- One **prespecified primary endpoint** [@schulz2010consort]
- Holm or Bonferroni for secondary endpoints
- Gatekeeping procedures in trials

**Do not:** run many tests and report only significant ones.

---

## Master decision table

**Primary test by outcome and design**

| Outcome | Design | Primary method |
|---------|--------|----------------|
| Continuous | 1 vs reference | One-sample *t* |
| Continuous | 2 independent groups | Welch *t* |
| Continuous | 2 paired measurements | Paired *t* |
| Continuous | 3+ independent groups | ANOVA + contrasts |
| Binary | 2 independent groups | Chi-square / Fisher |
| Binary | 2 paired measurements | McNemar |
| Count | 2+ independent groups | Poisson / NB GLM |

**Alternative or adjusted analysis**

| Outcome | Design | Alternative / next step |
|---------|--------|------------------------|
| Continuous | 1 vs reference | Wilcoxon signed-rank vs median |
| Continuous | 2 independent groups | Mann-Whitney |
| Continuous | 2 paired measurements | Wilcoxon signed-rank |
| Continuous | 3+ independent groups | Kruskal-Wallis |
| Binary | 2 independent groups | Logistic regression (adjusted) |
| Binary | 2 paired measurements | Logistic GEE (adjust covariates) |
| Count | 2+ independent groups | Negative binomial; Wilcoxon sensitivity |

Full map: [METHOD_MAP.md](../METHOD_MAP.md); Visual: `method_decision_tree.png`

!FEV1 by group (`ch04_fev1_by_group.png`)

Overlapping distributions warn against reading a small mean difference as clinically certain without the CI and sample size.

!`method_comparison_panel.png`

Side-by-side panels show how the same CASTOR subset looks under different comparison choices; use this to sanity-check pairing and outcome type before picking a test.

---

## Worked example: COPD trial FEV1

**Design:** Parallel RCT, n ≈ 200 per arm.  
**Estimand:** Difference in mean FEV1 (litres) at 12 weeks (intervention − standard).  
**Analysis:** Welch t-test (prespecified); linear model with baseline covariates as sensitivity.

**Results template:**

> Mean FEV1 was 3.85 L (SD 0.64) in the intervention arm and 3.76 L (SD 0.64) in standard care (n = 198 and 202). The mean difference was 0.09 L (95% CI −0.04 to 0.21; Welch t, p = 0.20). The difference is compatible with no effect and with clinically small benefits; this trial was not powered for a prespecified MCID of 0.10 L.

**Practice read:** not statistically significant; CI includes values that may or may not matter clinically.  
**Statistician read:** non-significant p does not prove no effect - interval estimation preferred [@harrell2015rms].

---


## R lab

Run the full script:

```r
source("R/examples/ch04_comparing_groups.R")
```

Includes: Welch t, Wilcoxon, ANOVA, Tukey, ANCOVA, permutation test, power calculation, chi-square, Fisher, Cohen's d, paired bronchodilator test.

---

## Common pitfalls in respiratory research

1. **Mixed spirometry standards** - pre- vs post-bronchodilator compared across groups.
2. **Ignoring clustering** - patients within hospitals analysed as independent.
3. **Multiple endpoints** - fishing without multiplicity control.
4. **Mean vs median** - skewed ICU length-of-stay analysed with t-test on small n.
5. **Baseline imbalance** - unadjusted observational comparison of FEV1 by exposure.

---

## Alternatives & extensions (choose by data and design)

Chapter 4 covers the default comparisons. Use these alternatives when the **assumptions, design, or estimand** differ.

### Continuous outcomes: beyond “t vs Wilcoxon”

| Situation | Alternative | Why / note |
|---|---|---|
| Heavy tails/outliers | **Trimmed-mean tests** (e.g. Yuen) | Robust mean-like estimand; report trimming |
| Small n; unclear distribution | **Permutation test** (already in Ch 4) | Minimal assumptions; prespecify statistic |
| Want CI without formulas | **Bootstrap CI** | See Ch 8 [@efron1993bootstrap] |
| Want distributional effect size | **Cliff’s delta** / rank-biserial | Nonparametric effect size |

### Binary outcomes: beyond chi-square/Fisher

| Situation | Alternative | Why / note |
|---|---|---|
| Stratified 2×2 tables | **Mantel-Haenszel** OR/RR | Adjust for one stratifier without full regression |
| Common outcome; want RR | **RR model** (log-binomial / modified Poisson) | See Ch 6 |
| Small samples | **Exact CIs** for OR/RR | Fisher test is exact; CI choice still matters |

### Count outcomes: compare *rates*, not raw counts

| Situation | Alternative | Why / note |
|---|---|---|
| Different follow-up time | **Poisson/NB + offset(log person-time)** | Ch 6 |
| Many zeros | **Zero-inflated / hurdle models** | Ch 6 (ZIP/ZINB) |

### Design extensions: clustered and crossover data

Standard Ch 4 tests assume **independent** observations. Respiratory studies often violate that.

### Technique: Clustered units (wards, centres, GP practices)

| | |
|---|---|
| **Answers** | Is the outcome different between arms when patients are nested in clusters? |
| **Outcome** | Continuous, binary, or count (same as unadjusted comparison) |
| **Design** | Cluster randomised trial, or patients nested in ICU wards / hospitals |
| **Assumptions** | Clusters are independent; enough clusters (not just patients) for inference |
| **Effect measure** | Same estimand as unadjusted comparison, with **cluster-appropriate SE** |
| **R (continuous)** | Mixed model: `lmer(outcome ~ arm + (1 \| cluster_id))` ([Ch 18](18-longitudinal-mixed-models.md)) |
| **R (binary/count)** | GEE with `cluster = cluster_id` or mixed GLMM |
| **Report** | Number of **clusters** and patients; ICC if reported; CI from cluster-aware model |
| **Avoid when** | Only 2–3 clusters (unstable); treating cluster members as independent (SE too small) |

**Plain language:** patients in the same ICU ward correlate; analyse at ward level or use a model that respects nesting.

**Precise language:** ignore clustering → anti-conservative SEs and inflated significance [@harrell2015rms].

**Practice read:** “n = 400 patients” may hide “8 wards”; ask how many **units** were randomised.

#### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Welch *t* on all ICU patients | Ward-level exposure shared | Mixed model or GEE with ward random effect |
| Cluster RCT analysed as individual RCT | Wrong denominator for inference | Cluster-level or mixed model with `(1 \| cluster)` |

### Technique: Crossover and paired bronchodilator designs

| | |
|---|---|
| **Answers** | Is post-BD FEV1 higher than pre-BD **within the same patient**? |
| **Outcome** | Continuous (FEV1, FVC) |
| **Design** | Paired measurements same visit (CASTOR: `bronchodilator_paired.csv`) |
| **Assumptions** | Pairs independent; difference approximately normal or large *n* |
| **Effect measure** | Mean change (post − pre) |
| **R** | `t.test(post, pre, paired = TRUE)` or mixed model if multiple crossover periods |
| **Report** | Mean change + 95% CI; *n* pairs; BD protocol (dose, wait time) |
| **Avoid when** | Carryover between periods in multi-period crossover without washout |

**Plain language:** same patient, two manoeuvres; use a **paired** test, not two independent groups.

**Practice read:** ATS/ERS BD reversibility uses within-patient change; do not split pre and post into fictional “groups.”

CASTOR paired example: `R/examples/ch04_comparing_groups.R` and Figure (`ch04_paired_bronchodilator.png`).

### Technique: Non-inferiority and equivalence trials {#technique-non-inferiority-and-equivalence-trials}

| | |
|---|---|
| **Answers** | Is the new therapy **not worse** than control by more than a prespecified margin? |
| **Outcome** | Continuous (FEV1 change), binary (exacerbation), or rate |
| **Design** | Parallel NI/ equivalence trial with **prespecified Δ** |
| **Assumptions** | Margin clinically justified; powered for NI (not superiority) |
| **Effect measure** | Mean difference vs margin; or proportion difference vs margin |
| **Methods** | Two one-sided tests (TOST); or 90% CI vs margin (common in NI) |
| **Report** | Margin Δ, NI conclusion yes/no, CI relative to Δ |
| **Avoid when** | Declaring equivalence from superiority *p* > 0.05 |

**Plain language:** “Not significantly different” ≠ “equivalent.” You must prespecify how much worse is acceptable.

**Practice read:** device and inhaler NI trials live or die on the **margin**, not the *p*-value from a superiority test.

#### Reporting template (non-inferiority, continuous FEV1)

**Methods:** The primary estimand was the mean difference in change from baseline FEV1 at 12 weeks (new therapy − control). Non-inferiority was prespecified with margin Δ = −0.10 L (one-sided α = 0.025). We used a two one-sided tests (TOST) procedure / 90% confidence interval against Δ.

**Results:** Mean difference = −0.03 L (90% CI −0.08 to 0.02). The upper bound of the CI was below Δ → **non-inferiority demonstrated** / exceeded Δ → **not demonstrated**.

**Do not say:** “Groups were equivalent because p = 0.34.”

See also [Chapter 8](08-validation-reporting.md) reporting checklist for NI trials.

### Design extensions (longitudinal and survival)

| Design feature | Why Ch 4 methods fail | Handbook chapter |
|---|---|---|
| Repeated measures | observations not independent | [Ch 18](18-longitudinal-mixed-models.md) mixed models / GEE |
| Multi-centre clustering | SEs too small if ignored | Cluster-robust SE / `(1 \| centre)` ; this chapter + Ch 18 |
| Time-to-event endpoints | censoring | [Ch 19](19-survival-analysis.md) survival analysis |

### Equivalence (superiority test insufficient)

If the scientific goal is **equivalence** (two-sided margin), prespecify bounds and use an equivalence framework. A non-significant *p*-value from a superiority test is not evidence of equivalence [@harrell2015rms] ; use the [NI template above](#technique-non-inferiority-and-equivalence-trials).

## Catalog of wrong analyses (comparison chapter)

| # | Wrong | Right |
|---|-------|-------|
| 1 | t-test on binary exacerbation Y/N | Logistic / compare proportions |
| 2 | t-test on count of exacerbations | Poisson / NB |
| 3 | Ignore pairing in pre/post BD | Paired t or Wilcoxon signed-rank |
| 4 | ANOVA then all pairwise without plan | Prespecified contrasts or Tukey with multiplicity awareness |
| 5 | Claim equivalence from p > 0.05 | NI trial with prespecified margin (TOST) |
| 6 | Pool sites without clustering check | Mixed model `(1 \| centre)` or GEE ([Ch 18](18-longitudinal-mixed-models.md)) |
| 7 | Cluster RCT analysed with patient-level Welch *t* | Cluster-aware mixed model / GEE |

---

## Chapter summary

- Define estimand and outcome type first.
- Welch t-test is the default for two independent continuous groups.
- ANCOVA adjusts follow-up comparisons for baseline lung function.
- Permutation tests and power analysis support robust and planned inference.
- Binary outcomes need RD/RR/OR with CIs, not only chi-square p-values.
- Always report effect size and CI.

## Exercises

[Chapter 4 exercises](../exercises/ch04_exercises.md); [Solutions](../solutions/ch04_solutions.md)

## Where this chapter leads

**Next:** Continuous outcomes with covariates → [Chapter 5](05-linear-models.md). Binary/count outcomes → [Chapter 6](06-generalized-linear-models.md). Repeated visits → [Chapter 18](18-longitudinal-mixed-models.md).

## Further reading

- Agresti, *An Introduction to Categorical Data Analysis* [@agresti2018introduction]  
- Harrell, *Regression Modeling Strategies* - comparison and MCID context [@harrell2015rms]  
- ATS/ERS spirometry standardisation [@graham2019spirometry]  
- Welch (1947); Mann & Whitney (1947) - original test papers [@welch1947t; @mann1947test]

**Next:** [Chapter 5 - Linear Models](05-linear-models.md)
