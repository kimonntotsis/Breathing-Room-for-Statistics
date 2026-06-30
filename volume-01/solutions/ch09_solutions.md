# Chapter 9 solutions

## E9.1

**Discrimination:** rank cases vs non-cases (AUC). **Calibration:** predicted probabilities match observed rates.

## E9.2

Model may order patients well but systematically over/under-predict absolute risk.

## E9.3

Using laboratory values collected after the exacerbation to predict it.

## E9.4

**EPV** = events per variable in the training set. CASTOR has ~14 train events and 4 predictors (EPV ≈ 3.5), below the usual 10–15 guideline. LASSO may shrink all coefficients to zero → constant risk → AUC = 0.5.

## E9.5

Examples: causation; external validation / deployment readiness; causal importance from RF; clinical net benefit without DCA.

## E9.6

When *p* ≫ *n* and many hyperparameters are tuned (elastic net on proteomics); nested CV prevents tuning leakage; see Ch 17.

## Applied

```r
source("R/examples/ch09_prediction.R")
readr::read_csv("volume-01/tables/ch09_model_comparison.csv")
```

**Q2:** LASSO/tree collapse because EPV is too low; they predict near-constant risk.

**Q3–Q4:** See CSV and calibration PNG; high-risk bins have very few events; wide uncertainty.

## Extension

**Q5:** XGBoost may rank similarly to RF (~0.73 vs 0.93 logistic in one seed); with 4 test events, differences are not decisive; prefer prespecified logistic + report CIs.

**Q6:** Use the Results template in the chapter filled with CSV values; limitation = no external validation, low test events, EPV below guideline.
