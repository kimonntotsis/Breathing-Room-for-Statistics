source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(broom)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

exac <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE) %>%
  mutate(
    smoking = as.logical(smoking),
    sex = factor(sex)
  )

# Confounders for total-effect estimand (FEV1 is a mediator, not in PS or outcome model)
confounders <- c("age", "sex", "prior_exacerbations")

# Naive adjusted: confounders only (not FEV1)
fit_naive <- glm(
  exacerbation_12m ~ smoking + age + sex + prior_exacerbations,
  data = exac,
  family = binomial()
)

# Propensity score for smoking given measured confounders
ps_formula <- as.formula(paste("smoking ~", paste(confounders, collapse = " + ")))
ps_fit <- glm(ps_formula, data = exac, family = binomial())
exac <- exac %>%
  mutate(
    ps = pmin(pmax(predict(ps_fit, type = "response"), 0.05), 0.95),
    wt = if_else(smoking, 1 / ps, 1 / (1 - ps))
  )

# Marginal IPW: smoking only, no FEV1 adjustment
fit_ipw <- glm(exacerbation_12m ~ smoking, data = exac, family = binomial(), weights = wt)

robust_or <- function(fit, term = "smokingTRUE") {
  vc <- sandwich::vcovHC(fit, type = "HC1")
  ct <- lmtest::coeftest(fit, vc)
  est_log <- unname(ct[term, "Estimate"])
  se_log <- unname(ct[term, "Std. Error"])
  z <- qnorm(0.975)
  p_col <- if ("Pr(>|z|)" %in% colnames(ct)) "Pr(>|z|)" else "Pr(>|t|)"
  stat_col <- if ("z value" %in% colnames(ct)) "z value" else "t value"
  tibble(
    term = term,
    estimate = exp(est_log),
    std.error = se_log,
    statistic = unname(ct[term, stat_col]),
    p.value = unname(ct[term, p_col]),
    conf.low = exp(est_log - z * se_log),
    conf.high = exp(est_log + z * se_log)
  )
}

ipw_compare <- bind_rows(
  tidy(fit_naive, conf.int = TRUE, exponentiate = TRUE) %>% mutate(model = "adjusted_confounders"),
  robust_or(fit_ipw) %>% mutate(model = "ipw_marginal")
) %>%
  filter(term == "smokingTRUE") %>%
  mutate(or_ci = sprintf("%.2f (%.2f to %.2f)", estimate, conf.low, conf.high))

write_csv(ipw_compare, file.path(tab_dir, "ch21_smoking_or_naive_vs_ipw.csv"))

bal_before <- exac %>%
  group_by(smoking) %>%
  summarise(
    phase = "before_weighting",
    mean_age = mean(age),
    mean_prior_exac = mean(prior_exacerbations),
    .groups = "drop"
  )

bal_after <- exac %>%
  group_by(smoking) %>%
  summarise(
    phase = "after_ipw",
    mean_age = weighted.mean(age, wt),
    mean_prior_exac = weighted.mean(prior_exacerbations, wt),
    .groups = "drop"
  )

bal_long <- bind_rows(bal_before, bal_after) %>%
  pivot_longer(c(mean_age, mean_prior_exac), names_to = "covariate", values_to = "value")

write_csv(bal_long, file.path(tab_dir, "ch21_balance_before_after_ipw.csv"))

bal_plot <- bal_long %>%
  mutate(
    covariate = recode(covariate,
      mean_age = "Age (years)",
      mean_prior_exac = "Prior exacerbations (mean)"
    ),
    phase = factor(phase, levels = c("before_weighting", "after_ipw"),
                   labels = c("Before IPW", "After IPW"))
  )

p_bal <- plot_balance_slopegraph(
  bal_plot,
  covariate = "covariate",
  group = "smoking",
  phase = "phase",
  value = "value",
  phase_levels = c("Before IPW", "After IPW"),
  title = "Covariate balance: confounders before vs after IPW",
  subtitle = "Lines should move toward overlap; FEV1 excluded (mediator on total-effect path)",
  ylab = "Mean (or weighted mean)",
  group_labels = c("Non-smoker", "Smoker"),
  group_colours = c("FALSE" = handbook_cols$nonsmoker, "TRUE" = handbook_cols$smoker)
)

handbook_save(p_bal, file.path(fig_dir, "ch21_covariate_balance.png"), 7.6, 4.6)

p_or <- plot_forest_ratio(
  ipw_compare %>% mutate(model = recode(model,
    adjusted_confounders = "Adjusted (confounders)",
    ipw_marginal = "IPW marginal (robust SE)"
  )),
  term = "model",
  title = "Smoking OR: confounder-adjusted vs marginal IPW",
  subtitle = "Total-effect estimand; FEV1 excluded from both models",
  xlab = "Odds ratio (95% CI, log scale)",
  point_color = handbook_cols$smoker
)

handbook_save(p_or, file.path(fig_dir, "ch21_or_naive_vs_ipw.png"), 7.0, 3.6)

wt_summary <- tibble(
  min_wt = min(exac$wt),
  max_wt = max(exac$wt),
  mean_wt = mean(exac$wt),
  pct_wt_above_5 = mean(exac$wt > 5) * 100
)
write_csv(wt_summary, file.path(tab_dir, "ch21_ipw_weight_summary.csv"))

message(
  "Chapter 21 causal inference complete. Adjusted OR = ",
  round(ipw_compare$estimate[1], 2),
  "; IPW OR = ",
  round(ipw_compare$estimate[2], 2)
)
