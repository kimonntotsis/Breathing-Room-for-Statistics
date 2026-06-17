# Run all chapter example scripts in order
source("R/00_setup.R")
source("R/generate_data.R")

# Handbook figures first (navigation + chapter plots)
message("Generating handbook figures...")
source("R/examples/generate_figures.R")

scripts <- sort(list.files("R/examples", pattern = "\\.R$", full.names = TRUE))
scripts <- scripts[!grepl("generate_figures\\.R$", scripts)]

for (f in scripts) {
  message("Running ", f)
  source(f)
}
message("All examples completed.")
