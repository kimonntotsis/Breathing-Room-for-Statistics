source("R/00_setup.R")

library(tidyverse)
library(broom)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

flow <- read_csv(file.path(paths$data, "flowcytometry_summary.csv"), show_col_types = FALSE)
cells <- read_csv(file.path(paths$data, "flowcytometry_cells_toy.csv"), show_col_types = FALSE)

logit <- function(p) log(p / (1 - p))
clip01 <- function(p) pmin(pmax(p, 1e-4), 1 - 1e-4)

cell_types <- c("CD4_T", "CD8_T", "B", "NK", "Mono")

# =============================================================================
# Participant-level comparison: proportions with drift adjustment
# =============================================================================
flow_long <- flow %>%
  select(sample_id, group, batch, starts_with("prop_")) %>%
  pivot_longer(starts_with("prop_"), names_to = "cell_type", values_to = "prop") %>%
  mutate(cell_type = sub("^prop_", "", cell_type))

p_props <- ggplot(flow_long, aes(group, prop, fill = group)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.25) +
  facet_wrap(~ cell_type, scales = "free_y", ncol = 3) +
  theme_minimal() +
  guides(fill = "none") +
  labs(title = "Flow summary: cell-type proportions by group (synthetic)")

ggsave(file.path(fig_dir, "ch15_flow_props_by_group.png"), p_props, width = 8.6, height = 6.2, dpi = 160)

p_drift <- ggplot(flow_long, aes(batch, prop, fill = batch)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.25) +
  facet_wrap(~ cell_type, scales = "free_y", ncol = 3) +
  theme_minimal() +
  guides(fill = "none") +
  labs(title = "Flow summary: drift by day/batch (synthetic)")

ggsave(file.path(fig_dir, "ch15_flow_props_by_batch.png"), p_drift, width = 8.6, height = 6.2, dpi = 160)

# =============================================================================
# Niche 1: compositional structure (stacked proportions by group)
# =============================================================================
flow_comp <- flow %>%
  select(sample_id, group, starts_with("prop_")) %>%
  pivot_longer(starts_with("prop_"), names_to = "cell_type", values_to = "prop") %>%
  mutate(cell_type = sub("^prop_", "", cell_type)) %>%
  group_by(sample_id, group) %>%
  mutate(prop_sum = sum(prop)) %>%
  ungroup()

p_stack <- ggplot(flow_comp, aes(sample_id, prop, fill = cell_type)) +
  geom_col(width = 0.9) +
  facet_wrap(~ group, scales = "free_x", ncol = 1) +
  theme_minimal() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(
    title = "Compositional structure: proportions sum to 1 per participant",
    subtitle = "Each bar = one participant; changing one segment affects others",
    x = "Participants (ordered)",
    y = "Proportion",
    fill = "Cell type"
  )

ggsave(file.path(fig_dir, "ch15_compositional_stacked.png"), p_stack, width = 8.0, height = 5.5, dpi = 160)

# Correlation between monocytes and CD4 (compositional coupling)
comp_corr <- flow %>%
  summarise(r_mono_cd4 = cor(prop_Mono, prop_CD4_T, use = "complete.obs"))
message("Correlation prop_Mono vs prop_CD4_T (participants): ", round(comp_corr$r_mono_cd4, 3))

# =============================================================================
# Participant-level models: all cell types (effect + CI table)
# =============================================================================
fit_celltype <- function(ct) {
  prop_col <- paste0("prop_", ct)
  df <- flow %>%
    mutate(logit_prop = logit(clip01(.data[[prop_col]])))
  fit <- lm(logit_prop ~ group + batch, data = df)
  td <- tidy(fit, conf.int = TRUE) %>% filter(term == "groupcontrol")
  tibble(
    cell_type = ct,
    n_participants = nrow(df),
    estimate_logit = td$estimate,
    conf_low = td$conf.low,
    conf_high = td$conf.high,
    p_value = td$p.value
  )
}

effects_tbl <- map_dfr(cell_types, fit_celltype) %>%
  mutate(q_value = p.adjust(p_value, method = "BH"))

write_csv(effects_tbl, file.path(tab_dir, "ch15_flow_effects_by_celltype.csv"))

# =============================================================================
# Mini-case: pseudo-replication (participant vs pooled cells)
# =============================================================================
# Participant-level: monocytes (correct unit)
flow_m <- flow %>% mutate(logit_mono = logit(clip01(prop_Mono)))
fit_participant <- lm(logit_mono ~ group, data = flow_m)
p_participant <- tidy(fit_participant) %>%
  filter(term == "groupcontrol") %>%
  pull("p.value") %>%
  as.numeric() %>%
  .[1]

# Wrong: pooled cells using CD14 as monocyte proxy (toy teaching comparison)
fit_cells <- lm(CD14 ~ group, data = cells)
p_cells_p <- tidy(fit_cells) %>%
  filter(grepl("^group", term)) %>%
  pull("p.value") %>%
  as.numeric() %>%
  .[1]

pseudo_demo <- tibble(
  analysis_unit = c("Participant summaries (correct)", "Pooled cells (pseudo-replication)"),
  n = c(nrow(flow), nrow(cells)),
  outcome = c("logit(prop_Mono)", "CD14 intensity (per cell)"),
  p_value = c(p_participant, p_cells_p),
  neglog10p = -log10(pmax(p_value, 1e-300))
)

p_pseudo <- ggplot(pseudo_demo, aes(analysis_unit, neglog10p, fill = analysis_unit)) +
  geom_col(width = 0.65) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "grey40") +
  theme_minimal() +
  guides(fill = "none") +
  labs(
    title = "Pseudo-replication demo: same comparison, different unit",
    subtitle = "Pooled cells inflate n and can shrink p-values misleadingly",
    x = NULL,
    y = expression(-log[10](p))
  )

ggsave(file.path(fig_dir, "ch15_pseudoreplication_demo.png"), p_pseudo, width = 7.4, height = 4.4, dpi = 160)

# =============================================================================
# Per-cell toy: PCA on marker intensities (descriptive only)
# =============================================================================
markers <- c("CD3", "CD4", "CD8", "CD19", "CD56", "CD14")
set.seed(20250617)
cells_sub <- cells %>% slice_sample(n = min(nrow(cells), 3000))
X <- cells_sub %>% select(all_of(markers))
pca <- prcomp(X, scale. = TRUE)
scores <- as_tibble(pca$x[, 1:2]) %>%
  mutate(cell_type_true = cells_sub$cell_type_true)

p_cell_pca <- ggplot(scores, aes(PC1, PC2, color = cell_type_true)) +
  geom_point(alpha = 0.55, size = 0.9) +
  theme_minimal() +
  guides(color = "none") +
  labs(title = "Per-cell toy: PCA of marker intensities (descriptive)")

ggsave(file.path(fig_dir, "ch15_flow_cells_pca.png"), p_cell_pca, width = 7.4, height = 5.0, dpi = 160)

# =============================================================================
# Mini-case summary table
# =============================================================================
overlap <- flow %>% count(group, batch, name = "n")

mini_summary <- tibble(
  scenario = c("A: participant summaries", "B: pooled cells (wrong)"),
  unit_of_analysis = c("participant", "cell"),
  n_used = c(nrow(flow), nrow(cells)),
  primary_outcome = c("logit(prop_Mono) per participant", "CD14 per cell"),
  p_value_group = c(p_participant, p_cells_p),
  defensible_for_inference = c(TRUE, FALSE),
  notes = c(
    "Adjust for batch in primary models; report n = participants",
    "Pseudo-replication: do not report as confirmatory"
  )
)

write_csv(mini_summary, file.path(tab_dir, "ch15_flow_mini_case_summary.csv"))

message("Monocyte logit-scale difference (control - case), participant model p = ", signif(p_participant, 3))
message("Pooled-cell CD14 model p = ", signif(p_cells_p, 3))
message("Chapter 15 flow cytometry complete. Figures saved to volume-01/figures/.")
