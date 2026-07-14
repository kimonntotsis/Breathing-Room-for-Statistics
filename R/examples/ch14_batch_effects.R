source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(broom)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# =============================================================================
# Proteomics: PCA colored by batch and group (subset for speed)
# =============================================================================
prot <- read_csv(file.path(paths$data, "proteomics_olink_like.csv"), show_col_types = FALSE)
X <- prot %>% select(starts_with("Prot_000"))

X_imp <- X %>% mutate(across(everything(), \(v) { v[is.na(v)] <- median(v, na.rm = TRUE); v }))

pca <- prcomp(X_imp, scale. = TRUE)
scores <- as_tibble(pca$x[, 1:2]) %>%
  mutate(batch = prot$batch, plate = prot$plate, group = prot$group)

batch_pal <- c(Batch1 = handbook_cols$nonsmoker, Batch2 = handbook_cols$smoker)
plate_pal <- grDevices::colorRampPalette(c("#CBD5E1", handbook_cols$intervention, "#8B7EC8"))(
  length(unique(scores$plate))
)
names(plate_pal) <- sort(unique(scores$plate))

p_batch <- plot_pca_dual(
  scores,
  colour = "batch",
  shape = "group",
  colour_palette = batch_pal,
  title = "Proteomics PCA (subset)",
  subtitle = "Colour = batch; shape = group — batch structure visible before DE",
  xlab = sprintf("PC1 (%.0f%%)", 100 * summary(pca)$importance[2, 1]),
  ylab = sprintf("PC2 (%.0f%%)", 100 * summary(pca)$importance[2, 2])
)

p_plate <- plot_pca_dual(
  scores,
  colour = "plate",
  shape = "group",
  colour_palette = plate_pal,
  show_colour_legend = FALSE,
  title = "Proteomics PCA (subset)",
  subtitle = "Colour = plate (legend hidden); shape = group",
  xlab = sprintf("PC1 (%.0f%%)", 100 * summary(pca)$importance[2, 1]),
  ylab = sprintf("PC2 (%.0f%%)", 100 * summary(pca)$importance[2, 2])
)

handbook_save(p_batch, file.path(fig_dir, "ch14_pca_proteomics_batch.png"), 7.4, 4.8)
handbook_save(p_plate, file.path(fig_dir, "ch14_pca_proteomics_plate.png"), 7.4, 4.8)

# =============================================================================
# Mini-case A: group × batch overlap vs Case B: confounded design
# =============================================================================
overlap_real <- prot %>%
  count(group, batch, name = "n") %>%
  mutate(scenario = "A: CASTOR-HD (overlap)")

overlap_conf <- expand_grid(
  group = c("control", "case"),
  batch = c("Batch1", "Batch2"),
  scenario = "B: confounded (no overlap)"
) %>%
  mutate(
    n = case_when(
      group == "control" & batch == "Batch1" ~ 20L,
      group == "case" & batch == "Batch2" ~ 20L,
      TRUE ~ 0L
    )
  )

overlap_plot_df <- bind_rows(overlap_real, overlap_conf)

p_overlap <- ggplot(overlap_plot_df, aes(batch, n, fill = group)) +
  geom_col(position = position_dodge(width = 0.72), width = 0.68, alpha = 0.9, colour = "white") +
  facet_wrap(~ scenario, scales = "free_x") +
  scale_fill_manual(values = handbook_group_fill, name = "Group") +
  labs(
    title = "Group × batch overlap: valid vs confounded design",
    subtitle = "Scenario B: group and batch are aliased — adjustment is not identifiable",
    x = "Batch",
    y = "Sample count"
  ) +
  handbook_theme(11)

handbook_save(p_overlap, file.path(fig_dir, "ch14_group_batch_overlap.png"), 8.6, 4.6)

set.seed(20250617)
y_conf <- rnorm(40, mean = ifelse(rep(c("control", "case"), each = 20) == "case", 1, 0))
df_conf <- tibble(
  y = y_conf,
  group = factor(rep(c("control", "case"), each = 20)),
  batch = factor(rep(c("Batch1", "Batch2"), each = 20))
)

fit_conf <- lm(y ~ group + batch, data = df_conf)
mm_conf <- model.matrix(~ group + batch, data = df_conf)
identifiable_conf <- qr(mm_conf)$rank == ncol(mm_conf)

# =============================================================================
# PC1 variance explained by batch vs group
# =============================================================================
pc1 <- scores$PC1
r2_batch <- summary(lm(PC1 ~ batch, data = scores))$r.squared
r2_group <- summary(lm(PC1 ~ group, data = scores))$r.squared
r2_both <- summary(lm(PC1 ~ batch + group, data = scores))$r.squared

var_expl <- tibble(
  predictor = c("batch", "group", "batch + group"),
  r_squared = c(r2_batch, r2_group, r2_both)
)

p_r2 <- plot_metric_bars(
  var_expl, x = "predictor", y = "r_squared",
  title = "PC1 variance explained (proteomics subset)",
  subtitle = "If batch dominates PC1, technical structure is large",
  ylab = "R-squared",
  y_limits = c(0, 1),
  y_labels = scales::percent_format()
)

handbook_save(p_r2, file.path(fig_dir, "ch14_pc1_variance_explained.png"), 7.0, 4.4)

# =============================================================================
# Sensitivity: discovery counts with vs without batch covariate
# =============================================================================
prot_features <- names(prot)[grepl("^Prot_", names(prot))]

fit_p <- function(with_batch = TRUE) {
  map_dbl(prot_features, function(nm) {
    df <- prot %>%
      select(group, age, sex, batch, plate, y = all_of(nm)) %>%
      filter(!is.na(y))
    if (nrow(df) < 40) return(NA_real_)
    f <- if (with_batch) y ~ group + age + sex + batch + plate else y ~ group + age + sex
    stats::anova(lm(f, data = df))["group", "Pr(>F)"] %>% as.numeric()
  })
}

p_with <- fit_p(TRUE)
p_without <- fit_p(FALSE)

q_with <- p.adjust(p_with, method = "BH")
q_without <- p.adjust(p_without, method = "BH")

message("Proteomics discoveries (q<0.05) with batch+plate: ", sum(q_with < 0.05, na.rm = TRUE))
message("Proteomics discoveries (q<0.05) without batch+plate: ", sum(q_without < 0.05, na.rm = TRUE))

sens <- tibble(
  model = c("with batch+plate", "without batch+plate"),
  discoveries_q05 = c(sum(q_with < 0.05, na.rm = TRUE), sum(q_without < 0.05, na.rm = TRUE))
)

p_bar <- plot_metric_bars(
  sens, x = "model", y = "discoveries_q05",
  title = "Sensitivity to batch adjustment",
  subtitle = "Inflated hits without batch covariates are a red flag in omics screens",
  ylab = "BH discoveries (q < 0.05)"
)

handbook_save(p_bar, file.path(fig_dir, "ch14_batch_sensitivity_discoveries.png"), 7.0, 4.2)

mini_summary <- tibble(
  scenario = c("A: CASTOR-HD overlap", "B: confounded (synthetic)"),
  group_batch_overlap = c("yes (both groups in both batches)", "no (batch == group)"),
  covariate_adjustment_defensible = c("yes (with sensitivity)", "no (not identifiable)"),
  pc1_r2_batch = c(round(r2_batch, 3), NA_real_),
  pc1_r2_group = c(round(r2_group, 3), NA_real_),
  discoveries_q05_with_batch = c(sum(q_with < 0.05, na.rm = TRUE), NA_integer_),
  discoveries_q05_without_batch = c(sum(q_without < 0.05, na.rm = TRUE), NA_integer_),
  group_effect_identifiable = c(NA, identifiable_conf)
)

write_csv(mini_summary, file.path(tab_dir, "ch14_batch_mini_case_summary.csv"))

message("Chapter 14 batch effects complete. Figures saved to volume-01/figures/.")
