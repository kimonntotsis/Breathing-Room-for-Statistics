# Chapter 6 — Exercises: Generalized Linear Models

## Conceptual

**E6.1** Why is `lm(exacerbation_12m ~ smoking)` inappropriate when `exacerbation_12m` is 0/1?

**E6.2** Interpret OR = 2.5 for smoking in a logistic model adjusting for age and FEV1.

**E6.3** When would you add an offset to a Poisson model in an exacerbation study?

**E6.4** What does overdispersion mean, and why does Poisson regression underestimate SEs when it is present?

**E6.5** What is complete separation, and what happens to MLE coefficients?

---

## Applied

**E6.6** Fit logistic regression: `exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations` on `data/exacerbation.csv`. Report ORs and 95% CIs.

**E6.7** How many events (exacerbations) occurred? Report events-per-variable (EPV). Is EPV above 10?

**E6.8** Fit Poisson and negative binomial models for `exacerbations_12m ~ smoking + ics_adherence` on `data/exacerbation_counts.csv`. Compare rate ratios.

**E6.9** Estimate Pearson dispersion for the Poisson model in E6.8. Is overdispersion suggested?

**E6.10** Compare nested logistic models with and without `prior_exacerbations` using likelihood ratio test.

**E6.11** (Optional) If `emmeans` is installed, compute marginal predicted probability of exacerbation by smoking status from the model in E6.6.

---

## Extension

**E6.12** Fit probit and logistic models with the same formula. Compare coefficient signs and rankings — are conclusions consistent?

**E6.13** Simulate count data with variance twice the mean. Show Poisson vs NB coverage of 95% CIs for a rate ratio.

---

[Solutions](../solutions/ch06_solutions.md)
