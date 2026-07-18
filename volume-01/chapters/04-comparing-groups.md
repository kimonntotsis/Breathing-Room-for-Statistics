# Chapter 4: Comparing Groups

> **Part II: Inference for Common Respiratory Outcomes**

## Opening scene: "Can we call this a win?"

Interim CASTOR results land: mean FEV₁ 3.85 L intervention vs 3.76 L standard care. The forest-plot snippet looks encouraging; *p* = 0.20. A steering member reads significance from colour alone.

Mei projects the mean difference and 95% CI: 0.09 L (−0.04 to 0.21). The prespecified MCID was 0.10 L. *"Non-significant superiority is inconclusive,"* she says, *"not proof the arms are equal. We report the estimand we wrote in the SAP."*

This chapter is the reference for that conversation — and for every other group comparison in respiratory work.

---

## Why this chapter

Most respiratory papers hinge on a comparison: means, proportions, or rates between arms. The mistakes repeat — wrong pairing, wrong outcome family, *p*-values without effect sizes. Work through the CASTOR primary here; bookmark the chapter when your endpoint changes.

Pre- and post-bronchodilator timing must match across arms. Classify exacerbation endpoints as **proportion vs count** before you pick a row in the master table — counts belong in GLMs, not here. **Welch *t*** is the default for two independent continuous groups; always pair it with **mean difference + 95% CI**, not *p* alone. A non-significant week-12 FEV₁ result is **inconclusive**, not proof of equivalence unless the SAP prespecified an equivalence margin. Wilcoxon compares **ranks**; if mean and median stories diverge, report both.

> **How to read this chapter:** Reference sections — read the opening scene and [Quick reference](#quick-reference-methods-in-this-chapter) first; jump to your outcome type. You do not read every technique sequentially.

---

## The comparison workflow

Every group comparison follows five steps:

1. **Estimand** - mean difference? median difference? risk difference?
2. **Design** - independent, paired, or clustered?
3. **Outcome type** - continuous, binary, count?
4. **Method** - matched to 1-3 with stated assumptions
5. **Report** - effect estimate, 95% CI, n, test/ model, limitations

---

## Unadjusted, adjusted, and multiple endpoints

Sponsor slides often mix three distinct decisions: a **crude arm difference**, a **covariate-adjusted** effect, and **several lung endpoints on one page**. Treat each as its own estimand with its own reporting rule.

### Unadjusted vs adjusted

| Analysis | Estimand (plain) | When it is primary | Report with |
|----------|------------------|--------------------|-------------|
| **Unadjusted** | Raw mean or proportion difference between groups | Balanced RCT with prespecified simple comparison; Table 1 shows acceptable balance (Ch 3) | Point estimate + 95% CI + **n** (and **events** for binary outcomes) |
| **Adjusted** | Difference **holding prespecified covariates fixed** (age, sex, baseline FEV1, centre, …) | Observational cohorts; baseline imbalance; pulmonary RCTs using ANCOVA | Same + **list covariates**; residual checks (Ch 5) |

**RCT rule:** prespecify in the SAP whether the primary analysis is unadjusted ITT, **ANCOVA with baseline FEV1**, or a prespecified change score. Do not run all three and promote the smallest *p*.

**Observational rule:** adjusted logistic or linear models are the main analysis; unadjusted comparisons are **sensitivity** analyses that show how much confounding matters: not proof of effect (Ch 21).

**Wording:** unadjusted → “mean difference between groups”; adjusted → “associated with … after adjustment for …” unless the design supports stronger causal language.

**Practice read:** Case B in Ch 12 shows crude proportions beside an adjusted exacerbation model: mirror that pattern when baseline imbalance or confounding is plausible.

#### Wrong analysis ⚠

Do not report a Fisher odds ratio or Welch mean difference as “adjusted” without covariates — label unadjusted explicitly and route adjustment to regression (next two chapters in Part III). Do not change covariates after seeing results; prespecify confounders in the SAP before unblinding and treat post-hoc tweaks as sensitivity only.

### Linking multiple clinical outcomes

FEV1, FVC, symptom scores, and exacerbation rate are **clinically related** but **statistically separate**. Link them in the **protocol**, not by running many primary *p*-values.

| Layer | Rule | Where to write it |
|-------|------|-------------------|
| **One primary** | Single estimand drives sample size and trial success | SAP + CONSORT primary line |
| **Secondaries in a family** | Prespecify order; **Holm** or gatekeeping across the family | [Multiplicity](#multiplicity) below; SAP |
| **Exploratory** | Hypothesis-generating; honest labelling | Discussion limits; Case 12 capstone |
| **Omics / biomarkers** | Separate testing family from clinical endpoints; FDR, not Holm on FEV1 | Part VI |
| **Unsupervised clusters** | Not linked to outcomes until externally validated | Ch 11 |

**Composite endpoints** (e.g. FEV1 responder **and** no exacerbation): define components, missing-data rules, and whether components are co-primary **before** data lock. This handbook does not treat composite construction in depth: borrow from trial-statistics references and freeze the **winning definition** in the SAP.

#### Worked example: composite primary (fictional pulmonary SAP)

A CLD trial team debates a single primary endpoint. They freeze this **before** database lock:

| Element | Prespecification |
|---------|------------------|
| **Composite name** | “Dual responder at week 12” |
| **Component A** | Post-BD FEV1 ≥100 mL above baseline at week 12 (ATS-acceptable manoeuvre) |
| **Component B** | No moderate/severe exacerbation from randomisation through week 12 |
| **Composite rule** | Responder = **both** A and B |
| **Missing data** | If week-12 spirometry missing → not a responder for primary ITT; sensitivity with multiple imputation prespecified |
| **Analysis** | Risk difference in responder proportion (intervention − control) + 95% CI; Fisher or logistic with covariates as supportive |
| **Secondaries** | FEV1 (continuous), exacerbation rate, CAT: **Holm family**, separate from composite test |
| **Not allowed** | Switching to FEV1 alone if composite p = 0.06 |

**Methods snippet:**

> *The primary endpoint was dual responder status at week 12 (FEV1 increase ≥0.10 L and no moderate/severe exacerbation). The estimand was the risk difference in responder proportion (intervention − standard care) in the intention-to-treat population. Secondary endpoints (FEV1 litres, annualised exacerbation rate, CAT) were tested in a prespecified order with Holm adjustment within the clinical family.*

**Practice read:** composites simplify steering narratives but complicate missing spirometry: write the missing-data rule **with** the composite, not after.

#### Wrong analysis ⚠

Do not put four primary *p*-values on one slide (FEV1, FVC, symptoms, exacerbations) — one primary, secondaries in a prespecified family, exploratory labelled. Do not package an omics volcano beside week-12 FEV1 as one confirmatory package; separate discovery from confirmatory (Ch 12, Ch 17).

---

## Continuous outcomes: two independent groups

### Technique: Welch two-sample t-test

Welch's *t*-test compares **means** between two independent groups on a continuous outcome — FEV₁, FVC, 6MWD — without assuming equal variances. It needs one measurement per patient, approximate normality within groups (or large *n*), and independence. The estimand is the mean difference (group A − group B); in R, `t.test(y ~ group, var.equal = FALSE)`.

**Plain language:** is average lung function higher in one arm?

**Precise language:** test $H_0$: $\mu_1 = \mu_2$ with a CI for $\mu_1 - \mu_2$; Welch-Satterthwaite degrees of freedom handle unequal spreads [@welch1947t].

**Clinical relevance:** ask whether the mean difference exceeds the **MCID** for that outcome — literature-based and disease-specific [@cazzola2008mcid]. Do not use Welch on binary or count outcomes, paired measurements, strongly skewed small samples, or clustered data without the paired/cluster methods below.

```r
t.test(fev1 ~ group, data = spirometry, var.equal = FALSE)
```

### Other respiratory settings

CASTOR uses COPD-style FEV1 trials. When you interpret a mean difference or CI:

- **Asthma:** MCID for FEV1 differs from COPD. Biologic trials may prespecify exacerbation reduction even when FEV1 moves modestly. Compare the CI to the margin in your protocol.
- **Mixed airways disease:** Match pre- and post-bronchodilator timing between arms before any group comparison or ANCOVA.

Fix the primary estimand in the SAP before unblinding.

**Practice read (CASTOR arms):** is the mean difference (e.g. 0.09 L) large enough to matter given MCID (~0.10 L in many COPD trials)? The CI answers that as well as *p*-values [@cazzola2008mcid].

**What Welch does not do:** it compares means, not medians — skewed FEV₁ in severe COPD may call for Mann–Whitney or median reporting alongside. It assumes **independence** (not ICU wardmates or repeated measures). It is a **one time point** comparison, not a decline model (Ch 18). In observational data, group differences may reflect confounding. A non-significant *p* with a CI that includes the MCID is **inconclusive**, not proof of no effect. Pre- vs post-bronchodilator protocol must match between groups [@graham2019spirometry].

The protocol says “compare FEV1 at week 12,” but exports include baseline visits, dropouts, and one site on post-BD only — map protocol → estimand → test before `t.test()`. Steering decks often stack FEV1, FVC, symptoms, and exacerbation rates: unless prespecified, label secondaries exploratory and report CIs. Non-inferiority device trials need a margin and TOST/CI-against-margin — not superiority *p* > 0.05 read as “similar” ([NI reporting](#technique-non-inferiority-and-equivalence-trials)).

**Common mismatches:** running a *t*-test on exacerbation **counts** (use Poisson/NB in Ch 6); mixing post-BD FEV₁ in one arm and pre-BD in the other; reading *p* > 0.05 as “equivalent” when the trial was never powered for equivalence.

#### Reporting template

**Methods:** FEV1 (L) at 12 weeks was compared between intervention and standard care using Welch's t-test (two-sided α = 0.05). The primary estimand was the mean difference (intervention − standard).

**Results:** Mean FEV1 was 3.85 L (SD 0.64) in intervention (n = 198) and 3.76 L (SD 0.64) in standard care (n = 202). Mean difference 0.09 L (95% CI −0.04 to 0.21; p = 0.20).

**Do not say:** "No effect of intervention"; "trend toward benefit" without prespecified trend test.

### Technique: Pooled two-sample t-test

Assumes equal variances — rarely needed; Welch is the default. Use only with strong domain reason and Levene supporting equality: `t.test(..., var.equal = TRUE)`.

### Technique: Mann–Whitney U (Wilcoxon rank-sum)

Rank-based comparison when FEV₁ is clearly skewed with small *n*, or as a **prespecified sensitivity** to Welch. Tests whether **distributions** differ, not whether **means** differ unless shifts are symmetric [@mann1947test]. Report median [IQR] or Hodges–Lehmann alongside any mean-based primary.

```r
wilcox.test(fev1 ~ group, data = spirometry)
```

**Common mistake:** run Mann–Whitney and report only the mean difference. **Instead:** if tests disagree, report mean difference + CI **and** median [IQR].

---

## Continuous outcomes: one sample

**One-sample *t*-test** — is the cohort mean FEV₁ different from a reference $\mu_0$? Use sparingly; reference equations are population-specific. Prefer % predicted or regression when comparing to “normal” spirometry.

```r
t.test(spirometry$fev1, mu = 3.0)
```

**Common mistake:** compare clinic mean to textbook “normal” FEV₁ without age/sex/height standardization.

---

## Continuous outcomes: paired measurements

### Technique: Paired t-test

Same patient, two measurements — pre/post bronchodilator FEV₁ (`bronchodilator_paired.csv`). Tests whether mean pairwise difference ≠ 0. Standardise BD protocol across visits [@graham2019spirometry]. **Common mistake:** Welch *t* on pre vs post as independent groups.

```r
bronchodilator <- read_csv(
 "data/bronchodilator_paired.csv",
 show_col_types = FALSE
)
t.test(bronchodilator$fev1_pre, bronchodilator$fev1_post, paired = TRUE)
```

**Practice read:** mean change ~0.25 L — compare to MCID for bronchodilator response [@cazzola2008mcid]. For skewed paired differences, use `wilcox.test(pre, post, paired = TRUE)`.

**Results template:** Mean FEV1 increased 0.25 L post-bronchodilator (95% CI 0.24 to 0.27; paired *t*, *p* < 0.001; *n* = 80).

---

## Continuous outcomes: three or more groups

**One-way ANOVA** tests whether any group means differ (CASTOR: FEV₁ by `diagnosis`). A significant F-test only says *some* pair differs — follow with **prespecified contrasts** or Tukey, not every pairwise test without adjustment.

```r
fit_aov <- aov(fev1 ~ diagnosis, data = spirometry)
summary(fit_aov)
TukeyHSD(fit_aov)
```

**Kruskal-Wallis** — nonparametric alternative when skew or ordinal severity dominates: `kruskal.test(fev1 ~ diagnosis, data = spirometry)`.

**Common mistake:** ANOVA significant → test all pairs without adjustment. **Results template:** FEV₁ differed by diagnosis (ANOVA *F* = 49.6, *p* < 0.001). Tukey: no obstruction vs moderate mean diff 1.52 L (95% CI …).

---

## Adjusting for baseline (preview)

When groups differ at baseline or you want greater precision in an RCT, ask whether follow-up FEV₁ differs **after adjusting baseline FEV₁ and prespecified covariates**. Full ANCOVA is **Chapter 5** — not a substitute for randomisation in causal claims.

```r
# lm(fev1_followup ~ group + fev1_baseline + age + sex, data = trial)
```

---

## Binary outcomes: comparing proportions

**Chi-square** tests independence in larger tables (expected counts ≥ ~5 per cell). **Fisher exact** when tables are sparse. Always report **risk difference, RR, or OR with 95% CI** — not *p* alone.

```r
tab <- table(exacerbation$therapy, exacerbation$exacerbation_12m)
chisq.test(tab)
# fisher.test(tab, simulate.p.value = TRUE, B = 10000)  # sparse tables
```

**Practice read (CASTOR smoking × exacerbation):** is the exacerbation rate different in smokers? Report absolute risk difference alongside any *p*-value — *"2.9% more events"* is clearer than *p* alone.

Unadjusted tables ignore age, FEV₁, and prior history. For adjusted associations, use logistic regression (Part III). **Common mistakes:** chi-square only with no effect size; reporting an unadjusted OR as an “adjusted effect.”

**Results template:** Exacerbation occurred in 13/171 smokers (7.6%) and 5/179 non-smokers (2.8%). Fisher exact *p* = 0.05; unadjusted OR 2.86 (95% CI 0.93 to 10.5). Confounders not adjusted.

### Effect measures for binary outcomes

| Measure | Meaning |
|---------|---------|
| **Risk difference** | Absolute difference in proportions |
| **Risk ratio** | Relative proportion |
| **Odds ratio** | Ratio of odds (logistic output) |

Risk difference tells you how many more patients per 100 experience the event. RD = $p_1 - p_2$; RR = $p_1/p_2$.

```r
prop.test(
 x = c(sum(exacerbation$exacerbation_12m[exacerbation$smoking]),
 sum(!exacerbation$exacerbation_12m[exacerbation$smoking])),
 n = c(sum(exacerbation$smoking), sum(!exacerbation$smoking))
)
```

### McNemar test (paired binary)

Same patient, before/after binary outcome (e.g. sputum culture positive pre vs post therapy). **Not** for independent groups — do not run chi-square on stacked before/after rows.

```r
# mcnemar.test(table(before, after))  # rows=before, cols=after
```

**Results template:** McNemar *p* = …; 12 improved, 3 worsened among discordant pairs (*n* = …).

---

## Count outcomes: comparing rates

For **exacerbation counts** between groups, Poisson or negative binomial regression is preferred over t-tests on raw counts. Use count/binary GLMs (Chapter 6).

Quick two-group comparison (equal follow-up):

```r
counts <- read_csv(
 "data/exacerbation_counts.csv",
 show_col_types = FALSE
)
wilcox.test(
 exacerbations_12m ~ factor(smoking),
 data = counts
) # descriptive
# Inferential: Poisson GLM (Ch 6)
```

---

## Effect sizes

### Cohen's d (two groups)

$$
d = \frac{\bar{x}_1 - \bar{x}_2}{s_p}
$$

where $s_p$ is pooled SD.

```r
cohen_d <- function(x, g) {
 stats <- tapply(x, g, function(v) {
 c(mean = mean(v), sd = sd(v), n = length(v))
 })
 m1 <- stats[[1]]["mean"]; m2 <- stats[[2]]["mean"]
 s1 <- stats[[1]]["sd"]; s2 <- stats[[2]]["sd"]
 n1 <- stats[[1]]["n"]; n2 <- stats[[2]]["n"]
 sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
 (m1 - m2) / sp
}
cohen_d(spirometry$fev1, spirometry$group)
```

Rule-of-thumb (Cohen): |d| ≈ 0.2 small, 0.5 medium, 0.8 large - context matters more in clinical research.

---

**Do not:** run many tests and report only significant ones.

---

## Permutation (randomisation) tests

Robustness check when *n* is small or distributions are doubtful: shuffle group labels and compare observed mean difference to the permutation distribution. Complements Welch — does not replace MCID reasoning or prespecification.

```r
set.seed(101)
obs_diff <- diff(tapply(spirometry$fev1, spirometry$group, mean))
perm_diff <- replicate(5000, {
 g <- sample(spirometry$group)
 diff(tapply(spirometry$fev1, g, mean))
})
mean(abs(perm_diff) >= abs(obs_diff))
```

---

## Sample size and power (design stage)

Before enrolment closes — not as post hoc rescue. Anchor expected effect on **MCID** or published mean difference, not Cohen's d tradition alone [@cazzola2008mcid; @harrell2015rms].

```r
pwr::pwr.t.test(d = 0.25, power = 0.8, sig.level = 0.05, type = "two.sample")
```

---

## Multiplicity

Testing FEV1, FVC, symptoms, and exacerbations without a plan inflates false positives [@benjamini1995fdr]. See [Unadjusted, adjusted, and multiple endpoints](#unadjusted-adjusted-and-multiple-endpoints) for how to **link** clinical outcomes in the SAP.

**Strategies:**

- One **prespecified primary endpoint** [@schulz2010consort]
- Holm or Bonferroni for **secondary endpoints in the same family**
- **Gatekeeping** when later endpoints are tested only if earlier ones succeed
- **Separate families** for omics screens (FDR; Ch 13) vs pulmonary function endpoints

**Do not:** run many tests and report only significant ones.

---

## Master decision table

*Quick lookup by outcome × design. For **when** and **why**, see [Method choice at a glance](#method-choice-at-a-glance) above.*

**Primary test by outcome and design**

| Outcome | Design | Primary method |
|---------|--------|----------------|
| Continuous | 1 vs reference | One-sample *t* |
| Continuous | 2 independent groups | Welch *t* |
| Continuous | 2 paired measurements | Paired *t* |
| Continuous | 3+ independent groups | ANOVA + contrasts |
| Binary | 2 independent groups | Chi-square / Fisher |
| Binary | 2 paired measurements | McNemar |
| Count | 2+ independent groups | Poisson / NB GLM |

**Alternative or adjusted analysis**

| Outcome | Design | Alternative / next step |
|---------|--------|------------------------|
| Continuous | 1 vs reference | Wilcoxon signed-rank vs median |
| Continuous | 2 independent groups | Mann-Whitney |
| Continuous | 2 paired measurements | Wilcoxon signed-rank |
| Continuous | 3+ independent groups | Kruskal-Wallis |
| Binary | 2 independent groups | Logistic regression (adjusted) |
| Binary | 2 paired measurements | Logistic GEE (adjust covariates) |
| Count | 2+ independent groups | Negative binomial; Wilcoxon sensitivity |

Full map: METHOD_MAP; Visual: `method_decision_tree.png`

![Raincloud: FEV1 by trial arm](../figures/ch04_fev1_by_group.png)

Overlapping distributions warn against reading a small mean difference as clinically certain without the CI and sample size.

### Figure hygiene: continuous comparison (mean bar vs distribution)

![Right vs wrong: FEV1 by trial arm](../figures/viz_pair_ch04_continuous.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Mean bar heights only | Spread, outliers, per-arm *n* on the plot |
| **Right** | Raincloud + mean diamond | (pair with Welch *t* CI in text) |

**Practice read:** would a sponsor infer “clear separation” from the wrong panel alone? The right panel should match the overlap in your 95% CI.

### Figure hygiene: paired bronchodilator (independence vs pairing)

![Right vs wrong: paired bronchodilator response](../figures/viz_pair_ch04_paired.png)

| Panel | Shows | Masks |
|-------|--------|-------|
| **Wrong** | Pre and post as two independent boxplots | Within-person correlation; paired estimand |
| **Right** | Dumbbell / paired segments | (supports paired *t* / Wilcoxon signed-rank) |


![method comparison panel](../figures/method_comparison_panel.png)

Side-by-side panels show how the same CASTOR subset looks under different comparison choices; use this to sanity-check pairing and outcome type before picking a test.

---

## Worked example: COPD trial FEV1

**Design:** Parallel RCT, n ≈ 200 per arm.
**Estimand:** Difference in mean FEV1 (litres) at 12 weeks (intervention − standard).
**Analysis:** Welch t-test (prespecified); linear model with baseline covariates as sensitivity.

**Results template:**

> Mean FEV1 was 3.85 L (SD 0.64) in the intervention arm and 3.76 L (SD 0.64) in standard care (n = 198 and 202). The mean difference was 0.09 L (95% CI −0.04 to 0.21; Welch t, p = 0.20). The difference is compatible with no effect and with clinically small benefits; this trial was not powered for a prespecified MCID of 0.10 L.

**Practice read:** not statistically significant; CI includes values that may or may not matter clinically.
**Statistician read:** non-significant p does not prove no effect - interval estimation preferred [@harrell2015rms].

---


## R lab

Run the full script:

```r
source("R/examples/ch04_comparing_groups.R")
```

Includes: Welch t, Wilcoxon, ANOVA, Tukey, ANCOVA, permutation test, power calculation, chi-square, Fisher, Cohen's d, paired bronchodilator test.

---

## Common pitfalls in respiratory research

1. **Mixed spirometry standards** - pre- vs post-bronchodilator compared across groups.
2. **Ignoring clustering** - patients within hospitals analysed as independent.
3. **Multiple endpoints** - fishing without multiplicity control.
4. **Mean vs median** - skewed ICU length-of-stay analysed with t-test on small n.
5. **Baseline imbalance** - unadjusted observational comparison of FEV1 by exposure.

---

## Alternatives & extensions (choose by data and design)

Chapter 4 covers the default comparisons. Use these alternatives when the **assumptions, design, or estimand** differ.

### Continuous outcomes: beyond “t vs Wilcoxon”

| Situation | Alternative | Why / note |
|---|---|---|
| Heavy tails/outliers | **Trimmed-mean tests** (e.g. Yuen) | Robust mean-like estimand; report trimming |
| Small n; unclear distribution | **Permutation test** (already in Ch 4) | Minimal assumptions; prespecify statistic |
| Want CI without formulas | **Bootstrap CI** | Bootstrap CI as optional sensitivity |
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
| **R (continuous)** | Mixed model: `lmer(outcome ~ arm + (1 \| cluster_id))` (Ch 18) |
| **R (binary/count)** | GEE with `cluster = cluster_id` or mixed GLMM |
| **Report** | Number of **clusters** and patients; ICC if reported; CI from cluster-aware model |
| **Avoid when** | Only 2–3 clusters (unstable); treating cluster members as independent (SE too small) |

**Plain language:** patients in the same ICU ward correlate; analyse at ward level or use a model that respects nesting.

**Precise language:** ignore clustering → anti-conservative SEs and inflated significance [@harrell2015rms].

**Practice read:** “n = 400 patients” may hide “8 wards”; ask how many **units** were randomised.

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

**Plain language:** same patient, two manoeuvres; use a **paired** test, not two independent groups.

**Practice read:** ATS/ERS BD reversibility uses within-patient change; do not split pre and post into fictional “groups.”

CASTOR paired example: `R/examples/ch04_comparing_groups.R` and Figure (`ch04_paired_bronchodilator.png`).

### Technique: Non-inferiority and equivalence trials {#technique-non-inferiority-and-equivalence-trials}

| | |
|---|---|
| **Answers** | Is the new therapy **not worse** than control by more than a prespecified margin? |
| **Outcome** | Continuous (FEV1 change), binary (exacerbation), or rate |
| **Design** | Parallel NI/ equivalence trial with **prespecified Δ** |
| **Assumptions** | Margin clinically justified; powered for NI (not superiority) |
| **Effect measure** | Mean difference vs margin; or proportion difference vs margin |
| **Methods** | Two one-sided tests (TOST); or 90% CI vs margin (common in NI) |
| **Report** | Margin Δ, NI conclusion yes/no, CI relative to Δ |
| **Avoid when** | Declaring equivalence from superiority *p* > 0.05 |

**Plain language:** “Not significantly different” ≠ “equivalent.” You must prespecify how much worse is acceptable.

**Practice read:** device and inhaler NI trials live or die on the **margin**, not the *p*-value from a superiority test.

#### Reporting template (non-inferiority, continuous FEV1)

**Methods:** The primary estimand was the mean difference in change from baseline FEV1 at 12 weeks (new therapy − control). Non-inferiority was prespecified with margin Δ = −0.10 L (one-sided α = 0.025). We used a two one-sided tests (TOST) procedure / 90% confidence interval against Δ.

**Results:** Mean difference = −0.03 L (90% CI −0.08 to 0.02). The upper bound of the CI was below Δ → **non-inferiority demonstrated** / exceeded Δ → **not demonstrated**.

**Do not say:** “Groups were equivalent because p = 0.34.”

NI trials: prespecify margin and CI-against-margin in the SAP.

### Design extensions (longitudinal and survival)

| Design feature | Why Ch 4 methods fail | Handbook chapter |
|---|---|---|
| Repeated measures | observations not independent | Ch 18 mixed models / GEE |
| Multi-centre clustering | SEs too small if ignored | Cluster-robust SE / `(1 \| centre)` ; this chapter + Ch 18 |
| Time-to-event endpoints | censoring | Ch 19 survival analysis |

### Equivalence (superiority test insufficient)

If the scientific goal is **equivalence** (two-sided margin), prespecify bounds and use an equivalence framework. A non-significant *p*-value from a superiority test is not evidence of equivalence [@harrell2015rms] ; use the [NI template above](#technique-non-inferiority-and-equivalence-trials).

## Catalog of wrong analyses (comparison chapter)

| # | Wrong | Right |
|---|-------|-------|
| 1 | t-test on binary exacerbation Y/N | Logistic / compare proportions |
| 2 | t-test on count of exacerbations | Poisson / NB |
| 3 | Ignore pairing in pre/post BD | Paired t or Wilcoxon signed-rank |
| 4 | ANOVA then all pairwise without plan | Prespecified contrasts or Tukey with multiplicity awareness |
| 5 | Claim equivalence from p > 0.05 | NI trial with prespecified margin (TOST) |
| 6 | Pool sites without clustering check | Mixed model `(1 \| centre)` or GEE (Ch 18) |
| 7 | Cluster RCT analysed with patient-level Welch *t* | Cluster-aware mixed model / GEE |

---

---

## Quick reference: methods in this chapter

Use the **[Master decision table](#master-decision-table)** for the full router. CASTOR primary (Case A): Welch *t* on week-12 FEV₁; report **mean difference + 95% CI** against prespecified MCID — not *p* alone.

## Exercises

[Chapter 4 exercises](../exercises/ch04_exercises.md); [Solutions](../solutions/ch04_solutions.md)

## Where we go next

The steering deck is filed, but Table 1 showed baseline FEV₁ imbalance across arms. Rivera asks whether the week-12 comparison should be adjusted. **Chapter 5** is that conversation — ANCOVA and linear models on continuous outcomes. If the secondary endpoint is exacerbation yes/no, stay in Part III but skip to **Chapter 6**; repeated visits are a different design entirely (Part VIII).

## Related chapters

| Chapter | When to open it |
|---------|------------------|
| [Chapter 3: Descriptive analysis](03-descriptive-analysis.md) | Table 1, plots, distribution checks |
| [Chapter 5: Linear models](05-linear-models.md) | ANCOVA, adjusted continuous associations |
| [Chapter 6: GLMs](06-generalized-linear-models.md) | Logistic, Poisson, count and binary outcomes |
| [Chapter 7: Model building](07-model-building.md) | Covariate choice, LASSO, prespecification |
| [Chapter 8: Validation & reporting](08-validation-reporting.md) | CONSORT, CIs, limits, calibration |
| [Chapter 11: Clustering](11-clustering.md) | Unsupervised subgroups — claim discipline |
| [Chapter 12: Case studies](12-case-studies.md) | Integrated CASTOR narratives A–E |
| [Chapter 13: Differential analysis & FDR](13-differential-analysis-fdr.md) | Omics discovery, BH-FDR |
| [Chapter 17: Integrated CASTOR-HD](17-integrated-castor-hd.md) | Full omics pipeline story |
| [Chapter 18: Longitudinal mixed models](18-longitudinal-mixed-models.md) | Repeated FEV₁, slopes, clustering |
| [Chapter 19: Survival analysis](19-survival-analysis.md) | Time to exacerbation, censoring |
| [Chapter 21: Causal inference](21-causal-inference.md) | Confounding, IPW, DAGs |

## Handbook resources

| Resource | When to use it |
|----------|----------------|
| [Appendix B: Quick reference](../appendix-b-quick-reference.md) | Choose a test or model by outcome and design |
| [Appendix I: Figure hygiene](../appendix-i-figure-hygiene.md) | Right vs wrong plot pairs for slides and papers |
| [METHOD_MAP](../METHOD_MAP.md) | Full method inventory and decision-tree text |

## Further reading

- Agresti, *An Introduction to Categorical Data Analysis* [@agresti2018introduction]
- Harrell, *Regression Modeling Strategies* - comparison and MCID context [@harrell2015rms]
- ATS/ERS spirometry standardisation [@graham2019spirometry]
- Welch (1947); Mann & Whitney (1947) - original test papers [@welch1947t; @mann1947test]

