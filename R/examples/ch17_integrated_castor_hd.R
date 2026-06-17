source("R/00_setup.R")

library(tidyverse)
library(broom)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

message("=== CASTOR-HD integrated pipeline (Ch 17) ===")

# Reuse chapter scripts (idempotent)
source("R/examples/ch13_differential_fdr.R")
source("R/examples/ch14_batch_effects.R")
source("R/examples/ch15_flow_cytometry.R")
source("R/examples/ch16_antibody_screening.R")

# Shortlist: top proteomics features by q then |effect|
prot_top <- read_csv(file.path(tab_dir, "ch13_proteomics_top_table.csv"), show_col_types = FALSE)
shortlist <- prot_top %>%
  arrange(q, desc(abs(estimate))) %>%
  slice_head(n = 30) %>%
  mutate(stage = "proteomics_DE_shortlist")

write_csv(shortlist, file.path(tab_dir, "ch17_integrated_shortlist.csv"))

# One-row pipeline summary for teaching
batch_case <- read_csv(file.path(tab_dir, "ch14_batch_mini_case_summary.csv"), show_col_types = FALSE)
flow_mono <- read_csv(file.path(tab_dir, "ch15_flow_effects_by_celltype.csv"), show_col_types = FALSE)
ppv_aga <- read_csv(file.path(tab_dir, "ch16_screen_ppv_by_antigen.csv"), show_col_types = FALSE)

summary_row <- tibble(
  step = c(
    "proteomics_shortlist_n",
    "batch_discoveries_with_adjustment",
    "batch_discoveries_without_adjustment",
    "flow_monocyte_p",
    "aga_screen_ppv"
  ),
  metric = c(
    as.character(nrow(shortlist)),
    as.character(batch_case$discoveries_q05_with_batch[1]),
    as.character(batch_case$discoveries_q05_without_batch[1]),
    as.character(flow_mono %>% filter(cell_type == "Mono") %>% pull(p_value)),
    as.character(ppv_aga %>% filter(antigen == "AgA") %>% pull(ppv))
  )
)

write_csv(summary_row, file.path(tab_dir, "ch17_integrated_pipeline_summary.csv"))
message("Integrated CASTOR-HD pipeline complete. See ch17_integrated_*.csv tables.")
