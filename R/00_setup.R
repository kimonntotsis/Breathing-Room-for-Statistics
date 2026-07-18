# Project setup: source this at the start of any session
find_project_root <- function() {
  path <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
  for (i in 1:8) {
    if (dir.exists(file.path(path, "volume-01"))) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) break
    path <- parent
  }
  normalizePath(getwd(), winslash = "/", mustWork = FALSE)
}

project_root <- find_project_root()

options(
  digits = 3,
  scipen = 999,
  stringsAsFactors = FALSE
)

# Core packages required by chapter scripts (Ch 1–12, 18–22)
required_pkgs <- c(
  "tidyverse", "broom", "patchwork", "survival", "lme4", "MASS",
  "glmnet", "randomForest", "cluster", "factoextra",
  "pROC", "mediation", "sandwich", "lmtest", "rpart"
)

missing <- required_pkgs[!vapply(required_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(missing) > 0) {
  stop(
    "Install missing core packages:\n  install.packages(c(",
    paste(sprintf('"%s"', missing), collapse = ", "),
    "))",
    call. = FALSE
  )
}

viz_pkgs <- c("ggridges", "ggalluvial", "ggforce", "ggrepel", "hexbin", "ggdendro", "ggraph", "igraph")
viz_missing <- viz_pkgs[!vapply(viz_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(viz_missing) > 0) {
  message(
    "Optional visualization packages (for R/viz_handbook.R and R/viz_omics.R): install.packages(c(",
    paste(sprintf('"%s"', viz_missing), collapse = ", "),
    "))"
  )
}

chapter_optional_pkgs <- c("mice", "logistf", "emmeans", "xgboost", "pscl", "pwr")
chapter_missing <- chapter_optional_pkgs[!vapply(chapter_optional_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(chapter_missing) > 0) {
  message(
    "Optional chapter packages (demos skip gracefully if absent): install.packages(c(",
    paste(sprintf('"%s"', chapter_missing), collapse = ", "),
    "))"
  )
}

omics_pkgs <- c("DESeq2", "limma", "edgeR", "fgsea", "sva")
omics_missing <- omics_pkgs[!vapply(omics_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(omics_missing) > 0) {
  message(
    "Optional omics analyst packages (Appendix L): BiocManager::install(c(",
    paste(sprintf('"%s"', omics_missing), collapse = ", "),
    "))"
  )
}

 `%||%` <- function(x, y) if (is.null(x)) y else x

paths <- list(
  root = project_root,
  data = file.path(project_root, "data"),
  r = file.path(project_root, "R")
)

dir.create(paths$data, showWarnings = FALSE, recursive = TRUE)

message("Project root: ", paths$root)
