# Run handbook R examples
# Usage:
#   source("R/run_all_examples.R")           # core path only (default)
#   source("R/run_all_examples.R"); run_all_examples(include_omics = TRUE)

run_all_examples <- function(include_omics = FALSE) {
  source("R/00_setup.R")
  source("R/generate_data.R")

  message("Generating handbook figures...")
  source("R/examples/generate_figures.R")

  all_scripts <- sort(list.files("R/examples", pattern = "\\.R$", full.names = TRUE))
  all_scripts <- all_scripts[!grepl("generate_figures\\.R$", all_scripts)]

  omics_pattern <- "ch13_analyst_|ch14_analyst_"
  core_scripts <- all_scripts[!grepl(omics_pattern, all_scripts)]

  scripts <- if (include_omics) all_scripts else core_scripts

  if (!include_omics) {
    message(
      "Running core examples only. Set include_omics = TRUE for Appendix L Bioconductor scripts."
    )
  }

  for (f in scripts) {
    message("Running ", f)
    tryCatch(
      source(f),
      error = function(e) {
        message("ERROR in ", f, ": ", conditionMessage(e))
        stop(e)
      }
    )
  }
  message("All requested examples completed.")
  invisible(TRUE)
}
