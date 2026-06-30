source("R/00_setup.R")

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

km_tidy <- tidy(fit_km) %>%
  filter(!is.na(estimate)) %>%
  mutate(
    smoking_lab = ifelse(grepl("Smoker", strata), "Smoker", "Non-smoker"),
    surv = estimate
  )

ymin <- max(0, min(km_tidy$surv, na.rm = TRUE) - 0.08)
n_events_smoker <- sum(surv$event & surv$smoking)
n_events_nonsmoker <- sum(surv$event & !surv$smoking)

p_km <- ggplot(km_tidy, aes(time, surv, color = smoking_lab)) +
  geom_step(linewidth = 1.1) +
  scale_color_manual(values = c("Non-smoker" = "grey40", "Smoker" = "#B22222")) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 1),
    limits = c(ymin, 1),
    expand = expansion(mult = c(0.02, 0))
  ) +
  scale_x_continuous(expand = expansion(mult = c(0.02, 0.02))) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = c(0.78, 0.28),
    legend.background = element_rect(fill = "white", color = NA),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = sprintf("Kaplan-Meier by smoking (log-rank p = %.3f)", logrank_p),
    subtitle = sprintf(
      "%d events in 365 d (%d smokers, %d non-smokers); y-axis zoomed to observed range",
      sum(surv$event), n_events_smoker, n_events_nonsmoker
    ),
    x = "Days to first exacerbation or censoring",
    y = "Event-free probability",
    color = NULL
  )

ggsave(file.path(fig_dir, "ch19_km_by_smoking.png"), p_km, width = 7.2, height = 4.8, dpi = 160)

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

p_forest <- cox_tbl %>%
  filter(term != "(Intercept)") %>%
  ggplot(aes(x = estimate, y = term)) +
  geom_point(size = 2.5) +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), orientation = "y", width = 0.2) +
  geom_vline(xintercept = 1, linetype = 2, color = "grey50") +
  scale_x_log10() +
  theme_minimal() +
  labs(
    title = "Cox model hazard ratios (95% CI)",
    x = "Hazard ratio (log scale)",
    y = NULL
  )

ggsave(file.path(fig_dir, "ch19_cox_forest.png"), p_forest, width = 6.8, height = 4.2, dpi = 160)

message(
  "Chapter 19 survival: events = ", sum(surv$event), "/", nrow(surv),
  "; log-rank p = ", signif(logrank_p, 3)
)
