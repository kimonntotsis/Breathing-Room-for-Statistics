# Premium omics visuals for teaching track (proteomics + RNA)
source("R/00_setup.R")
source("R/viz_handbook.R")
source("R/viz_omics.R")

library(tidyverse)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

prot <- read_csv(file.path(paths$data, "proteomics_olink_like.csv"), show_col_types = FALSE)
rna <- read_csv(file.path(paths$data, "rnaseq_counts.csv"), show_col_types = FALSE)
prot_features <- names(prot)[grepl("^Prot_", names(prot))]
gene_cols <- names(rna)[grepl("^Gene_", names(rna))]

if (!file.exists(file.path(tab_dir, "ch13_proteomics_all_results.csv"))) {
  prot_all <- map_dfr(prot_features, function(nm) {
    df <- prot %>% select(group, age, sex, batch, plate, y = all_of(nm)) %>% filter(!is.na(y))
    if (nrow(df) < 40) return(tibble(feature = nm, estimate = NA, p = NA))
    fit <- lm(y ~ group + age + sex + batch + plate, data = df)
    out <- broom::tidy(fit) %>% filter(term == "groupcontrol")
    tibble(feature = nm, estimate = out$estimate, p = out$p.value)
  }) %>% mutate(q = p.adjust(p, method = "BH"))
  write_csv(prot_all, file.path(tab_dir, "ch13_proteomics_all_results.csv"))
} else {
  prot_all <- read_csv(file.path(tab_dir, "ch13_proteomics_all_results.csv"), show_col_types = FALSE)
}

if (!file.exists(file.path(tab_dir, "ch13_rnaseq_all_results.csv"))) {
  rna_est <- map_dfr(gene_cols, function(nm) {
    df <- rna %>% dplyr::select(group, batch, library_size, y = all_of(nm)) %>%
      mutate(offset = log(pmax(library_size, 1)))
    fit <- tryCatch(MASS::glm.nb(y ~ group + batch + offset(offset), data = df), error = function(e) NULL)
    if (is.null(fit)) return(tibble(feature = nm, estimate = NA, p = NA))
    tibble(feature = nm, estimate = coef(fit)["groupcase"], p = summary(fit)$coefficients["groupcase", "Pr(>|z|)"])
  }) %>% mutate(q = p.adjust(p, method = "BH"))
  write_csv(rna_est, file.path(tab_dir, "ch13_rnaseq_all_results.csv"))
} else {
  rna_est <- read_csv(file.path(tab_dir, "ch13_rnaseq_all_results.csv"), show_col_types = FALSE)
  if (!"estimate" %in% names(rna_est)) {
    rna_est <- map_dfr(gene_cols, function(nm) {
      df <- rna %>% dplyr::select(group, batch, library_size, y = all_of(nm)) %>%
        mutate(offset = log(pmax(library_size, 1)))
      fit <- tryCatch(MASS::glm.nb(y ~ group + batch + offset(offset), data = df), error = function(e) NULL)
      if (is.null(fit)) return(tibble(feature = nm, estimate = NA, p = NA))
      tibble(feature = nm, estimate = coef(fit)["groupcase"], p = summary(fit)$coefficients["groupcase", "Pr(>|z|)"])
    }) %>% mutate(q = p.adjust(p, method = "BH"))
    write_csv(rna_est, file.path(tab_dir, "ch13_rnaseq_all_results.csv"))
  }
}

p_prot_vol <- plot_volcano_premium(
  prot_all %>% filter(!is.na(q)) %>% rename(log2FC = estimate, padj = q),
  logfc = "log2FC", qval = "padj", feature = "feature",
  fc_cut = 0.35, n_label = 8,
  title = "Proteomics volcano (premium)",
  subtitle = "Per-protein LM + BH FDR; labelled top hits",
  xlab = "Effect (control − case)"
)
omics_save(p_prot_vol, file.path(fig_dir, "ch13_proteomics_volcano_premium.png"), 8.2, 5.8)

p_rna_vol <- plot_volcano_premium(
  rna_est %>% filter(!is.na(q)) %>% rename(log2FC = estimate, padj = q),
  logfc = "log2FC", qval = "padj", feature = "feature",
  fc_cut = 0.5, n_label = 10,
  title = "RNA-seq volcano (premium teaching NB)",
  subtitle = "glm.nb per gene — compare to DESeq2/limma in analyst track",
  xlab = "log fold-change (case vs control)"
)
omics_save(p_rna_vol, file.path(fig_dir, "ch13_rnaseq_volcano_premium.png"), 8.2, 5.8)

X <- prot %>% dplyr::select(dplyr::starts_with("Prot_000"))
X_imp <- X %>% mutate(across(everything(), \(v) { v[is.na(v)] <- median(v, na.rm = TRUE); v }))
scores <- prcomp(X_imp, scale. = TRUE)$x[, 1:2, drop = FALSE]
scores <- as_tibble(scores)
if (!"PC1" %in% names(scores)) names(scores)[1:2] <- c("PC1", "PC2")
scores <- scores %>%
  mutate(batch = prot$batch, group = prot$group)

p_pca_prot <- plot_pca_omics(
  scores, colour = "batch", shape = "group",
  title = "Proteomics PCA (premium)",
  subtitle = "Ellipses by batch; shape = disease group"
)
omics_save(p_pca_prot, file.path(fig_dir, "ch13_proteomics_pca_premium.png"), 7.6, 5.4)

p_panel <- (p_prot_vol | p_rna_vol) / p_pca_prot +
  plot_annotation(
    title = "CASTOR-HD omics showcase",
    subtitle = "Premium DE + QC visuals for slides and manuscripts"
  )
omics_save(p_panel, file.path(fig_dir, "ch13_omics_showcase_panel.png"), 12.0, 9.0)

message("Premium omics visuals saved.")
