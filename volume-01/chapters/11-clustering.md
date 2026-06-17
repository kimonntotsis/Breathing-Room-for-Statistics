# Chapter 11: Clustering and Phenotype Discovery

> **Part VI: Structure Discovery**

## At a glance

| | |
|---|---|
| **Recurring cohort** | [CASTOR](RECURRING_COHORT.md) - `data/marker_panel.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Methods** | k-means, hierarchical, PAM, silhouette, bootstrap stability, validation ladder |
| **R** | `R/examples/ch11_clustering.R` |
| **Figures** | [FIGURE_INDEX](../FIGURE_INDEX.md) - `ch11_*.png` |
| **Navigation** | [QUICK_REFERENCE](../QUICK_REFERENCE.md) · Endotype ladder §11.6 · [REFERENCES](../REFERENCES.md) |
| **Exercises** | [ch11](../exercises/ch11_exercises.md) |

## Learning objectives

1. Distinguish unsupervised clustering from supervised classification.
2. Apply k-means, hierarchical, and PAM methods with appropriate scaling.
3. Choose *k* with silhouette, domain knowledge, and bootstrap stability - not post hoc storytelling.
4. Navigate the **endotype claim ladder**: exploratory clusters → replication → clinical utility.
5. Recognise batch effects, circularity, and overclaiming in respiratory phenotype papers.

## Prerequisites

Chapter 10 (PCA). Clustering on principal components is covered in §11.11.

---

## Opening question (CASTOR)

*Do CASTOR participants fall into distinct marker-based subgroups - and if so, what can we legitimately claim?*

Clustering finds **structure in measured variables**. It does not, by itself, prove **disease subtypes**, **endotypes**, or **treatment-responsive groups**. Those require a validation path this chapter makes explicit.

> **For participants:** “We looked for groups of patients with similar laboratory marker patterns. We do not yet know whether these groups need different treatments - that requires further studies.”

---

## Clustering vs classification

| | Clustering (unsupervised) | Classification (supervised) |
|---|---|---|
| **Uses outcome label?** | No | Yes |
| **Goal** | Discover groups of similar patients | Predict a known label |
| **CASTOR example** | k-means on M1-M30 | Logistic model for 12-month exacerbation (Ch 9) |
| **Typical claim** | “Exploratory subgroups” | “Predictor of outcome” |
| **Validation** | Replication, stability, external cohort | Cross-validation, calibration, TRIPOD [@moons2015tripod] |

**Clinician read:** clustering is hypothesis-generating. It does not replace a diagnostic label or a validated risk score.

---

## Technique: k-means clustering

### Technique card

| | |
|---|---|
| **Answers** | Partition *n* patients into *k* groups minimising within-cluster variation |
| **Input** | Continuous features; **scale** when units differ |
| **Requires** | *k* specified in advance; reasonable *n* per cluster |
| **Assumptions** | Roughly spherical, similar-sized clusters; Euclidean distance meaningful after scaling |
| **R** | `kmeans(X, centers = k, nstart = 25)` |
| **When to use** | Exploratory phenotyping; moderate *n*; compact clusters |
| **When NOT to use** | Confirmatory proof of endotypes; elongated or irregular geometry |
| **Does NOT prove** | Validated endotype, causal mechanism, or differential treatment response |

### Dual interpretation

**Plain language:** split patients into *k* subgroups with the most similar marker profiles.

**Precise language:** iterative relocation to a local minimum of within-cluster sum of squares; random starts (`nstart`) reduce bad local optima.

**Clinician read:** useful for generating hypotheses about subgroups - not for changing care until replicated and linked to outcomes or treatment.

### Precise math (optional)

Minimise within-cluster sum of squares:

$$
\mathrm{WCSS} = \sum_{c=1}^{k} \sum_{i \in C_c} \| \mathbf{x}_i - \boldsymbol{\mu}_c \|^2
$$

where $\mathbf{x}_i$ is the scaled marker vector for patient $i$, $C_c$ is cluster $c$, and $\boldsymbol{\mu}_c$ is the cluster centroid (mean vector).

### Caveats box

| Caveat | Why it matters in respiratory research |
|--------|----------------------------------------|
| Choose *k* | Elbow, silhouette, and clinical priors disagree - document how *k* was chosen |
| Scale features | FEV1 (litres) and blood eosinophils (% or cells/µL) must not dominate by unit |
| Outliers | Single severe patients can pull centroids; consider PAM (§11.4) |
| CASTOR teaching | `true_phenotype` is for learning only - real studies have no ground truth |
| Outcome circularity | Never cluster on markers **and** FEV1, then claim clusters “predict” lung function |
| Small *n* | Asthma/COPD omics with *n* < 100 → unstable clusters; avoid “precision medicine” language |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Try *k* = 2…10 until clusters “look clinical” |
| **Why it fails** | Multiple testing on cluster definitions; best-looking *k* is overfit |
| **Do instead** | Prespecify *k*, use bootstrap stability (§11.8), report all *k* explored |

| | |
|---|---|
| **Mistake** | Title: “Discovery of two asthma endotypes” from k-means on *n* = 80 |
| **Why it fails** | No external replication or prospective treatment validation |
| **Do instead** | “Exploratory marker-based clusters; validation planned” |

### Reporting template

**Methods:** Thirty blood markers were *z*-scored. Exploratory k-means clustering (*k* = 2, 25 random starts) was applied. Mean silhouette width and bootstrap item stability (200 resamples) summarised cluster separation. External validation was not performed.

**Results:** Two clusters were identified (mean silhouette = 0.25; mean item stability = 0.XX). Cluster profiles differed on M1-M5 (Figure). Agreement with hierarchical clustering was high in CASTOR (adjusted Rand index ≈ 1.0); agreement with processing batch was low (technical confounding not detected).

**Do not say:** “validated endotype”, “definitive subtype”, “precision medicine target” (from one cohort).

### R lab

```r
source("R/examples/ch11_clustering.R")
```

![k-means clusters coloured by true phenotype (teaching only)](../figures/ch11_kmeans_clusters.png)

### Clinician “so what?”

**Would this change management today?** Almost always **no** - until clusters replicate elsewhere and predict treatment response in a trial. Treat as a research finding for hypothesis generation.

---

## Technique: Hierarchical clustering

### Technique card

| | |
|---|---|
| **Answers** | Nested hierarchy of patients via sequential merging (agglomerative) |
| **Input** | Scaled continuous features; distance matrix |
| **Linkage** | `Ward.D2` (compact clusters), `complete`, `average` |
| **R** | `hclust(dist(X), method = "ward.D2")`; `cutree(hc, k = k)` |
| **Output** | Dendrogram - cut at height to obtain *k* groups |
| **When to use** | Heatmaps; exploratory hierarchy; visualising nested structure |
| **When NOT to use** | Large *n* (memory *O*(*n*²)); when you need soft/probabilistic membership |
| **Does NOT prove** | Optimal partition - early merges are irreversible |

### Dual interpretation

**Plain language:** build a family tree of patients from most similar to most different; cut the tree to get *k* groups.

**Precise language:** greedy agglomerative algorithm on pairwise distances; Ward minimises increase in within-cluster variance at each merge.

**Clinician read:** dendrograms are excellent for exploration and heatmaps; the cut height is subjective - agree *k* or validation criteria in advance.

### Precise math (optional)

Ward linkage merges clusters *A* and *B* that minimise the increase in total within-cluster sum of squares when combined. Distances between clusters depend on linkage rule - **different rules → different trees**.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Cut height | No unique “correct” cut - document *k* or height used |
| Linkage choice | `complete` vs `Ward.D2` can yield different clinical stories |
| Irreversibility | An early wrong merge cannot be undone |
| CASTOR | With *n* = 120, hierarchical is feasible; omics studies with *n* > 2000 often cannot use full distance matrices |
| Batch | Dendrogram branches may reflect processing site, not biology |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Cut dendrogram until groups differ on outcome used to colour the plot |
| **Why it fails** | Circular - outcome informed the visual cut |
| **Do instead** | Prespecify *k* or cut height; validate on independent outcomes |

### Reporting template

**Methods:** Pairwise Euclidean distances on *z*-scored markers; agglomerative clustering with Ward.D2 linkage. Dendrogram cut at *k* = 2 for comparison with k-means.

**Results:** Hierarchical clustering yielded two groups (Figure: dendrogram). Adjusted Rand index vs k-means = 0.XX (partial agreement).

### R lab

```r
hc <- hclust(dist(X), method = "ward.D2")
cl_hc <- cutree(hc, k = 2)
plot(hc, labels = FALSE); rect.hclust(hc, k = 2, border = "red")
# See ch11_clustering.R - ch11_dendrogram.png
```

![Ward.D2 dendrogram with k = 2 cut](../figures/ch11_dendrogram.png)

---

## Technique: PAM (k-medoids)

### Technique card

| | |
|---|---|
| **Answers** | Partition into *k* clusters using **actual patients** as centres (medoids) |
| **Input** | Scaled continuous features; distance matrix |
| **R** | `cluster::pam(X, k = 2)` |
| **When to use** | Outliers present; need a **representative patient** per cluster |
| **When NOT to use** | Very high *p* with small *n*; when k-means speed is critical on huge *n* |
| **Robustness** | Medoids resist outliers better than k-means centroids |
| **Does NOT prove** | More “real” than k-means - still exploratory |

### Dual interpretation

**Plain language:** like k-means, but cluster centres are real patients, not averages.

**Precise language:** minimises sum of dissimilarities to nearest medoid (k-medoids); SWAP algorithm refines medoids.

**Clinician read:** medoid patients can be shown as “prototypes” in talks - but they are data points, not clinical archetypes until validated.

### Caveats box

| Caveat | Detail |
|--------|--------|
| Outliers | PAM is more robust than k-means but not immune |
| Speed | Slower than k-means for large *n* |
| CASTOR | Compare PAM vs k-means in method shootout (§11.10) |
| Interpretation | “Typical patient” narratives from medoids overstate certainty |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Present medoid case as “the eosinophilic asthma patient” |
| **Do instead** | “Representative of **this exploratory** cluster in **this** dataset” |

### Reporting template

**Methods:** PAM (k = 2) on *z*-scored markers as sensitivity to k-means.

**Results:** PAM agreed with k-means on XX% of patients (adjusted Rand index = …).

---

## Technique: Choosing *k* (silhouette)

### Technique card

| | |
|---|---|
| **Metric** | Silhouette width ∈ [−1, 1]; higher = better separation |
| **Formula (patient *i*)** | $(b_i - a_i) / \max(a_i, b_i)$ where $a_i$ = mean distance to own cluster, $b_i$ = mean distance to nearest other cluster |
| **R** | `cluster::silhouette(cl, dist(X))`; compare mean width across *k* |
| **Use** | Compare candidate *k* values alongside domain knowledge |
| **Does NOT prove** | Correct *k* - geometry-dependent |

### Dual interpretation

**Plain language:** measures how well each patient fits their cluster vs the next-nearest cluster.

**Precise language:** average point-wise silhouette; favours compact, separated clusters.

**Clinician read:** a low silhouette (e.g. < 0.25) means groups overlap - do not force a crisp clinical narrative.

### Caveats box

| Caveat | Detail |
|--------|--------|
| Convex bias | Silhouette prefers spherical clusters |
| Best *k* on same data | Overfit if used to craft the publication story |
| Domain *k* | Sometimes *k* = 2 is prespecified (eosinophilic vs not) - silhouette is secondary |
| CASTOR | See `ch11_silhouette_k.png` for *k* = 2…6 |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Pick *k* with highest silhouette, then test clinical outcomes on same data |
| **Do instead** | Bootstrap stability (§11.8); external cohort for *k* and labels |

### Reporting template

**Results:** Mean silhouette was 0.25 (*k* = 2), 0.15 (*k* = 3), …; *k* = 2 was retained per prespecified plan [or: exploratory comparison only].

![Mean silhouette width by k](../figures/ch11_silhouette_k.png)

---

## The endotype claim ladder

This is the **governance framework** for respiratory phenotype papers. Most overclaiming happens by skipping rungs.

| Rung | What you did | Language allowed | Example |
|------|----------------|------------------|---------|
| **1 - Exploratory** | Cluster one cohort once | “Hypothesis-generating subgroups” | k-means on CASTOR markers |
| **2 - Stable** | Bootstrap / consensus / sensitivity analyses | “Internally stable clusters” | Item stability > 0.7 |
| **3 - Replicated** | Same structure in **independent** cohort | “Reproducible subgroups” | U-BIOPRED-style replication |
| **4 - Prognostic** | Clusters predict exacerbations/LRTI **not used in clustering** | “Prognostic phenotypes” | Cluster at baseline → future exacerbations |
| **5 - Predictive of treatment** | Differential treatment response in **RCT** | “Treatment-responsive endotype” (still cautious) | Biomarker-stratified trial |

**You may not use “endotype” in a title until rung 4-5 is credibly addressed.** Rung 1-2 alone → “exploratory clusters” [@wenzel2012asthma].

### Respiratory phenotype vocabulary (clinical names vs clustering)

Clinicians use rich labels; clustering may or may not recover them:

| Clinical construct | Common markers / features | Clustering caveat |
|--------------------|---------------------------|-------------------|
| **Th2-high asthma** | Eosinophils, FeNO, periostin | May map to one cluster - or overlap heavily |
| **Eosinophilic vs neutrophilic** | Blood/sputum cell counts | Requires validated thresholds, not just k-means |
| **Pauci-granulocytic asthma** | Low inflammation markers | Often a heterogeneous residual cluster |
| **COPD emphysema-dominant** | Low DLCO, low FEV1/FVC | Imaging/clinical variables often needed - not blood panel alone |
| **ACOS overlap** | Asthma + COPD features | Mixed cluster ≠ validated ACOS diagnosis |

**Key sentence:** clinical phenotypes are **constructs**; unsupervised clustering is an **empirical partition**. Alignment must be demonstrated, not assumed.

---

## Technique: Validation hierarchy

| Level | Method | What it shows |
|-------|--------|---------------|
| **Internal** | Silhouette, bootstrap item stability, consensus clustering | Clusters not purely noise **in this sample** |
| **External** | Reproduce in independent cohort; transfer centroids/medoids | Structure generalises |
| **Clinical** | Prospective outcome or treatment interaction | Clusters matter for patients |

### Dual interpretation

**Plain language:** a cluster is only “real” if it shows up again and makes a difference clinically.

**Precise language:** unsupervised discovery requires out-of-sample replication and pre-specified validation endpoints - analogous to TRIPOD discipline for prediction models [@moons2015tripod; @hennig2007cluster].

**Statistician read:** report stability coefficients, not only pretty heatmaps [@hennig2007cluster].

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Internal stability only → “validated endotype” in abstract |
| **Why it fails** | Stability ≠ generalisation; batch can be stable but technical |
| **Do instead** | External cohort + prespecified clinical endpoints |

---

## Technique: Bootstrap cluster stability

### Technique card

| | |
|---|---|
| **Answers** | How often is each patient assigned to a consistent cluster under resampling? |
| **Method** | Resample rows with replacement → re-cluster → item stability |
| **R** | See `bootstrap_item_stability()` in `ch11_clustering.R` |
| **Report** | Mean (and min) item stability across patients |
| **When to use** | Before naming subgroups in a paper |
| **Does NOT prove** | External validity |

### Reporting template

**Methods:** Bootstrap resampling (*B* = 200) with k-means (*k* = 2) at each draw; item stability = proportion of draws with same cluster assignment after **label alignment** (cluster numbers are arbitrary across runs) [@hennig2007cluster].

**Results:** Mean item stability = 0.78 (range 0.52-0.94). Low-stability patients flagged for sensitivity analysis.

---

## Technique: Heatmaps and batch effects

### Technique card

| | |
|---|---|
| **Answers** | Visualise patient × marker matrix with joint clustering |
| **Input** | Scaled expression/abundance matrix |
| **R** | `pheatmap::pheatmap()`, `heatmap()`, or `ComplexHeatmap` |
| **When to use** | Omics exploration; supplement to quantitative validation |
| **When NOT to use** | Sole evidence for biological subgroups |
| **Does NOT prove** | Causal biology - batch can dominate colour patterns |

### Dual interpretation

**Plain language:** a coloured grid showing which markers are high/low in which patients.

**Precise language:** reorder rows/columns by hierarchical clustering for visual coherence; structure may reflect technical artefacts.

**Clinician read:** if colours align with processing site rather than diagnosis, stop - fix batch before interpreting biology.

### Caveats box

| Caveat | CASTOR teaching |
|--------|-----------------|
| **Batch effects** | `processing_batch` (SiteA/SiteB) shifts M26-M30 - check before claiming biology [@mcshane2011biomarker] |
| **Double clustering** | Row + column cluster simultaneously → pretty but hard to validate |
| **Scale** | Log-transform and scale omics before heatmaps |

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Heatmap shows site-specific stripes → “two inflammatory endotypes” |
| **Do instead** | Batch correction or include batch in sensitivity; replicate externally |

### R lab

```r
table(km$cluster, omics$processing_batch)  # from ch11_clustering.R
```

---

## Method shootout (CASTOR)

Run multiple algorithms on the **same scaled markers** and compare - humility is the point.

| Comparison | Adjusted Rand index (illustrative) |
|------------|-------------------------------------|
| k-means vs hierarchical | Partial agreement expected |
| k-means vs PAM | Often high |
| k-means vs `true_phenotype` | Teaching only - never available in practice |
| k-means vs `processing_batch` | **High ARI = red flag** (technical not biological) |

```r
source("R/examples/ch11_clustering.R")  # prints shootout table
```

**Interpretation:** partial agreement between algorithms is normal. Perfect agreement with batch is a warning, not a discovery.

---

## Cluster in PC space vs all markers

Chapter 10 reduced 30 markers to a few components. Clustering on **5 PCs** often:

- reduces noise,
- improves stability,
- matches full-marker clustering reasonably well.

```r
# In ch11_clustering.R: ARI between k-means on 5 PCs vs all 30 markers
```

**Wrong analysis ⚠:** PCA on full data including outcome, then cluster on PCs, then test outcome - circular. Fit PCA on markers only; hold outcomes for external validation.

---

## Modern alternatives (pointers, not full treatment)

When k-means is too brittle, escalate deliberately:

| Method | Strength | Chapter |
|--------|----------|---------|
| **Latent class analysis (LCA)** | Mixed discrete/continuous; probabilistic membership | Ch 11 extensions |
| **Gaussian mixture models** | Soft clustering; model-based *k* | Ch 11 extensions |
| **Consensus clustering** | Stability across algorithms and *k* | Mention in sensitivity |
| **DBSCAN / HDBSCAN** | Irregular shapes; noise points | When domain suggests |

**Rule:** name the method in Methods; do not switch post hoc to the algorithm that “looks best” without disclosure.

---

## CASTOR worked example (end-to-end)

**Question:** Are there marker-based subgroups in CASTOR?

**Steps:**

1. *z*-score M1-M30.  
2. k-means *k* = 2, `nstart = 25`.  
3. Silhouette for *k* = 2…6 (`ch11_silhouette_k.png`).  
4. Bootstrap item stability (*B* = 200).  
5. Compare k-means, hierarchical, PAM (shootout table).  
6. Cluster profiles on M1-M5 (`ch11_cluster_profiles.png`).  
7. Check `processing_batch` confounding.  
8. Compare clustering on 5 PCs vs 30 markers.  
9. Compare to `true_phenotype` (**teaching only**).

**Claims allowed:** “Two exploratory clusters with moderate silhouette and reasonable bootstrap stability; partial alignment with prespecified marker contrasts on M1-M5.”

**Claims NOT allowed:** “Validated COPD endotypes ready for stratified care.”

**Results paragraph (template):**

> Among 120 participants with 30 blood markers, exploratory k-means (*k* = 2) identified two clusters (mean silhouette 0.25; mean bootstrap item stability 0.XX). Cluster profiles differed on M1-M5 (Figure). Agreement with hierarchical clustering was high (adjusted Rand index ≈ 1.0). Clusters were not aligned with processing site (adjusted Rand index ≈ 0.0); external validation and outcome linkage were not performed.

![Mean marker levels by cluster (M1-M5)](../figures/ch11_cluster_profiles.png)

---

## Catalog of wrong analyses (respiratory-specific)

| Wrong | Why it fails | Do instead |
|-------|--------------|------------|
| Cluster on markers **and** FEV1, then “predict” lung function | FEV1 defined groups | Cluster on markers only; test FEV1 externally |
| Enriched trial from exploratory clusters only | No prospective validation | Rung 5 ladder; prespecify in protocol |
| “Precision medicine” from *n* = 80 | Underpowered for care pathways | Exploratory language; plan replication |
| Latent class on symptoms, then test same biomarkers | Same circularity | Hold out validation markers |
| Ignore `processing_batch` | Technical clusters | Batch correction / sensitivity |
| Endotype in title, rung 1 only | Overclaiming | “Exploratory subgroups” |
| *k* chosen post hoc | Overfit | Document all *k* tried; bootstrap stability |

---

## Explaining to patients and general readers

> “We used computer methods to look for groups of patients with similar test results. This helps researchers form new hypotheses. It does **not** mean we have new diagnoses or that your treatment should change today. Further studies must check whether these groups behave differently over time or respond differently to medicines.”

---

## Chapter summary

- Clustering is **exploratory unsupervised** learning - not classification, not causal inference.
- k-means, hierarchical, and PAM answer different robustness/structure needs; **compare them**.
- The **endotype claim ladder** governs language: exploratory → stable → replicated → prognostic → treatment-responsive [@wenzel2012asthma].
- **Bootstrap stability**, batch checks, and PC-space clustering are modern minimum standards before naming subgroups [@hennig2007cluster].
- Respiratory phenotype names (Th2-high, eosinophilic, etc.) are clinical constructs - demonstrate alignment, do not assume it.

## Further reading

- Hennig, cluster stability assessment [@hennig2007cluster]  
- Wenzel, asthma phenotypes and endotypes [@wenzel2012asthma]  
- McShane et al., biomarker study reporting [@mcshane2011biomarker]  
- Jolliffe & Cadima, PCA (preprocessing for clustering) [@jolliffe2016pca]

## Exercises · [Solutions](../solutions/ch11_solutions.md)

**Next:** [Chapter 12 - Integrated case studies](12-case-studies.md)
