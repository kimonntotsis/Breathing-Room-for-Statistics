# APATE vignette (what CASTOR simplifies)

## What APATE means

**APATE** (Ἀπάτη) is the Greek personification of **deceit, fraud, and illusion**. In this handbook the name labels a **fictional registry story** — not a dataset.

| Name | What it is | In the repo |
|------|------------|-------------|
| **CASTOR** | Synthetic **COPD-flavoured** teaching cohort with CSV files + R scripts | `data/*.csv`, Ch 3–12; workflow applies to **CLD** when estimand/design match |
| **CASTOR-HD** | Synthetic **omics extension** (proteomics, RNA, flow, screens) | `data/proteomics_*.csv`, etc., Ch 13–17 |
| **APATE** | **Prose-only vignette** of a messy multi-site registry | **This file only** — no CSV, no R lab |

**Backronym (teaching label, not for Methods):** *Aggregated Pulmonary Airways Translational Epidemiology* — a name for the fictional registry below.

---

## What APATE is used for here

APATE does **not** teach new tests. It teaches **skepticism** before you sign off a real protocol, steering deck, or manuscript:

1. **Contrast** — CASTOR is clean on purpose; APATE lists what real studies hide (visit slippage, QC failure, site effects, batch confounding).
2. **Checklist** — Investigator questions to ask when your cohort is **not** in `data/*.csv`.
3. **Methods voice** — A sample paragraph showing honest *n*, exclusions, clustering, and exploratory vs confirmatory separation.

**Use with:** [RECURRING_COHORT](RECURRING_COHORT.md), [Ch 1](chapters/01-statistical-thinking.md), [Ch 2](chapters/02-respiratory-data.md), [Ch 12](chapters/12-case-studies.md), [Appendix J](appendix-j-investigator-minimum-path.md).

---

## The fictional APATE registry (narrative only)

> *APATE is a 14-site European pragmatic COPD registry: 2,840 patients enrolled over 4 years. Spirometry was “at least annual” but visit windows were ±8 weeks. Exacerbations mixed patient report and hospital records with inconsistent adjudication. A blood subset was assayed on two proteomics plates 18 months apart.*

**No row in `data/*.csv` is APATE.** The table below is the **mess** CASTOR deliberately removes so methods stay teachable.

---

## CASTOR vs APATE-style reality

| Topic | CASTOR (teaching data) | APATE-style reality (fictional) | What to do |
|-------|------------------------|----------------------------------|------------|
| **Visit timing** | Weeks 0, 12, 24, 52 exactly | Windows slipped; winter gaps; COVID pause | Prespecify scheduled vs observed visits ([Ch 18](chapters/18-longitudinal-mixed-models.md), [Ch 20](chapters/20-missing-data.md)) |
| **Spirometry QC** | All FEV1 valid | 11% failed ATS acceptability; pre-BD only at 3 sites | Report QC exclusions; harmonise BD protocol ([Ch 4](chapters/04-comparing-groups.md)) |
| **Missing FEV1** | Simulated MAR pattern | MNAR in severe disease + site staffing | Pattern plot + sensitivity ([Ch 20](chapters/20-missing-data.md)) |
| **Exacerbation definition** | Single binary 12 m | Mix of moderate/severe; recall bias | Lock definition; sensitivity ([Ch 6](chapters/06-generalized-linear-models.md)) |
| **Site / centre** | Independent patients | ICC ≈ 0.08 for FEV1 | Cluster-robust SE or site random effect ([Ch 4](chapters/04-comparing-groups.md), [Ch 18](chapters/18-longitudinal-mixed-models.md)) |
| **Therapy changes** | Static baseline class | 34% switched ICS/LABA mid-follow-up | Time-varying covariates / advanced causal framing ([Ch 21](chapters/21-causal-inference.md)) |
| **Proteomics** | Balanced batch overlap | Plate 2 mostly severe GOLD III–IV | Group × batch stop rule ([Ch 14](chapters/14-batch-effects.md)) |
| **Screen hits** | Tiered confirmation toy | Only top 12 clones confirmed (budget) | PPV and tiers, not rank slides ([Ch 16](chapters/16-antibody-discovery.md)) |

---

## Investigator questions (before sign-off on real data)

1. **Who is in the analysed set?** Enrolled vs protocol-compliant vs complete primary endpoint — three different *n*s.
2. **Is the figure honest?** [Appendix I](appendix-i-figure-hygiene.md) three questions on every primary figure.
3. **Does the estimand survive protocol deviation?** State treatment-policy vs hypothetical strategy.
4. **Would the conclusion change under MAR vs MNAR?** Say so in limitations ([Ch 20](chapters/20-missing-data.md)).
5. **Are discovery and confirmatory claims separated?** Volcano slides ≠ trial primary endpoint ([Ch 13](chapters/13-differential-analysis-fdr.md), [Ch 12](chapters/12-case-studies.md)).

---

## Worked narrative snippet (Methods-style, fictional APATE)

> *In the APATE registry, the estimand was the difference in mean post-bronchodilator FEV1 (L) at the year-1 visit between therapy lines, in patients with acceptable spirometry at baseline and year 1. Of 2,840 enrolled patients, 2,103 had year-1 spirometry meeting ATS criteria; missingness was higher in GOLD IV (38% vs 12% in GOLD II). Analyses used linear regression adjusting for age, sex, and baseline FEV1, with cluster-robust standard errors by site. A complete-case analysis and single imputation sensitivity are reported. Proteomics findings are exploratory with FDR control and batch adjustment; they were not used to select the primary pulmonary endpoint.*

Compare to CASTOR Methods boilerplate in [RECURRING_COHORT](RECURRING_COHORT.md).

---

## For analysts

CASTOR scripts remain the **method reference**. When moving to a real cohort:

1. Document deviations in your data dictionary (not in this repo).
2. Re-run the same diagnostic and figure-hygiene plots; expect uglier tails and missingness strips.
3. Use the [sign-off checklist](figures/viz_signoff_checklist.png) with real *n* and real limitations.

---

## Further reading

- Missing data checklists: [Appendix D](appendix-d-missing-data-checklists.md)  
- High-dimensional reporting: [HIGH_DIM_REPORTING_TEMPLATES](HIGH_DIM_REPORTING_TEMPLATES.md)  
- Handbook edition: [HANDBOOK_STATUS](HANDBOOK_STATUS.md)
