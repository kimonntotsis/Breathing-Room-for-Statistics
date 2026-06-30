source("R/00_setup.R")

library(tidyverse)
library(broom)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)

set.seed(20250618)
spirometry_miss <- spirometry %>%
  mutate(
    missing_fev1 = rbinom(n(), 1, prob = plogis(-2 + 0.8 * (diagnosis != "no_obstruction"))) == 1,
    fev1_obs = if_else(missing_fev1, NA_real_, fev1)
  )

enrol_n <- nrow(spirometry_miss)
analysed_n <- sum(!is.na(spirometry_miss$fev1_obs))
enrol_tbl <- tibble(
  stage = c("enrolled", "fev1_observed", "fev1_missing", "complete_case_regression"),
  n = c(enrol_n, analysed_n, enrol_n - analysed_n, analysed_n)
)
write_csv(enrol_tbl, file.path(tab_dir, "ch20_enrollment_flow.csv"))

miss_summary <- spirometry_miss %>%
  group_by(diagnosis) %>%
  summarise(n = n(), missing = sum(missing_fev1), .groups = "drop") %>%
  mutate(missing_pct = round(100 * missing / n, 1))

write_csv(miss_summary, file.path(tab_dir, "ch20_missingness_by_diagnosis.csv"))

p_miss <- ggplot(spirometry_miss, aes(diagnosis, as.integer(missing_fev1), fill = diagnosis)) +
  geom_bar(stat = "summary", fun = "mean") +
  theme_minimal() +
  guides(fill = "none") +
  labs(
    title = "Missing FEV1 fraction by obstruction severity (synthetic MAR)",
    subtitle = sprintf("Overall missing: %d / %d (%.1f%%)", enrol_n - analysed_n, enrol_n,
                       100 * (enrol_n - analysed_n) / enrol_n),
    x = NULL,
    y = "Proportion missing"
  )

ggsave(file.path(fig_dir, "ch20_missingness_pattern.png"), p_miss, width = 6.8, height = 4.4, dpi = 160)

fit_cc <- lm(fev1_obs ~ smoking + age + sex, data = spirometry_miss, na.action = na.omit)
spirometry_miss <- spirometry_miss %>%
  mutate(fev1_imp = if_else(is.na(fev1_obs), median(fev1, na.rm = TRUE), fev1_obs))
fit_imp <- lm(fev1_imp ~ smoking + age + sex, data = spirometry_miss)

compare <- bind_rows(
  tidy(fit_cc, conf.int = TRUE) %>% mutate(analysis = "complete_case"),
  tidy(fit_imp, conf.int = TRUE) %>% mutate(analysis = "median_impute")
) %>%
  filter(term == "smokingTRUE") %>%
  mutate(coef_ci = sprintf("%.3f (%.3f to %.3f)", estimate, conf.low, conf.high))

write_csv(compare, file.path(tab_dir, "ch20_smoking_coef_sensitivity.csv"))

# --- MICE (production demo): m = 20 imputations, pooled lm ---
mice_ok <- requireNamespace("mice", quietly = TRUE)
if (mice_ok) {
  imp_df <- spirometry_miss %>%
    mutate(
      diagnosis = factor(diagnosis),
      sex = factor(sex),
      smoking = factor(smoking)
    ) %>%
    select(fev1_obs, age, sex, smoking, diagnosis)

  set.seed(20250618)
  imp <- mice::mice(imp_df, m = 20, maxit = 5, printFlag = FALSE, seed = 20250618)
  fit_mi <- with(imp, lm(fev1_obs ~ smoking + age + sex))
  pooled <- mice::pool(fit_mi)
  mice_smoking <- broom::tidy(pooled, conf.int = TRUE) %>%
    filter(term == "smokingTRUE") %>%
    mutate(
      analysis = "mice_pooled",
      coef_ci = sprintf("%.3f (%.3f to %.3f)", estimate, conf.low, conf.high)
    )

  compare <- bind_rows(compare, mice_smoking %>% select(term, estimate, conf.low, conf.high, analysis, coef_ci))
  write_csv(compare, file.path(tab_dir, "ch20_smoking_coef_sensitivity.csv"))

  # Observed vs imputed FEV1 (first imputation) for diagnostic plot
  imp1 <- mice::complete(imp, 1)
  diag_df <- bind_rows(
    imp_df %>% filter(!is.na(fev1_obs)) %>% transmute(fev1 = fev1_obs, source = "observed"),
    imp_df %>% filter(is.na(fev1_obs)) %>%
      mutate(fev1 = imp1$fev1_obs[is.na(imp_df$fev1_obs)]) %>%
      transmute(fev1, source = "imputed (draw 1)")
  )

  p_mice <- ggplot(diag_df, aes(fev1, fill = source)) +
    geom_histogram(alpha = 0.55, position = "identity", bins = 25) +
    theme_minimal() +
    labs(
      title = "MICE diagnostic: observed vs imputed FEV1 (imputation 1)",
      subtitle = "Imputed values should sit in a plausible range, not a spike at one number",
      x = "FEV1 (L)",
      y = "Count"
    )

  ggsave(file.path(fig_dir, "ch20_mice_density.png"), p_mice, width = 7, height = 4.2, dpi = 160)
  message("Chapter 20 MICE: smoking coef = ", round(mice_smoking$estimate, 3),
          " (pooled, m = 20)")
} else {
  message("Install package 'mice' for MICE demo: install.packages(\"mice\")")
}

p_sens <- compare %>%
  ggplot(aes(x = estimate, y = analysis, xmin = conf.low, xmax = conf.high)) +
  geom_point(size = 2.5) +
  geom_errorbarh(height = 0.2) +
  geom_vline(xintercept = 0, linetype = 2, color = "grey50") +
  theme_minimal() +
  labs(
    title = "Smoking coefficient sensitivity: complete-case vs median imputation",
    subtitle = "Outcome: FEV1 (L); teaching contrast; use MICE in production",
    x = "Coefficient (smoking vs non-smoking)",
    y = NULL
  )

ggsave(file.path(fig_dir, "ch20_smoking_coef_sensitivity.png"), p_sens, width = 6.8, height = 3.8, dpi = 160)

message("Chapter 20: enrolled = ", enrol_n, "; analysed = ", analysed_n,
        "; missing = ", enrol_n - analysed_n)
