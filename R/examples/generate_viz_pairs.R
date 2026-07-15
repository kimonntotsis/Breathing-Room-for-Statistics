# Right vs wrong visualization pairs for the handbook
# Source after data load, or: source("R/examples/generate_viz_pairs.R")
if (!exists("paths")) source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(broom)
library(patchwork)
library(survival)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# -----------------------------------------------------------------------------
# Panel helpers
# -----------------------------------------------------------------------------
viz_theme <- function(base = 11) {
  theme_minimal(base_size = base) +
    theme(
      plot.title = element_text(face = "bold", size = base + 1, colour = "#0F172A"),
      plot.subtitle = element_text(size = base - 1, colour = "#64748B"),
      plot.caption = element_text(size = base - 2, colour = "#94A3B8", hjust = 0),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
}

viz_tag <- function(p, label, kind = NULL) {
  if (is.null(kind)) {
    kind <- if (grepl("^Wrong:", label, ignore.case = TRUE)) "wrong" else "right"
  }
  kind <- match.arg(kind, c("right", "wrong"))
  col <- if (kind == "right") "#115E59" else "#BE123C"
  p +
    labs(tag = label) +
    theme(
      plot.tag = element_text(
        face = "bold", size = 11, colour = col,
        hjust = 0.5, margin = margin(b = 4)
      ),
      plot.tag.position = "top",
      plot.margin = margin(t = 16, r = 10, b = 8, l = 10)
    )
}

viz_save_pair <- function(p_wrong, p_right, path, title, caption, width = 10, height = 5.1) {
  panel <- (p_wrong | p_right) +
    plot_layout(widths = c(1, 1)) +
    plot_annotation(
      title = title,
      caption = caption,
      theme = theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0.5, colour = "#0F172A"),
        plot.caption = element_text(size = 8.5, colour = "#64748B", hjust = 0.5, lineheight = 0.95)
      )
    )
  ggsave(path, panel, width = width, height = height, dpi = 200, bg = "white")
  invisible(path)
}

# -----------------------------------------------------------------------------
# Data
# -----------------------------------------------------------------------------
spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)
bronchodilator <- read_csv(file.path(paths$data, "bronchodilator_paired.csv"), show_col_types = FALSE)
exacerbation <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE)
long <- read_csv(file.path(paths$data, "longitudinal_spirometry.csv"), show_col_types = FALSE)
surv <- read_csv(file.path(paths$data, "time_to_exacerbation.csv"), show_col_types = FALSE) %>%
  mutate(
    smoking = as.logical(smoking),
    smoking_lab = if_else(smoking, "Smoker", "Non-smoker")
  )

set.seed(20250711)
spirometry_miss <- spirometry %>%
  mutate(
    missing_fev1 = rbinom(
      n(), 1,
      prob = plogis(-2.8 + 1.4 * (diagnosis == "moderate_obstruction") + 0.4 * smoking)
    ) == 1,
    fev1_obs = if_else(missing_fev1, NA_real_, fev1)
  )

prot_path <- file.path(paths$data, "proteomics_olink_like.csv")
if (file.exists(prot_path)) {
  prot <- read_csv(prot_path, show_col_types = FALSE)
  X_prot <- prot %>% select(starts_with("Prot_000"))
  X_imp <- X_prot %>% mutate(across(everything(), \(v) {
    v[is.na(v)] <- median(v, na.rm = TRUE)
    v
  }))
  pca_prot <- prcomp(X_imp, scale. = TRUE)
  pca_scores <- as_tibble(pca_prot$x[, 1:2]) %>%
    mutate(batch = prot$batch, group = prot$group)
}

# =============================================================================
# 1. Plot router (Appendix I + Ch 3)
# =============================================================================
draw_plot_router <- function(path) {
  # Illustrated master: figures/viz_plot_router.png
  # R fallback (optional): archive/figures/fallbacks/viz_plot_router_r.png
  if (!file.exists(path)) {
    draw_plot_router_modern(path)
  }
}

draw_plot_router(file.path(fig_dir, "viz_plot_router.png"))

# =============================================================================
# 2. Ch 3: truncated axis vs honest scale
# =============================================================================
means <- spirometry %>%
  group_by(group) %>%
  summarise(mean_fev1 = mean(fev1), n = n(), .groups = "drop")

p_wrong_scale <- ggplot(means, aes(group, mean_fev1, fill = group)) +
  geom_col(width = 0.55, alpha = 0.9) +
  geom_text(aes(label = sprintf("%.2f L", mean_fev1)), vjust = -0.4, size = 3.5, fontface = "bold") +
  scale_fill_manual(values = c(standard = "#94A3B8", intervention = "#1D4ED8"), guide = "none") +
  scale_y_continuous(limits = c(3.72, 3.92), breaks = seq(3.72, 3.92, 0.05)) +
  labs(
    title = "Mean FEV1 by arm",
    subtitle = "Y-axis starts at 3.72 L: difference looks large",
    x = NULL, y = "FEV1 (L)"
  ) +
  viz_theme()

p_right_scale <- plot_raincloud(
  spirometry, "group", "fev1", fill = "group",
  title = "Raincloud: FEV1 by arm",
  subtitle = "Full scale with density, box, points, and mean diamond",
  xlab = NULL, ylab = "FEV1 (L)"
)

viz_save_pair(
  viz_tag(p_wrong_scale, "Wrong: truncated axis exaggerates gap"),
  viz_tag(p_right_scale, "Right: full scale + raw data"),
  file.path(fig_dir, "viz_pair_ch03_scale_trap.png"),
  "Figure hygiene: axis truncation (CASTOR FEV1)",
  "Left: steering-deck favourite: small mean gap looks decisive. Right: same data with spread; sign-off needs CI and n."
)

# =============================================================================
# 3. Ch 4: mean bar vs box + points (continuous)
# =============================================================================
p_wrong_bar <- ggplot(means, aes(group, mean_fev1, fill = group)) +
  geom_col(width = 0.55, alpha = 0.9) +
  geom_text(aes(label = sprintf("n=%d", n)), vjust = -0.5, size = 3.2) +
  scale_fill_manual(values = c(standard = "#94A3B8", intervention = "#1D4ED8"), guide = "none") +
  labs(
    title = "Group means only",
    subtitle = "Hides spread and outliers",
    x = NULL, y = "Mean FEV1 (L)"
  ) +
  viz_theme()

p_right_box <- plot_raincloud(
  spirometry, "group", "fev1", fill = "group",
  title = "Raincloud + mean diamond",
  subtitle = "Supports Welch t-test estimand with visible spread",
  xlab = NULL, ylab = "FEV1 (L)"
)

viz_save_pair(
  viz_tag(p_wrong_bar, "Wrong: means without spread"),
  viz_tag(p_right_box, "Right: distribution + mean marker"),
  file.path(fig_dir, "viz_pair_ch04_continuous.png"),
  "Figure hygiene: continuous group comparison (CASTOR)",
  "Mean-only bars invite over-reading; boxplots show overlap that must match the reported CI."
)

# =============================================================================
# 4. Ch 4: paired bronchodilator: independent vs paired
# =============================================================================
bd_long <- bronchodilator %>%
  select(patient_id, fev1_pre, fev1_post) %>%
  pivot_longer(-patient_id, names_to = "visit", values_to = "fev1") %>%
  mutate(visit = if_else(visit == "fev1_pre", "Pre-BD", "Post-BD"))

p_wrong_indep <- ggplot(bd_long, aes(visit, fev1, fill = visit)) +
  geom_boxplot(alpha = 0.75, width = 0.5) +
  geom_jitter(width = 0.12, alpha = 0.35, size = 0.9) +
  scale_fill_manual(values = c("Pre-BD" = "#CBD5E1", "Post-BD" = "#1D4ED8"), guide = "none") +
  labs(
    title = "Pre vs post as independent groups",
    subtitle = "Treats 80 patients as 160 unrelated points",
    x = NULL, y = "FEV1 (L)"
  ) +
  viz_theme()

p_right_paired <- plot_dumbbell(
  bronchodilator, "patient_id", "fev1_pre", "fev1_post",
  title = "Dumbbell: paired bronchodilator response",
  subtitle = "Within-person segments support paired t-test / Wilcoxon signed-rank",
  xlab = "FEV1 (L)", ylab = NULL
) +
  theme(legend.position = "none")

viz_save_pair(
  viz_tag(p_wrong_indep, "Wrong: ignores pairing"),
  viz_tag(p_right_paired, "Right: within-person link"),
  file.path(fig_dir, "viz_pair_ch04_paired.png"),
  "Figure hygiene: paired bronchodilator response",
  "Independent boxplots inflate effective n and understate correlation; pairing must be visible."
)

# =============================================================================
# 5. Ch 6: forest vs bar without CI
# =============================================================================
logit_fit <- glm(
  exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
  data = exacerbation, family = binomial
)
forest_df <- tidy(logit_fit, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(term = str_replace_all(term, "_", " "))

p_wrong_or_bar <- ggplot(forest_df, aes(x = term, y = estimate, fill = estimate > 1)) +
  geom_col(width = 0.65, alpha = 0.85) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50") +
  scale_fill_manual(values = c("TRUE" = "#BE123C", "FALSE" = "#1D4ED8"), guide = "none") +
  labs(
    title = "Adjusted ORs (point only)",
    subtitle = "No 95% CI: precision invisible",
    x = NULL, y = "Odds ratio"
  ) +
  viz_theme() +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

p_right_forest <- ggplot(forest_df, aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), orientation = "y", width = 0.2, linewidth = 0.7) +
  geom_point(size = 3, colour = "#1D4ED8") +
  scale_x_log10() +
  labs(
    title = "Forest plot with 95% CI",
    subtitle = "Logistic regression (Ch 6)",
    x = "Odds ratio (log scale)", y = NULL
  ) +
  viz_theme()

viz_save_pair(
  viz_tag(p_wrong_or_bar, "Wrong: OR bars, no CI"),
  viz_tag(p_right_forest, "Right: forest plot"),
  file.path(fig_dir, "viz_pair_ch06_forest.png"),
  "Figure hygiene: adjusted odds ratios",
  "Point-only bars invite ranking predictors by eye; forest plots show uncertainty and null (OR = 1)."
)

# =============================================================================
# 6. Ch 9: AUC shootout vs calibration
# =============================================================================
if (requireNamespace("pROC", quietly = TRUE)) {
  exac <- exacerbation %>%
    mutate(exacerbation_12m = as.integer(exacerbation_12m), smoking = as.integer(smoking))
  set.seed(42)
  idx <- sample(nrow(exac), floor(0.7 * nrow(exac)))
  train <- exac[idx, ]
  test <- exac[-idx, ]
  log_mod <- glm(
    exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
    data = train, family = binomial
  )
  pred <- predict(log_mod, newdata = test, type = "response")
  auc_val <- as.numeric(pROC::auc(pROC::roc(test$exacerbation_12m, pred, quiet = TRUE)))

  auc_df <- tibble(
    metric = c("Logistic AUC", "LASSO AUC", "Tree AUC"),
    value = c(auc_val, auc_val * 0.98, auc_val * 1.02)
  )

  p_wrong_auc <- ggplot(auc_df, aes(metric, value, fill = metric)) +
    geom_col(width = 0.6, alpha = 0.9) +
    geom_text(aes(label = sprintf("%.3f", value)), vjust = -0.4, size = 3.5) +
    scale_fill_brewer(palette = "Blues", guide = "none") +
    scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2)) +
    labs(
      title = "Model shootout: AUC only",
      subtitle = "Discrimination hero slide: calibration omitted",
      x = NULL, y = "AUC"
    ) +
    viz_theme()

  n_events <- sum(test$exacerbation_12m)
  n_bins <- max(3L, min(5L, floor(nrow(test) / 25L)))
  cal_df <- tibble(y = test$exacerbation_12m, pred = pred) %>%
    mutate(bin = ntile(pred, n_bins)) %>%
    group_by(bin) %>%
    summarise(
      mean_pred = mean(pred), obs_rate = mean(y), n = n(),
      se = sqrt(pmax(obs_rate * (1 - obs_rate) / n, 1e-6)),
      .groups = "drop"
    )
  axis_max <- max(0.15, cal_df$mean_pred, cal_df$obs_rate + cal_df$se, na.rm = TRUE) * 1.15

  p_right_cal <- ggplot(cal_df, aes(mean_pred, obs_rate)) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey50") +
    geom_errorbar(aes(ymin = pmax(0, obs_rate - se), ymax = pmin(1, obs_rate + se)), width = 0.01, colour = "grey40") +
    geom_point(aes(size = n), colour = "#1D4ED8") +
    scale_size_continuous(range = c(3, 8), guide = "none") +
    coord_cartesian(xlim = c(0, axis_max), ylim = c(0, axis_max)) +
    labs(
      title = "Calibration on test set",
      subtitle = sprintf("%d events in test n=%d", n_events, nrow(test)),
      x = "Mean predicted risk", y = "Observed event rate"
    ) +
    viz_theme()

  viz_save_pair(
    viz_tag(p_wrong_auc, "Wrong: AUC-only shootout"),
    viz_tag(p_right_cal, "Right: calibration plot"),
    file.path(fig_dir, "viz_pair_ch09_prediction.png"),
    "Figure hygiene: prediction performance",
    "High AUC can still mislead clinicians if predicted risks are not calibrated to observed events (TRIPOD)."
  )
}

# =============================================================================
# 7. Ch 14: PCA group-only vs batch-first
# =============================================================================
if (exists("pca_scores")) {
  p_wrong_group <- ggplot(pca_scores, aes(PC1, PC2, colour = group)) +
    geom_point(alpha = 0.8, size = 1.8) +
    scale_colour_manual(values = c(control = "#94A3B8", case = "#BE123C")) +
    labs(
      title = "PCA coloured by case/control",
      subtitle = "Looks like biology: batch not shown",
      x = "PC1", y = "PC2", colour = "Group"
    ) +
    viz_theme()

  p_right_batch <- ggplot(pca_scores, aes(PC1, PC2, colour = batch, shape = group)) +
    geom_point(alpha = 0.8, size = 1.8) +
    labs(
      title = "PCA coloured by batch",
      subtitle = "QC first: technical structure visible",
      x = "PC1", y = "PC2", colour = "Batch", shape = "Group"
    ) +
    viz_theme()

  viz_save_pair(
    viz_tag(p_wrong_group, "Wrong: group colour only"),
    viz_tag(p_right_batch, "Right: batch QC first"),
    file.path(fig_dir, "viz_pair_ch14_batch_pca.png"),
    "Figure hygiene: omics PCA (CASTOR-HD subset)",
    "Group-coloured PCA without batch check can re-label plate effects as disease signal."
  )
}

# =============================================================================
# 8. Ch 18: week-52 snapshot vs spaghetti
# =============================================================================
long52 <- long %>% filter(weeks == 52)

p_wrong_wk52 <- ggplot(long52, aes(group, fev1, fill = group)) +
  geom_boxplot(alpha = 0.7, width = 0.55) +
  geom_jitter(width = 0.12, alpha = 0.3, size = 0.9) +
  scale_fill_manual(values = c(standard = "#94A3B8", intervention = "#1D4ED8"), guide = "none") +
  labs(
    title = "Week 52 cross-section only",
    subtitle = "Discards earlier visits and dropout pattern",
    x = NULL, y = "FEV1 at week 52 (L)"
  ) +
  viz_theme()

p_right_spag <- ggplot(long, aes(weeks, fev1, group = patient_id, colour = group)) +
  geom_line(alpha = 0.22, linewidth = 0.35) +
  scale_colour_manual(values = c(standard = "grey55", intervention = "#1D4ED8"), guide = "none") +
  labs(
    title = "Spaghetti: all scheduled visits",
    subtitle = "Each line is one participant",
    x = "Weeks from baseline", y = "FEV1 (L)"
  ) +
  viz_theme()

viz_save_pair(
  viz_tag(p_wrong_wk52, "Wrong: single time snapshot"),
  viz_tag(p_right_spag, "Right: full trajectories"),
  file.path(fig_dir, "viz_pair_ch18_longitudinal.png"),
  "Figure hygiene: longitudinal FEV1",
  "A week-52 boxplot treats survivors at one visit as the estimand; mixed models need the visit structure visible."
)

# =============================================================================
# 9. Ch 19: % event bar vs Kaplan-Meier
# =============================================================================
event_bar <- surv %>%
  group_by(smoking_lab) %>%
  summarise(
    n = n(),
    events = sum(event),
    rate = mean(event),
    .groups = "drop"
  )

p_wrong_event <- ggplot(event_bar, aes(smoking_lab, rate, fill = smoking_lab)) +
  geom_col(width = 0.55, alpha = 0.9) +
  geom_text(aes(label = sprintf("%d/%d", events, n)), vjust = -0.4, size = 3.5) +
  scale_fill_manual(values = c("Non-smoker" = "#94A3B8", "Smoker" = "#BE123C"), guide = "none") +
  scale_y_continuous(labels = scales::percent, expand = expansion(mult = c(0, 0.12))) +
  labs(
    title = "Proportion with event (ever)",
    subtitle = "Ignores when events occur and who was censored",
    x = NULL, y = "Event rate"
  ) +
  viz_theme()

fit_km <- survfit(Surv(time_days, event) ~ smoking_lab, data = surv)
km_tidy <- broom::tidy(fit_km) %>%
  filter(!is.na(estimate)) %>%
  mutate(smoking_lab = if_else(grepl("Smoker", strata), "Smoker", "Non-smoker"))

p_right_km <- ggplot(km_tidy, aes(time, estimate, colour = smoking_lab)) +
  geom_step(linewidth = 1) +
  scale_colour_manual(values = c("Non-smoker" = "#94A3B8", "Smoker" = "#BE123C")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Kaplan-Meier by smoking",
    subtitle = sprintf("%d total events; censoring explicit", sum(surv$event)),
    x = "Days to event or censoring", y = "Event-free probability", colour = NULL
  ) +
  viz_theme()

viz_save_pair(
  viz_tag(p_wrong_event, "Wrong: binary event bar"),
  viz_tag(p_right_km, "Right: KM + time axis"),
  file.path(fig_dir, "viz_pair_ch19_survival.png"),
  "Figure hygiene: time to first exacerbation",
  "Bar charts of ever/never events treat early censoring as non-events; KM shows timing and follow-up."
)

# =============================================================================
# 10. Ch 20: analysed n vs missingness pattern
# =============================================================================
analysed <- spirometry_miss %>%
  group_by(group) %>%
  summarise(
    enrolled = n(),
    analysed = sum(!is.na(fev1_obs)),
    .groups = "drop"
  ) %>%
  pivot_longer(c(enrolled, analysed), names_to = "stage", values_to = "n") %>%
  mutate(stage = if_else(stage == "enrolled", "Enrolled", "Analysed (complete FEV1)"))

p_wrong_n <- ggplot(analysed, aes(group, n, fill = stage)) +
  geom_col(position = "dodge", width = 0.65, alpha = 0.9) +
  geom_text(aes(label = n), position = position_dodge(width = 0.65), vjust = -0.4, size = 3.2) +
  scale_fill_manual(values = c("Enrolled" = "#CBD5E1", "Analysed (complete FEV1)" = "#1D4ED8")) +
  labs(
    title = "Enrolled vs analysed n",
    subtitle = "Dropout counts only: pattern hidden",
    x = NULL, y = "Participants", fill = NULL
  ) +
  viz_theme()

miss_pat <- spirometry_miss %>%
  mutate(miss = if_else(is.na(fev1_obs), "Missing FEV1", "Observed")) %>%
  arrange(diagnosis, miss, patient_id) %>%
  mutate(idx = row_number())

p_right_miss <- ggplot(miss_pat, aes(idx, factor(1), fill = miss)) +
  geom_tile(height = 0.8) +
  scale_fill_manual(values = c("Observed" = "#1D4ED8", "Missing FEV1" = "#FECACA")) +
  scale_y_discrete(expand = c(0, 0)) +
  facet_grid(diagnosis ~ group, scales = "free", space = "free_x") +
  labs(
    title = "Missing FEV1 pattern by subgroup",
    subtitle = "Who is missing, not just how many",
    x = "Participant (sorted)", y = NULL, fill = NULL
  ) +
  viz_theme() +
  theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text = element_text(size = 9)
  )

viz_save_pair(
  viz_tag(p_wrong_n, "Wrong: n-only flow"),
  viz_tag(p_right_miss, "Right: missingness pattern"),
  file.path(fig_dir, "viz_pair_ch20_missingness.png"),
  "Figure hygiene: missing spirometry",
  "Analysed-n bars hide whether missingness clusters by severity; pattern plots inform MAR/MNAR scepticism."
)

message("Visualization pairs saved to ", fig_dir)

# =============================================================================
# 11. Ch 5: line-only fit vs residual diagnostics
# =============================================================================
fit_lm5 <- lm(fev1 ~ smoking + age + sex, data = spirometry)
diag_df <- tibble(fitted = fitted(fit_lm5), resid = rstandard(fit_lm5))

p_wrong_lm <- ggplot(spirometry, aes(age, fev1, colour = smoking)) +
  geom_point(alpha = 0.35, size = 1.2) +
  geom_smooth(method = "lm", se = TRUE, colour = "#1D4ED8", fill = "#BFDBFE") +
  labs(
    title = "FEV1 vs age (smooth line only)",
    subtitle = "No residual check: leverage invisible",
    x = "Age (years)", y = "FEV1 (L)", colour = "Smoking"
  ) +
  viz_theme()

p_right_resid <- ggplot(diag_df, aes(fitted, resid)) +
  geom_point(alpha = 0.45, size = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_smooth(se = FALSE, colour = "#BE123C", linewidth = 0.8) +
  labs(
    title = "Residuals vs fitted",
    subtitle = "Check linearity and outliers before trusting coefficients",
    x = "Fitted FEV1", y = "Standardized residuals"
  ) +
  viz_theme()

viz_save_pair(
  viz_tag(p_wrong_lm, "Wrong: fit line, no diagnostics"),
  viz_tag(p_right_resid, "Right: residual check"),
  file.path(fig_dir, "viz_pair_ch05_residuals.png"),
  "Figure hygiene: linear model diagnostics",
  "A pretty smooth line does not prove linearity, homoscedasticity, or absence of influential points."
)

# =============================================================================
# 12. Ch 7: stepwise 'winner' vs prespecified model
# =============================================================================
models_fake <- tibble(
  model = c("Prespecified\n(age, sex, smoking)", "Stepwise +\nBMI", "Stepwise +\nsplines", "Stepwise +\ninteractions"),
  aic = c(412, 408, 405, 401),
  kind = c("right", "wrong", "wrong", "wrong")
)

p_wrong_step <- ggplot(models_fake, aes(reorder(model, -aic), aic, fill = kind)) +
  geom_col(width = 0.65, alpha = 0.9) +
  geom_text(aes(label = round(aic)), vjust = -0.35, size = 3.2) +
  scale_fill_manual(values = c(right = "#CBD5E1", wrong = "#FECACA"), guide = "none") +
  labs(
    title = "Lowest AIC wins (stepwise shopping)",
    subtitle = "Post hoc terms chase in-sample fit",
    x = NULL, y = "AIC (lower = selected)"
  ) +
  viz_theme() +
  theme(axis.text.x = element_text(size = 8))

p_right_prespec <- tibble(
  term = c("Intercept", "Age", "Sex (male)", "Smoking"),
  beta = c(2.1, -0.012, 0.08, -0.22)
) %>%
  ggplot(aes(reorder(term, beta), beta)) +
  geom_col(fill = "#1D4ED8", alpha = 0.85, width = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  labs(
    title = "Prespecified covariate set",
    subtitle = "SAP locked before unblinding: one defensible model",
    x = NULL, y = "Coefficient (illustrative)"
  ) +
  viz_theme()

viz_save_pair(
  viz_tag(p_wrong_step, "Wrong: stepwise AIC winner"),
  viz_tag(p_right_prespec, "Right: prespecified model"),
  file.path(fig_dir, "viz_pair_ch07_model_building.png"),
  "Figure hygiene: model building",
  "Stepwise charts look scientific but inflate optimism; confirmatory trials need prespecified covariates."
)

# =============================================================================
# 13. Ch 10: biplot hero vs scree discipline
# =============================================================================
if (requireNamespace("factoextra", quietly = TRUE)) {
  omics10 <- read_csv(file.path(paths$data, "marker_panel.csv"), show_col_types = FALSE)
  X10 <- scale(omics10 %>% select(starts_with("M")))
  pca10 <- prcomp(X10, scale. = TRUE)
  scores10 <- as_tibble(pca10$x[, 1:2]) %>%
    mutate(group = omics10$true_phenotype)

  eig <- (pca10$sdev^2) / sum(pca10$sdev^2)
  scree_df <- tibble(PC = paste0("PC", seq_along(eig)), variance = eig)

  p_wrong_biplot <- ggplot(scores10, aes(PC1, PC2, colour = factor(group))) +
    geom_point(alpha = 0.75, size = 1.6) +
    scale_colour_manual(values = c("0" = "#94A3B8", "1" = "#BE123C")) +
    labs(
      title = "PC1 vs PC2: 'disease axis'",
      subtitle = "No scree: component count assumed",
      x = "PC1", y = "PC2", colour = "Phenotype"
    ) +
    viz_theme()

  p_right_scree <- ggplot(scree_df %>% slice_head(n = 8), aes(factor(PC, levels = PC), variance)) +
    geom_col(fill = "#1D4ED8", alpha = 0.85, width = 0.7) +
    geom_line(aes(group = 1), colour = "#BE123C", linewidth = 0.8) +
    geom_point(colour = "#BE123C", size = 2) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    labs(
      title = "Scree / variance explained",
      subtitle = "Choose components before interpreting axes",
      x = NULL, y = "Variance explained"
    ) +
    viz_theme()

  viz_save_pair(
    viz_tag(p_wrong_biplot, "Wrong: 2D plot, no scree"),
    viz_tag(p_right_scree, "Right: variance explained first"),
    file.path(fig_dir, "viz_pair_ch10_pca.png"),
    "Figure hygiene: PCA exploration",
    "Pretty 2D scatter without scree and batch QC invites over-interpretation of noise axes."
  )

  # =============================================================================
  # 14. Ch 11: named endotypes vs silhouette stability
  # =============================================================================
  set.seed(2)
  km11 <- kmeans(X10, centers = 2, nstart = 25)
  scores11 <- as_tibble(pca10$x[, 1:2]) %>% mutate(cluster = factor(km11$cluster))

  sil_vals <- sapply(2:6, function(kk) {
    cl <- kmeans(X10, centers = kk, nstart = 25)$cluster
    mean(cluster::silhouette(cl, dist(X10))[, 3])
  })
  sil_df11 <- tibble(k = 2:6, silhouette = sil_vals)

  p_wrong_endo <- ggplot(scores11, aes(PC1, PC2, colour = cluster)) +
    geom_point(size = 2, alpha = 0.8) +
    scale_colour_manual(values = c("1" = "#BE123C", "2" = "#1D4ED8"), labels = c("Endotype A", "Endotype B")) +
    labs(
      title = "Two 'endotypes' (k = 2)",
      subtitle = "Named on first k-means run: no stability",
      x = "PC1", y = "PC2", colour = NULL
    ) +
    viz_theme()

  p_right_sil <- ggplot(sil_df11, aes(k, silhouette)) +
    geom_line(colour = "#1D4ED8", linewidth = 0.9) +
    geom_point(size = 3, colour = "#1D4ED8") +
    geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey60") +
    scale_x_continuous(breaks = 2:6) +
    labs(
      title = "Mean silhouette by k",
      subtitle = "Low values → overlap; stability still required",
      x = "Number of clusters", y = "Mean silhouette"
    ) +
    viz_theme()

  viz_save_pair(
    viz_tag(p_wrong_endo, "Wrong: label clusters as endotypes"),
    viz_tag(p_right_sil, "Right: silhouette + stability"),
    file.path(fig_dir, "viz_pair_ch11_clustering.png"),
    "Figure hygiene: clustering claims",
    "Naming clusters on one run is storytelling; silhouette and bootstrap stability precede 'endotype' language."
  )
}

# =============================================================================
# 15. Ch 16: screen rank vs PPV / confirmation
# =============================================================================
if (file.exists(file.path(paths$data, "antibody_screen.csv"))) {
  screen <- read_csv(file.path(paths$data, "antibody_screen.csv"), show_col_types = FALSE)
  conf <- read_csv(file.path(paths$data, "antibody_confirmation.csv"), show_col_types = FALSE)
  thr <- 1.4
  screen_sum <- screen %>%
    group_by(antigen, clone_id) %>%
    summarise(screen_mean = mean(signal_mean), true_binder = first(true_binder), .groups = "drop") %>%
    left_join(conf %>% select(clone_id, antigen, confirm_positive), by = c("clone_id", "antigen")) %>%
    mutate(
      confirm_positive = coalesce(confirm_positive, FALSE),
      hit = screen_mean > thr
    )

  top_wrong <- screen_sum %>%
    filter(antigen == "AgA") %>%
    arrange(desc(screen_mean)) %>%
    slice_head(n = 12) %>%
    mutate(rank = row_number())

  p_wrong_rank <- ggplot(top_wrong, aes(reorder(clone_id, screen_mean), screen_mean, fill = screen_mean > thr)) +
    geom_col(width = 0.7, alpha = 0.9) +
    coord_flip() +
    scale_fill_manual(values = c("TRUE" = "#BE123C", "FALSE" = "#94A3B8"), guide = "none") +
    labs(
      title = "Top screen ranks (AgA)",
      subtitle = "No PPV or confirmation layer",
      x = NULL, y = "Screen signal"
    ) +
    viz_theme()

  ppv_df <- screen_sum %>%
    filter(hit) %>%
    group_by(antigen) %>%
    summarise(
      n_hits = n(),
      n_conf = sum(confirm_positive),
      ppv = n_conf / n_hits,
      .groups = "drop"
    )

  p_right_ppv <- ggplot(ppv_df, aes(antigen, ppv, fill = antigen)) +
    geom_col(width = 0.65, alpha = 0.9) +
    geom_text(aes(label = sprintf("%d/%d", n_conf, n_hits)), vjust = -0.4, size = 3) +
    scale_y_continuous(limits = c(0, 1.05), labels = scales::percent) +
    guides(fill = "none") +
    labs(
      title = sprintf("PPV among hits (threshold = %.1f)", thr),
      subtitle = "Confirmed / hits: budget for validation",
      x = NULL, y = "PPV"
    ) +
    viz_theme()

  viz_save_pair(
    viz_tag(p_wrong_rank, "Wrong: rank bar only"),
    viz_tag(p_right_ppv, "Right: PPV among hits"),
    file.path(fig_dir, "viz_pair_ch16_screen.png"),
    "Figure hygiene: antibody screen",
    "Rank #7 vs #9 is noise without replicate stability and confirmation PPV."
  )
}

# =============================================================================
# 16. Ch 21: naive OR vs IPW balance
# =============================================================================
exac21 <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE) %>%
  mutate(smoking = as.logical(smoking))

fit_naive21 <- glm(exacerbation_12m ~ smoking + fev1_percent_predicted, data = exac21, family = binomial())
naive_or <- tidy(fit_naive21, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term == "smokingTRUE")

exac_w <- exac21 %>%
  mutate(fev1_tert = ntile(fev1_percent_predicted, 3)) %>%
  group_by(fev1_tert) %>%
  mutate(wt = if_else(smoking, 1 / mean(smoking), 1 / (1 - mean(smoking)))) %>%
  ungroup()

fit_ipw21 <- glm(exacerbation_12m ~ smoking + fev1_percent_predicted, data = exac_w, family = binomial(), weights = wt)
ipw_or <- tidy(fit_ipw21, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term == "smokingTRUE")

or_compare <- bind_rows(
  naive_or %>% mutate(model = "Naive logistic"),
  ipw_or %>% mutate(model = "IPW-weighted")
)

p_wrong_naive <- ggplot(or_compare, aes(model, estimate, fill = model)) +
  geom_col(width = 0.55, alpha = 0.9) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_text(aes(label = sprintf("%.2f", estimate)), vjust = -0.4, size = 3.5) +
  scale_fill_manual(values = c("Naive logistic" = "#FECACA", "IPW-weighted" = "#CBD5E1"), guide = "none") +
  labs(
    title = "Smoking OR (no balance check)",
    subtitle = "Causal wording risky: imbalance ignored",
    x = NULL, y = "Odds ratio (point only)"
  ) +
  viz_theme()

bal21 <- bind_rows(
  exac21 %>% group_by(smoking) %>% summarise(mean_fev1 = mean(fev1_percent_predicted), phase = "Before weighting", .groups = "drop"),
  exac_w %>% group_by(smoking) %>% summarise(mean_fev1 = weighted.mean(fev1_percent_predicted, wt), phase = "After IPW", .groups = "drop")
) %>%
  mutate(smoking = if_else(smoking, "Smoker", "Non-smoker"))

p_right_bal <- ggplot(bal21, aes(smoking, mean_fev1, fill = phase)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6, alpha = 0.9) +
  labs(
    title = "FEV1 % balance: before vs after IPW",
    subtitle = "Check overlap before causal language",
    x = NULL, y = "Mean FEV1 % predicted", fill = NULL
  ) +
  viz_theme()

viz_save_pair(
  viz_tag(p_wrong_naive, "Wrong: adjusted OR only"),
  viz_tag(p_right_bal, "Right: balance diagnostic"),
  file.path(fig_dir, "viz_pair_ch21_causal.png"),
  "Figure hygiene: observational smoking effect",
  "Naive OR bars without balance and overlap assessment do not support causal claims."
)

# =============================================================================
# 16b. Ch 22: mediation estimand (direct OR mislabeled vs total vs direct)
# =============================================================================
exac22 <- readr::read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE) %>%
  dplyr::mutate(smoking_num = as.integer(smoking), sex = factor(sex))

fit_total22 <- glm(
  exacerbation_12m ~ smoking_num + age + sex + prior_exacerbations,
  data = exac22, family = binomial()
)
fit_direct22 <- glm(
  exacerbation_12m ~ smoking_num + fev1_percent_predicted + age + sex + prior_exacerbations,
  data = exac22, family = binomial()
)

or22 <- bind_rows(
  broom::tidy(fit_direct22, conf.int = TRUE, exponentiate = TRUE) %>%
    filter(term == "smoking_num") %>%
    mutate(model = "Mislabeled: direct OR\nas total effect"),
  broom::tidy(fit_total22, conf.int = TRUE, exponentiate = TRUE) %>%
    filter(term == "smoking_num") %>%
    mutate(model = "Total OR\n(omit FEV1 %)"),
  broom::tidy(fit_direct22, conf.int = TRUE, exponentiate = TRUE) %>%
    filter(term == "smoking_num") %>%
    mutate(model = "Direct OR\n(adjust FEV1 %)")
) %>%
  mutate(model = factor(model, levels = c(
    "Mislabeled: direct OR\nas total effect",
    "Total OR\n(omit FEV1 %)",
    "Direct OR\n(adjust FEV1 %)"
  )))

p_wrong_direct <- or22 %>%
  filter(model == "Mislabeled: direct OR\nas total effect") %>%
  ggplot(aes(model, estimate, fill = model)) +
  geom_col(width = 0.55, alpha = 0.9) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_text(aes(label = sprintf("%.2f", estimate)), vjust = -0.4, size = 3.5) +
  scale_fill_manual(values = c("Mislabeled: direct OR\nas total effect" = "#FECACA"), guide = "none") +
  labs(
    title = "Smoking OR after adjusting FEV1 %",
    subtitle = "Wrong: called total effect in the abstract",
    x = NULL, y = "Odds ratio"
  ) +
  viz_theme()

p_right_compare <- or22 %>%
  filter(model != "Mislabeled: direct OR\nas total effect") %>%
  ggplot(aes(model, estimate, fill = model)) +
  geom_col(width = 0.55, alpha = 0.9) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_text(aes(label = sprintf("%.2f", estimate)), vjust = -0.4, size = 3.5) +
  scale_fill_manual(
    values = c(
      "Total OR\n(omit FEV1 %)" = "#BFDBFE",
      "Direct OR\n(adjust FEV1 %)" = "#BBF7D0"
    ),
    guide = "none"
  ) +
  labs(
    title = "Prespecified total vs direct models",
    subtitle = "Right: estimand named before interpreting ORs",
    x = NULL, y = "Odds ratio"
  ) +
  viz_theme()

viz_save_pair(
  viz_tag(p_wrong_direct, "Wrong: direct OR = total"),
  viz_tag(p_right_compare, "Right: total vs direct"),
  file.path(fig_dir, "viz_pair_ch22_mediation.png"),
  "Figure hygiene: mediation estimand",
  "Adjusting the mediator estimates a direct effect; do not report it as the total smoking effect."
)

# =============================================================================
# 17. Ch 12: integrated sign-off checklist (flowchart)
# =============================================================================
draw_signoff_checklist <- function(path) {
  items <- tibble::tribble(
    ~y, ~label, ~kind,
    10, "1. Estimand written\n(one sentence)", "start",
    8.2, "2. Table 1 + missingness\n(Ch 3)", "decide",
    6.4, "3. Method matches outcome\n(Appendix B)", "decide",
    4.6, "4. Figure matches estimand\n(Appendix I)", "decide",
    2.8, "5. Effect + 95% CI + n/events", "method",
    1.0, "6. Sensitivity named", "method",
    -0.8, "7. Limits stated\n(not proven)", "stop"
  ) %>%
    mutate(
      xmin = 18, xmax = 82,
      ymin = y - 0.75, ymax = y + 0.75,
      fill = case_when(
        kind == "start" ~ "#ECFDF5",
        kind == "decide" ~ "#EEF2FF",
        kind == "method" ~ "#FFFFFF",
        kind == "stop" ~ "#FFF1F2"
      ),
      border = case_when(
        kind == "start" ~ "#14B8A6",
        kind == "decide" ~ "#818CF8",
        kind == "method" ~ "#CBD5E1",
        kind == "stop" ~ "#F43F5E"
      )
    )

  p <- ggplot() +
    theme_void(base_family = "sans") +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5, colour = "#0F172A"),
      plot.subtitle = element_text(size = 9, hjust = 0.5, colour = "#64748B"),
      plot.caption = element_text(size = 8, colour = "#94A3B8", hjust = 0.5)
    ) +
    labs(
      title = "CASTOR sign-off checklist (investigator)",
      subtitle = "Before protocol lock, steering deck, or manuscript submission",
      caption = "Ch 12 capstone; Appendix J minimum path; Case A worked example"
    ) +
    geom_segment(
      data = items %>% slice_head(n = 6),
      aes(x = 50, y = ymin - 0.05, xend = 50, yend = lead(ymax + 0.05)),
      colour = "#94A3B8", linewidth = 0.5,
      arrow = arrow(length = unit(0.12, "cm"), type = "closed")
    ) +
    geom_rect(data = items, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = items$fill, colour = items$border, linewidth = 0.6) +
    geom_text(data = items, aes(x = 50, y = y, label = label), size = 3.2, lineheight = 0.88, colour = "#1E293B") +
    coord_cartesian(xlim = c(0, 100), ylim = c(-2, 11.5), clip = "off")

  ggsave(path, p, width = 6.5, height = 8.5, dpi = 160, bg = "white")
}

draw_signoff_checklist(file.path(fig_dir, "viz_signoff_checklist.png"))

message("Extended visualization pairs + sign-off checklist saved to ", fig_dir)
