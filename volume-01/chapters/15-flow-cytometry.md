# Chapter 15: Flow cytometry - from summaries to phenotyping

> **Part VI: High-dimensional biology and discovery**

## At a glance

| | |
|---|---|
| **Recurring datasets** | `data/flowcytometry_summary.csv`, `data/flowcytometry_cells_toy.csv` |
| **Format** | Technique cards + Caveats + Wrong analysis + Reporting ([template](../CHAPTER_TEMPLATE.md)) |
| **Main decisions** | (1) unit of analysis, (2) compositional constraints, (3) drift/batch, (4) inference vs visualization |
| **R** | `R/examples/ch15_flow_cytometry.R` |
| **Figures** | [FIGURE_INDEX](../FIGURE_INDEX.md) - `ch15_*.png` |
| **Templates** | [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md) |
| **Exercises** | [Chapter 15 exercises](../exercises/ch15_exercises.md) |

**Also see:** [Ch 14 batch](14-batch-effects.md), [Ch 17 pipeline](17-integrated-castor-hd.md)

---

## Investigator path (≈20 min)

1. [Why this chapter](#why-this-chapter) — participant-level inference
2. [Method choice at a glance](#method-choice-at-a-glance) — proportions vs cells
3. **Practice read** on pseudo-replication
4. [Wrong analysis](#wrong-analysis-) — modelling cells as patients
5. [Alternatives & extensions](#alternatives--extensions)

**Analyst read:** compositional plots, R lab below.

---

## Method choice at a glance

| Method | When to use | Why |
|--------|-------------|-----|
| **Participant-level proportions** | Compare arms on cell-type fractions | One row per person; defensible inference |
| **Median / mean proportion by group** | Simple arm comparison | Clear estimand; report n participants |
| **Linear model on proportions** | Adjust for covariates | Watch compositional constraint (sum to 1) |
| **Compositional (log-ratio) transforms** | Formal compositional data analysis | Accounts for closure; specialist |
| **Per-cell mixed models** | Rare; cells nested in patients | Harder to interpret than summaries |
| **Drift plot by batch/run** | QC before biology | Technical drift mimics disease ([Ch 14](14-batch-effects.md)) |
| **UMAP / PCA on cells** | Exploratory gating QC | Descriptive only; not primary inference |

**Extensions:** Dirichlet models in [Alternatives & extensions](#alternatives--extensions).

---

## Learning objectives

1. Choose the correct **unit of analysis**: participant-level summaries vs cells.
2. Recognise **compositional constraints** when proportions sum to 1.
3. Compare groups on cell-type proportions with interpretable effect measures and drift adjustment.
4. Use embeddings/clustering as **descriptive** tools unless validated.
5. Avoid **pseudo-replication** and "UMAP as evidence" claims.
6. Apply multiplicity control when testing many cell types (Ch 13 link).

## Prerequisites

Ch 4 (comparisons), Ch 5 (linear models), Ch 13 (multiplicity), Ch 14 (batch/drift logic).

---

## Why this chapter

Flow data are beautiful and easy to mis-analyse. A stunning UMAP is not evidence; pooling cells as if they were patients is pseudo-replication. This chapter keeps immune phenotyping at the **participant** level where results can be interpreted in plain language.

## Opening question

*Do cases differ in immune composition - and can we say it without turning UMAP into "evidence"?*

Flow cytometry invites a common error: using an appealing picture (embedding) as a statistical result. This chapter separates:

- **Inference** (estimates + uncertainty on **participant-level** summaries) from
- **Visualization** (embeddings, clustering, gating diagnostics).

---

## The flow analysis workflow

1. **Panel & gating**: document manual or algorithmic strategy.
2. **Summarise per participant**: proportions and/or median intensities.
3. **Drift QC**: plot by batch/run day ([Ch 14](14-batch-effects.md)).
4. **Primary models**: participant-level `lm` or beta regression on prespecified cell types.
5. **Multiplicity**: BH across cell types if many tested (Ch 13).
6. **Embeddings**: UMAP/PCA for QC only unless validated.

---

## Worked mini-case: cells vs participants (pseudo-replication)

The chapter script compares two analysis units on the same CASTOR-HD toy per-cell file.

### Case A (correct): participant-level summaries

| Step | What you do |
|---|---|
| 1 | Gate or classify cells **within each participant** |
| 2 | Compute **one proportion per participant** per cell type (e.g., % monocytes) |
| 3 | Compare groups using **n = number of participants** |
| 4 | Adjust for drift (run day/batch) when measured |
| **n in CASTOR-HD** | 120 participants in `flowcytometry_summary.csv` |

**Practice read:** "Among 120 people, cases had a higher median monocyte fraction" - this is the claim you can defend.

### Worked example (CASTOR-HD participant models)

From `ch15_flow_effects_by_celltype.csv` (logit scale, batch-adjusted, *n* = 120 participants):

| Cell type | Logit difference (case vs control) | *q* (BH) | Interpretation |
|-----------|-----------------------------------|----------|----------------|
| Mono | +0.81 | 0.025 | Higher monocyte proportion in cases |
| NK | +0.63 | 0.030 | Higher NK proportion in cases |
| CD8_T | −0.58 | 0.060 | Suggestive lower CD8 (borderline FDR) |
| CD4_T | −0.12 | 0.60 | No FDR evidence |

Report **participant *n***, not cell event counts. The pseudo-replication demo in the chapter script shows pooled-cell *p*-values far smaller than participant-level models for the same comparison.

### Case B (wrong): per-cell analysis as if independent

| Step | What people do (wrong) |
|---|---|
| 1 | Pool all cells across participants |
| 2 | Run a test comparing case vs control **cells** |
| 3 | Report **n = thousands of cells** and tiny p-values |
| **Why it fails** | Cells from the same person are correlated; SEs are far too small |

**Practice read:** "We studied 6,000 cells" sounds impressive but does **not** mean 6,000 independent patients.

### Teaching demonstration (script output)

The script fits the same group comparison twice:

1. **Participant model:** `lm(logit(prop_Mono) ~ group + batch)` on `flowcytometry_summary.csv` (n ≈ 120)
2. **Pseudo-replication model:** `lm(CD14 ~ group)` on pooled cells (n ≈ thousands)

The pseudo-replication model will show a much smaller p-value and misleading precision. **Do not report Case B as confirmatory inference.**

### Decision rule

| Question | If yes → |
|---|---|
| Is each row a **cell**? | Summarise to participant first (unless using a proper mixed model with random intercepts for patient) |
| Do proportions **sum to 1**? | Treat compositional structure explicitly or interpret one cell type at a time with caution |
| Is drift (run day) recorded? | Plot by batch; include in model (Ch 14 mindset) |
| Are you showing UMAP/t-SNE? | Label as **descriptive**; support with participant summaries |

---

## Technique: Participant-level summary analysis (default)

### Technique card

| | |
|---|---|
| **Answers** | Are cell-type proportions / marker medians different between groups? |
| **Outcome type** | proportions (0-1), continuous marker summaries |
| **Design** | independent groups; can adjust for covariates and drift |
| **Unit of analysis** | **one row per participant** |
| **Effect measure** | difference in mean proportion; logit-scale difference; median difference |
| **R** | `lm(logit(p) ~ group + batch)` (simple) or beta regression (advanced) |
| **When to use** | primary reporting; transparent; supports CI and covariates |
| **When NOT to use** | claiming new cell types from one embedding |
| **Does NOT prove** | mechanistic cell identity; causal immune pathways |

### Dual interpretation

**Plain language:** we compared the fraction of each major immune population between groups.

**Precise language:** we modelled participant-level proportions, accounting for drift, and reported effect sizes with uncertainty.

**Practice read:** these summaries are interpretable (e.g., "higher monocyte fraction"), but they are not a replacement for validated immunophenotyping.

### Caveats box

| Caveat | Why it matters |
|--------|----------------|
| Compositional constraints | proportions sum to 1; changes are not independent |
| Drift and instrument settings | day effects can mimic disease differences |
| Gating subjectivity | manual gating is a measurement process; report it |
| Rare populations | instability and zero inflation; avoid overinterpretation |
| Multiple comparisons | many cell types/markers -> multiplicity (Ch 13) |
| Unit of analysis | do not treat cells as independent patients |

### In practice

A flow core returns 50,000 events per patient and a beautiful t-SNE. Summarise to participant proportions first; show the embedding in supplementary material as QC.

### Wrong analysis ⚠

| | |
|---|---|
| **Mistake** | Treat 6000 cells as n = 6000 independent observations |
| **Why it fails** | pseudo-replication; SEs become meaningless |
| **Do instead** | summarise per participant (or use mixed models with care) |

| | |
|---|---|
| **Mistake** | Name clusters "new cell types" from one run of UMAP + k-means |
| **Why it fails** | embeddings distort distances; clustering is unstable |
| **Do instead** | call them "patterns", report stability, validate with markers/replication |

### Catalog of wrong analyses (flow cytometry)

| Wrong analysis | Why it fails | Do instead |
|---|---|---|
| **Pooled-cell t-test / logistic on cells** | Pseudo-replication inflates n and shrinks p-values | One summary per participant; n = participants |
| **Report cell count as sample size** | "n = 50,000 events" is not n = 50,000 people | Report participants and events per participant separately |
| **Ignore compositional constraint** | Increasing one population mechanically affects others | Interpret one type at a time; consider compositional methods if core question |
| **Compare proportions without drift check** | Run-day drift mimics group differences | Plot by batch; adjust when identifiable (Ch 14) |
| **UMAP separation = proof of disease subgroup** | Embedding is descriptive and unstable | Show participant summaries + marker validation |
| **Cherry-pick one cell type after scanning many** | Multiplicity without FDR | Prespecify populations or control FDR (Ch 13) |
| **Manual gating undisclosed** | Not reproducible; not auditable | Document gating strategy or algorithm + QC |
| **Rare population overclaim** | 0.1% subsets are noisy with small n | Report uncertainty; avoid mechanistic language |
| **Mixed model without random intercept for patient** | Still treats cells as exchangeable within patient incorrectly if misspecified | Patient random effect when modelling cells directly |
| **"Immune age" from one cohort** | Signature may track batch/site | External validation; drift diagnostics |

### Reporting template

Use Template C in [HIGH_DIM_REPORTING_TEMPLATES](../HIGH_DIM_REPORTING_TEMPLATES.md).

> Flow cytometry was performed on [panel]. Cells were gated [manual/algorithmic strategy]. For each participant we computed the proportion of [cell types] and median marker intensities. Group comparisons used participant-level models adjusting for run day/batch. Per-cell embeddings (PCA/UMAP) were used for **visual QC only**.

---

## Technique: Compositional structure (proportions sum to 1)

When you measure five cell-type proportions, they are **not independent**: if monocytes go up, something else must go down.

### Technique card

| | |
|---|---|
| **Answers** | How should we interpret changes in one population given the whole? |
| **When to use simple approach** | Prespecified primary population (e.g., % regulatory T cells) |
| **When to extend** | Core question is about **overall immune rebalancing** |
| **Alternatives** | compositional data analysis (log-ratio transforms), Dirichlet models (advanced) |
| **Does NOT prove** | which population "caused" the shift |

**Practical handbook rule:** for most respiratory papers, prespecify 1-3 populations for primary inference and treat the rest as exploratory.

---

## Technique: Per-cell visualization (secondary)

Embeddings (UMAP/t-SNE) and clustering can help you **see** structure and check gating, but they are not, by themselves, confirmatory inference.

**Rule:** if you show an embedding, also show participant-level summaries that support the claim.

![Cell-type proportions by group (participant-level)](../figures/ch15_flow_props_by_group.png)

Bars are participant means: the level at which group comparisons belong in a respiratory paper.

### Figure hygiene: participant vs cell-level inference

| Panel / figure | Right use | Wrong use |
|----------------|-----------|-----------|
| `ch15_flow_props_by_group.png` | Participant-level proportions by arm | — |
| `ch15_pseudoreplication_demo.png` | Teaching: why pooling cells inflates *p* | Inference at cell *n* |

![Pseudo-replication: participant vs pooled-cell p-values](../figures/ch15_pseudoreplication_demo.png)

Inflated significance when cells are pooled is the reason flow claims must stay at participant *n*.

---

## Alternatives & extensions

| Situation | Primary approach | Notes |
|---|---|---|
| Many cell types tested | FDR across populations (Ch 13) | prespecify primary endpoint |
| Strong drift | include batch + control beads QC | see Ch 14 overlap logic |
| Need single-cell discovery | clustering + stability (Ch 11 mindset) | do not call "endotypes" |
| Modelling cells directly | mixed model: `marker ~ group + (1\|patient_id)` | still harder to interpret than summaries |
| Compositional core question | log-ratio between prespecified types | advanced; document clearly |

### Mini-lab: beta regression pointer (proportions)

When proportions are bounded and skewed, `lm(logit(p) ~ ...)` is a teaching default. For publication, consider beta regression (`betareg` package) on (0,1) with jitter away from 0/1.

```r
# Teaching default (Ch 15 script):
fit <- lm(logit_mono ~ group + batch, data = flow_m)
```

---


## R lab: Flow cytometry on CASTOR-HD

**Script:** `R/examples/ch15_flow_cytometry.R`

Outputs:

- Participant proportions by group and batch (`ch15_flow_props_by_group.png`, `ch15_flow_props_by_batch.png`)
- **Compositional check:** stacked proportions (`ch15_compositional_stacked.png`)
- **Pseudo-replication demo:** participant vs pooled-cell p-values (`ch15_pseudoreplication_demo.png`)
- Per-cell PCA (descriptive): `ch15_flow_cells_pca.png`
- Summary table: `volume-01/tables/ch15_flow_mini_case_summary.csv`
- Effect table: `volume-01/tables/ch15_flow_effects_by_celltype.csv`

```r
source("R/00_setup.R")
library(tidyverse)

flow <- readr::read_csv(
  file.path(paths$data, "flowcytometry_summary.csv"),
  show_col_types = FALSE
)
table(flow$group, flow$batch)
```

### Sensitivity (minimum)

- Repeat the comparison for 2-3 cell types.
- Re-fit with and without `batch` and compare effect direction and magnitude.

### Niche figures (recommended)

- **Stacked compositional bars** by group (are shifts global rebalancing?)
- **Pseudo-replication contrast** (participant n vs cell n for the same comparison)

![Compositional structure: proportions sum to 1](../figures/ch15_compositional_stacked.png)

Shifts in one population often accompany opposite shifts elsewhere because proportions are bounded.

![Drift check: proportions by batch/day](../figures/ch15_flow_props_by_batch.png)

Batch-separated bars mean immunology and processing are confounded until drift is modelled or redesigned.

## Exercises ([Solutions](../solutions/ch15_solutions.md))

**E15.1** Why is pooling 6,000 cells as n = 6,000 wrong?

**E15.2** Name one compositional constraint when interpreting flow proportions.

**E15.3** When is a UMAP figure acceptable in a paper?

**E15.3** When is a UMAP figure acceptable in a paper?

**E15.4** Why prespecify 1–3 cell types for primary inference?

**Applied**

1. Run `source("R/examples/ch15_flow_cytometry.R")`.
2. Compare participant vs pooled-cell p-values in `ch15_pseudoreplication_demo.png`.
3. Interpret monocyte results in `volume-01/tables/ch15_flow_effects_by_celltype.csv`.
4. Write a Results sentence for monocyte proportion difference with batch adjustment.
5. State the unit of analysis in one Methods sentence.

---

## Where this chapter leads

**Next:** [Chapter 16](16-antibody-discovery.md) for confirmation assays; [Chapter 17](17-integrated-castor-hd.md) for the full CASTOR-HD story.

## Further reading

- Roederer & Moody flow cytometry guidelines; [Ch 14](14-batch-effects.md) for drift

## Chapter summary

- Default unit of analysis: **participant-level summaries**.
- **Pseudo-replication** (cells as n) produces false precision.
- **Compositional** structure matters when interpreting proportions.
- **Drift** diagnostics are mandatory (Ch 14 logic applies).
- Embeddings are for **QC and exploration**, not standalone proof.
