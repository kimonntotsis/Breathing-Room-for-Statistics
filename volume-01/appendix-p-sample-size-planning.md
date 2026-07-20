---
number-sections: false
---

# Appendix P: Sample size, precision, and analysis planning {.unnumbered}

> **Bookmark when designing a study or reviewing a protocol.** This handbook does not derive formulas exhaustively; it links **estimands** to what must be decided **before** data collection.

---

## Why this matters in respiratory research

Underpowered COPD and asthma studies produce **wide confidence intervals** compatible with both null and clinically important effects. Omics studies with too few biological replicates generate unstable discovery lists. Prediction models with too few events overfit and fail external validation.

Sample-size planning is **not** a post hoc comfort exercise. It must match:

1. **Primary estimand** (mean difference, risk difference, rate ratio, hazard contrast, AUC target, discovery FDR budget);
2. **Expected variability** (SD of FEV₁, event rate, overdispersion);
3. **Attrition and missingness** (spirometry failure, dropout, loss to follow-up);
4. **Clustering** (ICU wards, hospitals, families);
5. **Multiplicity** (secondary endpoints, omics screens).

---

## Precision-based planning (continuous FEV₁)

For a two-arm RCT with primary estimand **mean difference in FEV₁ at 12 weeks**:

- Specify **clinically important difference** (e.g. MCID ≈ 100 mL in many COPD contexts).
- Use pilot SD or literature SD (litres).
- Plan for **two-sided α** and **power** (often 80–90%).
- Inflate *n* for anticipated dropout in spirometry.

**R (illustrative):** `pwr::pwr.t.test(d = delta/SD, sig.level = 0.05, power = 0.8, type = "two.sample")`

Report: target *n* randomised, assumed SD, MCID, power, and attrition inflation.

---

## Binary and count endpoints

| Estimand | Planning note |
|----------|----------------|
| **Risk difference / proportion** | Events per arm; rare events → exact methods or wider CIs |
| **Exacerbation rate** | Person-time; specify follow-up window; plan for overdispersion |
| **Recurrent exacerbations** | First-event Cox **underpowers** recurrent questions; consider rate-based or recurrent-event designs (Ch 6, 19) |
| **Time-to-first event** | Events across arms; censoring assumptions; competing death |

---

## Prediction models

TRIPOD+AI and recent sample-size work emphasise **events in development and validation**, not total *n* alone [@collins2024tripodai; @riley2019minimum].

Plan for:

- adequate **events per candidate predictor** in training (EPV as rule of thumb, not law);
- a **hold-out or resampling** plan with enough events in validation folds;
- **external validation** cohort if deployment is the goal.

The CASTOR prediction demo (~18 events) is **intentionally underpowered** for deployment (Ch 9).

---

## Omics discovery versus confirmation

| Stage | Planning focus |
|-------|----------------|
| **Discovery** | Replicates, batch balance, FDR budget, pre-specified analysis path |
| **Confirmation** | Independent cohort, prespecified protein/gene list, no re-thresholding |

A “significant” volcano plot without replication plan is a **hypothesis list**, not a biomarker.

---

## What to prespecify in the analysis plan (minimum)

1. Primary estimand (one sentence).
2. Primary analysis method and covariates (if any).
3. Missing-data handling for primary estimand.
4. Key sensitivity analyses (e.g. MAR vs MNAR, cross-sectional vs mixed model).
5. Multiplicity rule for secondaries.
6. Software and package versions (or `renv` lockfile reference).

See [Chapter 1](chapters/01-statistical-thinking.md) and [Appendix D](appendix-d-missing-data-checklists.md).

---

## Further reading

- Riley et al., minimum sample size for prediction models [@riley2019minimum]
- Harrell, *Regression Modeling Strategies* — continuous and binary power [@harrell2015rms]
- ICH E9(R1) estimands (intercurrent events) — trial design context
