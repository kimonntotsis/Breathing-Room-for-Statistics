# Chapter 20 Solutions

**E20.1** Missingness depends only on observed data (given variables in the model), not on the unobserved missing value itself.

**E20.2** Complete-case samples are healthier; smoking–FEV1 association shifts toward less severe disease.

**E20.3** It fixes uncertainty at zero and does not propagate imputation variance; use MICE + pooling.

**E20.4** Enrolled *n*, analysed *n*, exclusions, and reasons; missing outcome/covariates by group where possible.

**E20.5** Otherwise test labels or future information leak into training, inflating performance.

**E20.6** Example: sputum proteomics only collected in participants who produced sputum. Structural: do not impute to non-producers unless the estimand explicitly requires it and science supports it.

**Applied** Enrolled 400, analysed 357 (43 missing FEV1). Complete-case smoking coef ≈ −0.40 L vs median impute ≈ −0.36 L; direction same, magnitude differs.
