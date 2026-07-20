### Book-wide omics workflow (Chapters 13–17)

Use this sequence whenever features outnumber patients:

| Step | Action | Handbook chapter |
|------|--------|------------------|
| 1 | **Scientific question** and estimand (discovery vs confirmation) | Ch 1, 13 |
| 2 | **Sample and feature QC** (missingness, LOD, library size) | Ch 13, 14 |
| 3 | **Normalisation / transformation** (assay-appropriate; log rules) | Ch 13, Appendix L |
| 4 | **Design matrix** matches design (blocking for paired samples; no pseudoreplication) | Ch 13–15 |
| 5 | **Feature-wise modelling** with prespecified covariates | Ch 13 |
| 6 | **Multiplicity** (BH-FDR across tested features; separate from clinical endpoints) | Ch 13 |
| 7 | **Batch sensitivity** before biological claims | Ch 14 |
| 8 | **Stability and validation** (independent cohort, pre-registered shortlist) | Ch 16–17 |
| 9 | **Biological interpretation** (triangulation, not mechanism proof) | Ch 17 |

**Design-matrix rule:** paired samples need subject blocking; technical replicates are not biological replicates; batch adjustment must preserve the biological contrast; preprocessing and filtering for prediction must occur **without leakage** (Ch 9, 17).

**FDR reminder:** an adjusted *p*-value is not the probability that an individual finding is false; FDR pertains to the **procedure** across the tested family.
