---
number-sections: false
---

# Appendix O: Chapter 4 comparison extensions {.unnumbered}

> **Bookmark when the default Ch 4 path is not enough.** Core comparisons (Welch *t*, chi-square, ANCOVA, paired tests) live in [Chapter 4](chapters/04-comparing-groups.md). This appendix holds specialised designs and method menus for cluster nesting, crossover pairing, non-inferiority margins, and rate-based count comparisons.

---

## Alternatives & extensions (choose by data and design)

Chapter 4 covers the default comparisons. Use these alternatives when the **assumptions, design, or estimand** differ.

### Continuous outcomes: beyond “t vs Wilcoxon”

| Situation | Alternative | Why / note |
|---|---|---|
| Heavy tails/outliers | **Trimmed-mean tests** (e.g. Yuen) | Robust mean-like estimand; report trimming |
| Small n; unclear distribution | **Permutation test** (already in Ch 4) | Minimal assumptions; prespecify statistic |
| Want CI without formulas | **Bootstrap CI** | See Ch 8 [@efron1993bootstrap] |
| Want distributional effect size | **Cliff’s delta** / rank-biserial | Nonparametric effect size |

### Binary outcomes: beyond chi-square/Fisher

| Situation | Alternative | Why / note |
|---|---|---|
| Stratified 2×2 tables | **Mantel-Haenszel** OR/RR | Adjust for one stratifier without full regression |
| Common outcome; want RR | **RR model** (log-binomial / modified Poisson) | See Ch 6 |
| Small samples | **Exact CIs** for OR/RR | Fisher test is exact; CI choice still matters |

### Count outcomes: compare *rates*, not raw counts

| Situation | Alternative | Why / note |
|---|---|---|
| Different follow-up time | **Poisson/NB + offset(log person-time)** | Ch 6 |
| Many zeros | **Zero-inflated / hurdle models** | Ch 6 (ZIP/ZINB) |

### Design extensions: clustered and crossover data

Standard Ch 4 tests assume **independent** observations. Respiratory studies often violate that.

### Technique: Clustered units (wards, centres, GP practices)

| | |
|---|---|
| **Answers** | Is the outcome different between arms when patients are nested in clusters? |
| **Outcome** | Continuous, binary, or count (same as unadjusted comparison) |
| **Design** | Cluster randomised trial, or patients nested in ICU wards / hospitals |
| **Assumptions** | Clusters are independent; enough clusters (not just patients) for inference |
| **Effect measure** | Same estimand as unadjusted comparison, with **cluster-appropriate SE** |
| **R (continuous)** | Mixed model: `lmer(outcome ~ arm + (1 \| cluster_id))` ([Ch 18](chapters/18-longitudinal-mixed-models.md)) |
| **R (binary/count)** | GEE with `cluster = cluster_id` or mixed GLMM |
| **Report** | Number of **clusters** and patients; ICC if reported; CI from cluster-aware model |
| **Avoid when** | Only 2–3 clusters (unstable); treating cluster members as independent (SE too small) |

patients in the same ICU ward correlate; analyse at ward level or use a model that respects nesting.

Formally: ignore clustering → anti-conservative SEs and inflated significance [@harrell2015rms].

“n = 400 patients” may hide “8 wards”; ask how many **units** were randomised.

#### Wrong analysis ⚠

| Mistake | Why it fails | Do instead |
|---------|--------------|------------|
| Welch *t* on all ICU patients | Ward-level exposure shared | Mixed model or GEE with ward random effect |
| Cluster RCT analysed as individual RCT | Wrong denominator for inference | Cluster-level or mixed model with `(1 \| cluster)` |

### Technique: Crossover and paired bronchodilator designs

| | |
|---|---|
| **Answers** | Is post-BD FEV1 higher than pre-BD **within the same patient**? |
| **Outcome** | Continuous (FEV1, FVC) |
| **Design** | Paired measurements same visit (CASTOR: `bronchodilator_paired.csv`) |
| **Assumptions** | Pairs independent; difference approximately normal or large *n* |
| **Effect measure** | Mean change (post − pre) |
| **R** | `t.test(post, pre, paired = TRUE)` or mixed model if multiple crossover periods |
| **Report** | Mean change + 95% CI; *n* pairs; BD protocol (dose, wait time) |
| **Avoid when** | Carryover between periods in multi-period crossover without washout |

same patient, two manoeuvres; use a **paired** test, not two independent groups.

ATS/ERS BD reversibility uses within-patient change; do not split pre and post into fictional “groups.”

CASTOR paired example: `R/examples/ch04_comparing_groups.R` and Figure (`ch04_paired_bronchodilator.png`).

### Technique: Non-inferiority and equivalence trials {#technique-non-inferiority-and-equivalence-trials}

| | |
|---|---|
| **Answers** | Is the new therapy **not worse** than control by more than a prespecified margin? |
| **Outcome** | Continuous (FEV1 change), binary (exacerbation), or rate |
| **Design** | Parallel NI/ equivalence trial with **prespecified Δ** |
| **Assumptions** | Margin clinically justified; powered for NI (not superiority) |
| **Effect measure** | Mean difference vs margin; or proportion difference vs margin |
| **Methods** | **Non-inferiority:** compare the **lower bound** of a **two-sided 95% CI** to prespecified margin Δ when the estimand is (new − control) and one-sided α = **0.025** (equivalent to a one-sided 2.5% test on that bound). If one-sided α = **0.05**, use a **90% two-sided CI** instead. **Equivalence:** **TOST** (two one-sided tests) with two prespecified margins — do not label NI as TOST. |
| **Report** | Margin Δ, NI conclusion yes/no, CI relative to Δ |
| **Avoid when** | Declaring equivalence from superiority *p* > 0.05 |

“Not significantly different” ≠ “equivalent.” You must prespecify how much worse is acceptable.

device and inhaler NI trials live or die on the **margin**, not the *p*-value from a superiority test.

#### Reporting template (non-inferiority, continuous FEV1)

**Methods:** The primary estimand was the mean difference in change from baseline FEV1 at 12 weeks (new therapy − control). Non-inferiority was prespecified with margin Δ = −0.10 L (one-sided α = 0.025). We compared the **lower bound of the two-sided 95% CI** to Δ (equivalent to one-sided 2.5% on that bound for this estimand). If your SAP uses one-sided α = 0.05, report a **90% two-sided CI** against Δ instead.

**Results:** Mean difference = −0.03 L (95% CI −0.08 to 0.02). The **lower CI bound (−0.08) exceeds Δ (−0.10)** → **non-inferiority demonstrated** / if the lower bound is ≤ Δ → **not demonstrated**.

**Do not say:** “Groups were equivalent because p = 0.34.”

See also [Chapter 8](chapters/08-validation-reporting.md) reporting checklist for NI trials.

### Design extensions (longitudinal and survival)

| Design feature | Why Ch 4 methods fail | Handbook chapter |
|---|---|---|
| Repeated measures | observations not independent | [Ch 18](chapters/18-longitudinal-mixed-models.md) mixed models / GEE |
| Multi-centre clustering | SEs too small if ignored | Cluster-robust SE / `(1 \| centre)`; this chapter + Ch 18 |
| Time-to-event endpoints | censoring | [Ch 19](chapters/19-survival-analysis.md) survival analysis |

### Equivalence (superiority test insufficient)

If the scientific goal is **equivalence** (two-sided margin), prespecify **both** bounds and use **TOST** (two one-sided tests) or an equivalent CI entirely within the equivalence region. A non-significant *p*-value from a superiority test is not evidence of equivalence [@harrell2015rms]. For **non-inferiority** (one margin, one-sided claim), use the [NI template above](#technique-non-inferiority-and-equivalence-trials), not TOST.

