# Chapter 4 solutions

## E4.1
Comparing post-BD FEV1 in one arm with pre-BD in another mixes **measurement conditions**. Bronchodilator response is part of the comparison; estimand is unclear. Both arms need the same spirometry protocol (pre or post).

## E4.2
- Plain: proportion with severe exacerbation on triple vs ICS alone.
- Formal: risk difference RD = p_triple − p_ICS (or RR = p_triple/p_ICS) in the target population at 12 months.

## E4.3
When outcome prevalence is high (e.g. >10–20%). OR exaggerates RR.

## E4.4
Expected false positives ≈ 5% × 5 = 25% under independence. Without adjustment, at least one spurious “significant” result is likely.

## E4.5
Report both with effect estimates (mean or median difference). Discuss sensitivity to assumptions. Do not cherry-pick the significant test.

## E4.6–E4.8

```r
source("R/00_setup.R")
library(tidyverse)
s <- read_csv("data/spirometry.csv", show_col_types = FALSE)
t.test(fev1 ~ group, data = s, var.equal = FALSE)
wilcox.test(fev1 ~ group, data = s)
source("R/examples/ch04_comparing_groups.R")  # Cohen's d printed
```

## E4.9

```r
fit <- aov(fev1 ~ diagnosis, data = s)
summary(fit); TukeyHSD(fit)
```

## E4.10

```r
exac <- read_csv("data/exacerbation.csv", show_col_types = FALSE)
fisher.test(table(exac$smoking, exac$exacerbation_12m))
```

## E4.11

```r
source("R/generate_data.R")
bd <- read_csv("data/bronchodilator_paired.csv", show_col_types = FALSE)
t.test(bd$fev1_pre, bd$fev1_post, paired = TRUE)
```

## E4.12 (template)
Mean FEV1 did not differ significantly between intervention and standard care (difference ~0.09 L, 95% CI includes 0; n ≈ 200/arm). Interpret against MCID and trial power.

## E4.13

```r
set.seed(99)
pvals <- replicate(100, {
  x <- rnorm(50, 0, 1); y <- rnorm(50, 0, 1)
  t.test(x, y)$p.value
})
mean(pvals < 0.05)  # ~0.05 under true null
```

## E4.14
Look up COPD FEV1 MCID (~100 mL often cited). Compare CI bounds from E4.6 to 0.10 L.

## ANCOVA extension

```r
trial <- read_csv("data/spirometry_trial.csv", show_col_types = FALSE)
summary(
  lm(
    fev1_followup ~ group + fev1_baseline + age + sex,
    data = trial
  )
)
```

## Permutation extension

See `R/examples/ch04_comparing_groups.R`; permutation p printed.

## Power extension

```r
# install.packages("pwr")
pwr::pwr.t.test(
  d = 0.25,
  power = 0.8,
  sig.level = 0.05,
  type = "two.sample"
)
```
