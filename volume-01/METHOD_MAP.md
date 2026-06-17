# Master method map — Statistical Methods for Respiratory Research

> **Handbook navigation:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md) · [HANDBOOK_GUIDE.md](HANDBOOK_GUIDE.md) · [Decision tree figure](figures/method_decision_tree.png) · [FIGURE_INDEX.md](FIGURE_INDEX.md)

Use this before opening any software. Start with the **scientific question**, not the menu of tests.

---

## Step 0: Define the estimand

Write one sentence: *What numerical quantity would change your clinical or scientific decision?*

Examples:

- Difference in mean FEV1 at 12 weeks between arms
- Adjusted odds of exacerbation comparing smokers to non-smokers
- Expected exacerbation rate per person-year on triple therapy

If you cannot write this sentence, stop and clarify the question.

---

## Step 1: Classify the outcome

| Outcome type | Examples in respiratory research | Chapter |
|--------------|----------------------------------|---------|
| Continuous | FEV1, FVC, distance walked | 3, 4, 5 |
| Binary | Any exacerbation Y/N; died Y/N | 4, 6, 9 |
| Count | Number of exacerbations | 4, 6 |
| Proportion | % with response (if n large) | 4 |
| Many continuous features | Biomarker panel | 10, 11 |
| Many features + groups (omics) | Proteomics, RNA-seq | 13, 14, 17 |
| Cell-type proportions | Flow cytometry | 15 |
| Screen + confirmation | Antibody discovery | 16 |
| Longitudinal | Repeated FEV1 | [Ch 18](chapters/18-longitudinal-mixed-models.md) |
| Time-to-event | Time to first exacerbation | [Ch 19](chapters/19-survival-analysis.md) |

---

## Step 2: Classify the design

| Design | Implication |
|--------|-------------|
| Randomised parallel groups | Mean differences / intention-to-treat estimands favoured |
| Paired / crossover | Paired tests or mixed models |
| Observational cohort | Confounding; causal language requires care |
| Case–control | Odds ratios natural; incidence not estimable |
| Clustered (centres, wards) | Standard errors wrong without adjustment |
| High-dimensional exploratory | No confirmatory p-values without replication |

---

## Step 3: What is the goal?

| Goal | Priority | Methods |
|------|----------|---------|
| **Describe** sample | Transparency | Ch 3 |
| **Compare** groups | Effect size + CI | Ch 4 |
| **Adjust** for confounders | Interpretable coefficients | Ch 5, 6 |
| **Predict** new patients | Calibration + discrimination | Ch 9, 17 (elastic net) |
| **Discover** structure | Stability + validation | Ch 10, 11 |
| **Discover** omics hits | FDR + batch audit | Ch 13–14, 17 |
| **Prioritise** binders | PPV + replicate stability | Ch 16 |

---

## Decision tree (simplified)

See also the visual figure: [figures/method_decision_tree.png](figures/method_decision_tree.png) and [method_comparison_panel.png](figures/method_comparison_panel.png).

```
OUTCOME?
│
├─ CONTINUOUS
│   ├─ One group vs fixed value?        → One-sample t-test (Ch 4)
│   ├─ Two independent groups?          → Welch t-test (Ch 4)
│   ├─ Two paired measurements?         → Paired t-test (Ch 4)
│   ├─ Three+ independent groups?       → ANOVA → post-hoc (Ch 4)
│   ├─ Non-normal, small n?             → Wilcoxon / Kruskal-Wallis (Ch 4)
│   ├─ Adjust for covariates?           → Linear regression / ANCOVA (Ch 5)
│   └─ Many predictors, prediction?     → LASSO / RF (Ch 7, 9)
│
├─ BINARY
│   ├─ Two independent groups?          → Chi-square / Fisher; RD, RR, OR (Ch 4)
│   ├─ Paired binary?                   → McNemar (Ch 4)
│   ├─ Adjust for covariates?           → Logistic regression (Ch 6)
│   └─ Predict risk?                    → Logistic + validation (Ch 6, 9)
│
├─ COUNT
│   ├─ Compare rates between groups?    → Poisson / neg binomial (Ch 6)
│   ├─ Varying follow-up?               → Offset log(person-time) (Ch 6)
│   └─ Excess zeros?                    → Zero-inflated (Vol II mention)
│
└─ MANY FEATURES
    ├─ Exploratory structure (markers)?     → PCA (Ch 10)
    ├─ Find subgroups?                      → Clustering (Ch 11)
    ├─ Many features + two groups?          → Per-feature DE + BH FDR (Ch 13)
    ├─ Batch/plate/run in omics?            → PCA overlap + sensitivity (Ch 14)
    ├─ Flow cell-type proportions?          → Participant-level models (Ch 15)
    ├─ Antibody screen hits?                → PPV + tiers + confirmation (Ch 16)
    └─ End-to-end CASTOR-HD pipeline?       → Ch 17 integrated case

LONGITUDINAL / SURVIVAL / CAUSAL (Ch 18–21)
    ├─ Repeated measures per patient?       → Mixed models (Ch 18)
    ├─ Time to event with censoring?        → Kaplan–Meier, Cox (Ch 19)
    ├─ Missing outcome/predictors?          → MI sensitivity (Ch 20)
    └─ Observational causal estimand?       → DAGs, IPW (Ch 21)
```

---

## Technique inventory (handbook)

### Descriptive (Ch 3)
- Mean, median, SD, IQR, range
- Frequency tables, proportions
- Histogram, density, boxplot, violin plot
- Scatterplot, correlation
- Table 1 (baseline characteristics)
- QQ plot for normality

### Comparing groups (Ch 4)
- One-sample t-test
- Welch two-sample t-test
- Pooled-variance t-test (rarely needed)
- Paired t-test
- One-way ANOVA
- Tukey HSD / pairwise t-tests with multiplicity control
- Kruskal-Wallis
- Mann–Whitney U / Wilcoxon rank-sum
- Sign test
- Chi-square test of independence
- Fisher's exact test
- McNemar test
- Risk difference, risk ratio, odds ratio
- Cohen's d (effect size)
- ANCOVA (adjusting baseline)

### Linear models (Ch 5)
- Simple linear regression
- Multiple linear regression
- Dummy coding for categorical predictors
- Interaction terms
- Polynomial and spline terms (intro)
- Log transformation
- VIF (multicollinearity)
- Residual diagnostics
- Influential points (Cook's distance)
- Standardized coefficients

### GLMs (Ch 6)
- Logistic regression
- Probit regression
- Poisson regression
- Quasi-Poisson
- Negative binomial regression
- Offset for person-time
- Deviance and AIC comparison
- Marginal / adjusted predictions (emmeans)
- Separation and sparse data issues

### Model building (Ch 7)
- Subject-matter confounder selection
- Nested likelihood ratio tests
- AIC / BIC
- Cross-validation (intro)
- Ridge / LASSO / elastic net (glmnet)
- Splines (splines::ns)
- Missing data overview

### Validation & reporting (Ch 8)
- Confidence intervals vs p-values
- Bootstrap
- Internal validation
- Multiplicity adjustment
- CONSORT / STROBE / TRIPOD checklists

### High-dimensional biology (Ch 13–17)
- Differential analysis (many features) + BH FDR
- Negative binomial RNA-seq (teaching per-gene workflow)
- Volcano plots (descriptive, not proof)
- Batch/plate/run effects: diagnosis + sensitivity analysis
- Flow cytometry: participant summaries vs per-cell visualization
- Antibody discovery screens: hit calling + confirmation + ranking stability
- Integrated CASTOR-HD pipeline (Ch 17)
- Elastic net + nested CV for \(p \gg n\) prediction
- Sensitivity analyses
- Reproducible reporting ([HIGH_DIM_REPORTING_TEMPLATES](HIGH_DIM_REPORTING_TEMPLATES.md))

### Longitudinal, survival, missing data, causal (Ch 18–21)
- Linear mixed models (random intercepts; teaching `lmer`)
- Spaghetti plots and trajectory visualization
- Kaplan–Meier curves; log-rank tests
- Cox proportional hazards models
- Missing data patterns (MCAR/MAR/MNAR); complete-case vs imputation sensitivity
- MICE overview (production workflows)
- Confounding; target trial; introductory IPW

### Prediction (Ch 9)
- Train/test split
- k-fold cross-validation
- AUC / ROC
- Sensitivity, specificity, PPV, NPV
- Brier score
- Calibration plots
- Logistic vs tree vs RF vs LASSO
- Data leakage examples

### Unsupervised (Ch 10–11)
- PCA (correlation/covariance)
- Scree plot, proportion variance
- Rotation (varimax)
- Biplots
- k-means clustering
- Hierarchical clustering
- PAM (k-medoids)
- Silhouette width
- Gap statistic (intro)

---

## Reporting minimums

| Analysis | Minimum report | Guideline |
|----------|----------------|-----------|
| t-test | Mean difference, 95% CI, n, test used | — |
| ANOVA | Omnibus test + prespecified contrasts | — |
| Logistic | OR or adjusted risk with 95% CI, n, events | STROBE [@vonelm2007strobe] |
| Poisson/NB | Rate ratio with 95% CI, offset stated | — |
| Regression | Coefficients, CI, n, R² optional | — |
| Prediction | AUC + calibration; training vs test stated | TRIPOD [@moons2015tripod] |
| PCA/cluster | n, scaling, k/components chosen, stability note | — |
| RCT | Primary estimand, CONSORT flow | CONSORT [@schulz2010consort] |

Full bibliography: [REFERENCES.md](REFERENCES.md) · `references.bib`

---

## Optional deeper topics (future expansion)

- Competing risks
- GEE vs mixed models in depth
- Instrumental variables
- Full Bayesian workflows
