source("R/00_setup.R")

library(tidyverse)
library(broom)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)
exacerbation <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE)
bronchodilator <- read_csv(file.path(paths$data, "bronchodilator_paired.csv"), show_col_types = FALSE)
trial <- read_csv(file.path(paths$data, "spirometry_trial.csv"), show_col_types = FALSE)

# --- Welch two-sample t-test ---
tt <- t.test(fev1 ~ group, data = spirometry, var.equal = FALSE)
print(tt)

cohen_d <- function(x, g) {
  stats <- tapply(x, g, function(v) c(mean = mean(v), sd = sd(v), n = length(v)))
  m1 <- stats[[1]]["mean"]; m2 <- stats[[2]]["mean"]
  s1 <- stats[[1]]["sd"];  s2 <- stats[[2]]["sd"]
  n1 <- stats[[1]]["n"];   n2 <- stats[[2]]["n"]
  sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
  unname((m1 - m2) / sp)
}
message("Cohen's d (FEV1 by group): ", round(cohen_d(spirometry$fev1, spirometry$group), 3))

print(wilcox.test(fev1 ~ group, data = spirometry))

# ANOVA + Tukey
fit_aov <- aov(fev1 ~ diagnosis, data = spirometry)
print(summary(fit_aov))
print(TukeyHSD(fit_aov))
print(kruskal.test(fev1 ~ diagnosis, data = spirometry))

# One-sample t-test
print(t.test(spirometry$fev1, mu = 3.0))

# Paired bronchodilator
print(t.test(bronchodilator$fev1_pre, bronchodilator$fev1_post, paired = TRUE))

# --- ANCOVA: follow-up FEV1 adjusted for baseline ---
ancova_fit <- lm(fev1_followup ~ group + fev1_baseline + age + sex, data = trial)
print(summary(ancova_fit))
print(tidy(ancova_fit, conf.int = TRUE) %>% filter(term == "groupintervention"))

# --- Permutation test for mean difference (Welch as reference) ---
set.seed(101)
obs_diff <- diff(tapply(spirometry$fev1, spirometry$group, mean))
perm_diff <- replicate(5000, {
  g <- sample(spirometry$group)
  diff(tapply(spirometry$fev1, g, mean))
})
perm_p <- mean(abs(perm_diff) >= abs(obs_diff))
message("Observed mean diff: ", round(obs_diff, 3),
        "; Permutation p: ", round(perm_p, 4))

# --- Sample size: power for two-sample t-test (design stage) ---
if (requireNamespace("pwr", quietly = TRUE)) {
  n_per_arm <- ceiling(pwr::pwr.t.test(
    d = 0.25, power = 0.8, sig.level = 0.05, type = "two.sample"
  )$n)
  message("Approx n per arm for 80% power, d=0.25, alpha=0.05: ", n_per_arm)
} else {
  message("Install pwr for sample-size calculations: install.packages('pwr')")
}

# Binary comparisons
tab_smoke <- table(exacerbation$smoking, exacerbation$exacerbation_12m)
print(fisher.test(tab_smoke))

message("Chapter 4 group comparisons complete.")
