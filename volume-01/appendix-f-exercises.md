---
number-sections: false
---

# Appendix F: Exercises {.unnumbered}

Practice problems for Chapters 1–21. **Solutions** (repository only): `volume-01/solutions/`; [INSTRUCTOR_PACK.md](INSTRUCTOR_PACK.md).

---

## Chapter 01

**E1.1** Define estimand for: *"Does pulmonary rehab improve 6-minute walk distance at 8 weeks?"*

**E1.2** Classify: inference or prediction? (a) Adjusted OR for smoking and exacerbation. (b) Risk score for hospital admission.

**E1.3** Give one example each of confounding, selection bias, and missing data in COPD cohorts.

**E1.4** A p-value of 0.06 is reported. What can and cannot you conclude?

**E1.5** Map each to study design: (a) FEV1 vs smoking in one visit. (b) RCT of biologic in asthma. (c) ICU patients nested in hospitals.

**E1.6** Name three handbook navigation files and when you would use each.

**Applied:** Write PICO for a study comparing two inhaler devices on exacerbation rate. Write the estimand in one sentence.

---

## Chapter 02

**E2.1** Classify outcome type: FEV1, exacerbation Y/N, exacerbations/year, time to first exacerbation.

**E2.2** Why is repeated FEV1 not independent cross-sectional data?

**E2.3** List three quality checks before analysing spirometry data.

**E2.4** Same variable `therapy` as exposure vs confounder; give scenarios.

**E2.5** Route `time_to_exacerbation.csv` to the correct handbook chapter.

**Applied**

1. Load `spirometry.csv` and `exacerbation.csv`; document outcome type and unit of analysis.
2. Complete the seven-item checklist for a smoking–FEV1 question.
3. Route each file in the CASTOR outcome map to a chapter.

---

## Chapter 03

**E3.1** When report median instead of mean for FEV1?

**E3.2** What should a Table 1 include for a two-arm RCT?

**E3.3** Why show individual points on small-n plots?

**Applied:** Create Table 1 by `group` for age, sex, smoking, FEV1. Histogram and boxplot of FEV1.

**Extension:** QQ plot of FEV1; comment on normality.

---

## Chapter 04

## Conceptual

**E4.1** A researcher compares post-bronchodilator FEV1 in arm A with pre-bronchodilator FEV1 in arm B using a Welch t-test. What is wrong?

**E4.2** State the estimand in plain language and formally for: *"Does triple therapy reduce the proportion with ≥1 severe exacerbation versus ICS alone?"*

**E4.3** When is an odds ratio a poor approximation to a risk ratio?

**E4.4** Explain why testing five secondary lung-function endpoints at α = 0.05 each is problematic.

**E4.5** A paired t-test and Wilcoxon signed-rank test disagree (one p < 0.05, one p > 0.05). What should you report?

---

## Applied (use book data)

**E4.6** Using `data/spirometry.csv`, compare mean FEV1 between `group` levels with Welch t-test. Report mean difference and 95% CI.

**E4.7** Repeat E4.6 with Mann–Whitney. Do conclusions align?

**E4.8** Compute Cohen's d for the comparison in E4.6.

**E4.9** Using `diagnosis` (3 levels), run one-way ANOVA on FEV1. If significant, apply Tukey HSD.

**E4.10** Using `data/exacerbation.csv`, build a 2×2 table of `smoking` vs `exacerbation_12m`. Run Fisher's exact test.

**E4.11** Using `data/bronchodilator_paired.csv`, test whether mean FEV1 change after bronchodilator is greater than zero (paired t-test).

**E4.12** Write a four-sentence results paragraph for E4.6 suitable for a clinical journal (estimate, CI, n, clinical context).

---

## Extension

**E4.13** Simulate 100 datasets where there is truly no FEV1 difference between groups (n = 50 per arm). How often does Welch t give p < 0.05? Relate to Type I error.

**E4.14** Look up an MCID for FEV1 in COPD or asthma. Is the CI from E4.6 compatible with a clinically important effect?

---

---

## Chapter 05

**E5.1** Interpret β = −0.03 for age (years) in FEV1 model.

**E5.2** What is reference category for `sex` in default R coding?

**E5.3** When include interaction smoking × age?

**Applied:** Fit `lm(fev1 ~ smoking + age + sex + height_cm)`. Report coefficients with CI. Residual plots.

**Extension:** Fit model with `smoking * age`. Interpret interaction.

---

## Chapter 06

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

**E6.12** Fit probit and logistic models with the same formula. Compare coefficient signs and rankings: are conclusions consistent?

**E6.13** Simulate count data with variance twice the mean. Show Poisson vs NB coverage of 95% CIs for a rate ratio.

---

---

## Chapter 07

**E7.1** Why not use stepwise selection for primary trial endpoint?

**E7.2** When is LASSO appropriate vs prespecified logistic?

**E7.3** Explain train/test split purpose.

**Applied:** Nested LRT: compare logistic models with/without `fev1_percent_predicted`. Fit `cv.glmnet` on exacerbation data.

---

## Chapter 08

**E8.1** CI vs p-value: what does each communicate?

**E8.2** Name three TRIPOD items for prediction models.

**E8.3** What is bootstrap used for?

**Applied:** Bootstrap 95% CI for mean FEV1 difference between groups (2000 replicates).

---

## Chapter 09

**E9.1** Define discrimination vs calibration.

**E9.2** Why can AUC be high but calibration poor?

**E9.3** Give one leakage example in exacerbation prediction.

**Applied:** Train logistic on 70% of exacerbation data; AUC on 30%. Calibration decile table.

**Extension:** Compare RF vs logistic AUC on same split.

---

## Chapter 10

**E10.1** Why scale variables before PCA on marker panel?

**E10.2** PC1 vs original marker: what does loadings tell you?

**Applied:** PCA on `marker_panel.csv`; scree plot; PC1 vs PC2 coloured by `true_phenotype`.

---

## Chapter 11

**E11.1** Why is clustering unsupervised? Give one CASTOR example of supervised learning for contrast.

**E11.2** k-means vs hierarchical vs PAM: one trade-off each.

**E11.3** Explain the **endotype claim ladder** in plain language. At which rung may you use the word “endotype” in a title?

**E11.4** Why can high agreement between clusters and `processing_batch` be a **red flag**?

**Applied**

1. Run `source("R/examples/ch11_clustering.R")`.
2. Report mean silhouette for *k* = 2 and mean bootstrap item stability.
3. Copy the method shootout table. Which comparisons worry you most, and why?
4. Write a Results paragraph using the template in §11.13 (replace XX with your output).

---

## Chapter 12

**E12.1** For Case A (trial FEV1): write estimand, test, and reporting sentence.

**E12.2** For Case B (observational logistic): one limitation for causal interpretation.

**E12.3** For Case C (clustering): why not call clusters "validated endotypes"?

**E12.4** For Case E: why are mixed models and Cox PH answering different clinical questions?

**Applied:** Run `ch12_case_a_trial.R`, `ch12_case_b_exacerbation.R`, `ch12_case_c_phenotypes.R`, and `ch12_case_e_longitudinal_survival.R`; write one paragraph per case.

---

## Chapter 13

**E13.1** Why is testing 1000 proteins at α = 0.05 a problem even if only 50 are "significant"?

**E13.2** What three columns must appear in a defensible DE/DA top table?

**E13.3** When would you distrust a volcano plot as "proof" of biology?

**E13.4** Why should RNA-seq use count models rather than a t-test on raw counts?

**E13.5** What does it mean when nominal *p* < 0.05 but all *q* > 0.05?

**Applied**

1. Run `source("R/examples/ch13_differential_fdr.R")`.
2. Open `volume-01/tables/ch13_proteomics_top_table.csv` and interpret the top 5 rows.
3. Compare proteomics vs RNA discovery counts at q < 0.05.
4. Write a Results paragraph using Template A.
5. Draft one honest sentence if proteomics yields zero BH discoveries.

---

## Chapter 14

**E14.1** When is including batch as a covariate defensible?

**E14.2** What does perfect confounding of batch and group imply?

**E14.3** Why is ComBat before train/test split a leakage problem?

**E14.4** What should you report if discoveries go from 50 to 0 when batch is added?

**Applied**

1. Run `source("R/examples/ch14_batch_effects.R")`.
2. Interpret `ch14_group_batch_overlap.png`.
3. Read `volume-01/tables/ch14_batch_mini_case_summary.csv`.
4. Draft a Methods sentence on batch handling.

---

## Chapter 15

**E15.1** Why is pooling cells as independent n wrong?

**E15.2** One compositional pitfall when interpreting proportions.

**E15.3** When is UMAP acceptable in a paper?

**E15.4** Why prespecify 1–3 cell types for primary inference?

**Applied**

1. Run `source("R/examples/ch15_flow_cytometry.R")`.
2. Compare pseudo-replication figure vs participant model.
3. Interpret monocyte and NK rows in `ch15_flow_effects_by_celltype.csv`.
4. Write one Methods sentence stating the unit of analysis.

---

## Chapter 16

**E16.1** Define PPV among screen hits.

**E16.2** What is Tier 1 stability?

**E16.3** Why avoid post hoc thresholds?

**E16.4** Why report PPV per antigen?

**Applied**

1. Run `source("R/examples/ch16_antibody_screening.R")`.
2. Report PPV by antigen from `ch16_screen_ppv_by_antigen.csv`.
3. Interpret threshold sensitivity plot at threshold 1.4.
4. List Tier 1 AgA clones from `ch16_ranking_tiers_aga.csv`.

---

## Chapter 17

**E17.1** At which pipeline step would you stop if batch and group are confounded?

**E17.2** Why is nested CV required for elastic net on 1000 proteins?

**E17.3** What is the difference between a Tier 1 antibody clone and a proteomics q < 0.05 hit?

**E17.4** Why must flow analyses use participant-level proportions?

**E17.5** Name one claim that would be **too strong** after this pipeline alone.

**Applied**

1. Run `source("R/examples/ch17_integrated_castor_hd.R")`.
2. Run `source("R/examples/ch17_elastic_net_proteomics.R")`.
3. Draft a 300-word integrated Results section using the templates.
4. List three claims you would **not** make from this pipeline alone.

---

## Chapter 18

**E18.1** Why is independence violated with repeated FEV1?

**E18.2** What does `(1|patient_id)` represent?

**E18.3** When is a week-52 *t*-test misleading compared with a mixed model?

**E18.4** If `weeks:groupintervention` is positive, how do you describe the intervention effect on **slope**?

**E18.5** Mixed model vs GEE: which estimand is population-averaged?

**Applied**

1. Run `R/examples/ch18_longitudinal_mixed_models.R`.
2. Interpret `weeks:groupintervention` from `ch18_mixed_model_coefficients.csv`.
3. Compare `ch18_sensitivity_mixed_vs_fixed.csv`; comment on SEs.
4. From the spaghetti plot, would you prespecify a random slope? Why or why not?

---

## Chapter 19

**E19.1** What does censoring mean at 365 days without an event?

**E19.2** When is a hazard ratio misleading on its own?

**E19.3** What does a log-rank test compare?

**E19.4** Why report events per group in addition to HR?

**E19.5** When would you prefer Cox over 12-month logistic regression?

**Applied**

1. Run `R/examples/ch19_survival_analysis.R`.
2. Report smoking HR from `ch19_cox_hazard_ratios.csv`.
3. Read `ch19_cox_ph_test.csv` for proportional hazards.
4. Estimate absolute event risk at 365 days from KM output.

---

## Chapter 20

**E20.1** Define MAR in one sentence.

**E20.2** Why is complete-case analysis risky when missingness relates to obstruction severity?

**E20.3** Why is median imputation inadequate as a final analysis?

**E20.4** What should appear in a CONSORT/STROBE flow diagram regarding missing data?

**E20.5** Why must imputation be inside CV folds for prediction (Ch 9)?

**E20.6** Give one example of structural missingness in respiratory research. Should it be imputed?

**Applied**

1. Run `R/examples/ch20_missing_data.R`.
2. Report enrolled vs analysed *n* from `ch20_enrollment_flow.csv`.
3. Compare smoking coefficients in `ch20_smoking_coef_sensitivity.csv`.
4. Argue MAR vs MNAR for CASTOR missing FEV1 in one paragraph.

---

## Chapter 21

**E21.1** Name one confounder on the smoking → exacerbation path in CASTOR.

**E21.2** What does the "no unmeasured confounding" assumption mean?

**E21.3** Why check weight distributions after IPW?

**E21.4** Is FEV1 a confounder, mediator, or both? Why does it matter?

**E21.5** What is one component of a target trial emulation?

**Applied**

1. Run `R/examples/ch21_causal_inference.R`.
2. Compare naive vs IPW OR in `ch21_smoking_or_naive_vs_ipw.csv`.
3. Read `ch21_ipw_weight_summary.csv` for extreme weights.
4. Rewrite a causal sentence as associational (STROBE-safe).

---

## Chapter 22

**E22.1** What is the difference between total and direct effect of smoking on exacerbation?

**E22.2** Why must age and prior exacerbations appear in **both** mediator and outcome models here?

**E22.3** What does ACME quantify in this chapter's path diagram?

**E22.4** Why is proportion mediated unstable when the total effect is near zero?

**E22.5** Give one reason CASTOR cross-sectional data limit causal mediation claims.

**Applied**

1. Run `R/examples/ch22_mediation.R`.
2. Compare total vs direct ORs in `ch22_total_vs_direct_or.csv`.
3. Read ACME and ADE in `ch22_mediation_effects.csv`.
4. Interpret the smoking coefficient in the mediator model from `ch22_path_coefficients.csv`.
5. Write a one-paragraph Results section using the reporting template.

---
