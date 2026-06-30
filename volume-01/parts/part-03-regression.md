# Part III: Regression (continuous, binary, count) {.unnumbered}

This part unifies model choice under one idea:

- **Gaussian / linear models** for continuous outcomes (Ch 5)
- **Generalized linear models** for binary and count outcomes (Ch 6)
- **Model building discipline** (Ch 7) so we do not fool ourselves

The goal is not “run a model,” but:

1. pick the right outcome family
2. state the estimand
3. fit the model defensibly
4. report the estimate, uncertainty, and limitations

**Read this if:** your outcome is continuous, binary, or count and you need adjusted associations (smoking, FEV1 % predicted, therapy line).

**Skip this if:** you only need an unadjusted arm comparison (→ [Part II](parts/part-02-describe-compare.md) Ch 4) or a prediction model with validation metrics (→ [Part IV](parts/part-04-validation-prediction.md) Ch 9).

## CASTOR vignette: the exacerbation endpoint

The protocol labels exacerbations as a **count**, but the first draft manuscript reports a logistic “any exacerbation” model because the PI prefers odds ratios. **Part III** is where the team picks the GLM family that matches the estimand (Ch 6) and resists stepwise fishing (Ch 7).
