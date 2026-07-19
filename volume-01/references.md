# References

> **Quarto build:** formatted cited-reference list → [`references.qmd`](references.qmd) (appendix in PDF/HTML). Render with `quarto render` from `volume-01/`.

Curated reading list by topic. BibTeX keys match `references.bib` for Quarto/PDF builds (`[@key]` syntax).

---

## Core textbooks

| Topic | Reference | Key |
|-------|-----------|-----|
| Regression strategy | Harrell, *Regression Modeling Strategies* (2nd ed.) | `harrell2015rms` |
| Categorical data | Agresti, *Introduction to Categorical Data Analysis* (3rd ed.) | `agresti2018introduction` |
| Applied R / GLMs | Venables & Ripley, *Modern Applied Statistics with S* | `venables2002modern` |
| Statistical learning | James et al., *Introduction to Statistical Learning* (2nd ed.) | `james2023ISL` |
| Biostatistics with R | Stoltzfus, *Biostatistics for Health and Biological Science Users of R* | `stoltzfus2019biostatistics` |
| Count data | Hilbe, *Modeling Count Data* | `hilbe2014count` |

---

## Reporting guidelines

| Guideline | Use when | Key |
|-----------|----------|-----|
| **CONSORT 2010** | Randomised trials | `schulz2010consort` |
| **STROBE** | Observational cohorts, case–control | `vonelm2007strobe` |
| **TRIPOD** | Prediction model development/validation | `moons2015tripod` |
| **RECORD** | Routinely collected health data | `benchimol2015record` |

See [Ch 8: Validation & reporting](chapters/08-validation-reporting.md).

---

## Respiratory methods & endpoints

| Topic | Reference | Key |
|-------|-----------|-----|
| COPD research questions (ATS/ERS) | Celli et al., 2015 | `celli2015copdresearch` |
| Spirometry standardisation | Graham et al., 2019 (ATS/ERS) | `graham2019spirometry` |
| Exacerbation definitions in COPD | Hurst et al., 2010 | `hurst2010exacerbation` |
| MCID for COPD outcomes | Cazzola et al., 2008 (example) | `cazzola2008mcid` |
| Asthma phenotypes / endotypes | Wenzel, 2012 | `wenzel2012asthma` |
| Biomarker reporting (respiratory) | McShane et al., 2011 | `mcshane2011biomarker` |

---

## Statistical methods (primary sources)

| Method | Reference | Key |
|--------|-----------|-----|
| Welch *t*-test | Welch, 1947 | `welch1947t` |
| Mann–Whitney | Mann & Whitney, 1947 | `mann1947test` |
| Logistic regression | Hosmer, Lemeshow & Sturdivant, 2013 | `hosmer2013applied` |
| Firth penalized logistic | Firth, 1993 | `firth1993bias` |
| Poisson / overdispersion | Cameron & Trivedi, 2013 | `cameron2013regression` |
| Negative binomial | Hilbe, 2011 | `hilbe2011nb` |
| Bootstrap | Efron & Tibshirani, 1993 | `efron1993bootstrap` |
| Multiple comparisons | Benjamini & Hochberg, 1995 | `benjamini1995fdr` |
| PCA | Jolliffe & Cadima, 2016 | `jolliffe2016pca` |
| Cluster validation | Hennig, 2007 | `hennig2007cluster` |
| Causal inference | Hernán & Robins, *Causal Inference: What If* | `hernan2020whatif` |
| Multiple imputation | van Buuren, *Flexible Imputation of Missing Data* | `vanbuuren2011mice` |

---

## Omics (analyst track)

| Method | Reference | Key |
|--------|-----------|-----|
| DESeq2 | Love, Huber & Anders, 2014 | `love2014deseq2` |
| limma-voom | Ritchie et al., 2015 | `ritchie2015limma` |
| ComBat batch correction | Johnson, Li & Rabinovic, 2007 | `johnson2007combat` |

See [Appendix L: Omics analyst track](appendix-l-omics-analyst-track.md).

---

## Machine learning & prediction

| Topic | Reference | Key |
|-------|-----------|-----|
| Prediction vs inference | Shmueli, 2010 | `shmueli2010predict` |
| Calibration | Steyerberg, 2019 | `steyerberg2019clinical` |
| Random forests (intro) | Breiman, 2001 | `breiman2001rf` |

See [Ch 9](chapters/09-prediction-vs-inference.md).

---

## R and visualization

| Resource | Key |
|----------|-----|
| ggplot2 | `wickham2016ggplot2` |
| tidyverse | `wickham2019tidyverse` |
| broom (tidy model output) | `robinson2024broom` |

---

## How to cite this handbook

See **[Cite this book](chapters/00-preface.md#cite-this-book)** in the Preface (APA 7th ed.).

---

## Full bibliography

All entries: [`../references.bib`](../references.bib)
