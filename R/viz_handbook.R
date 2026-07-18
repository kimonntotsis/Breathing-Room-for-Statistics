# Handbook visualization theme and premium plot builders
# source("R/viz_handbook.R") after R/00_setup.R

handbook_cols <- list(
  standard = "#64748B",
  intervention = "#3A9E92",
  smoker = "#E879A8",
  nonsmoker = "#5EC4B8",
  accent = "#0C0D12",
  muted = "#94A3B8",
  wrong = "#BE123C",
  right = "#115E59",
  heat_lo = "#F8FAFC",
  heat_mid = "#FFFFFF",
  heat_hi = "#3A9E92"
)

handbook_group_fill <- c(
  standard = handbook_cols$standard,
  intervention = handbook_cols$intervention
)

handbook_arm_colors <- c(
  standard = handbook_cols$standard,
  intervention = handbook_cols$intervention
)

handbook_smoke_colors <- c(
  "Non-smoker" = handbook_cols$nonsmoker,
  "Smoker" = handbook_cols$smoker
)

#' Forest plot for ratios (OR, HR, RR) on log scale
plot_forest_ratio <- function(
    data,
    estimate = "estimate",
    conf.low = "conf.low",
    conf.high = "conf.high",
    term = "term",
    xlab = "Ratio (95% CI, log scale)",
    title = NULL,
    subtitle = NULL,
    ref = 1,
    point_color = handbook_cols$intervention
) {
  est_sym <- .col_name(estimate)
  lo_sym <- .col_name(conf.low)
  hi_sym <- .col_name(conf.high)
  term_sym <- .col_name(term)
  df <- data |>
    dplyr::mutate(
      .term = .data[[term_sym]],
      .term = stats::reorder(.data[[term_sym]], .data[[est_sym]])
    )
  ggplot2::ggplot(df, ggplot2::aes(
    x = .data[[est_sym]], y = .term,
    xmin = .data[[lo_sym]], xmax = .data[[hi_sym]]
  )) +
    ggplot2::geom_vline(xintercept = ref, linetype = "dashed", colour = "#94A3B8", linewidth = 0.6) +
    ggplot2::geom_errorbar(orientation = "y", width = 0.22, linewidth = 0.75, colour = handbook_cols$accent) +
    ggplot2::geom_point(size = 3.2, colour = point_color) +
    ggplot2::scale_x_log10() +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = NULL) +
    handbook_theme(11)
}

#' Coefficient sensitivity plot (linear scale, vertical reference)
plot_coef_sensitivity <- function(
    data,
    estimate = "estimate",
    conf.low = "conf.low",
    conf.high = "conf.high",
    y = "analysis",
    xlab = "Coefficient (95% CI)",
    title = NULL,
    subtitle = NULL,
    ref = 0,
    point_color = handbook_cols$intervention
) {
  est_sym <- .col_name(estimate)
  lo_sym <- .col_name(conf.low)
  hi_sym <- .col_name(conf.high)
  y_sym <- .col_name(y)
  df <- data |>
    dplyr::mutate(.y = stats::reorder(.data[[y_sym]], .data[[est_sym]]))
  ggplot2::ggplot(df, ggplot2::aes(
    x = .data[[est_sym]], y = .y,
    xmin = .data[[lo_sym]], xmax = .data[[hi_sym]]
  )) +
    ggplot2::geom_vline(xintercept = ref, linetype = "dashed", colour = "#94A3B8", linewidth = 0.6) +
    ggplot2::geom_errorbar(orientation = "y", width = 0.22, linewidth = 0.75, colour = "#64748B") +
    ggplot2::geom_point(size = 3.2, colour = point_color) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = NULL) +
    handbook_theme(11)
}

#' Kaplan-Meier curves with optional confidence ribbons
plot_km_handbook <- function(
    data,
    time = "time",
    surv = "estimate",
    group = "strata",
    conf.low = NULL,
    conf.high = NULL,
    title = NULL,
    subtitle = NULL,
    xlab = "Time",
    ylab = "Event-free probability",
    palette = handbook_smoke_colors,
    show_censor = FALSE,
    censor_time = NULL,
    censor_event = NULL
) {
  time_sym <- .col_name(time)
  surv_sym <- .col_name(surv)
  grp_sym <- .col_name(group)
  p <- ggplot2::ggplot(data, ggplot2::aes(
    x = .data[[time_sym]], y = .data[[surv_sym]],
    colour = .data[[grp_sym]], fill = .data[[grp_sym]]
  ))
  if (!is.null(conf.low) && !is.null(conf.high)) {
    lo_sym <- .col_name(conf.low)
    hi_sym <- .col_name(conf.high)
    p <- p + ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data[[lo_sym]], ymax = .data[[hi_sym]]),
      alpha = 0.14, colour = NA, linewidth = 0
    )
  }
  p <- p +
    ggplot2::geom_step(linewidth = 1.05) +
    ggplot2::scale_colour_manual(values = palette, name = NULL) +
    ggplot2::scale_fill_manual(values = palette, guide = "none") +
    ggplot2::scale_y_continuous(
      labels = scales::percent_format(accuracy = 1),
      limits = c(0, 1),
      expand = ggplot2::expansion(mult = c(0.02, 0.01))
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(12) +
    ggplot2::theme(legend.position = c(0.82, 0.22))
  if (show_censor && !is.null(censor_time) && !is.null(censor_event)) {
    ct_sym <- .col_name(censor_time)
    ce_sym <- .col_name(censor_event)
    cens <- data |>
      dplyr::filter(.data[[ce_sym]] == 0) |>
      dplyr::distinct(.data[[grp_sym]], .data[[ct_sym]], .data[[surv_sym]])
    if (nrow(cens) > 0) {
      p <- p + ggplot2::geom_point(
        data = cens,
        ggplot2::aes(x = .data[[ct_sym]], y = .data[[surv_sym]]),
        shape = 3, size = 1.6, stroke = 0.45, colour = "#334155"
      )
    }
  }
  p
}

#' Calibration plot with perfect-calibration reference
plot_calibration <- function(
    cal_df,
    pred = "mean_pred",
    obs = "obs_rate",
    n = NULL,
    se = NULL,
    title = NULL,
    subtitle = NULL,
    xlab = "Mean predicted risk",
    ylab = "Observed event rate",
    axis_max = NULL
) {
  pred_sym <- .col_name(pred)
  obs_sym <- .col_name(obs)
  p <- ggplot2::ggplot(cal_df, ggplot2::aes(.data[[pred_sym]], .data[[obs_sym]])) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "#94A3B8", linewidth = 0.7) +
    ggplot2::geom_line(colour = handbook_cols$intervention, linewidth = 0.9, alpha = 0.85)
  if (!is.null(se)) {
    se_sym <- .col_name(se)
    p <- p + ggplot2::geom_errorbar(
      ggplot2::aes(
        ymin = pmax(0, .data[[obs_sym]] - .data[[se_sym]]),
        ymax = pmin(1, .data[[obs_sym]] + .data[[se_sym]])
      ),
      width = 0.01, linewidth = 0.55, colour = "#64748B"
    )
  }
  if (!is.null(n)) {
    n_sym <- .col_name(n)
    p <- p + ggplot2::geom_point(
      ggplot2::aes(size = .data[[n_sym]]),
      colour = handbook_cols$accent, alpha = 0.9
    ) +
      ggplot2::scale_size_continuous(range = c(3, 9), name = "n per bin")
  } else {
    p <- p + ggplot2::geom_point(colour = handbook_cols$accent, size = 3.5)
  }
  if (is.null(axis_max)) {
    axis_max <- max(cal_df[[pred_sym]], cal_df[[obs_sym]], na.rm = TRUE) * 1.12
    axis_max <- max(0.12, axis_max)
  }
  p +
    ggplot2::coord_cartesian(xlim = c(0, axis_max), ylim = c(0, axis_max)) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(12)
}

#' PCA scree plot (ggplot native)
plot_scree <- function(pca, title = NULL, subtitle = NULL, max_pc = 10L) {
  var <- (pca$sdev^2) / sum(pca$sdev^2)
  n <- min(length(var), max_pc)
  df <- tibble::tibble(
    pc = factor(paste0("PC", seq_len(n)), levels = paste0("PC", seq_len(n))),
    variance = var[seq_len(n)],
    cumulative = cumsum(var[seq_len(n)])
  )
  ggplot2::ggplot(df, ggplot2::aes(pc, variance)) +
    ggplot2::geom_col(fill = handbook_cols$intervention, alpha = 0.82, width = 0.72) +
    ggplot2::geom_text(
      ggplot2::aes(label = scales::percent(variance, accuracy = 1)),
      vjust = -0.35, size = 3, colour = "#475569"
    ) +
    ggplot2::scale_y_continuous(labels = scales::percent_format(accuracy = 1), expand = ggplot2::expansion(mult = c(0, 0.12))) +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = "Variance explained") +
    handbook_theme(11) +
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
}

#' PCA score plot with optional 68% ellipses
plot_pca_scores <- function(
    data,
    x = "PC1",
    y = "PC2",
    colour = "phenotype",
    title = NULL,
    subtitle = NULL,
    xlab = NULL,
    ylab = NULL,
    palette = NULL
) {
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  c_sym <- .col_name(colour)
  if (is.null(palette)) {
    lv <- unique(data[[c_sym]])
    palette <- grDevices::colorRampPalette(c(handbook_cols$nonsmoker, handbook_cols$intervention, handbook_cols$smoker))(length(lv))
    names(palette) <- lv
  }
  p <- ggplot2::ggplot(data, ggplot2::aes(
    .data[[x_sym]], .data[[y_sym]], colour = .data[[c_sym]]
  )) +
    ggplot2::geom_point(alpha = 0.72, size = 2.2) +
    ggplot2::stat_ellipse(type = "norm", linewidth = 0.65, alpha = 0.75, linetype = "dashed") +
    ggplot2::scale_colour_manual(values = palette, name = NULL) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(11)
  p
}

#' Teaching volcano (BH/q threshold, handbook palette)
plot_volcano_teaching <- function(
    data,
    x = "estimate",
    y = "neglog10p",
    q = NULL,
    q_cut = 0.05,
    title = NULL,
    subtitle = NULL,
    xlab = "Effect estimate",
    ylab = expression(-log[10](p))
) {
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  df <- data
  sig_low <- sprintf("q < %.2f", q_cut)
  sig_high <- sprintf("q \u2265 %.2f", q_cut)
  if (!is.null(q)) {
    q_sym <- .col_name(q)
    df <- dplyr::mutate(
      df,
      sig = ifelse(.data[[q_sym]] < q_cut, sig_low, sig_high)
    )
  } else {
    df <- dplyr::mutate(df, sig = "All features")
  }
  pal <- stats::setNames(
    c(handbook_cols$smoker, "#CBD5E1", "#94A3B8"),
    c(sig_low, sig_high, "All features")
  )
  ggplot2::ggplot(df, ggplot2::aes(.data[[x_sym]], .data[[y_sym]], colour = sig)) +
    ggplot2::geom_hline(yintercept = -log10(q_cut), linetype = 2, colour = "#94A3B8", linewidth = 0.45) +
    ggplot2::geom_vline(xintercept = 0, linetype = 3, colour = "#E2E8F0", linewidth = 0.45) +
    ggplot2::geom_point(alpha = 0.7, size = 1.25) +
    ggplot2::scale_colour_manual(values = pal, name = NULL) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(11)
}

#' Residual diagnostic panel (hexbin + Q-Q)
plot_residual_panel <- function(fit, title_resid = "Residuals vs fitted", title_qq = "Normal Q-Q of residuals") {
  df <- tibble::tibble(fitted = fitted(fit), resid = rstandard(fit))
  if (requireNamespace("hexbin", quietly = TRUE)) {
    p_resid <- ggplot2::ggplot(df, ggplot2::aes(fitted, resid)) +
      ggplot2::geom_hex(bins = 28, alpha = 0.88) +
      ggplot2::scale_fill_gradient(low = "#F1F5F9", high = handbook_cols$intervention, name = "Count")
  } else {
    p_resid <- ggplot2::ggplot(df, ggplot2::aes(fitted, resid)) +
      ggplot2::geom_point(alpha = 0.25, size = 1.1, colour = "#64748B")
  }
  p_resid <- p_resid +
    ggplot2::geom_hline(yintercept = 0, linetype = "dashed", colour = "#94A3B8") +
    ggplot2::geom_smooth(ggplot2::aes(fitted, resid), se = FALSE, colour = handbook_cols$wrong, linewidth = 0.75) +
    ggplot2::labs(
      title = title_resid,
      subtitle = "Curved smooth line flags misspecification (Ch 5)",
      x = "Fitted values", y = "Standardised residuals"
    ) +
    handbook_theme(11)
  p_qq <- ggplot2::ggplot(df, ggplot2::aes(sample = resid)) +
    ggplot2::stat_qq(alpha = 0.6, colour = "#64748B") +
    ggplot2::stat_qq_line(linewidth = 0.8, colour = handbook_cols$intervention) +
    ggplot2::labs(title = title_qq, x = "Theoretical", y = "Sample") +
    handbook_theme(11)
  if (requireNamespace("patchwork", quietly = TRUE)) {
    p_resid + p_qq
  } else {
    p_resid
  }
}

handbook_theme <- function(base = 12, grid = "minor") {
  ggplot2::theme_minimal(base_size = base, base_family = "sans") +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold", size = base + 1, colour = handbook_cols$accent,
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        size = base - 1, colour = "#64748B", margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(size = base - 2.5, colour = "#94A3B8", hjust = 0),
      plot.margin = ggplot2::margin(10, 12, 10, 12),
      panel.grid.minor = if (grid == "minor") {
        ggplot2::element_line(colour = "#F1F5F9", linewidth = 0.35)
      } else {
        ggplot2::element_blank()
      },
      panel.grid.major = ggplot2::element_line(colour = "#E2E8F0", linewidth = 0.4),
      axis.title = ggplot2::element_text(colour = "#334155", face = "bold", size = base - 0.5),
      axis.text = ggplot2::element_text(colour = "#475569"),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(face = "bold", size = base - 1),
      legend.key.size = grid::unit(0.45, "cm"),
      strip.text = ggplot2::element_text(face = "bold", colour = handbook_cols$accent),
      strip.background = ggplot2::element_rect(fill = "#F8FAFC", colour = "#E2E8F0", linewidth = 0.3)
    )
}

handbook_save <- function(plot, path, width, height, dpi = 180) {
  ggplot2::ggsave(path, plot, width = width, height = height, dpi = dpi, bg = "white")
  invisible(path)
}

.col_name <- function(x) {
  if (is.character(x) && length(x) == 1L) return(x)
  rlang::as_name(rlang::ensym(x))
}

#' Raincloud: violin + box + jitter (ggplot2 only)
plot_raincloud <- function(data, x, y, fill = NULL, pal = handbook_group_fill,
                           title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL) {
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  fill_sym <- if (is.null(fill)) x_sym else .col_name(fill)
  ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], .data[[y_sym]], fill = .data[[fill_sym]])) +
    ggplot2::geom_violin(trim = FALSE, alpha = 0.45, colour = NA, width = 0.9) +
    ggplot2::geom_boxplot(width = 0.14, alpha = 0.85, outlier.shape = NA, colour = "#334155") +
    ggplot2::geom_jitter(width = 0.09, alpha = 0.22, size = 0.85, colour = "#334155") +
    ggplot2::stat_summary(
      fun = mean, geom = "point", shape = 18, size = 2.8,
      colour = handbook_cols$accent, fill = "white", stroke = 0.9
    ) +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme()
}

#' Split violin: secondary factor within primary x (dodged half-violins)
plot_split_violin <- function(data, x, y, split, title = NULL, subtitle = NULL,
                              xlab = NULL, ylab = NULL) {
  split_lab <- .col_name(split)
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  if (is.logical(data[[split_lab]])) {
    data <- dplyr::mutate(
      data,
      .split = ifelse(.data[[split_lab]], "Smoker", "Non-smoker")
    )
    pal <- c("Non-smoker" = handbook_cols$nonsmoker, "Smoker" = handbook_cols$smoker)
  } else {
    data <- dplyr::mutate(data, .split = as.character(.data[[split_lab]]))
    pal <- setNames(
      grDevices::colorRampPalette(c(handbook_cols$nonsmoker, handbook_cols$smoker))(length(unique(data$.split))),
      unique(data$.split)
    )
  }
  ggplot2::ggplot(data, ggplot2::aes(
    x = .data[[x_sym]],
    y = .data[[y_sym]],
    fill = .split
  )) +
    ggplot2::geom_violin(
      position = ggplot2::position_dodge(width = 0.75),
      trim = FALSE, alpha = 0.72, colour = "#334155", linewidth = 0.25
    ) +
    ggplot2::geom_boxplot(
      position = ggplot2::position_dodge(width = 0.75),
      width = 0.12, alpha = 0.9, outlier.alpha = 0.35, colour = "#334155"
    ) +
    ggplot2::scale_fill_manual(values = pal, name = "Smoking") +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme()
}

#' Ridge density by grouping variable (ggridges)
plot_density_ridge <- function(data, x, y, fill = NULL, title = NULL, subtitle = NULL,
                               xlab = NULL, ylab = NULL) {
  if (!requireNamespace("ggridges", quietly = TRUE)) {
    stop("Install ggridges for ridge plots: install.packages('ggridges')")
  }
  y_sym <- .col_name(y)
  x_sym <- .col_name(x)
  fill_sym <- if (is.null(fill)) y_sym else .col_name(fill)
  n_fill <- length(unique(data[[fill_sym]]))
  pal <- if (n_fill <= 2) handbook_group_fill else grDevices::colorRampPalette(c("#CBD5E1", "#3A9E92"))(n_fill)
  ggplot2::ggplot(data, ggplot2::aes(
    x = .data[[x_sym]], y = .data[[y_sym]], fill = .data[[fill_sym]]
  )) +
    ggridges::geom_density_ridges(
      alpha = 0.78, colour = "white", linewidth = 0.6,
      scale = 0.92, rel_min_height = 0.01
    ) +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme() +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
}

#' Correlation heatmap (upper triangle)
plot_corr_heatmap <- function(data, vars, title = NULL, subtitle = NULL) {
  mat <- stats::cor(data[, vars, drop = FALSE], use = "pairwise.complete.obs")
  ord <- stats::hclust(stats::as.dist(1 - mat))$order
  mat <- mat[ord, ord]
  df <- as.data.frame(as.table(mat))
  names(df) <- c("var1", "var2", "r")
  df <- dplyr::mutate(
    df,
    var1 = factor(var1, levels = ord),
    var2 = factor(var2, levels = rev(ord)),
    label = sprintf("%.2f", r),
    upper = as.integer(var1) >= as.integer(var2)
  )
  ggplot2::ggplot(df, ggplot2::aes(var1, var2, fill = r)) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.8) +
    ggplot2::geom_text(
      data = dplyr::filter(df, upper == 1L),
      ggplot2::aes(label = label), size = 3.2, colour = "#0C0D12"
    ) +
    ggplot2::scale_fill_gradient2(
      low = "#F1F5F9", mid = "white", high = "#3A9E92",
      midpoint = 0, limits = c(-1, 1), name = "r"
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    handbook_theme(11) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      panel.grid = ggplot2::element_blank()
    )
}

#' Distribution combo: histogram + density + rug
plot_dist_combo <- function(data, x, fill = NULL, title = NULL, subtitle = NULL,
                            xlab = NULL, ylab = "Density") {
  x_sym <- .col_name(x)
  if (!is.null(fill)) {
    fill_sym <- .col_name(fill)
    ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], fill = .data[[fill_sym]])) +
      ggplot2::geom_histogram(
        ggplot2::aes(y = ggplot2::after_stat(density)),
        alpha = 0.45, position = "identity", bins = 28, colour = NA
      ) +
      ggplot2::geom_density(alpha = 0.35, linewidth = 0.9) +
      ggplot2::geom_rug(alpha = 0.25, sides = "b", length = grid::unit(0.02, "npc")) +
      ggplot2::scale_fill_manual(values = handbook_group_fill, guide = "none") +
      ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
      handbook_theme()
  } else {
    ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]])) +
      ggplot2::geom_histogram(
        ggplot2::aes(y = ggplot2::after_stat(density)),
        fill = "#CBD5E1", colour = "white", bins = 28, alpha = 0.85
      ) +
      ggplot2::geom_density(colour = "#3A9E92", fill = "#3A9E92", alpha = 0.2, linewidth = 1) +
      ggplot2::geom_rug(alpha = 0.3, sides = "b", colour = "#64748B") +
      ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
      handbook_theme()
  }
}

#' Alluvial flow between two categorical variables (ggalluvial)
plot_alluvial_flow <- function(data, cat1, cat2, title = NULL, subtitle = NULL) {
  if (!requireNamespace("ggalluvial", quietly = TRUE)) {
    stop("Install ggalluvial: install.packages('ggalluvial')")
  }
  c1 <- .col_name(cat1)
  c2 <- .col_name(cat2)
  tab <- data |>
    dplyr::count(.data[[c1]], .data[[c2]], name = "freq") |>
    dplyr::mutate(
      !!c1 := as.character(.data[[c1]]),
      !!c2 := as.character(.data[[c2]])
    )
  pal <- c(handbook_cols$nonsmoker, handbook_cols$smoker)
  ggplot2::ggplot(
    tab,
    ggplot2::aes(
      y = freq,
      axis1 = .data[[c1]],
      axis2 = .data[[c2]]
    )
  ) +
    ggalluvial::geom_alluvium(
      ggplot2::aes(fill = .data[[c1]]), width = 1 / 5, alpha = 0.78, curve_type = "sigmoid"
    ) +
    ggalluvial::geom_stratum(width = 1 / 5, fill = "#F8FAFC", colour = "#CBD5E1") +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::scale_x_discrete(limits = c(c1, c2), expand = c(0.08, 0.08)) +
    ggplot2::labs(title = title, subtitle = subtitle, y = "Participants", x = NULL) +
    handbook_theme(11) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
}

#' Dumbbell / slope chart for paired measurements
plot_dumbbell <- function(data, id, before, after, title = NULL, subtitle = NULL,
                          xlab = NULL, ylab = NULL) {
  id_sym <- rlang::as_name(rlang::ensym(id))
  b_sym <- rlang::as_name(rlang::ensym(before))
  a_sym <- rlang::as_name(rlang::ensym(after))
  long <- data |>
    dplyr::transmute(
      !!id_sym := .data[[id_sym]],
      pre = .data[[b_sym]],
      post = .data[[a_sym]]
    )
  means <- tibble::tibble(
    visit = c("Pre-BD", "Post-BD"),
    fev1 = c(mean(long$pre), mean(long$post)),
    se = c(stats::sd(long$pre) / sqrt(nrow(long)), stats::sd(long$post) / sqrt(nrow(long)))
  )
  ggplot2::ggplot(long, ggplot2::aes(x = fev1, y = 0.5, colour = "#64748B")) +
    ggplot2::geom_segment(
      ggplot2::aes(x = pre, xend = post, y = 0.5, yend = 0.5),
      alpha = 0.28, linewidth = 0.45
    ) +
    ggplot2::geom_point(ggplot2::aes(x = pre), alpha = 0.35, size = 1.1) +
    ggplot2::geom_point(ggplot2::aes(x = post), alpha = 0.35, size = 1.1) +
    ggplot2::geom_segment(
      data = means,
      ggplot2::aes(x = fev1, xend = dplyr::lead(fev1), y = 0.2, yend = 0.2),
      colour = handbook_cols$intervention, linewidth = 1.4,
      arrow = grid::arrow(length = grid::unit(0.18, "cm"), type = "closed")
    ) +
    ggplot2::geom_errorbarh(
      data = means, ggplot2::aes(xmin = fev1 - se, xmax = fev1 + se, y = 0.2),
      height = 0.04, colour = handbook_cols$intervention, linewidth = 0.8
    ) +
    ggplot2::geom_point(
      data = means, ggplot2::aes(x = fev1, y = 0.2),
      size = 4, colour = handbook_cols$accent, shape = 18
    ) +
    ggplot2::annotate("text", x = means$fev1[1], y = 0.08, label = "Pre-BD", size = 3.5, colour = "#475569") +
    ggplot2::annotate("text", x = means$fev1[2], y = 0.08, label = "Post-BD", size = 3.5, colour = "#475569") +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = NULL) +
    ggplot2::scale_colour_identity() +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme() +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
}

#' Radar / spider profiles from long format (axis, group, value)
plot_radar <- function(profile, group_var, axis_var, value_var, title = NULL, subtitle = NULL) {
  g_sym <- rlang::as_name(rlang::ensym(group_var))
  a_sym <- rlang::as_name(rlang::ensym(axis_var))
  v_sym <- rlang::as_name(rlang::ensym(value_var))
  axes <- unique(profile[[a_sym]])
  n_ax <- length(axes)
  closed <- profile |>
    dplyr::group_by(.data[[g_sym]]) |>
    dplyr::group_modify(\(d, ...) {
      first <- d[1, , drop = FALSE]
      first[[a_sym]] <- axes[1]
      dplyr::bind_rows(d, first)
    }) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      axis_id = as.integer(factor(.data[[a_sym]], levels = axes)),
      angle = (axis_id - 1) / n_ax * 2 * pi
    )
  pal <- grDevices::colorRampPalette(c("#64748B", "#3A9E92", "#8B7EC8"))(length(unique(closed[[g_sym]])))
  ggplot2::ggplot(closed, ggplot2::aes(
    x = .data[[a_sym]], y = .data[[v_sym]],
    group = .data[[g_sym]], colour = .data[[g_sym]], fill = .data[[g_sym]]
  )) +
    ggplot2::geom_polygon(alpha = 0.18, linewidth = 0.9) +
    ggplot2::geom_point(size = 2.4) +
    ggplot2::coord_polar() +
    ggplot2::scale_colour_manual(values = pal, name = "Cluster") +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    handbook_theme(11) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(colour = "#E2E8F0", linetype = "dashed"),
      axis.text.x = ggplot2::element_text(size = 10, face = "bold")
    )
}

#' Centroid heatmap from wide or long profile data
plot_profile_heatmap <- function(profile, row_var, col_var, value_var, title = NULL, subtitle = NULL) {
  r_sym <- rlang::as_name(rlang::ensym(row_var))
  c_sym <- rlang::as_name(rlang::ensym(col_var))
  v_sym <- rlang::as_name(rlang::ensym(value_var))
  ggplot2::ggplot(profile, ggplot2::aes(
    .data[[c_sym]], .data[[r_sym]], fill = .data[[v_sym]]
  )) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.9) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", .data[[v_sym]])), size = 3.1, colour = "#0C0D12") +
    ggplot2::scale_fill_gradient2(
      low = "#F1F5F9", mid = "white", high = "#3A9E92", midpoint = 0, name = "z-score"
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    handbook_theme(11) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
}

#' Missingness heatmap (sampled rows)
plot_miss_heatmap <- function(data, id, vars, title = NULL, subtitle = NULL, n_show = 48L) {
  id_sym <- rlang::as_name(rlang::ensym(id))
  miss <- data |>
    dplyr::select(dplyr::all_of(c(id_sym, vars))) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(vars), ~ as.integer(is.na(.x))))
  if (nrow(miss) > n_show) {
    miss <- dplyr::slice_sample(miss, n = n_show)
  }
  long <- miss |>
    tidyr::pivot_longer(dplyr::all_of(vars), names_to = "variable", values_to = "missing")
  ggplot2::ggplot(long, ggplot2::aes(variable, .data[[id_sym]], fill = factor(missing))) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.4) +
    ggplot2::scale_fill_manual(
      values = c(`0` = "#E2E8F0", `1` = "#E879A8"),
      labels = c("Observed", "Missing"),
      name = NULL
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = "Participants (sample)") +
    handbook_theme(10) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}

#' Circular bar chart (polar column)
plot_circular_bar <- function(data, x, y, fill = NULL, title = NULL, subtitle = NULL) {
  fill <- fill %||% x
  x_sym <- rlang::as_name(rlang::ensym(x))
  y_sym <- rlang::as_name(rlang::ensym(y))
  fill_sym <- rlang::as_name(rlang::ensym(fill))
  n <- length(unique(data[[x_sym]]))
  pal <- grDevices::colorRampPalette(c("#CBD5E1", "#3A9E92", "#8B7EC8", "#E879A8", "#5EC4B8"))(n)
  ggplot2::ggplot(data, ggplot2::aes(
    x = .data[[x_sym]], y = .data[[y_sym]], fill = .data[[fill_sym]]
  )) +
    ggplot2::geom_col(width = 0.85, alpha = 0.88, colour = "white", linewidth = 0.5) +
    ggplot2::coord_polar(start = 0) +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    handbook_theme(11) +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_line(colour = "#F1F5F9"),
      axis.text.y = ggplot2::element_blank()
    )
}

#' Love plot: before/after balance dots connected
plot_love_balance <- function(balance, covariate, before, after, title = NULL, subtitle = NULL) {
  c_sym <- rlang::as_name(rlang::ensym(covariate))
  b_sym <- rlang::as_name(rlang::ensym(before))
  a_sym <- rlang::as_name(rlang::ensym(after))
  ggplot2::ggplot(balance, ggplot2::aes(
    x = .data[[c_sym]], y = 0, colour = phase
  )) +
    ggplot2::geom_segment(
      ggplot2::aes(x = .data[[b_sym]], xend = .data[[a_sym]], y = 0, yend = 0),
      colour = "#CBD5E1", linewidth = 1.1
    ) +
    ggplot2::geom_point(ggplot2::aes(x = .data[[b_sym]], colour = "Before"), size = 4) +
    ggplot2::geom_point(ggplot2::aes(x = .data[[a_sym]], colour = "After"), size = 4) +
    ggplot2::scale_colour_manual(
      values = c(Before = "#94A3B8", After = "#3A9E92"),
      name = NULL
    ) +
    ggplot2::facet_wrap(ggplot2::vars(.data[[c_sym]]), nrow = 1, scales = "free_x") +
    ggplot2::labs(title = title, subtitle = subtitle, x = "Standardised mean difference (toy)", y = NULL) +
    handbook_theme(11) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}

#' Marginal scatter with density contours (ggforce)
plot_marginal_scatter <- function(data, x, y, colour = NULL, title = NULL, subtitle = NULL,
                                  xlab = NULL, ylab = NULL) {
  if (!requireNamespace("ggforce", quietly = TRUE)) {
    stop("Install ggforce: install.packages('ggforce')")
  }
  x_sym <- rlang::as_name(rlang::ensym(x))
  y_sym <- rlang::as_name(rlang::ensym(y))
  if (!is.null(colour)) {
    c_sym <- .col_name(colour)
    pal <- c(`FALSE` = handbook_cols$nonsmoker, `TRUE` = handbook_cols$smoker)
    ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], .data[[y_sym]], colour = .data[[c_sym]])) +
      ggplot2::stat_ellipse(
        ggplot2::aes(colour = .data[[c_sym]]),
        type = "norm", linewidth = 0.7, alpha = 0.7, show.legend = FALSE
      ) +
      ggplot2::geom_point(alpha = 0.55, size = 2) +
      ggplot2::geom_smooth(method = "lm", se = TRUE, linewidth = 0.85, alpha = 0.12) +
      ggplot2::scale_colour_manual(values = pal, labels = c("Non-smoker", "Smoker"), name = "Smoking") +
      ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
      handbook_theme()
  } else {
    ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], .data[[y_sym]])) +
      ggplot2::geom_point(alpha = 0.55, size = 2, colour = "#64748B") +
      ggplot2::geom_smooth(method = "lm", se = TRUE, colour = "#3A9E92", fill = "#3A9E92", alpha = 0.15) +
      ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
      handbook_theme()
  }
}

#' k-means / cluster assignment on PCA plane (Ch 11)
plot_cluster_pca <- function(
    data,
    x = "PC1",
    y = "PC2",
    cluster = "cluster",
    label = NULL,
    title = NULL,
    subtitle = NULL,
    xlab = NULL,
    ylab = NULL,
    cluster_palette = NULL
) {
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  cl_sym <- .col_name(cluster)
  lv <- unique(data[[cl_sym]])
  if (is.null(cluster_palette)) {
    cluster_palette <- grDevices::colorRampPalette(c(handbook_cols$standard, handbook_cols$intervention, "#8B7EC8"))(length(lv))
    names(cluster_palette) <- lv
  }
  p <- ggplot2::ggplot(data, ggplot2::aes(
    .data[[x_sym]], .data[[y_sym]], colour = .data[[cl_sym]]
  )) +
    ggplot2::geom_point(alpha = 0.78, size = 2.4) +
    ggplot2::stat_ellipse(linewidth = 0.65, linetype = "dashed", alpha = 0.75) +
    ggplot2::scale_colour_manual(values = cluster_palette, name = "Cluster")
  if (!is.null(label)) {
    lab_sym <- .col_name(label)
    p <- p + ggplot2::aes(shape = .data[[lab_sym]]) +
      ggplot2::scale_shape_discrete(name = "True phenotype")
  }
  p + ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) + handbook_theme(11)
}

#' Hierarchical clustering dendrogram (ggplot via ggdendro)
plot_dendrogram_handbook <- function(
    hc,
    k = 2L,
    title = NULL,
    subtitle = NULL,
    xlab = "Participant index",
    ylab = "Height"
) {
  if (!requireNamespace("ggdendro", quietly = TRUE)) {
    stop("Install ggdendro for dendrogram plots: install.packages('ggdendro')")
  }
  dd <- ggdendro::dendro_data(hc, type = "rectangle")
  cut_h <- if (k > 1L && length(hc$height) >= k - 1L) {
    rev(sort(hc$height))[k - 1L]
  } else {
    NA_real_
  }
  p <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = dd$segments,
      ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
      colour = "#64748B", linewidth = 0.45
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(11) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
  if (!is.na(cut_h)) {
    p <- p + ggplot2::geom_hline(
      yintercept = cut_h, linetype = "dashed",
      colour = handbook_cols$smoker, linewidth = 0.85
    )
  }
  p
}

#' PCA QC with colour + shape (batch / group teaching)
plot_pca_dual <- function(
    data,
    x = "PC1",
    y = "PC2",
    colour = "batch",
    shape = "group",
    title = NULL,
    subtitle = NULL,
    xlab = NULL,
    ylab = NULL,
    colour_palette = NULL,
    show_colour_legend = TRUE
) {
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  c_sym <- .col_name(colour)
  s_sym <- .col_name(shape)
  if (is.null(colour_palette)) {
    n_c <- length(unique(data[[c_sym]]))
    colour_palette <- grDevices::colorRampPalette(c(handbook_cols$nonsmoker, handbook_cols$smoker, "#8B7EC8"))(n_c)
    names(colour_palette) <- unique(data[[c_sym]])
  }
  p <- ggplot2::ggplot(data, ggplot2::aes(
    .data[[x_sym]], .data[[y_sym]],
    colour = .data[[c_sym]], shape = .data[[s_sym]]
  )) +
    ggplot2::geom_point(alpha = 0.82, size = 2.2) +
    ggplot2::scale_colour_manual(values = colour_palette, name = stringr::str_to_title(c_sym)) +
    ggplot2::scale_shape_discrete(name = stringr::str_to_title(s_sym)) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(11)
  if (!show_colour_legend) {
    p <- p + ggplot2::guides(colour = "none")
  }
  p
}

#' Simple metric bar chart (counts, R², PPV)
plot_metric_bars <- function(
    data,
    x,
    y,
    fill = NULL,
    title = NULL,
    subtitle = NULL,
    xlab = NULL,
    ylab = NULL,
    y_limits = NULL,
    y_labels = NULL
) {
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  fill_sym <- if (is.null(fill)) x_sym else .col_name(fill)
  n <- length(unique(data[[fill_sym]]))
  pal <- grDevices::colorRampPalette(c(handbook_cols$intervention, handbook_cols$nonsmoker, handbook_cols$smoker))(n)
  names(pal) <- unique(data[[fill_sym]])
  p <- ggplot2::ggplot(data, ggplot2::aes(
    .data[[x_sym]], .data[[y_sym]], fill = .data[[fill_sym]]
  )) +
    ggplot2::geom_col(width = 0.68, alpha = 0.9, colour = "white", linewidth = 0.4) +
    ggplot2::scale_fill_manual(values = pal, guide = "none") +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(11)
  if (!is.null(y_limits)) p <- p + ggplot2::scale_y_continuous(limits = y_limits, labels = y_labels)
  else if (!is.null(y_labels)) p <- p + ggplot2::scale_y_continuous(labels = y_labels)
  p
}

#' Dual-metric line panel helper (threshold sensitivity)
plot_dual_line_panel <- function(
    data,
    x,
    y1,
    y2,
    x_ref = NULL,
    title = NULL,
    subtitle = NULL,
    xlab = NULL,
    ylab1 = NULL,
    ylab2 = NULL
) {
  x_sym <- .col_name(x)
  y1_sym <- .col_name(y1)
  y2_sym <- .col_name(y2)
  p1 <- ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], .data[[y1_sym]])) +
    ggplot2::geom_line(linewidth = 1, colour = handbook_cols$intervention) +
    ggplot2::geom_point(size = 2.2, colour = handbook_cols$accent) +
    ggplot2::labs(title = ylab1, x = NULL, y = NULL) +
    handbook_theme(10)
  p2 <- ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], .data[[y2_sym]])) +
    ggplot2::geom_line(linewidth = 1, colour = handbook_cols$smoker) +
    ggplot2::geom_point(size = 2.2, colour = handbook_cols$accent) +
    ggplot2::labs(title = ylab2, x = xlab, y = NULL) +
    handbook_theme(10)
  if (!is.null(x_ref)) {
    p1 <- p1 + ggplot2::geom_vline(xintercept = x_ref, linetype = "dashed", colour = "#94A3B8")
    p2 <- p2 + ggplot2::geom_vline(xintercept = x_ref, linetype = "dashed", colour = "#94A3B8")
  }
  if (requireNamespace("patchwork", quietly = TRUE)) {
    p1 / p2 + patchwork::plot_annotation(title = title, subtitle = subtitle, theme = handbook_theme(12))
  } else {
    p1
  }
}

#' Reference line for clinical minimum important difference (continuous y)
geom_mcid_hline <- function(yintercept, label = "MCID", ...) {
  ggplot2::list(
    ggplot2::geom_hline(
      yintercept = yintercept, linetype = "dotted",
      colour = handbook_cols$smoker, linewidth = 0.65, alpha = 0.85, ...
    ),
    ggplot2::annotate(
      "text", x = Inf, y = yintercept, label = label,
      hjust = 1.05, vjust = -0.35, size = 3, colour = handbook_cols$smoker
    )
  )
}

#' Normal Q-Q with handbook styling
plot_qq_handbook <- function(data, sample, title = NULL, subtitle = NULL,
                             xlab = "Theoretical quantiles", ylab = "Sample quantiles") {
  s_sym <- .col_name(sample)
  ggplot2::ggplot(data, ggplot2::aes(sample = .data[[s_sym]])) +
    ggplot2::stat_qq(alpha = 0.55, colour = "#64748B", size = 1.6) +
    ggplot2::stat_qq_line(linewidth = 0.85, colour = handbook_cols$intervention) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(11)
}

#' emmeans / marginal means: dot-and-whisker
plot_emmeans_dot <- function(data, x, estimate, lower, upper, title = NULL, subtitle = NULL,
                             xlab = NULL, ylab = NULL, point_color = handbook_cols$intervention) {
  x_sym <- .col_name(x)
  e_sym <- .col_name(estimate)
  lo_sym <- .col_name(lower)
  hi_sym <- .col_name(upper)
  df <- data
  if (is.logical(df[[x_sym]])) {
    df[[x_sym]] <- factor(df[[x_sym]], levels = c(FALSE, TRUE), labels = c("Non-smoker", "Smoker"))
  }
  ggplot2::ggplot(df, ggplot2::aes(.data[[x_sym]], .data[[e_sym]])) +
    ggplot2::geom_hline(
      yintercept = mean(data[[e_sym]], na.rm = TRUE),
      linetype = "dotted", colour = "#CBD5E1", linewidth = 0.55
    ) +
    ggplot2::geom_linerange(
      ggplot2::aes(ymin = .data[[lo_sym]], ymax = .data[[hi_sym]]),
      linewidth = 1.05, colour = "#64748B"
    ) +
    ggplot2::geom_point(size = 4.8, colour = point_color) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    handbook_theme(11)
}

#' Slopegraph: covariate balance before vs after weighting
plot_balance_slopegraph <- function(
    data,
    covariate,
    group,
    phase,
    value,
    phase_levels = NULL,
    title = NULL,
    subtitle = NULL,
    ylab = "Mean (or weighted mean)",
    group_labels = NULL,
    group_colours = NULL
) {
  c_sym <- .col_name(covariate)
  g_sym <- .col_name(group)
  p_sym <- .col_name(phase)
  v_sym <- .col_name(value)
  df <- data
  if (!is.null(phase_levels)) {
    df[[p_sym]] <- factor(df[[p_sym]], levels = phase_levels)
  }
  if (is.null(group_colours) && is.logical(df[[g_sym]])) {
    group_colours <- c("FALSE" = handbook_cols$nonsmoker, "TRUE" = handbook_cols$smoker)
  }
  ggplot2::ggplot(df, ggplot2::aes(
    .data[[p_sym]], .data[[v_sym]],
    colour = .data[[g_sym]], group = .data[[g_sym]]
  )) +
    ggplot2::geom_line(linewidth = 1.15, alpha = 0.9) +
    ggplot2::geom_point(size = 4.2, alpha = 0.95) +
    ggplot2::facet_wrap(ggplot2::vars(.data[[c_sym]]), nrow = 1, scales = "free_y") +
    ggplot2::scale_colour_manual(values = group_colours, labels = group_labels, name = NULL) +
    ggplot2::labs(title = title, subtitle = subtitle, x = NULL, y = ylab) +
    handbook_theme(11) +
    ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
}

#' AUC / metric comparison: horizontal dot plot with optional CI
plot_metric_dotplot <- function(
    data,
    y,
    x,
    xmin = NULL,
    xmax = NULL,
    title = NULL,
    subtitle = NULL,
    xlab = "AUC (95% bootstrap CI)",
    ref = 0.5,
    ref_label = "Chance (0.5)",
    point_color = handbook_cols$intervention
) {
  y_sym <- .col_name(y)
  x_sym <- .col_name(x)
  lo_sym <- if ("auc_lo" %in% names(data)) "auc_lo" else if ("conf.low" %in% names(data)) "conf.low" else NULL
  hi_sym <- if ("auc_hi" %in% names(data)) "auc_hi" else if ("conf.high" %in% names(data)) "conf.high" else NULL
  df <- data |>
    dplyr::mutate(.y = stats::reorder(.data[[y_sym]], .data[[x_sym]]))
  p <- ggplot2::ggplot(df, ggplot2::aes(.data[[x_sym]], .y))
  if (!is.null(lo_sym) && !is.null(hi_sym)) {
    p <- p + ggplot2::geom_errorbar(
      ggplot2::aes(y = .y, xmin = .data[[lo_sym]], xmax = .data[[hi_sym]]),
      orientation = "y",
      width = 0.22, linewidth = 0.75, colour = "#64748B"
    )
  }
  xlim <- if (is.null(xmin) && is.null(xmax)) {
    NULL
  } else {
    c(if (is.null(xmin)) NA_real_ else xmin, if (is.null(xmax)) NA_real_ else xmax)
  }
  p +
    ggplot2::geom_vline(xintercept = ref, linetype = "dashed", colour = "#94A3B8", linewidth = 0.6) +
    ggplot2::geom_point(size = 3.4, colour = point_color) +
    ggplot2::scale_x_continuous(
      limits = xlim,
      expand = ggplot2::expansion(mult = c(0.02, 0.06))
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = NULL) +
    handbook_theme(11)
}

#' Grouped lollipop for counts / rates (POLLUX, batch sensitivity)
plot_grouped_lollipop <- function(
    data, x, y, group = NULL,
    title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
    pal = NULL
) {
  x_sym <- .col_name(x)
  y_sym <- .col_name(y)
  if (is.null(group)) {
    ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], .data[[y_sym]])) +
      ggplot2::geom_segment(
        ggplot2::aes(x = .data[[x_sym]], xend = .data[[x_sym]], y = 0, yend = .data[[y_sym]]),
        colour = "#CBD5E1", linewidth = 0.9
      ) +
      ggplot2::geom_point(size = 4, colour = handbook_cols$intervention) +
      ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
      handbook_theme(11)
  } else {
    g_sym <- .col_name(group)
    if (is.null(pal)) {
      n_g <- length(unique(data[[g_sym]]))
      pal <- grDevices::colorRampPalette(c(handbook_cols$intervention, handbook_cols$smoker, handbook_cols$nonsmoker))(n_g)
      names(pal) <- unique(data[[g_sym]])
    }
    ggplot2::ggplot(data, ggplot2::aes(.data[[x_sym]], .data[[y_sym]], colour = .data[[g_sym]])) +
      ggplot2::geom_segment(
        ggplot2::aes(x = .data[[x_sym]], xend = .data[[x_sym]], y = 0, yend = .data[[y_sym]]),
        linewidth = 0.85, alpha = 0.55
      ) +
      ggplot2::geom_point(size = 3.8, alpha = 0.95) +
      ggplot2::scale_colour_manual(values = pal, name = NULL) +
      ggplot2::labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
      handbook_theme(11) +
      ggplot2::theme(panel.grid.major.x = ggplot2::element_blank())
  }
}

#' Mediation path diagram (handbook styling)
plot_mediation_path_handbook <- function(
    title = "Mediation path",
    subtitle = NULL,
    nodes = c("Smoking", "FEV1 % pred.", "Exacerbation (12 m)"),
    node_colours = c("#FECACA", "#E0F2FE", "#DCFCE7")
) {
  path_nodes <- tibble::tibble(
    node = nodes,
    x = c(1, 2.5, 4),
    y = c(2, 2, 2),
    fill = node_colours
  )
  path_edges <- tibble::tibble(
    x = c(1.35, 2.85), y = c(2, 2), xend = c(2.15, 3.65), yend = c(2, 2),
    label = c("a", "b")
  )
  ggplot2::ggplot() +
    ggplot2::geom_curve(
      ggplot2::aes(x = 1.15, y = 2.42, xend = 3.85, yend = 2.42),
      curvature = 0.08,
      arrow = grid::arrow(length = grid::unit(0.2, "cm"), type = "closed"),
      linewidth = 0.85, colour = "#334155"
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = 2.5, y = 2.58, label = "c'"),
      size = 3.8, colour = "#64748B"
    ) +
    ggplot2::geom_segment(
      data = path_edges,
      ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
      arrow = grid::arrow(length = grid::unit(0.2, "cm"), type = "closed"),
      linewidth = 0.85, colour = "#334155"
    ) +
    ggplot2::geom_text(
      data = path_edges,
      ggplot2::aes(x = (x + xend) / 2, y = y - 0.18, label = label),
      size = 3.8, colour = "#64748B"
    ) +
    ggplot2::geom_label(
      data = path_nodes,
      ggplot2::aes(x = x, y = y, label = node, fill = fill),
      colour = "#0F172A", linewidth = 0.25, size = 4.2, label.size = 0.15
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_cartesian(xlim = c(0.35, 4.65), ylim = c(1.55, 2.85), clip = "off") +
    ggplot2::labs(title = title, subtitle = subtitle) +
    handbook_theme(11) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}
