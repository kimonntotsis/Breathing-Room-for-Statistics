source("R/00_setup.R")

library(tidyverse)

tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

message("=== Case E: longitudinal FEV1 + time to exacerbation (Ch 12) ===")

source("R/examples/ch18_longitudinal_mixed_models.R")
source("R/examples/ch19_survival_analysis.R")

mixed_coef <- read_csv(file.path(tab_dir, "ch18_mixed_model_coefficients.csv"), show_col_types = FALSE)
cox_hr <- read_csv(file.path(tab_dir, "ch19_cox_hazard_ratios.csv"), show_col_types = FALSE)

summary_row <- tibble(
  analysis = c(
    "longitudinal_mixed_group_intervention",
    "longitudinal_mixed_weeks_x_group",
    "survival_cox_smoking_HR",
    "survival_logrank_smoking"
  ),
  metric = c(
    as.character(mixed_coef %>% filter(term == "groupintervention") %>% pull(estimate)),
    as.character(mixed_coef %>% filter(term == "weeks:groupintervention") %>% pull(estimate)),
    as.character(cox_hr %>% filter(term == "smokingTRUE") %>% pull(hr_ci)),
    "see ch19_km_by_smoking.png subtitle"
  )
)

write_csv(summary_row, file.path(tab_dir, "ch12_case_e_summary.csv"))
message("Case E complete. See ch12_case_e_summary.csv")
