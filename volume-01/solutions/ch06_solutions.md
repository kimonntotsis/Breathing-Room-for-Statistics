# Chapter 6 solutions

## E6.1
Linear model predicts values outside [0,1]; error variance not constant; wrong likelihood.

## E6.2
Adjusted OR 2.5: smokers have 2.5× the odds of exacerbation vs non-smokers, holding covariates fixed. Not 2.5× risk unless events rare.

## E6.3
When follow-up time varies; include `offset(log(person_years))` in Poisson/NB model.

## E6.4
Variance > mean; Poisson SEs too small → anti-conservative inference.

## E6.5
Perfect separation → MLE coefficients ±∞; use Firth (`logistf`) or collapse categories.

## E6.6–E6.11

```r
source("R/examples/ch06_glm.R")
exac <- read_csv("data/exacerbation.csv", show_col_types = FALSE)
events <- sum(exac$exacerbation_12m)
predictors <- 4
events / predictors # EPV; aim >= 10
```

## E6.12

```r
source("R/examples/ch06_glm.R") # probit + logistic in script
```

## E6.13
Simulate overdispersed counts; compare Poisson vs NB CI coverage for rate ratio.

## Firth logistic

```r
# install.packages("logistf")
logistf::logistf(
 exacerbation_12m ~ smoking + age +
 fev1_percent_predicted + prior_exacerbations,
 data = exac
)
```

## Log-binomial (RR)

```r
glm(
 exacerbation_12m ~ smoking + age,
 data = exac,
 family = binomial(link = "log")
)
# exp(coef) = risk ratios if model converges
```

## Zero-inflated

```r
zi <- read_csv(
 "data/exacerbation_zero_inflated.csv",
 show_col_types = FALSE
)
pscl::zeroinfl(exacerbations_12m ~ smoking | smoking, data = zi)
```

## Offset example

```r
counts <- read_csv(
 "data/exacerbation_counts.csv",
 show_col_types = FALSE
)
glm(
 exacerbations_12m ~ smoking + offset(log(person_years)),
 data = counts,
 family = poisson
)
```
