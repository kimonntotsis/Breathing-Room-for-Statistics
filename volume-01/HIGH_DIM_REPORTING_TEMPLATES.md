# Reporting templates: high-dimensional biology (proteomics, RNA, flow, antibody screens)

Use these as copy/paste scaffolds for Results/Methods. Replace bracketed placeholders.

---

## Template A: Differential abundance / expression (many features + FDR)

**Question:** Which features differ between groups, by how much, with uncertainty?

**Methods (1 paragraph)**

> We analysed [proteomics/RNA] measurements from [N] samples ([n_case] cases, [n_ctrl] controls). Measurements were [NPX/log2(counts per million)] and were processed by [normalization approach] with batch variables ([batch variables]) handled by [include as covariate / remove unwanted variation / ComBat]. For each feature, we fit a [linear model / negative binomial model] with predictors [group + covariates], reporting effect sizes as [log2 fold-change / mean difference] and 95% confidence intervals. We controlled the false discovery rate using the Benjamini-Hochberg procedure at q < [0.05]. Analyses were performed using the synthetic CASTOR-HD datasets and are fully reproducible from `data/*.csv`.

**Results (core paragraph)**

> Compared with controls, cases showed [direction] differences in [pathway/theme]. At FDR q < [0.05], [K] of [P] features were differentially [abundant/expressed]. The largest effects included [Feature1] (effect [estimate], 95% CI [..], q = [..]) and [Feature2] (effect [estimate], 95% CI [..], q = [..]). Effect sizes were interpreted on the [log2 / original] scale and are reported with uncertainty rather than p-values alone.

**Results (robustness / sensitivity paragraph)**

> Results were [consistent/sensitive] to [normalization choice / batch handling], with [K’] discoveries overlapping ([%]) between approaches. No single batch dominated the discoveries, and QC plots (PCA and sample-level diagnostics) did not indicate residual batch structure after adjustment.

**Reporting checklist**

- **Outcome scale**: what does the effect size mean?
- **Multiplicity**: report FDR method and threshold (BH q-value).
- **Batch/plate/run**: explicitly state whether corrected and how.
- **Leakage rule**: any normalization/correction done within the resampling loop if predictive.
- **Share**: ranked table with effect, CI, q-value (top 20 + full supplement).

---

## Template B: High-dimensional prediction (p >> n) with honest validation

**Question:** Can we predict [clinical outcome] from high-dimensional measurements?

**Methods (short)**

> We developed prediction models for [outcome] using [proteomics/RNA/flow summary] features. All preprocessing steps that use information across samples ([normalization, batch adjustment, feature filtering/selection]) were performed **within** resampling to avoid information leakage. We used [nested cross-validation / repeated cross-validation] to tune hyperparameters for [elastic net / random forest / gradient boosting], reporting discrimination as AUC (95% CI via bootstrap) and calibration via [calibration slope / calibration curve]. We prespecified the primary metric as [AUC / Brier score] and report full model performance rather than best-case results.

**Results (short)**

> The [model] achieved AUC [..] (95% CI [..]) with calibration slope [..]. Performance was [similar/different] across batches ([summary]) and degraded when evaluated on [held-out batch / pseudo-external split], suggesting [batch sensitivity / limited transportability]. Feature importance rankings were unstable/stable under bootstrap, and we therefore interpret the model as [predictive tool / exploratory signal] rather than a definitive biomarker panel.

**Reporting checklist**

- **Data split**: define training/validation and whether external validation exists.
- **Leakage**: confirm preprocessing and feature selection were inside CV.
- **Calibration**: always report at least one calibration diagnostic.
- **Stability**: bootstrap selection frequency for top features.
- **Intended use**: triage vs diagnosis vs mechanistic inference (do not mix).

---

## Template C: Flow cytometry (gating vs automated phenotyping)

**Question:** Are cell populations or marker intensities different between groups?

**Methods (short)**

> Flow cytometry data were summarised per participant as [cell-type proportions / marker medians] using a prespecified panel ([markers]) and QC thresholds. Batch/day effects were assessed using [QC plots / control beads] and handled by [include batch covariate / normalize]. Group differences in cell-type proportions were estimated using [beta regression / logit-transformed linear model] with [covariates]. For automated phenotyping, we used [clustering/embedding] for visualization and report cluster stability under bootstrap rather than naming clusters as biological cell types.

**Results (short)**

> Cases had [higher/lower] [cell type] proportions (difference [..], 95% CI [..]) and [higher/lower] median [marker] intensity (difference [..]). Automated clustering identified [k] clusters; however, stability analysis showed [..], so cluster labels are presented as descriptive patterns rather than definitive subsets.

**Reporting checklist**

- **Panel + gating**: exact markers and gating strategy (or algorithm).
- **Batch drift**: whether present and what was done.
- **Summary definition**: proportion vs counts vs medians.
- **Interpretation**: visualization ≠ inference (UMAP/t-SNE are descriptive).

---

## Template D: Antibody discovery screens (hit calling + confirmation)

**Question:** Which clones are “hits” and how stable are rankings?

**Methods (short)**

> Screening assays measured binding signals for [N] clones against [antigen(s)] with [R] technical replicates. We defined primary screen signal as the replicate mean and assessed replicate agreement using [correlation / Bland-Altman]. Hits were called using a prespecified threshold of [..] relative to controls, and top-ranked clones were advanced to confirmation assays measuring [KD / functional readout]. We report the positive predictive value of the screen by comparing screen hits to confirmation positives and quantify ranking stability using bootstrap resampling of replicates.

**Results (short)**

> The screen identified [K] candidate binders to [Ag], of which [k_confirm] were confirmed (PPV [..]). Replicate agreement was [..]. Ranking stability analysis showed that [top 10] clones were [stable/unstable] under replicate resampling; therefore, we interpret small rank differences as noise and report candidates in tiers rather than a strict 1..K ranking.

**Reporting checklist**

- **Threshold**: prespecified hit criterion and negative/positive controls.
- **Replicates**: agreement and how combined.
- **Confirmation**: definition of “confirmed positive” (KD cutoff, etc.).
- **Stability**: tiers rather than exact ranks when unstable.

