source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(broom)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)
fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

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

handbook_save(
  plot_residual_panel(fit),
  file.path(fig_dir, "ch05_residual_diagnostics.png"),
  9.2, 4.2
)

if (requireNamespace("emmeans", quietly = TRUE)) {
  em_df <- as.data.frame(emmeans::emmeans(fit, ~ smoking))
  p_adj <- ggplot(em_df, aes(smoking, emmean)) +
    geom_hline(yintercept = mean(em_df$emmean), linetype = "dotted", colour = "#CBD5E1") +
    geom_linerange(aes(ymin = lower.CL, ymax = upper.CL), linewidth = 1.1, colour = "#64748B") +
    geom_point(size = 4.5, colour = handbook_cols$intervention) +
    geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.08, linewidth = 0.9, colour = handbook_cols$accent) +
    labs(
      title = "Adjusted mean FEV1 by smoking (emmeans)",
      subtitle = "From linear model adjusting age, sex, height (Ch 5)",
      x = "Smoking", y = "Estimated mean FEV1 (L)"
    ) +
    handbook_theme()
  handbook_save(p_adj, file.path(fig_dir, "ch05_fev1_by_smoking_adjusted.png"), 5.8, 4.6)
}

message("Chapter 5 linear models complete.")
