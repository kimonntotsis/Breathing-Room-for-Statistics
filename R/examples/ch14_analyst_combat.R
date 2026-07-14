# Analyst track: ComBat batch correction on proteomics subset + before/after PCA
source("R/00_setup.R")
source("R/viz_handbook.R")
source("R/viz_omics.R")

if (!requireNamespace("sva", quietly = TRUE)) {
  stop("Install sva: BiocManager::install('sva')", call. = FALSE)
}

library(tidyverse)
library(sva)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

prot <- read_csv(file.path(paths$data, "proteomics_olink_like.csv"), show_col_types = FALSE)
feat <- names(prot)[grepl("^Prot_", names(prot))]

# Subset for speed; median impute per protein (visualization / ComBat teaching only)
X <- prot %>% select(all_of(feat))
X_imp <- X %>%
  mutate(across(everything(), \(v) {
    v[is.na(v)] <- median(v, na.rm = TRUE)
    v
  })) %>%
  as.matrix() %>%
  t()

batch <- prot$batch
group <- prot$group

pca_before <- prcomp(t(X_imp), scale. = TRUE)$x[, 1:2, drop = FALSE]
pca_before <- as_tibble(pca_before)
if (!"PC1" %in% names(pca_before)) names(pca_before)[1:2] <- c("PC1", "PC2")
pca_before <- pca_before %>%
  mutate(batch = batch, group = group)

mod <- model.matrix(~ group, data = prot)
combat_mat <- t(ComBat(dat = X_imp, batch = batch, mod = mod))

pca_after_mat <- prcomp(combat_mat, scale. = TRUE)$x[, 1:2, drop = FALSE]
pca_after <- as_tibble(pca_after_mat)
if (!"PC1" %in% names(pca_after)) names(pca_after)[1:2] <- c("PC1", "PC2")
pca_after <- pca_after %>%
  mutate(batch = batch, group = group)

p_panel <- plot_batch_correction_panels(
  pca_before, pca_after, colour = "batch",
  title = "Proteomics PCA: before vs after ComBat"
)
omics_save(p_panel, file.path(fig_dir, "ch14_analyst_combat_pca.png"), 10.5, 5.0)

# PC1 variance explained by batch before/after
r2 <- tibble(
  stage = c("Before ComBat", "After ComBat"),
  r_squared_batch = c(
    summary(lm(PC1 ~ batch, data = pca_before))$r.squared,
    summary(lm(PC1 ~ batch, data = pca_after))$r.squared
  )
)
write_csv(r2, file.path(tab_dir, "ch14_analyst_combat_pc1_r2.csv"))

p_r2 <- ggplot(r2, aes(stage, r_squared_batch, fill = stage)) +
  geom_col(width = 0.55, alpha = 0.9) +
  scale_y_continuous(limits = c(0, 1), labels = scales::percent_format()) +
  scale_fill_manual(values = c("Before ComBat" = "#FECACA", "After ComBat" = "#BBF7D0"), guide = "none") +
  labs(
    title = "PC1 variance explained by batch",
    subtitle = "ComBat should reduce batch-driven structure (not a substitute for design)",
    x = NULL, y = "R² (PC1 ~ batch)"
  ) +
  omics_theme()
omics_save(p_r2, file.path(fig_dir, "ch14_analyst_combat_r2.png"), 6.8, 4.4)

message("ComBat analyst track complete. PC1 R² batch before = ",
        round(r2$r_squared_batch[1], 3), "; after = ", round(r2$r_squared_batch[2], 3))
