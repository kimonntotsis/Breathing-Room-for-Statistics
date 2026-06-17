source("R/00_setup.R")

library(tidyverse)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

screen <- read_csv(file.path(paths$data, "antibody_screen.csv"), show_col_types = FALSE)
conf <- read_csv(file.path(paths$data, "antibody_confirmation.csv"), show_col_types = FALSE)

PRESPEC_THRESHOLD <- 1.4
TOP_K <- 20L

# =============================================================================
# Replicate agreement
# =============================================================================
p_rep <- screen %>%
  filter(antigen == "AgA") %>%
  ggplot(aes(signal_rep1, signal_rep2, color = screen_batch)) +
  geom_point(alpha = 0.6, size = 1.2) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.7, color = "grey30") +
  theme_minimal() +
  labs(title = "Replicate agreement (AgA)", x = "replicate 1 signal", y = "replicate 2 signal")

ggsave(file.path(fig_dir, "ch16_screen_replicate_agreement.png"), p_rep, width = 6.8, height = 4.6, dpi = 160)

# =============================================================================
# Per-clone summary
# =============================================================================
screen_sum <- screen %>%
  group_by(antigen, clone_id) %>%
  summarise(
    screen_mean = mean(signal_mean),
    batch = first(screen_batch),
    true_binder = first(true_binder),
    .groups = "drop"
  )

conf_lu <- conf %>%
  select(clone_id, antigen, confirm_positive, kd_nM)

screen_eval <- screen_sum %>%
  left_join(conf_lu, by = c("clone_id", "antigen")) %>%
  mutate(confirm_positive = ifelse(is.na(confirm_positive), FALSE, confirm_positive))

# =============================================================================
# Hit calling at prespecified threshold + PPV by antigen
# =============================================================================
hits_prespec <- screen_eval %>%
  mutate(hit = screen_mean > PRESPEC_THRESHOLD)

ppv_by_ag <- hits_prespec %>%
  group_by(antigen) %>%
  summarise(
    threshold = PRESPEC_THRESHOLD,
    n_clones = n(),
    n_hits = sum(hit),
    n_confirmed_in_hits = sum(confirm_positive & hit),
    ppv = ifelse(n_hits == 0, NA_real_, n_confirmed_in_hits / n_hits),
    .groups = "drop"
  )

write_csv(ppv_by_ag, file.path(tab_dir, "ch16_screen_ppv_by_antigen.csv"))
print(ppv_by_ag)

p_ppv <- ppv_by_ag %>%
  ggplot(aes(antigen, ppv, fill = antigen)) +
  geom_col(width = 0.65) +
  theme_minimal() +
  guides(fill = "none") +
  scale_y_continuous(limits = c(0, 1)) +
  labs(
    title = sprintf("Screen PPV by antigen (prespecified threshold = %.1f)", PRESPEC_THRESHOLD),
    y = "PPV among hits",
    x = NULL
  )

ggsave(file.path(fig_dir, "ch16_screen_ppv.png"), p_ppv, width = 6.8, height = 4.2, dpi = 160)

# =============================================================================
# Threshold sensitivity curve (hits + PPV vs threshold) - AgA focus
# =============================================================================
threshold_grid <- seq(0.5, 2.5, by = 0.1)

sens_thr <- map_dfr(threshold_grid, function(thr) {
  screen_eval %>%
    filter(antigen == "AgA") %>%
    mutate(hit = screen_mean > thr) %>%
    summarise(
      threshold = thr,
      n_hits = sum(hit),
      ppv = ifelse(n_hits == 0, NA_real_, mean(confirm_positive[hit])),
      .groups = "drop"
    )
})

write_csv(sens_thr, file.path(tab_dir, "ch16_threshold_sensitivity.csv"))

p_hits <- ggplot(sens_thr, aes(threshold, n_hits)) +
  geom_line(linewidth = 0.9, color = "steelblue") +
  geom_vline(xintercept = PRESPEC_THRESHOLD, linetype = "dashed", color = "grey40") +
  theme_minimal() +
  labs(title = "Threshold sensitivity (AgA)", y = "Number of hits", x = "Screen signal threshold")

p_ppv_curve <- ggplot(sens_thr, aes(threshold, ppv)) +
  geom_line(linewidth = 0.9, color = "#B22222") +
  geom_vline(xintercept = PRESPEC_THRESHOLD, linetype = "dashed", color = "grey40") +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  labs(title = "PPV among hits vs threshold (AgA)", y = "PPV", x = "Screen signal threshold")

p_thr_panel <- p_hits / p_ppv_curve +
  plot_annotation(
    title = "Hit calling sensitivity: do not tune threshold post hoc",
    subtitle = "Dashed line = prespecified teaching threshold"
  )

ggsave(file.path(fig_dir, "ch16_threshold_sensitivity.png"), p_thr_panel, width = 7.2, height = 6.8, dpi = 160)

# =============================================================================
# Ranking stability tiers (AgA): top-K overlap across replicates
# =============================================================================
rank_top <- function(rep_col, k = TOP_K) {
  screen %>%
    filter(antigen == "AgA") %>%
    group_by(clone_id) %>%
    summarise(s = mean(.data[[rep_col]]), .groups = "drop") %>%
    slice_max(s, n = k, with_ties = FALSE) %>%
    pull(clone_id)
}

t1 <- rank_top("signal_rep1")
t2 <- rank_top("signal_rep2")
t3 <- rank_top("signal_rep3")

in_top <- screen %>%
  filter(antigen == "AgA") %>%
  distinct(clone_id) %>%
  mutate(
    in_rep1 = clone_id %in% t1,
    in_rep2 = clone_id %in% t2,
    in_rep3 = clone_id %in% t3,
    n_top_lists = as.integer(in_rep1) + as.integer(in_rep2) + as.integer(in_rep3),
    stability_tier = case_when(
      n_top_lists == 3 ~ "Tier 1 (3/3)",
      n_top_lists == 2 ~ "Tier 2 (2/3)",
      n_top_lists == 1 ~ "Tier 3 (1/3)",
      TRUE ~ "Below tier"
    )
  )

tiers_aga <- in_top %>%
  left_join(screen_eval %>% filter(antigen == "AgA") %>% select(clone_id, screen_mean, confirm_positive), by = "clone_id") %>%
  arrange(desc(n_top_lists), desc(screen_mean))

write_csv(tiers_aga, file.path(tab_dir, "ch16_ranking_tiers_aga.csv"))

tier_summary <- tiers_aga %>%
  group_by(stability_tier) %>%
  summarise(
    n_clones = n(),
    n_confirmed = sum(confirm_positive),
    ppv = ifelse(n_clones == 0, NA_real_, mean(confirm_positive)),
    .groups = "drop"
  ) %>%
  mutate(stability_tier = factor(stability_tier, levels = c("Tier 1 (3/3)", "Tier 2 (2/3)", "Tier 3 (1/3)", "Below tier")))

p_tiers <- ggplot(tier_summary, aes(stability_tier, n_clones, fill = stability_tier)) +
  geom_col(width = 0.7) +
  theme_minimal() +
  guides(fill = "none") +
  labs(title = "Ranking stability tiers (AgA, top-20 lists)", y = "Clones", x = NULL)

p_tier_ppv <- ggplot(tier_summary %>% filter(stability_tier != "Below tier"), aes(stability_tier, ppv, fill = stability_tier)) +
  geom_col(width = 0.7) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  guides(fill = "none") +
  labs(title = "PPV by stability tier (AgA)", y = "PPV", x = NULL)

p_tier_panel <- p_tiers + p_tier_ppv +
  plot_annotation(title = "Prefer Tier 1/2 clones for confirmation claims")

ggsave(file.path(fig_dir, "ch16_stability_tiers.png"), p_tier_panel, width = 9.0, height = 4.2, dpi = 160)

overlap <- tibble(
  pair = c("rep1 vs rep2", "rep1 vs rep3", "rep2 vs rep3"),
  overlap_top20 = c(length(intersect(t1, t2)), length(intersect(t1, t3)), length(intersect(t2, t3)))
)
print(overlap)

p_overlap <- ggplot(overlap, aes(pair, overlap_top20, fill = pair)) +
  geom_col(width = 0.65) +
  theme_minimal() +
  guides(fill = "none") +
  labs(title = "Ranking stability (AgA): overlap of top-20", y = "Shared clones", x = NULL)

ggsave(file.path(fig_dir, "ch16_ranking_stability.png"), p_overlap, width = 7.2, height = 4.0, dpi = 160)

# =============================================================================
# Mini-case summary table
# =============================================================================
tier1_n <- sum(tiers_aga$stability_tier == "Tier 1 (3/3)")
tier1_ppv <- tier_summary %>% filter(stability_tier == "Tier 1 (3/3)") %>% pull(ppv)

mini_summary <- tibble(
  step = c(
    "1. Replicate QC",
    "2. Prespecified hit rule",
    "3. Confirmation PPV",
    "4. Stability tiers"
  ),
  teaching_output = c(
    "Rep1 vs Rep2 scatter (+ batch color)",
    sprintf("Hit if screen_mean > %.1f", PRESPEC_THRESHOLD),
    sprintf("AgA PPV among hits = %.2f (see table by antigen)", ppv_by_ag$ppv[ppv_by_ag$antigen == "AgA"]),
    sprintf("AgA Tier 1 clones = %d; Tier 1 PPV = %.2f", tier1_n, tier1_ppv)
  ),
  defensible_claim = c(
    "Agreement assessed before hit calling",
    "Threshold fixed before looking at confirmation",
    "PPV uses confirmation assay, not screen p-values",
    "Report tiers, not fragile ranks 1..K"
  )
)

write_csv(mini_summary, file.path(tab_dir, "ch16_mini_case_summary.csv"))

message("Chapter 16 antibody screening complete. Figures saved to volume-01/figures/.")
