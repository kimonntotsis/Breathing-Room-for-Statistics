source("R/00_setup.R")

library(tidyverse)
library(broom)
library(patchwork)

dir.create(file.path(paths$root, "volume-01", "figures"), showWarnings = FALSE, recursive = TRUE)
fig_dir <- file.path(paths$root, "volume-01", "figures")

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)

# --- Table 1 with gtsummary (if available) ---
if (requireNamespace("gtsummary", quietly = TRUE)) {
  tbl <- spirometry %>%
    select(group, age, sex, smoking, fev1, fvc) %>%
    gtsummary::tbl_summary(by = group, missing = "no") %>%
    gtsummary::add_p() %>%
    gtsummary::modify_header(label ~ "**Characteristic**")
  print(tbl)
} else {
  message("Install gtsummary for publication Table 1: install.packages('gtsummary')")
  print(spirometry %>%
    group_by(group) %>%
    summarise(
      n = n(), age = mean(age), sd_age = sd(age),
      pct_male = 100 * mean(sex == "male"),
      mean_fev1 = mean(fev1), sd_fev1 = sd(fev1),
      .groups = "drop"
    ))
}

# --- Histogram + density ---
p_hist <- ggplot(spirometry, aes(x = fev1, fill = group)) +
  geom_histogram(aes(y = after_stat(density)), alpha = 0.5, position = "identity", bins = 25) +
  geom_density(alpha = 0.3) +
  labs(x = "FEV1 (L)", y = "Density", title = "FEV1 distribution") +
  theme_minimal(base_size = 12)

# --- Violin + boxplot ---
p_violin <- ggplot(spirometry, aes(x = group, y = fev1, fill = group)) +
  geom_violin(alpha = 0.5, trim = FALSE) +
  geom_boxplot(width = 0.15, outlier.alpha = 0.4) +
  geom_jitter(width = 0.08, alpha = 0.25, size = 1) +
  labs(x = NULL, y = "FEV1 (L)", title = "FEV1 by trial arm") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

# --- Scatter with smooth ---
p_scatter <- ggplot(spirometry, aes(x = age, y = fev1, colour = smoking)) +
  geom_point(alpha = 0.55, size = 2) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.8) +
  labs(x = "Age (years)", y = "FEV1 (L)", colour = "Smoking",
       title = "FEV1 vs age") +
  theme_minimal(base_size = 12)

# --- QQ plot for normality (overall FEV1) ---
p_qq <- ggplot(spirometry, aes(sample = fev1)) +
  stat_qq(alpha = 0.6) +
  stat_qq_line(linewidth = 0.8) +
  labs(title = "Normal Q-Q: FEV1", x = "Theoretical quantiles", y = "Sample quantiles") +
  theme_minimal(base_size = 12)

# --- Correlation ---
cor_age_fev1 <- cor(spirometry$age, spirometry$fev1)
message("Correlation age–FEV1: ", round(cor_age_fev1, 3))

# --- Save figures ---
ggsave(file.path(fig_dir, "ch03_fev1_histogram.png"), p_hist, width = 7, height = 4, dpi = 150)
ggsave(file.path(fig_dir, "ch03_fev1_violin.png"), p_violin, width = 6, height = 4, dpi = 150)
ggsave(file.path(fig_dir, "ch03_fev1_qq.png"), p_qq, width = 5, height = 4, dpi = 150)
ggsave(file.path(fig_dir, "ch03_fev1_scatter.png"), p_scatter, width = 6, height = 4, dpi = 150)

print(p_hist / (p_violin | p_qq))
message("Figures saved to ", fig_dir)
message("Chapter 3 descriptive analysis complete.")
