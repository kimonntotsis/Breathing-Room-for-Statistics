source("R/00_setup.R")
source("R/viz_handbook.R")

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

# --- Distribution combo (histogram + density + rug) ---
p_hist <- plot_dist_combo(
  spirometry, "fev1", fill = "group",
  title = "FEV1 distribution by trial arm",
  subtitle = "Histogram, density, and rug: shape before mean-based tests",
  xlab = "FEV1 (L)"
)

# --- Ridge plot by diagnosis ---
p_ridge <- plot_density_ridge(
  spirometry, "fev1", "diagnosis", fill = "diagnosis",
  title = "FEV1 ridges by obstruction category",
  subtitle = "Overlapping ridges show where arms will and will not separate",
  xlab = "FEV1 (L)", ylab = NULL
)

# --- Split violin: smoking within trial arm ---
p_split <- plot_split_violin(
  spirometry, "group", "fev1", "smoking",
  title = "Split violin: FEV1 by arm and smoking",
  subtitle = "Two distributions per arm without hiding overlap",
  xlab = NULL, ylab = "FEV1 (L)"
)

# --- Correlation heatmap (continuous Table 1 variables) ---
p_corr <- plot_corr_heatmap(
  spirometry,
  vars = c("age", "height_cm", "fev1", "fvc", "fev1_fvc"),
  title = "Correlation heatmap: baseline continuous traits",
  subtitle = "Hierarchically ordered; upper triangle labels only"
)

# --- Marginal scatter with ellipses ---
p_scatter <- plot_marginal_scatter(
  spirometry, "age", "fev1", "smoking",
  title = "FEV1 vs age with smoking ellipses",
  subtitle = "Covariance visible before adjustment (Ch 5)",
  xlab = "Age (years)", ylab = "FEV1 (L)"
)

# --- QQ plot for normality (overall FEV1) ---
p_qq <- ggplot(spirometry, aes(sample = fev1)) +
  stat_qq(alpha = 0.6, colour = "#64748B") +
  stat_qq_line(linewidth = 0.8, colour = "#3A9E92") +
  labs(
    title = "Normal Q-Q: FEV1",
    subtitle = "Tail deviation is common in spirometry cohorts",
    x = "Theoretical quantiles", y = "Sample quantiles"
  ) +
  handbook_theme()

cor_age_fev1 <- cor(spirometry$age, spirometry$fev1)
message("Correlation age–FEV1: ", round(cor_age_fev1, 3))

# --- Save figures ---
handbook_save(p_hist, file.path(fig_dir, "ch03_fev1_histogram.png"), 7.2, 4.5)
handbook_save(p_ridge, file.path(fig_dir, "ch03_fev1_ridge.png"), 7, 4.8)
handbook_save(p_split, file.path(fig_dir, "ch03_fev1_violin.png"), 6.8, 4.6)
handbook_save(p_corr, file.path(fig_dir, "ch03_corr_heatmap.png"), 6.5, 5.2)
handbook_save(p_scatter, file.path(fig_dir, "ch03_fev1_scatter.png"), 6.8, 4.8)
handbook_save(p_qq, file.path(fig_dir, "ch03_fev1_qq.png"), 5.2, 4.4)

message("Figures saved to ", fig_dir)
message("Chapter 3 descriptive analysis complete.")
