---
number-sections: false
---

# Appendix Q: Diagnostic accuracy and clinical prediction tests {.unnumbered}

> **Bookmark when evaluating a biomarker, screening tool, spirometry threshold, FeNO cut-off, or imaging classifier.** This is **not** the same workflow as multivariable risk prediction (Ch 9), though both use discrimination metrics.

---

## When this appendix applies

| Study type | Examples in respiratory research |
|------------|----------------------------------|
| **Single test vs reference standard** | FeNO ≥50 ppb vs physician diagnosis; CT pattern vs surgical biopsy |
| **Threshold on continuous marker** | Blood eosinophils for biologic eligibility |
| **Screening in a defined population** | COPD case-finding questionnaire |
| **Device comparison** | Portable vs lab spirometer for obstruction |

Multivariable **prediction models** (many predictors → risk score) follow **TRIPOD+AI** (Ch 9). **Diagnostic accuracy** studies often report sensitivity, specificity, and predictive values for **one test** against a gold standard.

---

## Core quantities

| Measure | Question it answers | Trap |
|---------|---------------------|------|
| **Sensitivity** | Among people **with** disease, how many test positive? | Ignores prevalence |
| **Specificity** | Among people **without** disease, how many test negative? | Same |
| **PPV / NPV** | If my test is positive/negative, what is P(disease)? | **Strongly prevalence-dependent** |
| **Likelihood ratio (LR+ / LR−)** | How much does the test shift pre-test to post-test odds? | More transportable than PPV alone |
| **AUC (ROC)** | Discrimination across thresholds | **Not** a clinical threshold; can look good with useless PPV in low prevalence |

**Respiratory example:** A FeNO test with 80% sensitivity and 70% specificity sounds useful, but PPV in a low-prevalence primary-care screen can still be poor. Report **prevalence**, **confusion matrix**, and **predictive values in your target population**.

---

## Workflow (STARD-minded)

1. **Target population** and setting (severe asthma clinic vs primary care).
2. **Index test** and **reference standard** (blinding where feasible).
3. **Threshold** prespecified **before** seeing data (avoid data-driven cut-offs).
4. **Flow diagram**: enrolled → tested → reference available → analysed.
5. **2×2 table** with denominators; CIs for proportions (Wilson or exact methods).
6. **ROC curve** only if thresholds are genuinely uncertain **and** prespecified as exploratory.
7. **Calibration** if the test outputs a probability score.
8. **Clinical utility**: who would be treated differently? (link to decision thresholds, Ch 9 DCA when relevant).

---

## Common wrong analyses

| What went wrong | Why it matters | Better approach |
|-----------------|----------------|-----------------|
| Optimise cut-off on the same data used to report accuracy | Inflated sensitivity/specificity | Prespecify threshold; or split derivation/validation |
| Report AUC only | Hides operating point | Confusion matrix at prespecified threshold |
| Compare PPV across studies with different prevalence | Misleading ranking | Report LR or standardise prevalence |
| **Verification bias** | Only sick patients get reference test | Describe who received gold standard |
| **Spectrum bias** | Only extreme cases enrolled | Match spectrum to intended use |
| Treat OR from logistic screen as diagnostic accuracy | Different estimand | Cross-sectional 2×2 vs reference |

---

## Relationship to other handbook chapters

| Topic | Where |
|-------|-------|
| Binary GLMs / OR | Ch 6 (association, not diagnostic workflow) |
| Prediction models, calibration, TRIPOD+AI | Ch 9 |
| Agreement between two **continuous** measures (not gold standard) | Ch 3 (Bland–Altman) |
| Sample size for precision of sensitivity | Appendix P |

---

## Reporting template

**Methods:**

> We evaluated [index test] against [reference standard] in [population]. The prespecified positivity threshold was [value]. Reference assessment was [blinded / independent]. We report sensitivity, specificity, positive and negative predictive values with [95% CIs], and the area under the ROC curve as a secondary summary when threshold selection was exploratory.

**Results:**

> Among *n* participants (*prevalence* = …%), the index test was positive in …%. Sensitivity was …% (95% CI … to …) and specificity …% (95% CI … to …). PPV was …% and NPV …%. At the prespecified threshold, … of … patients with disease tested positive (true positives / false negatives in Supplementary Table …).

**Do not say:** "The biomarker is validated for clinical use" after a single-centre accuracy study without external replication.

---

## Further reading

- Steyerberg, *Clinical Prediction Models* — discrimination, calibration, validation [@steyerberg2019clinical]
- Harrell, *Regression Modeling Strategies* — diagnostic vs prognostic framing [@harrell2015rms]
- TRIPOD+AI when the “test” is a multivariable model [@collins2024tripodai]
