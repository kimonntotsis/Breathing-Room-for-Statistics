# Case study F: asthma biologic trial (synthetic teaching data)
source("R/00_setup.R")
library(tidyverse)
library(broom)

asthma <- read_csv(file.path(paths$data, "asthma_biologic_trial.csv"), show_col_types = FALSE) %>%
  mutate(arm = factor(arm, levels = c("placebo", "biologic")))

# Table 1 style summaries
asthma %>%
  group_by(arm) %>%
  summarise(
    n = n(),
    age_mean = mean(age),
    fev1_baseline = mean(baseline_fev1_l),
    fev1_week12 = mean(post_bd_fev1_week12_l),
    exac_rate = sum(severe_exacerbations_52w) / sum(followup_years),
    .groups = "drop"
  ) %>%
  print()

# Primary: ANCOVA week-12 post-BD FEV1 adjusting baseline
fit_ancova <- lm(
  post_bd_fev1_week12_l ~ arm + baseline_fev1_l + age + sex,
  data = asthma
)
tidy(fit_ancova, conf.int = TRUE) %>%
  filter(term == "armbiologic") %>%
  print()

# Secondary: severe exacerbation rate (NB with offset)
if (requireNamespace("MASS", quietly = TRUE)) {
  fit_nb <- MASS::glm.nb(
    severe_exacerbations_52w ~ arm + offset(log(followup_years)),
    data = asthma
  )
  tidy(fit_nb, conf.int = TRUE, exponentiate = TRUE) %>%
    filter(term == "armbiologic") %>%
    print()
}

message("Case study F (asthma biologic trial) complete.")
