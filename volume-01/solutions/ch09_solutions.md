# Chapter 9 — Solutions

## E9.1
**Discrimination:** rank cases vs non-cases (AUC). **Calibration:** predicted probabilities match observed rates.

## E9.2
Model may order patients well but systematically over/under-predict absolute risk.

## E9.3
Using laboratory values collected after the exacerbation to predict it.

## Applied & Extension

```r
source("R/examples/ch09_prediction.R")
# Prints AUC/Brier table for logistic, lasso, tree, RF
# Calibration plot saved to volume-01/figures/ch09_calibration_logistic.png
```

Compare AUC column across models on same test set — differences often modest with small event counts.
