source("R/00_setup.R")

library(tidyverse)
library(broom)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

exac <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE) %>%
  mutate(smoking = as.logical(smoking))

fit_naive <- glm(exacerbation_12m ~ smoking + fev1_percent_predicted, data = exac, family = binomial())

exac <- exac %>%
  mutate(fev1_tert = ntile(fev1_percent_predicted, 3)) %>%
  group_by(fev1_tert) %>%
  mutate(
    p_smoke = mean(smoking),
    wt = if_else(smoking, 1 / p_smoke, 1 / (1 - p_smoke))
  ) %>%
  ungroup()

fit_ipw <- glm(
  exacerbation_12m ~ smoking + fev1_percent_predicted,
  data = exac,
  family = binomial(),
  weights = wt
)

ipw_compare <- bind_rows(
  tidy(fit_naive, conf.int = TRUE, exponentiate = TRUE) %>% mutate(model = "naive_logistic"),
  tidy(fit_ipw, conf.int = TRUE, exponentiate = TRUE) %>% mutate(model = "ipw_weighted")
) %>%
  filter(term == "smokingTRUE") %>%
  mutate(or_ci = sprintf("%.2f (%.2f to %.2f)", estimate, conf.low, conf.high))

write_csv(ipw_compare, file.path(tab_dir, "ch21_smoking_or_naive_vs_ipw.csv"))

bal_before <- exac %>%
  group_by(smoking) %>%
  summarise(phase = "before_weighting", mean_fev1 = mean(fev1_percent_predicted), .groups = "drop")

bal_after <- exac %>%
  group_by(smoking) %>%
  summarise(
    phase = "after_ipw_on_tertiles",
    mean_fev1 = weighted.mean(fev1_percent_predicted, wt),
    .groups = "drop"
  )

bal_tbl <- bind_rows(bal_before, bal_after)
write_csv(bal_tbl, file.path(tab_dir, "ch21_balance_before_after_ipw.csv"))

p_bal <- bal_tbl %>%
  mutate(smoking = factor(smoking, levels = c(FALSE, TRUE), labels = c("Non-smoker", "Smoker"))) %>%
  ggplot(aes(smoking, mean_fev1, fill = phase)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_fill_manual(values = c("before_weighting" = "grey70", "after_ipw_on_tertiles" = "steelblue")) +
  theme_minimal() +
  labs(
    title = "FEV1 % balance: before vs IPW-weighted (toy)",
    subtitle = "Teaching IPW on FEV1 tertiles, not a full propensity model",
    x = NULL,
    y = "Mean (or weighted mean) FEV1 % predicted",
    fill = NULL
  )

ggsave(file.path(fig_dir, "ch21_covariate_balance.png"), p_bal, width = 7.0, height = 4.2, dpi = 160)

p_or <- ipw_compare %>%
  ggplot(aes(x = estimate, y = model, xmin = conf.low, xmax = conf.high)) +
  geom_point(size = 2.5) +
  geom_errorbarh(height = 0.2) +
  geom_vline(xintercept = 1, linetype = 2, color = "grey50") +
  scale_x_log10() +
  theme_minimal() +
  labs(
    title = "Smoking OR: naive vs IPW-weighted logistic",
    x = "Odds ratio (log scale)",
    y = NULL
  )

ggsave(file.path(fig_dir, "ch21_or_naive_vs_ipw.png"), p_or, width = 6.8, height = 3.6, dpi = 160)

wt_summary <- tibble(
  min_wt = min(exac$wt),
  max_wt = max(exac$wt),
  mean_wt = mean(exac$wt),
  pct_wt_above_5 = mean(exac$wt > 5) * 100
)
write_csv(wt_summary, file.path(tab_dir, "ch21_ipw_weight_summary.csv"))

message("Chapter 21 causal inference complete. Naive OR = ",
        round(ipw_compare$estimate[1], 2), "; IPW OR = ", round(ipw_compare$estimate[2], 2))
