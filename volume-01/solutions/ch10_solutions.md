# Chapter 10 — Solutions

## E10.1
Markers on different scales (e.g. protein concentrations); without scaling, high-variance markers dominate PC1.

## E10.2
Loadings = correlation-like weight of each marker on that component; large |loading| → marker contributes strongly to that axis.

## Applied

```r
source("R/examples/ch10_pca.R")
# Or:
library(tidyverse)
o <- read_csv("data/marker_panel.csv", show_col_types = FALSE)
X <- scale(o %>% select(starts_with("M")))
pca <- princomp(X)  # or prcomp
summary(pca)
```

Use `fviz_pca_ind` coloured by `true_phenotype` for separation visualization.
