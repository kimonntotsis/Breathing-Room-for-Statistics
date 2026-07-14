# Analyst track: fgsea pathway enrichment on DESeq2 ranked list
source("R/00_setup.R")
source("R/viz_handbook.R")
source("R/viz_omics.R")

if (!requireNamespace("fgsea", quietly = TRUE)) {
  stop("Install fgsea: BiocManager::install('fgsea')", call. = FALSE)
}

library(tidyverse)
library(fgsea)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

if (!file.exists(file.path(tab_dir, "ch13_analyst_deseq2_all.csv"))) {
  source("R/examples/ch13_analyst_deseq2.R")
}

res_df <- read_csv(file.path(tab_dir, "ch13_analyst_deseq2_all.csv"), show_col_types = FALSE)

# Synthetic pathways aligned to CASTOR-HD generate_data.R blocks
pathways <- list(
  CASTOR_DE_BLOCK = sprintf("Gene_%04d", 1:80),
  CASTOR_INFLAM_AXIS = sprintf("Gene_%04d", 81:120),
  CASTOR_BATCH_TECH = sprintf("Gene_%04d", 900:980),
  CASTOR_NULL_SET_A = sprintf("Gene_%04d", 200:279),
  CASTOR_NULL_SET_B = sprintf("Gene_%04d", 400:479)
)

stats_vec <- res_df %>%
  filter(!is.na(log2FoldChange)) %>%
  arrange(feature) %>%
  { setNames(.$log2FoldChange, .$feature) }

set.seed(20260715)
fg <- fgsea(
  pathways = pathways,
  stats = stats_vec,
  minSize = 10,
  maxSize = 500,
  nperm = 10000
)

fg_tbl <- fg %>%
  as_tibble() %>%
  arrange(padj) %>%
  mutate(
    n_genes = map_int(leadingEdge, length),
    gene_ratio = n_genes / size
  )

write_csv(fg_tbl %>% select(-leadingEdge), file.path(tab_dir, "ch13_analyst_fgsea_results.csv"))

p_dot <- plot_enrichment_dot(
  fg_tbl %>% mutate(pathway = as.character(pathway)),
  title = "Pathway enrichment (fgsea on DESeq2 ranks)",
  subtitle = "Synthetic CASTOR pathways; DE block should enrich — batch block is a technical warning"
)
omics_save(p_dot, file.path(fig_dir, "ch13_analyst_fgsea_dotplot.png"), 8.0, 5.2)

# GSEA-style running enrichment for top pathway (if significant)
top_pw <- fg_tbl$pathway[1]
if (length(top_pw) == 1 && !is.na(fg_tbl$padj[1]) && fg_tbl$padj[1] < 0.25) {
  ranked <- sort(stats_vec, decreasing = TRUE)
  hits <- pathways[[as.character(top_pw)]]
  running <- tibble(
    rank = seq_along(ranked),
    gene = names(ranked),
    score = ranked,
    in_pathway = gene %in% hits
  ) %>%
    mutate(es = cumsum(if_else(in_pathway, abs(score), -abs(score) / (length(pathways[[1]]) / 80))))

  p_running <- ggplot(running, aes(rank, es, colour = in_pathway)) +
    geom_line(linewidth = 0.8) +
    scale_colour_manual(values = c("TRUE" = omics_cols$sig, "FALSE" = omics_cols$ns), name = "In pathway") +
    labs(
      title = paste0("Running enrichment: ", top_pw),
      subtitle = "Illustrative GSEA trace on ranked DESeq2 statistics",
      x = "Gene rank",
      y = "Enrichment score"
    ) +
    omics_theme()
  omics_save(p_running, file.path(fig_dir, "ch13_analyst_fgsea_running.png"), 8.0, 4.6)
}

message("fgsea analyst track complete. Top pathway padj = ", round(fg_tbl$padj[1], 4))
