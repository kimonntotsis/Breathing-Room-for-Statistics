source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(broom)
library(mediation)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

exac <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE) %>%
  mutate(
    smoking = as.logical(smoking),
    smoking_num = as.integer(smoking),
    sex = factor(sex)
  )

covars <- c("age", "sex", "prior_exacerbations")

fit_m <- lm(
  fev1_percent_predicted ~ smoking_num + age + sex + prior_exacerbations,
  data = exac
)

fit_y <- glm(
  exacerbation_12m ~ smoking_num + fev1_percent_predicted + age + sex + prior_exacerbations,
  data = exac,
  family = binomial()
)

fit_total <- glm(
  exacerbation_12m ~ smoking_num + age + sex + prior_exacerbations,
  data = exac,
  family = binomial()
)

path_coefs <- bind_rows(
  tidy(fit_m, conf.int = TRUE) %>% mutate(model = "mediator_fev1"),
  tidy(fit_y, conf.int = TRUE, exponentiate = TRUE) %>% mutate(model = "outcome_logistic")
) %>%
  filter(term %in% c("smoking_num", "fev1_percent_predicted"))

write_csv(path_coefs, file.path(tab_dir, "ch22_path_coefficients.csv"))

or_compare <- bind_rows(
  tidy(fit_total, conf.int = TRUE, exponentiate = TRUE) %>%
    filter(term == "smoking_num") %>%
    mutate(estimand = "total_effect_no_mediator"),
  tidy(fit_y, conf.int = TRUE, exponentiate = TRUE) %>%
    filter(term == "smoking_num") %>%
    mutate(estimand = "direct_effect_with_mediator")
) %>%
  mutate(or_ci = sprintf("%.2f (%.2f to %.2f)", estimate, conf.low, conf.high))

write_csv(or_compare, file.path(tab_dir, "ch22_total_vs_direct_or.csv"))

set.seed(20260628)
med_out <- mediate(
  fit_m,
  fit_y,
  treat = "smoking_num",
  mediator = "fev1_percent_predicted",
  boot = TRUE,
  sims = 500
)

med_summary <- tibble(
  effect = c("ACME (indirect)", "ADE (direct)", "Total effect", "Prop. mediated"),
  estimate = c(med_out$d0, med_out$z0, med_out$tau.coef, med_out$n0),
  ci_low = c(med_out$d0.ci[1], med_out$z0.ci[1], med_out$tau.ci[1], med_out$n0.ci[1]),
  ci_high = c(med_out$d0.ci[2], med_out$z0.ci[2], med_out$tau.ci[2], med_out$n0.ci[2]),
  p_value = c(med_out$d0.p, med_out$z0.p, med_out$tau.p, med_out$n0.p),
  scale = "average difference in predicted probability (binary outcome)"
) %>%
  mutate(
    label = case_when(
      effect == "ACME (indirect)" ~ "Natural indirect effect (via FEV1 %)",
      effect == "ADE (direct)" ~ "Natural direct effect (not via FEV1 %)",
      effect == "Total effect" ~ "Total effect",
      TRUE ~ "Proportion mediated"
    ),
    display = if_else(
      effect == "Prop. mediated",
      sprintf("%.2f (%.2f to %.2f)", estimate, ci_low, ci_high),
      sprintf("%.3f (%.3f to %.3f)", estimate, ci_low, ci_high)
    )
  )

write_csv(med_summary, file.path(tab_dir, "ch22_mediation_effects.csv"))

p_path <- plot_mediation_path_handbook(
  title = "Mediation path: smoking, FEV1 %, 12-month exacerbation",
  subtitle = "Prespecified decomposition; adjust age, sex, prior exacerbations in each equation"
)

handbook_save(p_path, file.path(fig_dir, "ch22_mediation_path.png"), 8.2, 3.8)

p_forest <- plot_coef_sensitivity(
  med_summary %>%
    filter(effect != "Prop. mediated") %>%
    mutate(
      analysis = label,
      conf.low = ci_low,
      conf.high = ci_high
    ),
  y = "analysis",
  title = "Natural effects on probability scale (bootstrap)",
  subtitle = "Binary outcome; ACME/ADE = average differences in predicted P(exacerbation)",
  xlab = "Effect estimate (probability difference)",
  point_color = handbook_cols$accent
)

handbook_save(p_forest, file.path(fig_dir, "ch22_mediation_effects.png"), 7.2, 4.2)

p_or <- plot_forest_ratio(
  or_compare %>%
    mutate(
      estimand = recode(estimand,
        total_effect_no_mediator = "Total (omit FEV1 %)",
        direct_effect_with_mediator = "Direct (adjust FEV1 %)"
      )
    ),
  term = "estimand",
  title = "Smoking OR: total vs direct effect models",
  subtitle = "Adjusting the mediator targets the direct path, not the total effect",
  xlab = "Odds ratio (95% CI, log scale)",
  point_color = handbook_cols$smoker
)

handbook_save(p_or, file.path(fig_dir, "ch22_total_vs_direct_or.png"), 7.0, 3.8)

message(
  "Chapter 22 mediation complete. Total OR = ",
  round(or_compare$estimate[1], 2),
  "; direct OR = ",
  round(or_compare$estimate[2], 2),
  "; ACME = ",
  round(med_out$d0, 3)
)
