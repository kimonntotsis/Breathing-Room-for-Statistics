# Chapter 12 solutions

## E12.1 (Case A)
**Estimand:** mean FEV1 difference at 12 weeks. **Test:** Welch t (prespecified). **Sentence:** "Mean FEV1 differed by 0.09 L (95% CI −0.04 to 0.21; n = 400); inconclusive vs MCID 0.10 L."

## E12.2 (Case B)
Unmeasured confounding: adherence, socioeconomic factors, disease severity not fully captured. Cannot claim smoking **causes** exacerbation.

## E12.3 (Case C)
Unsupervised clusters on one dataset may reflect noise; no external replication or outcome validation → not "validated endotypes."

## E12.4 (Case E)
Mixed models estimate **FEV1 trajectory** over scheduled visits (continuous, repeated measures). Cox PH estimates **time to first exacerbation** with censoring: a different outcome scale and estimand. Linking them narratively is fine; merging them into one statistical model is not.

## Applied

```r
source("R/examples/ch12_case_a_trial.R")
source("R/examples/ch12_case_b_exacerbation.R")
source("R/examples/ch12_case_c_phenotypes.R")
source("R/examples/ch12_case_e_longitudinal_survival.R")
```

Write one paragraph per case using Results templates in Chapter 12.

## Synthesis checklist

Complete all items in §12.3 for your own dataset before treating analysis as publication-ready.
