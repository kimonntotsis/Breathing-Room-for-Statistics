source("R/00_setup.R")

library(tidyverse)

if (!requireNamespace("factoextra", quietly = TRUE)) {
  stop("Install factoextra for PCA plots: install.packages('factoextra')")
}

omics <- read_csv(file.path(paths$data, "marker_panel.csv"), show_col_types = FALSE)
X <- omics %>% select(starts_with("M"))

pca <- prcomp(X, scale. = TRUE)
print(summary(pca))

print(factoextra::fviz_eig(pca, addlabels = TRUE, barfill = "steelblue", barcolor = "steelblue"))
print(factoextra::fviz_pca_var(pca, col.var = "contrib", gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07")))
print(factoextra::fviz_pca_ind(pca, habillage = omics$true_phenotype, addEllipses = TRUE, palette = "jco"))

message("Chapter 10 PCA complete.")
