# Chapter 8 solutions

## E8.1
**CI:** range of compatible parameter values. **p-value:** compatibility with null hypothesis; does not measure effect size or clinical importance.

## E8.2
TRIPOD examples: study design, outcome definition, predictor definitions, sample size/events, statistical methods, model validation, performance measures (AUC, calibration).

## E8.3
Resample data with replacement to approximate sampling distribution when formula CI unavailable or doubtful.

## Applied

```r
source("R/00_setup.R")
library(tidyverse)
s <- read_csv("data/spirometry.csv", show_col_types = FALSE)
t.test(fev1 ~ group, data = s)$conf.int
set.seed(1)
B <- 2000
boot <- replicate(B, {
 d <- s[sample(nrow(s), replace = TRUE), ]
 diff(tapply(d$fev1, d$group, mean))
})
quantile(boot, c(0.025, 0.975))
sessionInfo()
```

Compare bootstrap CI to Welch CI; should be similar for mean difference.
