source("R/00_setup.R")

library(tidyverse)
library(broom)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)
exac <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE)

# Nested linear models
m1 <- lm(fev1 ~ smoking + age + sex, data = spirometry)
m2 <- lm(fev1 ~ smoking * age + sex, data = spirometry)
print(anova(m1, m2))

# Nested GLM
reduced <- glm(exacerbation_12m ~ smoking + age, data = exac, family = binomial)
full <- glm(exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
            data = exac, family = binomial)
print(anova(reduced, full, test = "Chisq"))

# LASSO with cross-validation
if (requireNamespace("glmnet", quietly = TRUE)) {
  exac_num <- exac %>%
    mutate(
      smoking = as.integer(smoking),
      exacerbation_12m = as.integer(exacerbation_12m)
    )
  form <- exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations
  x <- model.matrix(form, data = exac_num)[, -1]
  y <- exac_num$exacerbation_12m
  cv <- glmnet::cv.glmnet(x, y, family = "binomial", alpha = 1)
  print(coef(cv, s = "lambda.1se"))
}

# Spline for age
fit_spline <- lm(fev1 ~ smoking + splines::ns(age, df = 3) + sex, data = spirometry)
print(summary(fit_spline))

message("Chapter 7 model building complete.")
