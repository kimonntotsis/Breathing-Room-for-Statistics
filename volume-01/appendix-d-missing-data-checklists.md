---
number-sections: false
---

# Appendix D: Missing data checklists {.unnumbered}

Operational checklists for **data analysis plans (DAPs)** and **manuscripts** in multi-centre respiratory research. Statistical concepts and CASTOR examples: [Chapter 20](chapters/20-missing-data.md). Omics and LOD: [Chapter 13](chapters/13-differential-analysis-fdr.md). Longitudinal dropout: [Chapter 18](chapters/18-longitudinal-mixed-models.md).

These checklists generalise consortium good practice. They do not replace study-specific statistical review or protocol-defined estimands.

---

## Core principles

| Principle | Plain language |
|-----------|----------------|
| **Transparency** | Describe missingness before modelling |
| **Pre-specification** | Primary missing-data approach in the DAP before unblinded analysis |
| **Proportionality** | Match method complexity to amount, mechanism, and importance of missingness |
| **Preserve raw data** | Keep unimputed values available; label imputed layers clearly |
| **No automatic imputation** | Complete-case, likelihood-based, or weighting may be preferable |
| **Sensitivity** | When missingness is non-negligible, show whether conclusions hold |

---

## Before you analyse: required assessment

Complete this **even if no imputation is planned**.

| Step | Minimum content |
|------|-----------------|
| 1. Classify each variable | Outcome, exposure, covariate, auxiliary, derived, assay-limited, or **structural** |
| 2. Variable-level missingness | *n* and % missing (non-structural); structural missing reported separately |
| 3. Missingness by strata | By arm, visit, site, severity, sex, or other DAP-relevant groups |
| 4. Pattern | Isolated, intermittent, monotone dropout, or clustered |
| 5. Mechanism | Plausible MCAR, MAR, or MNAR with subject-matter rationale (not a single test) |
| 6. Compare groups | Key characteristics: participants with vs without missing values |
| 7. Denominator | State whether % uses full cohort or eligible-for-measurement *n* |

### Recommended outputs

| Output | Contents |
|--------|----------|
| **Table: variable missingness** | Variable, role, total *N*, missing *n*, missing %, structural *n*, reason if known |
| **Table: missingness by strata** | Same metrics by visit, site, arm, or phenotype |
| **Table: complete-case retention** | *n* in primary model and *n* excluded |
| **Figure: pattern plot** | Heatmap or bar chart of missingness structure |
| **Figure: observed vs imputed** | Distribution comparison when imputation is used |

---

## Decision thresholds (starting points)

See [Chapter 20](chapters/20-missing-data.md) for narrative. Percentages alone do not dictate the method.

| Non-structural % missing | Starting interpretation |
|--------------------------|-------------------------|
| 0% to &lt;5% | Complete-case often OK if not differential; document |
| 5% to &lt;20% | Assess bias; consider MI or model-based methods for key variables |
| 20% to &lt;40% | Complete-case rarely sufficient for primary inference; sensitivity required |
| 40% to &lt;60% | Cautious interpretation; imputation only with strong justification |
| 60%+ | Descriptive or subgroup analyses; avoid strong causal claims |

**Primary outcome** missingness: always discuss and sensitivity-test unless negligible.

---

## By data type (quick routing)

| Data type | First-line options | Handbook chapter |
|-----------|-------------------|------------------|
| Cross-sectional clinical/demographic | Complete-case if very low missing; MICE if MAR plausible | Ch 20 |
| Longitudinal FEV1 / visits | Mixed models under MAR; distinguish intermittent vs dropout | Ch 18, 20 |
| Binary/count outcomes with missing covariates | MI including outcome in imputation model when appropriate | Ch 6, 20 |
| Proteomics / RNA missingness + LOD | QC, detection rate, batch; not generic MI on all features | Ch 13, 14 |
| Flow / imaging derived | Structural vs failed algorithm; participant-level summaries | Ch 15 |
| Prediction with missing predictors | MI **inside** cross-validation folds | Ch 9, 17 |

---

## Imputation specification (when MI is used)

The DAP or Methods must state:

- software and method (e.g. MICE, predictive mean matching for continuous variables);
- variables in the imputation model and their types;
- number of imputations (minimum **m = 20** in most settings);
- iterations and convergence checks;
- passive imputation rules for derived variables (BMI, change scores, responders);
- bounds for clinically plausible values;
- random seed and package versions;
- pooling rule for final estimates (Rubin's rules).

**Diagnostics (minimum):** observed vs imputed distributions; plausibility bounds; convergence traces for MICE; % imputed per variable.

---

## Sensitivity analyses to prespecify

Choose at least one alternative when missingness is moderate or outcome-related:

- [ ] Complete-case analysis  
- [ ] Available-case descriptives  
- [ ] Alternative imputation model or *m*  
- [ ] Observed-outcome mixed model (longitudinal)  
- [ ] IPW for dropout or attendance (see Ch 21)  
- [ ] MNAR scenario / tipping-point (advanced)  
- [ ] Analysis on raw vs centrally processed variables (multi-centre studies)  

Report whether conclusions change materially.

---

## Multi-centre and shared variables

When several teams use the same core covariates:

| Practice | Why |
|----------|-----|
| Distribute **raw** and **analysis-ready** layers | Audit and sensitivity on unimputed data |
| Label imputed variables (`_imp` or separate file) | Prevents silent overwrite |
| Document pipeline version, seed, date | Reproducibility |
| Do not re-impute centrally imputed core variables without justification | Consistency across analyses |

Local variables (omics panels, working-group endpoints) are documented in the **study-specific DAP**.

---

## DAP minimum content (copy-ready headings)

1. Variable roles and structural missingness rules  
2. Missingness assessment tables and figures (planned)  
3. Assumed mechanism (MCAR / MAR / MNAR) with rationale  
4. Primary missing-data method aligned to estimand  
5. Imputation model specification (if applicable)  
6. Planned diagnostics  
7. Prespecified sensitivity analyses  
8. Software, seed, and code location  
9. LOD / below-detection handling (omics assays), if applicable  

---

## Manuscript / report minimum content

- Enrolled *n* vs analysed *n* for each analysis  
- Missing *n* and % for key variables (denominator stated)  
- Reasons for missing if collected  
- Structural missingness described separately  
- Methods sentence for handling missing data  
- Sensitivity results (not only primary)  
- Limitations related to missingness mechanism  

**Methods template:**

> Of *N* participants enrolled, *n* = … had observed [outcome] at [timepoint] (…% missing non-structurally). Missingness was …% in [stratum]. We assumed [MCAR/MAR/MNAR] because …. The primary analysis used [complete-case / multiple imputation with *m* = … / mixed model / …]. Variables in the imputation model were …. Pooled estimates were …. Results were [similar / materially changed] under complete-case analysis (Table …). Below-limit-of-detection values were handled by ….

---

## Analysis-plan approval checklist

| # | Item | Done? |
|---|------|-------|
| 1 | Each variable classified (role, structural vs random, assay-limited) | |
| 2 | Raw and imputed/processed versions identified | |
| 3 | Variable-level missingness reported | |
| 4 | Missingness by key strata assessed | |
| 5 | Pattern plot or table produced | |
| 6 | Mechanism discussed (MCAR / MAR / MNAR) | |
| 7 | Thresholds applied with justification (not mechanically) | |
| 8 | Primary approach matches estimand | |
| 9 | Imputation fully specified (if used) | |
| 10 | Longitudinal: intermittent vs dropout distinguished | |
| 11 | LOD handled separately from ordinary missing (if applicable) | |
| 12 | Diagnostics planned | |
| 13 | Sensitivity analyses prespecified | |
| 14 | Scripted workflow, seed, versions documented | |

---

## Reproducibility minimum

- Scripted analysis (R/Python), not undocumented point-and-click imputation  
- Fixed random seed for stochastic imputation  
- Saved logs of missingness tables and diagnostic plots  
- Data extraction date and version recorded  

---

*Adapted from operational missing-data standards used in multi-centre respiratory consortia. For teaching workflow and wrong analyses, see [Chapter 20](chapters/20-missing-data.md).*
