source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(broom)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# =============================================================================
# Proteomics: per-protein model + BH FDR + volcano plot
# =============================================================================
prot <- read_csv(file.path(paths$data, "proteomics_olink_like.csv"), show_col_types = FALSE)
prot_features <- names(prot)[grepl("^Prot_", names(prot))]

fit_one_protein <- function(nm) {
  df <- prot %>%
    select(group, age, sex, batch, plate, y = all_of(nm)) %>%
    filter(!is.na(y))
  if (nrow(df) < 40) return(tibble(feature = nm, estimate = NA_real_, conf_low = NA_real_, conf_high = NA_real_, p = NA_real_, n = nrow(df)))
  fit <- lm(y ~ group + age + sex + batch + plate, data = df)
  out <- tidy(fit) %>% filter(term == "groupcontrol")
  ci <- suppressMessages(confint(fit, parm = "groupcontrol", level = 0.95))
  tibble(
    feature = nm,
    estimate = out$estimate,
    conf_low = unname(ci[1]),
    conf_high = unname(ci[2]),
    p = out$p.value,
    n = nrow(df)
  )
}

prot_res <- map_dfr(prot_features, fit_one_protein) %>%
  mutate(
    q = p.adjust(p, method = "BH"),
    neglog10p = -log10(pmax(p, 1e-300))
  )

message("Proteomics: BH q<0.05 discoveries: ", sum(prot_res$q < 0.05, na.rm = TRUE))

# Write top table (copy-ready for supplement or appendix)
prot_top <- prot_res %>%
  filter(!is.na(p)) %>%
  arrange(q, desc(abs(estimate))) %>%
  mutate(
    effect_ci = sprintf("%.3f (%.3f to %.3f)", estimate, conf_low, conf_high)
  ) %>%
  select(feature, n, estimate, conf_low, conf_high, effect_ci, p, q) %>%
  slice_head(n = 30)

write_csv(prot_top, file.path(tab_dir, "ch13_proteomics_top_table.csv"))

p_volcano_prot <- plot_volcano_teaching(
  prot_res,
  title = "Proteomics differential analysis (CASTOR-HD)",
  subtitle = "Per-protein linear models (group + covariates + batch + plate); BH FDR",
  xlab = "Estimated difference (control - case) on synthetic scale",
  q = "q"
)

handbook_save(p_volcano_prot, file.path(fig_dir, "ch13_volcano_proteomics.png"), 7.8, 5.2)

# Niche 1: missingness-by-group diagnostic (proteomics)
miss_df <- prot %>%
  transmute(
    group = group,
    missing_fraction = rowMeans(is.na(select(., starts_with("Prot_"))))
  )

p_miss <- ggplot(miss_df, aes(group, missing_fraction, fill = group)) +
  geom_boxplot(alpha = 0.78, outlier.alpha = 0.25, colour = "#334155", linewidth = 0.35) +
  scale_fill_manual(values = handbook_group_fill, guide = "none") +
  labs(
    title = "Proteomics: missingness fraction by group (LOD-style)",
    subtitle = "Differential missingness can masquerade as biology",
    x = NULL,
    y = "Fraction missing across proteins"
  ) +
  handbook_theme()

handbook_save(p_miss, file.path(fig_dir, "ch13_proteomics_missingness_by_group.png"), 6.8, 4.4)

# Niche 2: raw p-value distribution (proteomics) — diagnostic under null features
p_p <- prot_res %>%
  filter(!is.na(p)) %>%
  ggplot(aes(p)) +
  geom_histogram(bins = 40, fill = handbook_cols$intervention, colour = "white", alpha = 0.88) +
  labs(
    title = "Proteomics: raw p-value distribution",
    subtitle = "Uniform tail under null is ideal; spike near 0 suggests signal (or bias/misspecification)",
    x = "Nominal p-value (group term)", y = "Proteins"
  ) +
  handbook_theme()

handbook_save(p_p, file.path(fig_dir, "ch13_proteomics_qvalue_hist.png"), 6.8, 4.4)

# =============================================================================
# RNA-seq: per-gene negative binomial DE + BH FDR + volcano plot
# Teaching workflow: glm.nb with library-size offset (not log-CPM Gaussian)
# =============================================================================
rna <- read_csv(file.path(paths$data, "rnaseq_counts.csv"), show_col_types = FALSE)
gene_features <- names(rna)[grepl("^Gene_", names(rna))]

fit_one_gene <- function(nm) {
  df <- rna %>%
    dplyr::select(group, batch, library_size, y = all_of(nm)) %>%
    mutate(offset = log(pmax(library_size, 1)))
  fit <- tryCatch(
    MASS::glm.nb(y ~ group + batch + offset(offset), data = df),
    error = function(e) NULL
  )
  if (is.null(fit)) {
    return(tibble(
      feature = nm, estimate = NA_real_, conf_low = NA_real_, conf_high = NA_real_,
      p = NA_real_, mean_logcpm = NA_real_
    ))
  }
  out <- tidy(fit) %>% filter(term == "groupcontrol")
  ci <- tryCatch(
    suppressMessages(confint(fit, parm = "groupcontrol", level = 0.95)),
    error = function(e) matrix(NA_real_, 1, 2)
  )
  cpm <- (df$y / pmax(df$library_size, 1)) * 1e6
  tibble(
    feature = nm,
    estimate = out$estimate,
    conf_low = unname(ci[1]),
    conf_high = unname(ci[2]),
    p = out$p.value,
    mean_logcpm = mean(log2(cpm + 0.5))
  )
}

rna_res <- map_dfr(gene_features, fit_one_gene) %>%
  mutate(
    q = p.adjust(p, method = "BH"),
    neglog10p = -log10(pmax(p, 1e-300))
  )

message("RNA (NB): BH q<0.05 discoveries: ", sum(rna_res$q < 0.05, na.rm = TRUE))

rna_top <- rna_res %>%
  filter(!is.na(p)) %>%
  arrange(q, desc(abs(estimate))) %>%
  mutate(effect_ci = sprintf("%.3f (%.3f to %.3f)", estimate, conf_low, conf_high)) %>%
  select(feature, estimate, conf_low, conf_high, effect_ci, p, q, mean_logcpm) %>%
  slice_head(n = 30)

write_csv(rna_top, file.path(tab_dir, "ch13_rnaseq_top_table.csv"))

p_volcano_rna <- plot_volcano_teaching(
  rna_res,
  title = "RNA differential analysis (CASTOR-HD)",
  subtitle = "NB GLM per gene (group + batch + library offset); BH FDR",
  xlab = "Estimated log fold-change (control vs case, NB coefficient)",
  q = "q"
)

handbook_save(p_volcano_rna, file.path(fig_dir, "ch13_volcano_rnaseq.png"), 7.8, 5.2)

# Niche 3: MA plot (RNA) - abundance vs effect (teaching)
p_ma <- rna_res %>%
  mutate(sig = ifelse(q < 0.05, "q < 0.05", "q \u2265 0.05")) %>%
  ggplot(aes(x = mean_logcpm, y = estimate, colour = sig)) +
  geom_hline(yintercept = 0, linewidth = 0.55, colour = "#94A3B8") +
  geom_point(alpha = 0.65, size = 1.1) +
  scale_colour_manual(
    values = c("q < 0.05" = handbook_cols$intervention, "q \u2265 0.05" = "#CBD5E1"),
    name = NULL
  ) +
  labs(
    title = "RNA: MA plot (NB teaching model)",
    subtitle = "Mean log-CPM vs NB log fold-change (control vs case)",
    x = "Mean log-CPM",
    y = "Effect estimate"
  ) +
  handbook_theme()

handbook_save(p_ma, file.path(fig_dir, "ch13_rnaseq_ma_plot.png"), 7.4, 4.8)

# Combined panel (handbook-friendly)
p_panel <- p_volcano_prot / p_volcano_rna +
  patchwork::plot_annotation(
    title = "Differential analysis + FDR: two omics examples (synthetic)",
    theme = handbook_theme(12)
  )
handbook_save(p_panel, file.path(fig_dir, "ch13_volcano_panel.png"), 8.6, 9.2)

message("Chapter 13 differential analysis complete. Figures saved to volume-01/figures/.")

