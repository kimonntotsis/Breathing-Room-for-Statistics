# Part VI: High-dimensional biology and discovery {.unnumbered}

This part extends the handbook workflow to datasets where \(p \gg n\) and technical variation can dominate biology:

- **Proteomics** (e.g. Olink-style panels): missingness near limits of detection, plate effects, multiplicity (FDR).
- **RNA** (gene counts): count models, library size, normalization, differential expression, FDR.
- **Flow cytometry**: summaries vs per-cell data, drift, gating vs automated phenotyping.
- **Discovery screens** (antibodies): replicate agreement, hit calling, confirmation, ranking stability.

The goal is not to memorise methods. It is to make defensible claims:

1. **What changed (effect size)?**
2. **How uncertain is it (CI / stability)?**
3. **How many chances did we give ourselves to be wrong (FDR / multiplicity)?**
4. **Could this be technical (batch / plate / run)?**
5. **Does it generalise (honest validation / confirmation)?**

**Recurring datasets:** the CASTOR-HD synthetic files in `data/` (see [Ch 2](../chapters/02-respiratory-data.md) and [RECURRING_COHORT](../RECURRING_COHORT.md)).

