source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(survival)
library(broom)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

surv <- read_csv(file.path(paths$data, "time_to_exacerbation.csv"), show_col_types = FALSE) %>%
  mutate(
    smoking = as.logical(smoking),
    smoking_lab = ifelse(smoking, "Smoker", "Non-smoker"),
    therapy = factor(therapy, levels = c("ICS", "ICS_LABA", "triple"))
  )

events_tbl <- surv %>%
  group_by(smoking) %>%
  summarise(
    n = n(),
    events = sum(event),
    censored = sum(1 - event),
    med_time = median(time_days),
    .groups = "drop"
  )
write_csv(events_tbl, file.path(tab_dir, "ch19_events_by_smoking.csv"))

fit_km <- survfit(Surv(time_days, event) ~ smoking_lab, data = surv)
lr <- survdiff(Surv(time_days, event) ~ smoking_lab, data = surv)
logrank_p <- 1 - pchisq(lr$chisq, df = 1)

km_tidy <- tidy(fit_km, conf.int = TRUE) %>%
  filter(!is.na(estimate)) %>%
  mutate(
    smoking_lab = ifelse(grepl("Smoker", strata), "Smoker", "Non-smoker"),
    surv = estimate
  )

n_events_smoker <- sum(surv$event & surv$smoking)
n_events_nonsmoker <- sum(surv$event & !surv$smoking)

p_km <- plot_km_handbook(
  km_tidy,
  time = "time",
  surv = "surv",
  group = "smoking_lab",
  conf.low = "conf.low",
  conf.high = "conf.high",
  title = sprintf("Kaplan-Meier by smoking (log-rank p = %.3f)", logrank_p),
  subtitle = sprintf(
    "%d events in 365 d (%d smokers, %d non-smokers); ribbons = 95%% CI",
    sum(surv$event), n_events_smoker, n_events_nonsmoker
  ),
  xlab = "Days to first exacerbation or censoring",
  ylab = "Event-free probability"
)

handbook_save(p_km, file.path(fig_dir, "ch19_km_by_smoking.png"), 7.4, 4.8)

fit_cox <- coxph(
  Surv(time_days, event) ~ smoking + fev1_percent_predicted + therapy + age,
  data = surv
)

cox_tbl <- tidy(fit_cox, conf.int = TRUE, exponentiate = TRUE) %>%
  mutate(hr_ci = sprintf("%.2f (%.2f to %.2f)", estimate, conf.low, conf.high))

write_csv(cox_tbl, file.path(tab_dir, "ch19_cox_hazard_ratios.csv"))

ph_test <- cox.zph(fit_cox)
ph_tbl <- as.data.frame(ph_test$table) %>%
  rownames_to_column("term") %>%
  rename(chisq = chisq, df = df, p = p)
write_csv(ph_tbl, file.path(tab_dir, "ch19_cox_ph_test.csv"))

p_forest <- plot_forest_ratio(
  cox_tbl %>% filter(term != "(Intercept)"),
  title = "Cox model hazard ratios (95% CI)",
  subtitle = "Adjusted for FEV1 %, therapy, age; log scale",
  xlab = "Hazard ratio (95% CI, log scale)"
)

handbook_save(p_forest, file.path(fig_dir, "ch19_cox_forest.png"), 7.0, 4.4)

message(
  "Chapter 19 survival: events = ", sum(surv$event), "/", nrow(surv),
  "; log-rank p = ", signif(logrank_p, 3)
)
