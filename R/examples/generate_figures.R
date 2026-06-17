# Generate all handbook figures (navigation, chapters 4–6, 10)
source("R/00_setup.R")

library(tidyverse)
library(broom)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)
exacerbation <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE)
bronchodilator <- read_csv(file.path(paths$data, "bronchodilator_paired.csv"), show_col_types = FALSE)
counts <- read_csv(file.path(paths$data, "exacerbation_counts.csv"), show_col_types = FALSE)
omics <- read_csv(file.path(paths$data, "marker_panel.csv"), show_col_types = FALSE)

# =============================================================================
# 1. Method decision tree (handbook navigation)
# =============================================================================
draw_method_decision_tree <- function(path) {
  png(path, width = 1400, height = 2100, res = 120)
  par(mar = c(0.5, 0.5, 2, 0.5), family = "sans")
  plot.new()
  plot.window(xlim = c(0, 10), ylim = c(0, 21))

  box <- function(x, y, w, h, label, col = "lightblue", border = "steelblue") {
    rect(x - w / 2, y - h / 2, x + w / 2, y + h / 2, col = col, border = border, lwd = 1.5)
    text(x, y, label, cex = 0.85)
  }
  arrow <- function(x1, y1, x2, y2) {
    arrows(x1, y1, x2, y2, length = 0.08, lwd = 1.2)
  }

  title("Handbook — Method decision tree", cex.main = 1.3, font.main = 2)
  box(5, 19.5, 4.5, 0.9, "1. Write estimand\n(Ch 1)", col = "#FFF3CD", border = "#856404")
  box(5, 17.8, 4.5, 0.9, "2. Outcome type?\n(Ch 2, QUICK_REFERENCE)", col = "#D1ECF1", border = "#0C5460")

  # Outcome branches
  box(1.5, 15.5, 2.2, 0.85, "Continuous\nFEV1, scores", col = "#D4EDDA", border = "#155724")
  box(5, 15.5, 2.2, 0.85, "Binary\nexacerbation Y/N", col = "#D4EDDA", border = "#155724")
  box(8.5, 15.5, 2.2, 0.85, "Count\n# exacerbations", col = "#D4EDDA", border = "#155724")

  arrow(5, 19.1, 5, 18.25)
  arrow(5, 17.35, 1.5, 15.95)
  arrow(5, 17.35, 5, 15.95)
  arrow(5, 17.35, 8.5, 15.95)

  # Continuous methods
  box(1.5, 13.2, 2.4, 1.0, "2 groups:\nWelch t-test\nAlt: Mann-Whitney", col = "white")
  box(1.5, 11.2, 2.4, 0.9, "Paired:\nPaired t-test", col = "white")
  box(1.5, 9.2, 2.4, 0.9, "Adjust:\nLinear / ANCOVA\n(Ch 5)", col = "white")

  arrow(1.5, 15.05, 1.5, 13.75)
  arrow(1.5, 12.65, 1.5, 11.7)
  arrow(1.5, 10.65, 1.5, 9.7)

  # Binary methods
  box(5, 13.2, 2.4, 1.0, "2 groups:\nChi-square / Fisher\nMcNemar if paired", col = "white")
  box(5, 11.2, 2.4, 0.9, "Adjust:\nLogistic\n(Ch 6)", col = "white")
  box(5, 9.2, 2.4, 0.9, "Sparse events:\nFirth logistic", col = "white")

  arrow(5, 15.05, 5, 13.75)
  arrow(5, 12.65, 5, 11.7)
  arrow(5, 10.65, 5, 9.7)

  # Count methods
  box(8.5, 13.2, 2.4, 1.0, "Never t-test\non counts", col = "#F8D7DA", border = "#721C24")
  box(8.5, 11.2, 2.4, 0.9, "Poisson GLM\n+ offset if needed", col = "white")
  box(8.5, 9.2, 2.4, 0.9, "Overdispersion:\nNegative binomial", col = "white")

  arrow(8.5, 15.05, 8.5, 13.75)
  arrow(8.5, 12.65, 8.5, 11.7)
  arrow(8.5, 10.65, 8.5, 9.7)

  # Many features / omics branch
  box(5, 6.8, 7.5, 1.1, "MANY FEATURES / OMICS (Ch 10–17)\nDE+FDR (13) · batch (14) · flow (15) · screen (16) · pipeline (17)", col = "#E8DAEF", border = "#6C3483")
  arrow(1.5, 8.75, 3.2, 7.4)
  arrow(5, 8.75, 5, 7.4)
  arrow(8.5, 8.75, 6.8, 7.4)

  # Reporting
  box(5, 4.5, 6, 1.0, "Report: effect + 95% CI + n + limitations\nCONSORT / STROBE / TRIPOD (Ch 8)", col = "#E2E3E5")
  arrow(1.5, 8.75, 3.5, 5.05)
  arrow(5, 6.25, 5, 5.05)
  arrow(8.5, 8.75, 6.5, 5.05)

  # Extended topics pointer
  box(5, 2.5, 7, 0.9, "Ch 18–21: longitudinal, survival, missing data, causal", col = "#F5F5F5", border = "grey60")

  text(5, 1.2, "See QUICK_REFERENCE.md and METHOD_MAP.md", cex = 0.75, col = "grey30")
  dev.off()
}

draw_method_decision_tree(file.path(fig_dir, "method_decision_tree.png"))

# =============================================================================
# 2. Comparison panel (t-test vs Wilcoxon vs linear; chi vs logistic)
# =============================================================================
p_cont <- tibble(
  method = c("Welch t-test", "Mann-Whitney", "Linear regression"),
  use_when = c(
    "Default: 2 independent groups",
    "Very skew + small n",
    "Adjust for covariates"
  ),
  outcome = "Continuous (FEV1)"
) %>%
  ggplot(aes(x = method, y = 1, fill = method)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.2) +
  scale_fill_brewer(palette = "Blues", guide = "none") +
  labs(title = "Continuous outcomes") +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

p_bin <- tibble(
  method = c("Chi-square / Fisher", "McNemar", "Logistic regression"),
  use_when = c(
    "2 independent groups",
    "Paired binary",
    "Adjust for covariates"
  ),
  outcome = "Binary (exacerbation Y/N)"
) %>%
  ggplot(aes(x = method, y = 1, fill = method)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.2) +
  scale_fill_brewer(palette = "Greens", guide = "none") +
  labs(title = "Binary / categorical outcomes") +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

p_count <- tibble(
  method = c("NOT t-test", "Poisson GLM", "Negative binomial"),
  use_when = c(
    "Wrong for counts",
    "Equal / offset follow-up",
    "Overdispersion"
  ),
  outcome = "Count (exacerbations)"
) %>%
  ggplot(aes(x = method, y = 1, fill = method)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.2) +
  scale_fill_manual(values = c("#F8D7DA", "#D4EDDA", "#D4EDDA"), guide = "none") +
  labs(title = "Count outcomes") +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

p_panel <- p_cont / p_bin / p_count +
  plot_annotation(
    title = "Method comparison panel — handbook",
    subtitle = "Full tables: volume-01/QUICK_REFERENCE.md"
  )

ggsave(file.path(fig_dir, "method_comparison_panel.png"), p_panel, width = 9, height = 8, dpi = 150)

# =============================================================================
# 3. Chapter 4 figures
# =============================================================================
p_ch04_box <- ggplot(spirometry, aes(group, fev1, fill = group)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.4) +
  geom_jitter(width = 0.12, alpha = 0.25, size = 1) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, colour = "black") +
  labs(
    title = "FEV1 by trial arm (CASTOR)",
    subtitle = "Diamond = mean; use Welch t-test for independent groups (Ch 4)",
    x = NULL, y = "FEV1 (L)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "ch04_fev1_by_group.png"), p_ch04_box, width = 6, height = 4.5, dpi = 150)

p_ch04_paired <- bronchodilator %>%
  select(patient_id, fev1_pre, fev1_post) %>%
  pivot_longer(-patient_id, names_to = "visit", values_to = "fev1") %>%
  mutate(visit = if_else(visit == "fev1_pre", "Pre-BD", "Post-BD")) %>%
  ggplot(aes(visit, fev1, group = patient_id)) +
  geom_line(alpha = 0.35, colour = "steelblue") +
  geom_point(alpha = 0.5, size = 1.2) +
  stat_summary(aes(group = visit), fun = mean, geom = "point", size = 4, colour = "red") +
  stat_summary(aes(group = visit), fun.data = mean_se, geom = "errorbar", width = 0.1, colour = "red") +
  labs(
    title = "Bronchodilator response (paired FEV1)",
    subtitle = "Use paired t-test or Wilcoxon signed-rank (Ch 4)",
    x = NULL, y = "FEV1 (L)"
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(fig_dir, "ch04_paired_bronchodilator.png"), p_ch04_paired, width = 5.5, height = 4.5, dpi = 150)

exac_rate <- exacerbation %>%
  group_by(smoking) %>%
  summarise(
    n = n(),
    events = sum(exacerbation_12m),
    rate = mean(exacerbation_12m),
    .groups = "drop"
  ) %>%
  mutate(smoking = if_else(smoking, "Smoker", "Non-smoker"))

p_ch04_bar <- ggplot(exac_rate, aes(smoking, rate, fill = smoking)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_text(aes(label = sprintf("%d/%d (%.1f%%)", events, n, 100 * rate)), vjust = -0.5, size = 3.5) +
  scale_y_continuous(labels = scales::percent, limits = c(0, max(exac_rate$rate) * 1.25)) +
  labs(
    title = "12-month exacerbation by smoking status",
    subtitle = "Use Fisher / chi-square or logistic regression (Ch 4, 6)",
    x = NULL, y = "Proportion with ≥1 exacerbation"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "ch04_exacerbation_by_smoking.png"), p_ch04_bar, width = 5.5, height = 4.5, dpi = 150)

# =============================================================================
# 4. Chapter 5 figures
# =============================================================================
fit_lm <- lm(fev1 ~ smoking + age + sex + height_cm, data = spirometry)

p_resid <- ggplot(tibble(fitted = fitted(fit_lm), resid = rstandard(fit_lm)), aes(fitted, resid)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_smooth(se = FALSE, colour = "firebrick", linewidth = 0.8) +
  labs(title = "Residuals vs fitted", x = "Fitted FEV1", y = "Standardized residuals") +
  theme_minimal(base_size = 11)

p_qq <- ggplot(spirometry, aes(sample = rstandard(fit_lm))) +
  stat_qq(alpha = 0.6) +
  stat_qq_line(linewidth = 0.8) +
  labs(title = "Normal Q-Q of residuals", x = "Theoretical", y = "Sample") +
  theme_minimal(base_size = 11)

ggsave(
  file.path(fig_dir, "ch05_residual_diagnostics.png"),
  p_resid | p_qq,
  width = 9, height = 4, dpi = 150
)

if (requireNamespace("emmeans", quietly = TRUE)) {
  em <- emmeans::emmeans(fit_lm, ~ smoking)
  em_df <- as.data.frame(em)
  p_adj <- ggplot(em_df, aes(smoking, emmean)) +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.15) +
    labs(
      title = "Adjusted mean FEV1 by smoking (CASTOR)",
      subtitle = "From linear model adjusting age, sex, height (Ch 5)",
      x = "Smoking", y = "Estimated mean FEV1 (L)"
    ) +
    theme_minimal(base_size = 12)
  ggsave(file.path(fig_dir, "ch05_fev1_by_smoking_adjusted.png"), p_adj, width = 5.5, height = 4.5, dpi = 150)
}

# =============================================================================
# 5. Chapter 6 figures
# =============================================================================
logit_fit <- glm(
  exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
  data = exacerbation, family = binomial
)

forest_df <- tidy(logit_fit, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(term = str_replace_all(term, "_", " "))

p_forest <- ggplot(forest_df, aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_point(size = 3, colour = "steelblue") +
  scale_x_log10() +
  labs(
    title = "Adjusted odds ratios — 12-month exacerbation",
    subtitle = "Logistic regression (Ch 6); log scale",
    x = "Odds ratio (95% CI)", y = NULL
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(fig_dir, "ch06_logistic_forest.png"), p_forest, width = 7, height = 4.5, dpi = 150)

if ("person_years" %in% names(counts)) {
  pois_fit <- glm(
    exacerbations_12m ~ smoking + ics_adherence + offset(log(person_years)),
    data = counts, family = poisson
  )
} else {
  pois_fit <- glm(exacerbations_12m ~ smoking + ics_adherence, data = counts, family = poisson)
}

rr_df <- tidy(pois_fit, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(term = str_replace_all(term, "_", " "))

p_rr <- ggplot(rr_df, aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_point(size = 3, colour = "darkgreen") +
  scale_x_log10() +
  labs(
    title = "Rate ratios — exacerbation counts",
    subtitle = "Poisson GLM (Ch 6); log scale",
    x = "Rate ratio (95% CI)", y = NULL
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(fig_dir, "ch06_poisson_rate_ratio.png"), p_rr, width = 7, height = 3.5, dpi = 150)

# =============================================================================
# 6. Chapter 10 PCA figures
# =============================================================================
if (requireNamespace("factoextra", quietly = TRUE)) {
  X <- omics %>% select(starts_with("M"))
  pca <- prcomp(X, scale. = TRUE)

  p_scree <- factoextra::fviz_eig(pca, addlabels = TRUE, barfill = "steelblue", barcolor = "steelblue") +
    labs(title = "PCA scree plot — CASTOR marker panel")

  ggsave(file.path(fig_dir, "ch10_scree.png"), p_scree, width = 6, height = 4.5, dpi = 150)

  p_biplot <- factoextra::fviz_pca_ind(
    pca, habillage = omics$true_phenotype,
    addEllipses = TRUE, palette = "jco",
    title = "PCA: PC1 vs PC2 (true phenotype, teaching only)"
  )
  ggsave(file.path(fig_dir, "ch10_pca_biplot.png"), p_biplot, width = 7, height = 5, dpi = 150)
} else {
  message("Install factoextra for PCA figures: install.packages('factoextra')")
}

message("Handbook figures saved to ", fig_dir)
message("See volume-01/FIGURE_INDEX.md for the full list.")
