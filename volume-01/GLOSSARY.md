# Glossary — handbook (Ch 0–21)

| Term | Plain language | Precise definition |
|------|----------------|-------------------|
| **Estimand** | The target number your analysis should estimate | A precise numerical summary defined for a specific population under a stated treatment/intervention condition |
| **Parameter** | Unknown truth in the population | Fixed quantity in a statistical model (e.g. β in regression) |
| **Statistic** | Number computed from your sample | Function of observed data (e.g. sample mean) |
| **p-value** | How surprising the data would be if there were truly no effect | Probability, under the null model, of data at least as extreme as observed |
| **Confidence interval** | Range of plausible values for the effect | Interval procedure with stated long-run coverage probability (e.g. 95%) |
| **Type I error** | False alarm — declaring an effect when none exists | Rejecting a true null hypothesis |
| **Type II error** | Miss — failing to detect a real effect | Not rejecting a false null hypothesis |
| **Power** | Chance of detecting an effect if it exists | 1 − P(Type II error) under a specified alternative |
| **Confounding** | Another factor distorts the exposure–outcome link | Common cause of exposure and outcome, or selection path inducing spurious association |
| **Overfitting** | Model memorises this dataset | Low bias on training data but poor generalisation to new data |
| **Calibration** | Predicted risks match observed rates | Agreement between predicted probabilities and empirical outcome frequencies |
| **Discrimination** | Model ranks high-risk above low-risk | Ability to separate cases from non-cases (e.g. AUC) |
| **Offset** | Fixed adjustment for exposure time | Known component of linear predictor with coefficient fixed at 1 (e.g. log person-years) |
| **Overdispersion** | Count data more variable than Poisson expects | Variance > mean in count outcomes |
| **Link function** | Connects mean outcome to predictors | Monotonic function g with g(μ) = Xβ in GLMs |
| **Odds ratio** | Multiplicative change in odds | exp(β) in logistic regression; not equal to risk ratio unless outcome rare |
| **Rate ratio** | Multiplicative change in expected count | exp(β) in log-link count models |
| **MCID** | Smallest change patients/clinicians care about | Minimum clinically important difference |
| **Multiplicity** | Many tests inflate false positives | Multiple comparisons problem; requires prespecification or adjustment |
| **Bootstrap** | Resample your data to estimate uncertainty | Nonparametric simulation of sampling distribution by resampling with replacement |
| **PCA** | Find weighted combinations capturing variance | Orthogonal linear combinations from eigen decomposition of covariance/correlation matrix |
| **Clustering** | Group similar patients | Partition or hierarchy based on dissimilarity without using outcome (unsupervised) |
| **Random intercept** | Each patient has their own baseline level | Random effect allowing cluster-specific intercept in mixed models |
| **Mixed model** | Fixed effects + random effects for clustered/repeated data | Hierarchical model (e.g. `lmer`) with both population-level and cluster-specific components |
| **Censoring** | Follow-up ends before event | Observation contributes time up to censoring; event indicator = 0 |
| **Hazard ratio** | Instantaneous event rate ratio | Multiplicative change in hazard at time *t* (Cox model); not a risk difference |

See chapters for context and respiratory examples.
