source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(lme4)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

long <- read_csv(file.path(paths$data, "longitudinal_spirometry.csv"), show_col_types = FALSE)

visit_tbl <- long %>%
  count(weeks, group) %>%
  pivot_wider(names_from = group, values_from = n, values_fill = 0)
write_csv(visit_tbl, file.path(tab_dir, "ch18_visit_counts_by_group.csv"))

p_spaghetti <- long %>%
  ggplot(aes(weeks, fev1, group = patient_id, colour = group)) +
  geom_line(alpha = 0.28, linewidth = 0.45) +
  scale_color_manual(values = handbook_arm_colors, labels = c("Standard", "Intervention")) +
  guides(color = "none") +
  labs(
    title = "Longitudinal FEV1 (CASTOR extension)",
    subtitle = "Spaghetti plot: each line is one participant",
    x = "Weeks from baseline",
    y = "FEV1 (L)"
  ) +
  handbook_theme()

handbook_save(p_spaghetti, file.path(fig_dir, "ch18_spaghetti_fev1.png"), 7.2, 4.6)

long_ridge <- long %>%
  mutate(weeks_f = factor(weeks, levels = sort(unique(weeks))))

p_ridge <- plot_density_ridge(
  long_ridge, "fev1", "weeks_f", fill = "group",
  title = "Ridge plot: FEV1 distribution by visit week",
  subtitle = "Colour = trial arm; distribution shifts across follow-up",
  xlab = "FEV1 (L)", ylab = "Week"
)
handbook_save(p_ridge, file.path(fig_dir, "ch18_fev1_ridge.png"), 7.4, 5.4)

long_m <- long %>% mutate(
  group = factor(group, levels = c("standard", "intervention")),
  sex = factor(sex),
  smoking = as.logical(smoking)
)

fit_mixed <- lmer(
  fev1 ~ weeks * group + age + sex + smoking + (1 | patient_id),
  data = long_m
)

coef_tbl <- as.data.frame(summary(fit_mixed)$coefficients) %>%
  rownames_to_column("term") %>%
  rename(estimate = Estimate, std.error = `Std. Error`, statistic = `t value`)

write_csv(coef_tbl, file.path(tab_dir, "ch18_mixed_model_coefficients.csv"))

# Sensitivity: cross-sectional lm at week 52 only vs mixed model (teaching contrast)
wk52 <- long_m %>% filter(weeks == 52)
fit_lm52 <- lm(fev1 ~ group + age + sex + smoking, data = wk52)
lm52_out <- summary(fit_lm52)$coefficients["groupintervention", , drop = FALSE]
lmer_out <- summary(fit_mixed)$coefficients["groupintervention", , drop = FALSE]
sens <- tibble(
  model = c("lm_week52_cross_section", "lmer_all_visits"),
  term = "groupintervention",
  estimate = c(lm52_out[, "Estimate"], lmer_out[, "Estimate"]),
  std.error = c(lm52_out[, "Std. Error"], lmer_out[, "Std. Error"])
)
write_csv(sens, file.path(tab_dir, "ch18_sensitivity_mixed_vs_fixed.csv"))

pred_grid <- expand_grid(
  weeks = c(0, 12, 24, 52),
  group = factor(c("standard", "intervention"), levels = c("standard", "intervention")),
  age = median(long$age),
  sex = factor("female", levels = c("female", "male")),
  smoking = FALSE
) %>%
  mutate(fev1_hat = predict(fit_mixed, newdata = ., re.form = NA))

p_fit <- ggplot(long_m, aes(weeks, fev1, colour = group)) +
  geom_point(alpha = 0.12, size = 1.1, colour = "#CBD5E1") +
  geom_line(data = pred_grid, aes(y = fev1_hat), linewidth = 1.15) +
  scale_color_manual(values = handbook_arm_colors, labels = c("Standard", "Intervention")) +
  labs(
    title = "Mixed model fitted means (population level)",
    subtitle = "lmer: fev1 ~ weeks * group + covariates + (1|patient_id)",
    x = "Weeks",
    y = "FEV1 (L)",
    colour = NULL
  ) +
  handbook_theme()

handbook_save(p_fit, file.path(fig_dir, "ch18_mixed_model_fitted.png"), 7.4, 4.8)

message("Chapter 18: participants = ", n_distinct(long$patient_id),
        "; visits = ", nrow(long))
