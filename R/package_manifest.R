# Package manifest for Breathing Room for Statistics
# Pin versions locally with renv for production work:
#   install.packages("renv"); renv::init(); renv::snapshot()

core_packages <- c(
  "tidyverse", "broom", "patchwork", "survival", "lme4", "MASS",
  "glmnet", "randomForest", "cluster", "factoextra",
  "pROC", "mediation", "sandwich", "lmtest", "rpart"
)

optional_chapter_packages <- c(
  "mice", "logistf", "emmeans", "xgboost", "pscl", "pwr", "car"
)

optional_viz_packages <- c(
  "ggridges", "ggalluvial", "ggforce", "ggrepel", "hexbin", "ggdendro", "ggraph", "igraph"
)

optional_omics_packages <- c(
  "DESeq2", "limma", "edgeR", "fgsea", "sva", "ggrepel", "msigdbr"
)

install_core <- function() {
  to_install <- core_packages[!vapply(core_packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
  if (length(to_install) > 0) install.packages(to_install)
  invisible(core_packages)
}

install_optional <- function() {
  pkgs <- c(optional_chapter_packages, optional_viz_packages)
  to_install <- pkgs[!vapply(pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
  if (length(to_install) > 0) install.packages(to_install)
  invisible(pkgs)
}
