source("R/00_setup.R")

library(tidyverse)
library(broom)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)

fit <- lm(fev1 ~ smoking + age + sex + height_cm, data = spirometry)
print(summary(fit))
print(tidy(fit, conf.int = TRUE))

newdata <- tibble(
  smoking = c(FALSE, TRUE),
  age = 60,
  sex = "male",
  height_cm = 175
)
print(predict(fit, newdata, interval = "confidence"))

# Residual diagnostics
par(mfrow = c(1, 2))
plot(fitted(fit), residuals(fit), xlab = "Fitted", ylab = "Residuals",
     main = "Residuals vs fitted")
qqnorm(rstandard(fit), main = "Normal Q-Q")
qqline(rstandard(fit))
par(mfrow = c(1, 1))

message("Chapter 5 linear models complete.")
