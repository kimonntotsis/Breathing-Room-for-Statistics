# Chapter 5 — Solutions

## E5.1
Each additional year of age is associated with 0.03 L lower mean FEV1, holding other predictors fixed.

## E5.2
**Female** (alphabetically first level unless releveled).

## E5.3
When smoking effect on FEV1 may differ by age (effect modification); prespecify interaction.

## Applied

```r
source("R/00_setup.R")
library(tidyverse); library(broom)
s <- read_csv("data/spirometry.csv", show_col_types = FALSE)
fit <- lm(fev1 ~ smoking + age + sex + height_cm, data = s)
tidy(fit, conf.int = TRUE)
par(mfrow=c(2,2)); plot(fit); par(mfrow=c(1,1))
```

## Extension

```r
fit2 <- lm(fev1 ~ smoking * age + sex + height_cm, data = s)
summary(fit2)
# Interpret smoking effect at specific ages via emmeans or manual slopes
```
