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

required_pkgs <- c(
  "tidyverse", "broom", "patchwork", "survival", "lme4",
  "glmnet", "randomForest", "cluster", "factoextra"
)

missing <- required_pkgs[!vapply(required_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(missing) > 0) {
  stop(
    "Install missing packages:\n  install.packages(c(",
    paste(sprintf('"%s"', missing), collapse = ", "),
    "))",
    call. = FALSE
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
