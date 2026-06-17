source("R/00_setup.R")

library(tidyverse)
library(broom)

exac <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE)
counts <- read_csv(file.path(paths$data, "exacerbation_counts.csv"), show_col_types = FALSE)
counts_zi <- read_csv(file.path(paths$data, "exacerbation_zero_inflated.csv"), show_col_types = FALSE)

# --- Logistic regression ---
logit_fit <- glm(
  exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
  data = exac, family = binomial
)
print(tidy(logit_fit, conf.int = TRUE, exponentiate = TRUE))
message("Events: ", sum(exac$exacerbation_12m), " / n = ", nrow(exac))

# --- Log-binomial (risk ratios) ---
logbin_fit <- tryCatch(
  glm(exacerbation_12m ~ smoking + age + fev1_percent_predicted,
      data = exac, family = binomial(link = "log")),
  error = function(e) { message("Log-binomial: ", e$message); NULL }
)
if (!is.null(logbin_fit)) {
  print(tidy(logbin_fit, conf.int = TRUE, exponentiate = TRUE))
}

# --- Firth penalized logistic (separation-resistant) ---
if (requireNamespace("logistf", quietly = TRUE)) {
  firth_fit <- logistf::logistf(
    exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
    data = exac
  )
  print(exp(coef(firth_fit)))
  print(exp(confint(firth_fit)))
} else {
  message("Install logistf: install.packages('logistf')")
}

# Marginal predictions
if (requireNamespace("emmeans", quietly = TRUE)) {
  print(emmeans::emmeans(logit_fit, ~ smoking, type = "response"))
}

# --- Poisson with offset ---
pois_off <- glm(
  exacerbations_12m ~ smoking + ics_adherence + offset(log(person_years)),
  data = counts, family = poisson
)
print(tidy(pois_off, conf.int = TRUE, exponentiate = TRUE))

# --- Negative binomial ---
nb_fit <- MASS::glm.nb(exacerbations_12m ~ smoking + ics_adherence, data = counts)
print(tidy(nb_fit, conf.int = TRUE, exponentiate = TRUE))

# --- Zero-inflated Poisson ---
if (requireNamespace("pscl", quietly = TRUE)) {
  zi_fit <- pscl::zeroinfl(exacerbations_12m ~ smoking | smoking, data = counts_zi)
  print(summary(zi_fit))
} else {
  message("Install pscl for zero-inflated models: install.packages('pscl')")
}

message("Chapter 6 GLMs complete.")
