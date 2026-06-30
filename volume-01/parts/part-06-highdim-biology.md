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

**Read this if:** you analyse or interpret proteomics, RNA-seq, flow cytometry, or antibody screens; you review omics Methods sections; or you need FDR and batch vocabulary.

**Skip this if:** you work only on spirometry and exacerbation endpoints. [Appendix H](appendix-h-clinicians-route.md) may be enough; return here when omics or flow data appear.

## CASTOR vignette: the omics email

At the start of the week: “We have 1,000 proteins and 200 DE hits.” After batch QC, the FDR-controlled list may be empty, and that is the honest result to report. **Part VI** walks proteomics, RNA, flow, and antibody screens with the same question: what are we willing to fund for validation?


