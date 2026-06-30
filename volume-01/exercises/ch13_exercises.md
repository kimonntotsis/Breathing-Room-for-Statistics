# Chapter 13 Exercises: Differential analysis and FDR

**E13.1** Why is testing 1000 proteins at α = 0.05 a problem even if only 50 are "significant"?

**E13.2** What three columns must appear in a defensible DE/DA top table?

**E13.3** When would you distrust a volcano plot as "proof" of biology?

**E13.4** Why should RNA-seq use count models rather than a t-test on raw counts?

**E13.5** What does it mean when nominal *p* < 0.05 but all *q* > 0.05?

**Applied**

1. Run `source("R/examples/ch13_differential_fdr.R")`.
2. Open `volume-01/tables/ch13_proteomics_top_table.csv` and interpret the top 5 rows.
3. Compare proteomics vs RNA discovery counts at q < 0.05.
4. Write a Results paragraph using Template A.
5. Draft one honest sentence if proteomics yields zero BH discoveries.

[Solutions](../solutions/ch13_solutions.md)
