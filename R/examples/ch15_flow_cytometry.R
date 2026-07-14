source("R/00_setup.R")
source("R/viz_handbook.R")

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

props_mean <- flow_long %>%
  group_by(group, cell_type) %>%
  summarise(mean_prop = mean(prop), .groups = "drop")

p_props <- ggplot(props_mean, aes(cell_type, mean_prop, fill = group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.82, alpha = 0.9, colour = "white", linewidth = 0.4) +
  coord_polar(start = 0) +
  scale_fill_manual(values = handbook_group_fill, name = "Group") +
  labs(
    title = "Circular bar: mean cell-type proportions by group",
    subtitle = "Participant-level summaries; polar layout highlights compositional balance",
    x = NULL, y = NULL
  ) +
  handbook_theme(11) +
  theme(panel.grid.major.y = element_line(colour = "#F1F5F9"), axis.text.y = element_blank())

handbook_save(p_props, file.path(fig_dir, "ch15_flow_props_by_group.png"), 7.2, 6.4)

p_drift <- ggplot(flow_long, aes(batch, prop, fill = batch)) +
  geom_violin(trim = FALSE, alpha = 0.55, colour = NA) +
  geom_boxplot(width = 0.12, alpha = 0.85, outlier.alpha = 0.25) +
  facet_wrap(~ cell_type, scales = "free_y", ncol = 3) +
  handbook_theme(10) +
  guides(fill = "none") +
  labs(
    title = "Drift check: violin + box by batch/day",
    subtitle = "Run-day effects visible before group comparison",
    x = "Batch / run day", y = "Proportion"
  )

handbook_save(p_drift, file.path(fig_dir, "ch15_flow_props_by_batch.png"), 8.6, 6.2)

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
  geom_col(width = 0.92, colour = "white", linewidth = 0.2) +
  facet_wrap(~ group, scales = "free_x", ncol = 1) +
  scale_fill_manual(
    values = grDevices::colorRampPalette(c(handbook_cols$nonsmoker, handbook_cols$intervention, handbook_cols$smoker, "#8B7EC8", "#64748B"))(5),
    name = "Cell type"
  ) +
  labs(
    title = "Compositional structure: proportions sum to 1 per participant",
    subtitle = "Each bar = one participant; changing one segment affects others",
    x = "Participants (ordered)",
    y = "Proportion"
  ) +
  handbook_theme(10) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

handbook_save(p_stack, file.path(fig_dir, "ch15_compositional_stacked.png"), 8.2, 5.6)

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
  geom_col(width = 0.68, alpha = 0.9, colour = "white") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", colour = handbook_cols$wrong, linewidth = 0.7) +
  scale_fill_manual(
    values = c(
      "Participant summaries (correct)" = handbook_cols$intervention,
      "Pooled cells (pseudo-replication)" = handbook_cols$smoker
    ),
    guide = "none"
  ) +
  labs(
    title = "Pseudo-replication demo: same comparison, different unit",
    subtitle = "Pooled cells inflate n and can shrink p-values misleadingly",
    x = NULL,
    y = expression(-log[10](p))
  ) +
  handbook_theme(11)

handbook_save(p_pseudo, file.path(fig_dir, "ch15_pseudoreplication_demo.png"), 7.6, 4.6)

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

p_cell_pca <- plot_pca_scores(
  scores,
  colour = "cell_type_true",
  title = "Per-cell toy: PCA of marker intensities (descriptive)",
  subtitle = "Teaching only — inference stays at participant level in Ch 15",
  xlab = sprintf("PC1 (%.0f%%)", 100 * summary(pca)$importance[2, 1]),
  ylab = sprintf("PC2 (%.0f%%)", 100 * summary(pca)$importance[2, 2])
) +
  ggplot2::guides(colour = "none")

handbook_save(p_cell_pca, file.path(fig_dir, "ch15_flow_cells_pca.png"), 7.6, 5.2)

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
