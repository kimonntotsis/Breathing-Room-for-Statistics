source("R/00_setup.R")

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
X <- prot %>% select(starts_with("Prot_000")) # first ~100 proteins

# Simple median imputation per protein for PCA visualization only
X_imp <- X %>% mutate(across(everything(), \(v) { v[is.na(v)] <- median(v, na.rm = TRUE); v }))

pca <- prcomp(X_imp, scale. = TRUE)
scores <- as_tibble(pca$x[, 1:2]) %>%
  mutate(batch = prot$batch, plate = prot$plate, group = prot$group)

p_batch <- ggplot(scores, aes(PC1, PC2, color = batch, shape = group)) +
  geom_point(alpha = 0.85) +
  theme_minimal() +
  labs(title = "Proteomics PCA (subset)", subtitle = "Color=batch; shape=group")

p_plate <- ggplot(scores, aes(PC1, PC2, color = plate, shape = group)) +
  geom_point(alpha = 0.85) +
  theme_minimal() +
  guides(color = "none") +
  labs(title = "Proteomics PCA (subset)", subtitle = "Color=plate (hidden legend); shape=group")

ggsave(file.path(fig_dir, "ch14_pca_proteomics_batch.png"), p_batch, width = 7.2, height = 4.8, dpi = 160)
ggsave(file.path(fig_dir, "ch14_pca_proteomics_plate.png"), p_plate, width = 7.2, height = 4.8, dpi = 160)

# =============================================================================
# Mini-case A: group × batch overlap (CASTOR-HD) vs Case B: confounded design
# =============================================================================
overlap_real <- prot %>%
  count(group, batch, name = "n") %>%
  mutate(scenario = "A: CASTOR-HD (overlap)")

# Synthetic confounded design for teaching (not in CSV)
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
  geom_col(position = "dodge", width = 0.7) +
  facet_wrap(~ scenario, scales = "free_x") +
  theme_minimal() +
  labs(
    title = "Group × batch overlap: valid vs confounded design",
    x = "Batch",
    y = "Sample count",
    fill = "Group"
  )

ggsave(file.path(fig_dir, "ch14_group_batch_overlap.png"), p_overlap, width = 8.4, height = 4.4, dpi = 160)

# Demonstrate non-identifiability in confounded case (single feature)
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
# Niche figure: how much does PC1 track batch vs group? (R-squared from ANOVA)
# =============================================================================
pc1 <- scores$PC1
r2_batch <- summary(lm(PC1 ~ batch, data = scores))$r.squared
r2_group <- summary(lm(PC1 ~ group, data = scores))$r.squared
r2_both <- summary(lm(PC1 ~ batch + group, data = scores))$r.squared

var_expl <- tibble(
  predictor = c("batch", "group", "batch + group"),
  r_squared = c(r2_batch, r2_group, r2_both)
)

p_r2 <- ggplot(var_expl, aes(predictor, r_squared, fill = predictor)) +
  geom_col(width = 0.65) +
  scale_y_continuous(limits = c(0, 1), labels = scales::percent_format()) +
  theme_minimal() +
  guides(fill = "none") +
  labs(
    title = "PC1 variance explained (proteomics subset)",
    subtitle = "If batch dominates PC1, technical structure is large",
    x = NULL,
    y = "R-squared"
  )

ggsave(file.path(fig_dir, "ch14_pc1_variance_explained.png"), p_r2, width = 6.8, height = 4.2, dpi = 160)

# =============================================================================
# Sensitivity illustration: discovery counts with vs without batch covariate
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

p_bar <- ggplot(sens, aes(model, discoveries_q05, fill = model)) +
  geom_col(width = 0.65) +
  theme_minimal() +
  guides(fill = "none") +
  labs(title = "Sensitivity to batch adjustment", y = "BH discoveries (q < 0.05)", x = NULL)

ggsave(file.path(fig_dir, "ch14_batch_sensitivity_discoveries.png"), p_bar, width = 6.8, height = 4.0, dpi = 160)

# Mini-case summary table (for chapter appendix / copy-paste)
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
