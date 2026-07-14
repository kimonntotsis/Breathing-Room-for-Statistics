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
  p_value = c(med_out$d0.p, med_out$z0.p, med_out$tau.p, med_out$n0.p)
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

path_nodes <- tribble(
  ~node, ~x, ~y, ~fill,
  "Smoking", 1, 2, "#FECACA",
  "FEV1 % pred.", 3, 2, "#E0F2FE",
  "Exacerbation\n(12 m)", 5, 2, "#DCFCE7"
)

path_edges <- tribble(
  ~x, ~y, ~xend, ~yend, ~label, ~path,
  1.55, 2, 2.45, 2, "a", "a",
  3.55, 2, 4.45, 2, "b", "b",
  1.55, 2.15, 4.45, 2.15, "c'", "c"
)

p_path <- ggplot() +
  geom_segment(
    data = path_edges,
    aes(x = x, y = y, xend = xend, yend = yend),
    arrow = arrow(length = unit(0.22, "cm"), type = "closed"),
    linewidth = 0.9,
    colour = "#334155"
  ) +
  geom_label(
    data = path_nodes,
    aes(x = x, y = y, label = node, fill = fill),
    colour = "#0F172A",
    linewidth = 0.2,
    size = 4.2
  ) +
  geom_text(
    data = path_edges,
    aes(x = (x + xend) / 2, y = y + if_else(path == "c", 0.22, 0.18), label = label),
    size = 4,
    colour = "#64748B"
  ) +
  scale_fill_identity() +
  coord_cartesian(xlim = c(0.4, 5.6), ylim = c(1.4, 2.8), clip = "off") +
  theme_void(base_family = "sans") +
  labs(
    title = "Mediation path: smoking, FEV1 %, 12-month exacerbation",
    subtitle = "Prespecified decomposition; adjust age, sex, prior exacerbations in each equation",
    caption = "CASTOR exacerbation.csv teaching example"
  )

handbook_save(p_path, file.path(fig_dir, "ch22_mediation_path.png"), 7.4, 3.2)

  p_forest <- med_summary %>%
  filter(effect != "Prop. mediated") %>%
  mutate(label = factor(label, levels = rev(label))) %>%
  ggplot(aes(x = estimate, y = label, xmin = ci_low, xmax = ci_high)) +
  geom_vline(xintercept = 0, linetype = 2, colour = "#94A3B8") +
  geom_point(size = 3, colour = handbook_cols$accent) +
  geom_errorbar(orientation = "y", width = 0.18, linewidth = 0.7, colour = handbook_cols$accent) +
  labs(
    title = "Mediation effects on log-odds scale (bootstrap)",
    subtitle = "Binary outcome; continuous mediator; 500 simulations",
    x = "Effect estimate (log-odds difference)",
    y = NULL
  ) +
  handbook_theme()

handbook_save(p_forest, file.path(fig_dir, "ch22_mediation_effects.png"), 7.2, 4.2)

p_or <- or_compare %>%
  mutate(
    estimand = factor(
      estimand,
      levels = c("total_effect_no_mediator", "direct_effect_with_mediator"),
      labels = c("Total (omit FEV1 %)", "Direct (adjust FEV1 %)")
    )
  ) %>%
  ggplot(aes(x = estimate, y = estimand, xmin = conf.low, xmax = conf.high)) +
  geom_vline(xintercept = 1, linetype = 2, colour = "#94A3B8") +
  geom_point(size = 3, colour = handbook_cols$smoker) +
  geom_errorbar(orientation = "y", width = 0.2, linewidth = 0.7, colour = handbook_cols$smoker) +
  scale_x_log10() +
  labs(
    title = "Smoking OR: total vs direct effect models",
    subtitle = "Adjusting the mediator targets the direct path, not the total effect",
    x = "Odds ratio (log scale)",
    y = NULL
  ) +
  handbook_theme()

handbook_save(p_or, file.path(fig_dir, "ch22_total_vs_direct_or.png"), 7.0, 3.8)

message(
  "Chapter 22 mediation complete. Total OR = ",
  round(or_compare$estimate[1], 2),
  "; direct OR = ",
  round(or_compare$estimate[2], 2),
  "; ACME = ",
  round(med_out$d0, 3)
)
