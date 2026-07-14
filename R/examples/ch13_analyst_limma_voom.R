# Analyst track: limma-voom on CASTOR-HD RNA-seq + method comparison
source("R/00_setup.R")
source("R/viz_handbook.R")
source("R/viz_omics.R")

if (!requireNamespace("limma", quietly = TRUE) || !requireNamespace("edgeR", quietly = TRUE)) {
  stop("Install limma and edgeR via BiocManager", call. = FALSE)
}

library(tidyverse)
library(limma)
library(edgeR)

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
  mutate(
    group = factor(group, levels = c("control", "case")),
    batch = factor(batch)
  )

dge <- DGEList(counts = count_mat, samples = col_data)
keep <- filterByExpr(dge, group = col_data$group)
dge <- dge[keep, , keep.lib.sizes = FALSE]
dge <- calcNormFactors(dge)

design <- model.matrix(~ batch + group, data = col_data)
v <- voom(dge, design, plot = FALSE)
fit <- lmFit(v, design)
fit <- eBayes(fit)

coef_name <- grep("^group", colnames(design), value = TRUE)[1]
tt <- topTable(fit, coef = coef_name, number = Inf, sort.by = "P") %>%
  rownames_to_column("feature") %>%
  rename(log2FC = logFC, pval = "P.Value", padj = "adj.P.Val")

write_csv(tt %>% arrange(padj) %>% slice_head(n = 50), file.path(tab_dir, "ch13_analyst_limma_top50.csv"))
message("limma-voom padj < 0.05: ", sum(tt$padj < 0.05, na.rm = TRUE))

p_volcano <- plot_volcano_premium(
  tt,
  logfc = "log2FC",
  qval = "padj",
  feature = "feature",
  title = "RNA-seq: limma-voom volcano (CASTOR-HD)",
  subtitle = "TMM normalization + empirical Bayes moderation",
  xlab = "log2 fold-change (case vs control)"
)
omics_save(p_volcano, file.path(fig_dir, "ch13_analyst_limma_volcano.png"), 8.2, 5.8)

# Teaching glm.nb results (all genes)
if (!file.exists(file.path(tab_dir, "ch13_rnaseq_all_results.csv"))) {
  teaching_all <- map_dfr(gene_cols, function(nm) {
    df <- rna %>%
      dplyr::select(group, batch, library_size, y = all_of(nm)) %>%
      mutate(group = factor(group, levels = c("control", "case")), offset = log(pmax(library_size, 1)))
    fit <- tryCatch(MASS::glm.nb(y ~ group + batch + offset(offset), data = df), error = function(e) NULL)
    if (is.null(fit)) return(tibble(feature = nm, estimate = NA_real_, p = NA_real_))
    term <- intersect(c("groupcase", "groupcontrol"), rownames(summary(fit)$coefficients))[1]
    tibble(
      feature = nm,
      estimate = unname(coef(fit)[term]),
      p = summary(fit)$coefficients[term, "Pr(>|z|)"]
    )
  }) %>%
    mutate(q = p.adjust(p, method = "BH"))
  write_csv(teaching_all, file.path(tab_dir, "ch13_rnaseq_all_results.csv"))
} else {
  teaching_all <- read_csv(file.path(tab_dir, "ch13_rnaseq_all_results.csv"), show_col_types = FALSE)
}

if (!file.exists(file.path(tab_dir, "ch13_analyst_deseq2_all.csv"))) {
  source("R/examples/ch13_analyst_deseq2.R")
}

deseq2_all <- read_csv(file.path(tab_dir, "ch13_analyst_deseq2_all.csv"), show_col_types = FALSE)

overlap_counts <- tibble(
  method = c("Teaching (glm.nb)", "DESeq2", "limma-voom"),
  n_sig = c(
    sum(teaching_all$q < 0.05, na.rm = TRUE),
    sum(deseq2_all$padj < 0.05, na.rm = TRUE),
    sum(tt$padj < 0.05, na.rm = TRUE)
  )
)
write_csv(overlap_counts, file.path(tab_dir, "ch13_rnaseq_method_compare.csv"))

p_overlap <- plot_method_overlap(
  overlap_counts,
  title = "RNA-seq method comparison: discovery counts",
  subtitle = "CASTOR-HD; padj/q < 0.05 — pipelines should be directionally similar"
)
omics_save(p_overlap, file.path(fig_dir, "ch13_analyst_method_compare.png"), 7.0, 4.8)

message("limma-voom analyst track complete.")
