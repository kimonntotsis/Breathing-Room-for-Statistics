# POLLUX messy registry: QC, exclusions, and analysis-ready export
# Teaching script — not a production pipeline
source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

raw <- read_csv(file.path(paths$data, "pollux_registry_messy.csv"), show_col_types = FALSE) %>%
  mutate(
    smoking = as.logical(smoking),
    spirometry_qc_fail = as.logical(spirometry_qc_fail),
    exacerbation_yn = as.logical(exacerbation_yn),
    visit_in_window = visit_week_scheduled >= 0 & visit_week_scheduled <= 56
  )

n_enrolled <- nrow(raw)

flow <- tibble(
  stage = c(
    "enrolled",
    "spirometry_qc_pass",
    "fev1_observed",
    "visit_in_window",
    "analysis_ready_fev1"
  ),
  n = c(
    n_enrolled,
    sum(!raw$spirometry_qc_fail),
    sum(!raw$spirometry_qc_fail & !is.na(raw$fev1_l)),
    sum(!raw$spirometry_qc_fail & !is.na(raw$fev1_l) & raw$visit_in_window),
    sum(!raw$spirometry_qc_fail & !is.na(raw$fev1_l) & raw$visit_in_window)
  )
)
write_csv(flow, file.path(tab_dir, "pollux_enrollment_flow.csv"))

miss_by_gold <- raw %>%
  group_by(gold_stage) %>%
  summarise(
    n = n(),
    fev1_missing = sum(is.na(fev1_l)),
    qc_fail = sum(spirometry_qc_fail),
    .groups = "drop"
  ) %>%
  mutate(
    missing_pct = round(100 * fev1_missing / n, 1),
    qc_fail_pct = round(100 * qc_fail / n, 1)
  )
write_csv(miss_by_gold, file.path(tab_dir, "pollux_missingness_by_gold.csv"))

site_tbl <- raw %>%
  count(site_id, name = "n_enrolled") %>%
  arrange(desc(n_enrolled))
write_csv(site_tbl, file.path(tab_dir, "pollux_site_counts.csv"))

analysis_ready <- raw %>%
  filter(!spirometry_qc_fail, !is.na(fev1_l), visit_in_window)

write_csv(analysis_ready, file.path(paths$data, "pollux_registry_clean.csv"))

p_miss <- plot_grouped_lollipop(
  miss_by_gold %>%
    pivot_longer(c(fev1_missing, qc_fail), names_to = "issue", values_to = "count") %>%
    mutate(
      issue = recode(issue,
        fev1_missing = "Missing FEV1",
        qc_fail = "Spirometry QC fail"
      ),
      gold_stage = factor(gold_stage, levels = c("II", "III", "IV"))
    ),
  x = "gold_stage", y = "count", group = "issue",
  title = "POLLUX registry: missing FEV1 and QC failure by GOLD stage",
  subtitle = "Messy export before exclusions; compare to clean CASTOR spirometry.csv",
  xlab = "GOLD stage", ylab = "Count",
  pal = c("Missing FEV1" = "#FECACA", "Spirometry QC fail" = "#BFDBFE")
)

handbook_save(p_miss, file.path(fig_dir, "pollux_missingness_by_gold.png"), 7.2, 4.4)

message(
  "POLLUX clean registry: enrolled = ", n_enrolled,
  "; analysis-ready FEV1 rows = ", nrow(analysis_ready),
  "; saved data/pollux_registry_clean.csv"
)
