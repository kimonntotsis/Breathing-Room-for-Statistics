# Premium omics visualizations (publication / social-style DE and QC plots)
# source("R/viz_omics.R") after R/00_setup.R and R/viz_handbook.R

omics_cols <- list(
  up = "#DC2626",
  down = "#2563EB",
  ns = "#CBD5E1",
  sig = "#0F766E",
  batch1 = "#F59E0B",
  batch2 = "#8B5CF6",
  batch3 = "#06B6D4",
  case = "#E879A8",
  control = "#5EC4B8",
  heat_lo = "#F8FAFC",
  heat_hi = "#0F766E"
)

omics_theme <- function(base = 11) {
  handbook_theme(base = base) +
    ggplot2::theme(
      plot.margin = ggplot2::margin(10, 12, 10, 12),
      panel.grid.minor = ggplot2::element_blank()
    )
}

#' Enhanced volcano: dual colour up/down, threshold lines, optional labels
plot_volcano_premium <- function(
    data,
    logfc,
    pval = NULL,
    qval = NULL,
    feature = "feature",
    fc_cut = 0.5,
    q_cut = 0.05,
    n_label = 12,
    title = NULL,
    subtitle = NULL,
    xlab = "log2 fold-change",
    ylab = expression(-log[10](q))
) {
  fc_sym <- .col_name(logfc)
  feat_sym <- .col_name(feature)
  y_sym <- if (!is.null(qval)) .col_name(qval) else .col_name(pval)

  df <- data %>%
    dplyr::mutate(
      neglog10y = -log10(pmax(.data[[y_sym]], 1e-300)),
      direction = dplyr::case_when(
        .data[[y_sym]] < q_cut & .data[[fc_sym]] > fc_cut ~ "Up",
        .data[[y_sym]] < q_cut & .data[[fc_sym]] < -fc_cut ~ "Down",
        TRUE ~ "NS"
      ),
      label_flag = dplyr::row_number() <= n_label &
        .data[[y_sym]] < q_cut &
        abs(.data[[fc_sym]]) >= fc_cut
    )

  pal <- c(Up = omics_cols$up, Down = omics_cols$down, NS = omics_cols$ns)

  p <- ggplot2::ggplot(df, ggplot2::aes(.data[[fc_sym]], neglog10y, colour = direction)) +
    ggplot2::geom_vline(xintercept = c(-fc_cut, fc_cut), linetype = 2, colour = "#94A3B8", linewidth = 0.4) +
    ggplot2::geom_hline(yintercept = -log10(q_cut), linetype = 2, colour = "#94A3B8", linewidth = 0.4) +
    ggplot2::geom_point(
      data = dplyr::filter(df, direction == "NS"),
      alpha = 0.35, size = 1.0
    ) +
    ggplot2::geom_point(
      data = dplyr::filter(df, direction != "NS"),
      alpha = 0.75, size = 1.4
    ) +
    ggplot2::scale_colour_manual(values = pal, name = NULL) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    omics_theme()

  if (requireNamespace("ggrepel", quietly = TRUE) && n_label > 0) {
    lab_df <- dplyr::filter(df, label_flag)
    if (nrow(lab_df) > 0) {
      p <- p + ggrepel::geom_text_repel(
        data = lab_df,
        ggplot2::aes(label = .data[[feat_sym]]),
        size = 2.6,
        colour = "#334155",
        max.overlaps = 30,
        box.padding = 0.25,
        segment.size = 0.2,
        show.legend = FALSE
      )
    }
  }
  p
}

#' MA plot with significance colouring
plot_ma_premium <- function(data, mean_col, lfc_col, q_col, q_cut = 0.05,
                            title = NULL, subtitle = NULL) {
  mean_sym <- .col_name(mean_col)
  lfc_sym <- .col_name(lfc_col)
  q_sym <- .col_name(q_col)

  df <- data %>%
    dplyr::mutate(sig = ifelse(.data[[q_sym]] < q_cut, "q < 0.05", "q ≥ 0.05"))

  ggplot2::ggplot(df, ggplot2::aes(.data[[mean_sym]], .data[[lfc_sym]], colour = sig)) +
    ggplot2::geom_hline(yintercept = 0, colour = "#94A3B8", linewidth = 0.5) +
    ggplot2::geom_point(alpha = 0.65, size = 1.1) +
    ggplot2::scale_colour_manual(
      values = c("q < 0.05" = omics_cols$sig, "q ≥ 0.05" = omics_cols$ns),
      name = NULL
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = "Mean expression (log scale)",
      y = "log2 fold-change"
    ) +
    omics_theme()
}

#' ClusterProfiler-style enrichment dot plot
plot_enrichment_dot <- function(enrich_df, title = NULL, subtitle = NULL) {
  df <- enrich_df %>%
    dplyr::arrange(padj) %>%
    dplyr::mutate(
      pathway = forcats::fct_reorder(.data$pathway, -.data$padj),
      neglog10padj = -log10(pmax(.data$padj, 1e-300))
    )

  ggplot2::ggplot(
    df,
    ggplot2::aes(
      gene_ratio,
      pathway,
      colour = neglog10padj,
      size = n_genes
    )
  ) +
    ggplot2::geom_point(alpha = 0.9) +
    ggplot2::scale_colour_gradient(
      low = "#BFDBFE",
      high = omics_cols$sig,
      name = expression(-log[10](padj))
    ) +
    ggplot2::scale_size_continuous(range = c(3, 10), name = "Genes") +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = "Gene ratio (hits / pathway size)",
      y = NULL
    ) +
    omics_theme() +
    ggplot2::theme(axis.text.y = ggplot2::element_text(size = 9))
}

#' PCA with optional ellipses (ggforce)
plot_pca_omics <- function(scores, x = "PC1", y = "PC2", colour, shape = NULL,
                           title = NULL, subtitle = NULL, ellipses = TRUE) {
  col_sym <- .col_name(colour)
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)

  p <- ggplot2::ggplot(scores, ggplot2::aes(.data[[x_sym]], .data[[y_sym]], colour = .data[[col_sym]])) +
    ggplot2::geom_point(size = 2.4, alpha = 0.85) +
    ggplot2::labs(title = title, subtitle = subtitle, colour = NULL) +
    omics_theme()

  if (!is.null(shape)) {
    sh_sym <- .col_name(shape)
    p <- ggplot2::ggplot(scores, ggplot2::aes(
      .data[[x_sym]], .data[[y_sym]],
      colour = .data[[col_sym]], shape = .data[[sh_sym]]
    )) +
      ggplot2::geom_point(size = 2.4, alpha = 0.85) +
      ggplot2::labs(title = title, subtitle = subtitle, colour = NULL, shape = NULL) +
      omics_theme()
  }

  if (ellipses && requireNamespace("ggforce", quietly = TRUE)) {
    p <- p + ggforce::geom_mark_ellipse(
      ggplot2::aes(colour = .data[[col_sym]], fill = .data[[col_sym]]),
      alpha = 0.06, linewidth = 0.5, show.legend = FALSE
    )
  }
  p
}

#' Before/after batch correction PCA panel
plot_batch_correction_panels <- function(before_df, after_df, colour = "batch",
                                         title = NULL) {
  col_sym <- .col_name(colour)
  p1 <- plot_pca_omics(
    before_df, colour = col_sym,
    title = "Before correction",
    subtitle = "Technical structure visible",
    ellipses = TRUE
  )
  p2 <- plot_pca_omics(
    after_df, colour = col_sym,
    title = "After correction",
    subtitle = "Biology should dominate",
    ellipses = TRUE
  )
  patchwork::wrap_plots(p1, p2, ncol = 2) +
    patchwork::plot_annotation(title = title, theme = ggplot2::theme(plot.title = ggplot2::element_text(face = "bold", size = 13)))
}

#' ggplot heatmap for top features (no pheatmap dependency)
plot_heatmap_top <- function(mat_z, annot, title = NULL, subtitle = NULL) {
  feat <- rownames(mat_z)
  samp <- colnames(mat_z)
  long <- as.data.frame(mat_z) %>%
    tibble::rownames_to_column("feature") %>%
    tidyr::pivot_longer(-feature, names_to = "sample", values_to = "z")

  ann_long <- annot %>%
    tibble::rownames_to_column("sample") %>%
    tidyr::pivot_longer(-sample, names_to = "annot_var", values_to = "annot_val")

  ggplot2::ggplot(long, ggplot2::aes(sample, feature, fill = z)) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.15) +
    ggplot2::scale_fill_gradient2(
      low = "#3B82F6", mid = "white", high = omics_cols$up,
      midpoint = 0, name = "Z-score"
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    omics_theme() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(size = 6)
    )
}

#' Method overlap bar (DESeq2 vs limma vs teaching)
plot_method_overlap <- function(overlap_tbl, title = NULL, subtitle = NULL) {
  ggplot2::ggplot(overlap_tbl, ggplot2::aes(method, n_sig, fill = method)) +
    ggplot2::geom_col(width = 0.62, alpha = 0.92) +
    ggplot2::geom_text(ggplot2::aes(label = n_sig), vjust = -0.35, size = 3.5, colour = "#334155") +
    ggplot2::scale_fill_manual(
      values = c(
        "Teaching (glm.nb)" = "#94A3B8",
        "DESeq2" = omics_cols$sig,
        "limma-voom" = "#7C3AED"
      ),
      guide = "none"
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = "Discoveries (padj < 0.05)") +
    omics_theme() +
    ggplot2::expand_limits(y = max(overlap_tbl$n_sig) * 1.12)
}

omics_save <- function(plot, path, width, height, dpi = 200) {
  handbook_save(plot, path, width, height, dpi = dpi)
}
