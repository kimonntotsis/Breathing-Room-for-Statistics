# Analyst track: DESeq2 on CASTOR-HD RNA-seq + premium visuals
source("R/00_setup.R")
source("R/viz_handbook.R")
source("R/viz_omics.R")

if (!requireNamespace("DESeq2", quietly = TRUE)) {
  stop("Install DESeq2: BiocManager::install('DESeq2')", call. = FALSE)
}

library(tidyverse)
library(DESeq2)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

rna <- read_csv(file.path(paths$data, "rnaseq_counts.csv"), show_col_types = FALSE)
gene_cols <- names(rna)[grepl("^Gene_", names(rna))]

count_mat <- rna %>%
  select(all_of(gene_cols)) %>%
  as.matrix()
storage.mode(count_mat) <- "integer"
count_mat <- t(count_mat)
rownames(count_mat) <- gene_cols
colnames(count_mat) <- rna$sample_id

col_data <- rna %>%
  select(sample_id, group, batch) %>%
  mutate(
    group = factor(group, levels = c("control", "case")),
    batch = factor(batch)
  ) %>%
  column_to_rownames("sample_id")

dds <- DESeqDataSetFromMatrix(
  countData = count_mat,
  colData = col_data,
  design = ~ batch + group
)
dds <- DESeq(dds)
res <- results(dds, contrast = c("group", "case", "control"))
res_df <- as_tibble(res, rownames = "feature") %>%
  mutate(
    padj = pmax(padj, .Machine$double.xmin),
    direction = case_when(
      padj < 0.05 & log2FoldChange > 0 ~ "Up in case",
      padj < 0.05 & log2FoldChange < 0 ~ "Down in case",
      TRUE ~ "NS"
    )
  )

write_csv(
  res_df %>% arrange(padj) %>% slice_head(n = 50),
  file.path(tab_dir, "ch13_analyst_deseq2_top50.csv")
)
write_csv(
  res_df %>% arrange(padj),
  file.path(tab_dir, "ch13_analyst_deseq2_all.csv")
)

n_sig <- sum(res_df$padj < 0.05, na.rm = TRUE)
message("DESeq2 padj < 0.05: ", n_sig)

p_volcano <- plot_volcano_premium(
  res_df %>% filter(!is.na(padj)),
  logfc = "log2FoldChange",
  qval = "padj",
  feature = "feature",
  fc_cut = 0.5,
  q_cut = 0.05,
  n_label = 10,
  title = "RNA-seq: DESeq2 volcano (CASTOR-HD)",
  subtitle = "Design ~ batch + group; contrast case vs control",
  xlab = "log2 fold-change (case vs control)"
)
omics_save(p_volcano, file.path(fig_dir, "ch13_analyst_deseq2_volcano.png"), 8.2, 5.8)

base_mean <- rowMeans(counts(dds, normalized = TRUE))
p_ma <- plot_ma_premium(
  res_df %>% mutate(baseMean_log = log10(base_mean[.data$feature] + 1)),
  mean_col = "baseMean_log",
  lfc_col = "log2FoldChange",
  q_col = "padj",
  title = "RNA-seq: DESeq2 MA plot",
  subtitle = "Mean normalized count vs log2FC"
)
omics_save(p_ma, file.path(fig_dir, "ch13_analyst_deseq2_ma.png"), 7.6, 5.2)

# Top DE heatmap (z-scored vst)
vsd <- vst(dds, blind = FALSE)
top_genes <- res_df %>%
  filter(padj < 0.05) %>%
  arrange(padj) %>%
  slice_head(n = 30) %>%
  pull(feature)

if (length(top_genes) >= 5) {
  mat <- assay(vsd)[top_genes, , drop = FALSE]
  mat_z <- t(scale(t(mat)))
  annot <- col_data %>% select(group, batch)
  p_heat <- plot_heatmap_top(
    mat_z, annot,
    title = "Top DESeq2 hits: sample-level expression (VST z-score)",
    subtitle = "Rows = genes; columns = samples (group/batch in metadata)"
  )
  omics_save(p_heat, file.path(fig_dir, "ch13_analyst_deseq2_heatmap.png"), 9.0, 6.5)
}

# PCA on vst
pca_mat <- prcomp(t(assay(vsd)), scale. = FALSE)$x[, 1:2, drop = FALSE]
pca_scores <- as_tibble(pca_mat, rownames = "sample_id")
if (!"PC1" %in% names(pca_scores)) {
  names(pca_scores)[1:2] <- c("PC1", "PC2")
}
pca_scores <- pca_scores %>%
  left_join(rna %>% select(sample_id, group, batch), by = "sample_id")

p_pca <- plot_pca_omics(
  pca_scores,
  colour = "batch", shape = "group",
  title = "RNA-seq PCA (VST)",
  subtitle = "Colour = batch; shape = group — check overlap before DE claims"
)
omics_save(p_pca, file.path(fig_dir, "ch13_analyst_deseq2_pca.png"), 7.4, 5.4)

message("DESeq2 analyst track complete.")
