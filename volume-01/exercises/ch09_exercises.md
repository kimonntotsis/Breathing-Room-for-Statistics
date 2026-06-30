# Chapter 9 Exercises: Prediction

**E9.1** Define discrimination vs calibration.

**E9.2** Why can AUC be high but calibration poor?

**E9.3** Give one leakage example in exacerbation prediction.

**E9.4** What is EPV? Why does CASTOR (~14 train events, 4 predictors) make LASSO risky?

**E9.5** List three things a prediction model does **not** prove (see chapter checklist).

**E9.6** When would you prefer nested CV ([Ch 17](../chapters/17-integrated-castor-hd.md)) over a single 70/30 split?

**Applied**

1. Run `source("R/examples/ch09_prediction.R")` and read `volume-01/tables/ch09_model_comparison.csv`.
2. Why do LASSO and the tree show AUC = 0.50 in the teaching run?
3. Report logistic AUC with bootstrap CI and Brier on the test set.
4. Inspect the calibration figure; what happens in the highest-risk bin with only four test events?

**Extension**

5. If `xgboost` is installed, compare its test AUC to logistic on the **same** split. Does it beat logistic? Should you switch models?
6. Draft a TRIPOD Results paragraph using numbers from the CSV and state one explicit limitation.

[Solutions](../solutions/ch09_solutions.md)
