# Generate all handbook figures (navigation, chapters 4–6, 10)
source("R/00_setup.R")

library(tidyverse)
library(broom)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

spirometry <- read_csv(file.path(paths$data, "spirometry.csv"), show_col_types = FALSE)
exacerbation <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE)
bronchodilator <- read_csv(file.path(paths$data, "bronchodilator_paired.csv"), show_col_types = FALSE)
counts <- read_csv(file.path(paths$data, "exacerbation_counts.csv"), show_col_types = FALSE)
omics <- read_csv(file.path(paths$data, "marker_panel.csv"), show_col_types = FALSE)

# =============================================================================
# Flowchart helpers (ggplot2: modern palette, clipped labels)
# =============================================================================
fc_styles <- tibble::tribble(
  ~kind,    ~fill,     ~border,   ~text,     ~fontface,
  "start",  "#ECFDF5", "#14B8A6", "#115E59", "bold",
  "decide", "#EEF2FF", "#818CF8", "#3730A3", "bold",
  "cat",    "#F8FAFC", "#CBD5E1", "#475569", "bold",
  "method", "#FFFFFF", "#E2E8F0", "#1E293B", "plain",
  "warn",   "#FFF1F2", "#FB7185", "#9F1239", "bold",
  "omics",  "#F5F3FF", "#A78BFA", "#5B21B6", "plain",
  "report", "#F1F5F9", "#94A3B8", "#334155", "plain",
  "foot",   "#FFFFFF", "#E2E8F0", "#64748B", "plain",
  "stop",   "#FFF1F2", "#F43F5E", "#BE123C", "bold"
)

fc_node <- function(id, x, y, label, w, kind = "method") {
  n <- stringr::str_count(label, "\n") + 1L
  h <- 5.5 + n * 3.1
  sty <- fc_styles[fc_styles$kind == kind, , drop = FALSE]
  dplyr::bind_cols(
    tibble::tibble(id = id, x = x, y = y, w = w, h = h, label = label, kind = kind),
    sty |> dplyr::select(-kind)
  )
}

fc_stack <- function(specs, x, y_top, gap = 2.4) {
  y <- y_top
  out <- list()
  for (s in specs) {
    n <- stringr::str_count(s$label, "\n") + 1L
    h <- 5.5 + n * 3.1
    y <- y - h / 2
    out[[length(out) + 1L]] <- fc_node(s$id, x, y, s$label, s$w, s$kind)
    y <- y - h / 2 - gap
  }
  dplyr::bind_rows(out)
}

fc_edges <- function(from, to, nodes) {
  from <- as.character(from)
  to <- as.character(to)
  purrr::map2_dfr(from, to, function(a, b) {
    na <- nodes |> dplyr::filter(id == a)
    nb <- nodes |> dplyr::filter(id == b)
    if (nrow(na) == 0L || nrow(nb) == 0L) {
      return(tibble::tibble(x = NA_real_, y = NA_real_, xend = NA_real_, yend = NA_real_))
    }
    tibble::tibble(
      x = na$x[[1]], y = na$y[[1]] - na$h[[1]] / 2 - 0.4,
      xend = nb$x[[1]], yend = nb$y[[1]] + nb$h[[1]] / 2 + 0.4
    )
  }) |>
    dplyr::filter(!is.na(x))
}

fc_branch_edges <- function(from_id, to_ids, nodes, drop = 0.6) {
  na <- nodes |> dplyr::filter(id == from_id)
  branch_y <- na$y[[1]] - na$h[[1]] / 2 - drop
  purrr::map_dfr(to_ids, function(b) {
    nb <- nodes |> dplyr::filter(id == b)
    if (nrow(nb) == 0L) {
      return(tibble::tibble(x = NA_real_, y = NA_real_, xend = NA_real_, yend = NA_real_, xmid = NA_real_, ymid = NA_real_))
    }
    tibble::tibble(
      x = na$x[[1]], y = branch_y, xend = nb$x[[1]], yend = nb$y[[1]] + nb$h[[1]] / 2 + 0.4,
      xmid = nb$x[[1]], ymid = branch_y
    )
  }) |>
    dplyr::filter(!is.na(x))
}

fc_save <- function(nodes, edges, title, subtitle, caption, path, w_in, h_in, accent_edges = NULL) {
  nodes <- nodes |>
    dplyr::mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2
    )

  y_lo <- min(nodes$ymin) - 3
  y_hi <- max(nodes$ymax) + 3
  if (!is.null(accent_edges) && nrow(accent_edges) > 0) {
    y_lo <- min(y_lo, accent_edges$ymid, accent_edges$yend, na.rm = TRUE) - 2
  }

  p <- ggplot2::ggplot() +
    ggplot2::theme_void(base_family = "sans") +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#F8FAFC", colour = NA),
      plot.margin = ggplot2::margin(18, 14, 14, 14),
      plot.title = ggplot2::element_text(
        face = "bold", size = 16, colour = "#0F172A", hjust = 0.5, margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 9, colour = "#64748B", hjust = 0.5, margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(size = 7.5, colour = "#94A3B8", hjust = 0.5, margin = ggplot2::margin(t = 8))
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption) +
    ggplot2::coord_cartesian(xlim = c(0, 100), ylim = c(y_lo, y_hi), clip = "off")

  if (nrow(edges) > 0) {
    if ("xmid" %in% names(edges)) {
      p <- p +
        ggplot2::geom_segment(
          data = edges, ggplot2::aes(x = x, y = y, xend = xmid, yend = ymid),
          colour = "#94A3B8", linewidth = 0.45, lineend = "round"
        ) +
        ggplot2::geom_segment(
          data = edges, ggplot2::aes(x = xmid, y = ymid, xend = xend, yend = yend),
          colour = "#94A3B8", linewidth = 0.45, lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.14, "cm"), type = "closed")
        )
    } else {
      p <- p +
        ggplot2::geom_segment(
          data = edges, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
          colour = "#94A3B8", linewidth = 0.45, lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.14, "cm"), type = "closed")
        )
    }
  }

  if (!is.null(accent_edges) && nrow(accent_edges) > 0) {
    if ("xmid" %in% names(accent_edges)) {
      p <- p +
        ggplot2::geom_segment(
          data = accent_edges, ggplot2::aes(x = x, y = y, xend = xmid, yend = ymid),
          colour = "#F43F5E", linewidth = 0.5, linetype = "22", lineend = "round"
        ) +
        ggplot2::geom_segment(
          data = accent_edges, ggplot2::aes(x = xmid, y = ymid, xend = xend, yend = yend),
          colour = "#F43F5E", linewidth = 0.5, linetype = "22", lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
        )
    } else {
      p <- p +
        ggplot2::geom_segment(
          data = accent_edges, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
          colour = "#F43F5E", linewidth = 0.5, linetype = "22", lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
        )
    }
  }

  p <- p +
    ggplot2::geom_rect(
      data = nodes, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = nodes$fill, colour = nodes$border, linewidth = 0.55
    ) +
    ggplot2::geom_text(
      data = nodes, ggplot2::aes(x = x, y = y, label = label),
      size = 2.55, lineheight = 0.88, colour = nodes$text,
      fontface = nodes$fontface, family = "sans"
    )

  ggplot2::ggsave(path, p, width = w_in, height = h_in, dpi = 200, bg = "#F8FAFC")
}

# =============================================================================
# 1. Method decision tree (handbook navigation)
# =============================================================================
draw_method_decision_tree <- function(path) {
  top <- fc_stack(
    list(
      list(id = "e1", label = "1. Write estimand\nCh 1", w = 34, kind = "start"),
      list(id = "e2", label = "2. Outcome type?\nCh 2 · Appendix B", w = 38, kind = "decide")
    ),
    x = 50, y_top = 97, gap = 3.2
  )
  branch_top <- min(top$y - top$h / 2) - 2
  col1 <- fc_stack(
    list(
      list(id = "c1", label = "Continuous\nFEV1 · scores · 6MWD", w = 26, kind = "cat"),
      list(id = "m1a", label = "2 independent groups\nWelch t-test\nAlt: Mann-Whitney", w = 26, kind = "method"),
      list(id = "m1b", label = "Paired design\npaired t-test", w = 26, kind = "method"),
      list(id = "m1c", label = "Adjust covariates\nlinear · ANCOVA\nCh 5", w = 26, kind = "method")
    ),
    x = 18, y_top = branch_top, gap = 3
  )
  col2 <- fc_stack(
    list(
      list(id = "c2", label = "Binary\nexacerbation Y/N", w = 26, kind = "cat"),
      list(id = "m2a", label = "2 independent groups\nchi-square · Fisher", w = 26, kind = "method"),
      list(id = "m2b", label = "Paired binary\nMcNemar", w = 26, kind = "method"),
      list(id = "m2c", label = "Adjust covariates\nlogistic · Firth if sparse\nCh 6", w = 26, kind = "method")
    ),
    x = 50, y_top = branch_top, gap = 3
  )
  col3 <- fc_stack(
    list(
      list(id = "c3", label = "Count\nevents per follow-up", w = 26, kind = "cat"),
      list(id = "m3a", label = "Never t-test\non counts", w = 26, kind = "warn"),
      list(id = "m3b", label = "Poisson GLM\noffset if needed", w = 26, kind = "method"),
      list(id = "m3c", label = "Overdispersion\nnegative binomial", w = 26, kind = "method")
    ),
    x = 82, y_top = branch_top, gap = 3
  )
  col_min <- min(c(col1$y - col1$h / 2, col2$y - col2$h / 2, col3$y - col3$h / 2))
  bottom <- fc_stack(
    list(
      list(id = "omics", label = "Many features / omics · Ch 10–17\nDE + FDR (13) · batch (14) · flow (15) · screen (16) · pipeline (17)", w = 78, kind = "omics"),
      list(id = "report", label = "Report effect · 95% CI · n · limitations\nCONSORT · STROBE · TRIPOD · Ch 8", w = 72, kind = "report"),
      list(id = "extra", label = "Ch 18–21 · longitudinal · survival · missing data · causal", w = 68, kind = "foot")
    ),
    x = 50, y_top = col_min - 2, gap = 2.6
  )
  nodes <- dplyr::bind_rows(top, col1, col2, col3, bottom)

  edges <- dplyr::bind_rows(
    fc_edges("e1", "e2", nodes),
    fc_branch_edges("e2", c("c1", "c2", "c3"), nodes, drop = 1.2),
    fc_edges(c("c1", "m1a", "m1b", "m1c"), c("m1a", "m1b", "m1c", "omics"), nodes),
    fc_edges(c("c2", "m2a", "m2b", "m2c"), c("m2a", "m2b", "m2c", "omics"), nodes),
    fc_edges(c("c3", "m3a", "m3b", "m3c"), c("m3a", "m3b", "m3c", "omics"), nodes),
    fc_edges(c("omics", "report"), c("report", "extra"), nodes)
  )

  fc_save(
    nodes, edges,
    title = "Method decision tree",
    subtitle = "After steps 1–3 of the CASTOR pipeline · pick test or model by outcome type",
    caption = "QUICK_REFERENCE.md · METHOD_MAP.md · analysis_pipeline.png",
    path = path, w_in = 7.2, h_in = 12.5
  )
}

draw_method_decision_tree(file.path(fig_dir, "method_decision_tree_r.png"))

# Illustrated method decision tree (handbook): figures/method_decision_tree.png
#: custom asset; not overwritten by this script. R fallback: method_decision_tree_r.png

# =============================================================================
# 1b. CASTOR analysis pipeline (process before method choice)
# =============================================================================
draw_analysis_pipeline <- function(path) {
  spine <- fc_stack(
    list(
      list(id = "s1", label = "1. Clinical question\nWhat would change practice?", w = 42, kind = "start"),
      list(id = "s2", label = "2. Estimand + population\nWho · what contrast · when", w = 42, kind = "start"),
      list(id = "s3", label = "3. Describe the sample\nTable 1 · plots · missingness", w = 42, kind = "decide"),
      list(id = "s4", label = "4. Choose method\nOutcome type + design", w = 42, kind = "cat"),
      list(id = "s5", label = "5. Fit model / test in R\nPrespecified script", w = 42, kind = "method"),
      list(id = "s6", label = "6. Diagnostics + sensitivity\nAssumptions · MI · alternatives", w = 42, kind = "omics"),
      list(id = "s7", label = "7. Report estimate + 95% CI\nn · limitations · guidelines", w = 42, kind = "report"),
      list(id = "s8", label = "8. State what was NOT proven\nStop: do not over-claim", w = 42, kind = "stop")
    ),
    x = 46, y_top = 92, gap = 2.8
  ) |> dplyr::mutate(x = 46)

  branches <- fc_stack(
    list(
      list(id = "b1", label = "Prediction\nCh 9", w = 22, kind = "decide"),
      list(id = "b2", label = "Method tree\nAppendix B", w = 22, kind = "method"),
      list(id = "b3", label = "Omics / discovery\nCh 13–17", w = 22, kind = "omics"),
      list(id = "b4", label = "Longitudinal\nCh 18–19", w = 22, kind = "cat")
    ),
    x = 82, y_top = spine$y[spine$id == "s4"] + 8, gap = 2.2
  )

  loop_y <- min(spine$y - spine$h / 2) - 6
  loop <- fc_node("loop", 46, loop_y, "Estimand ≠ design?\nReturn to steps 1–2", 42, "warn")
  nodes <- dplyr::bind_rows(spine, branches, loop)

  s4 <- nodes |> dplyr::filter(id == "s4")
  accent <- tibble::tibble(
    x = s4$x - s4$w / 2,
    y = s4$y,
    xmid = 18,
    ymid = loop$y + loop$h / 2 + 1,
    xend = loop$x - loop$w / 2,
    yend = loop$y + loop$h / 2 + 0.5
  )

  edges <- dplyr::bind_rows(
    fc_edges(paste0("s", 1:7), paste0("s", 2:8), nodes),
    fc_branch_edges("s4", c("b1", "b2", "b3", "b4"), nodes, drop = 3.5)
  )

  fc_save(
    nodes, edges,
    title = "CASTOR analysis pipeline",
    subtitle = "Question first · method second · report what you did not prove",
    caption = "Ch 1 & 12 · CASTOR workflow: Clinical question → Assess → Select → Test → Output → Report limits",
    path = path, w_in = 6.8, h_in = 10.5,
    accent_edges = accent
  )
}

draw_analysis_pipeline(file.path(fig_dir, "analysis_pipeline_r.png"))

# Illustrated CASTOR pipeline (handbook): figures/analysis_pipeline.png
#: custom asset; not overwritten by this script. R fallback: analysis_pipeline_r.png

# =============================================================================
# 2. Comparison panel (t-test vs Wilcoxon vs linear; chi vs logistic)
# =============================================================================
p_cont <- tibble(
  method = c("Welch t-test", "Mann-Whitney", "Linear regression"),
  use_when = c(
    "Default: 2 independent groups",
    "Very skew + small n",
    "Adjust for covariates"
  ),
  outcome = "Continuous (FEV1)"
) %>%
  ggplot(aes(x = method, y = 1, fill = method)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.2) +
  scale_fill_brewer(palette = "Blues", guide = "none") +
  labs(title = "Continuous outcomes") +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

p_bin <- tibble(
  method = c("Chi-square / Fisher", "McNemar", "Logistic regression"),
  use_when = c(
    "2 independent groups",
    "Paired binary",
    "Adjust for covariates"
  ),
  outcome = "Binary (exacerbation Y/N)"
) %>%
  ggplot(aes(x = method, y = 1, fill = method)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.2) +
  scale_fill_brewer(palette = "Greens", guide = "none") +
  labs(title = "Binary / categorical outcomes") +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

p_count <- tibble(
  method = c("NOT t-test", "Poisson GLM", "Negative binomial"),
  use_when = c(
    "Wrong for counts",
    "Equal / offset follow-up",
    "Overdispersion"
  ),
  outcome = "Count (exacerbations)"
) %>%
  ggplot(aes(x = method, y = 1, fill = method)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.2) +
  scale_fill_manual(values = c("#F8D7DA", "#D4EDDA", "#D4EDDA"), guide = "none") +
  labs(title = "Count outcomes") +
  theme_void(base_size = 11) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

p_panel <- p_cont / p_bin / p_count +
  plot_annotation(
    title = "Method comparison panel",
    subtitle = "Full tables: volume-01/QUICK_REFERENCE.md"
  )

ggsave(file.path(fig_dir, "method_comparison_panel.png"), p_panel, width = 9, height = 8, dpi = 150)

# =============================================================================
# 3. Chapter 4 figures
# =============================================================================
p_ch04_box <- ggplot(spirometry, aes(group, fev1, fill = group)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.4) +
  geom_jitter(width = 0.12, alpha = 0.25, size = 1) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, colour = "black") +
  labs(
    title = "FEV1 by trial arm (CASTOR)",
    subtitle = "Diamond = mean; use Welch t-test for independent groups (Ch 4)",
    x = NULL, y = "FEV1 (L)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "ch04_fev1_by_group.png"), p_ch04_box, width = 6, height = 4.5, dpi = 150)

p_ch04_paired <- bronchodilator %>%
  select(patient_id, fev1_pre, fev1_post) %>%
  pivot_longer(-patient_id, names_to = "visit", values_to = "fev1") %>%
  mutate(visit = if_else(visit == "fev1_pre", "Pre-BD", "Post-BD")) %>%
  ggplot(aes(visit, fev1, group = patient_id)) +
  geom_line(alpha = 0.35, colour = "steelblue") +
  geom_point(alpha = 0.5, size = 1.2) +
  stat_summary(aes(group = visit), fun = mean, geom = "point", size = 4, colour = "red") +
  stat_summary(aes(group = visit), fun.data = mean_se, geom = "errorbar", width = 0.1, colour = "red") +
  labs(
    title = "Bronchodilator response (paired FEV1)",
    subtitle = "Use paired t-test or Wilcoxon signed-rank (Ch 4)",
    x = NULL, y = "FEV1 (L)"
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(fig_dir, "ch04_paired_bronchodilator.png"), p_ch04_paired, width = 5.5, height = 4.5, dpi = 150)

exac_rate <- exacerbation %>%
  group_by(smoking) %>%
  summarise(
    n = n(),
    events = sum(exacerbation_12m),
    rate = mean(exacerbation_12m),
    .groups = "drop"
  ) %>%
  mutate(smoking = if_else(smoking, "Smoker", "Non-smoker"))

p_ch04_bar <- ggplot(exac_rate, aes(smoking, rate, fill = smoking)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_text(aes(label = sprintf("%d/%d (%.1f%%)", events, n, 100 * rate)), vjust = -0.5, size = 3.5) +
  scale_y_continuous(labels = scales::percent, limits = c(0, max(exac_rate$rate) * 1.25)) +
  labs(
    title = "12-month exacerbation by smoking status",
    subtitle = "Use Fisher / chi-square or logistic regression (Ch 4, 6)",
    x = NULL, y = "Proportion with ≥1 exacerbation"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "ch04_exacerbation_by_smoking.png"), p_ch04_bar, width = 5.5, height = 4.5, dpi = 150)

# =============================================================================
# 4. Chapter 5 figures
# =============================================================================
fit_lm <- lm(fev1 ~ smoking + age + sex + height_cm, data = spirometry)

p_resid <- ggplot(tibble(fitted = fitted(fit_lm), resid = rstandard(fit_lm)), aes(fitted, resid)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_smooth(se = FALSE, colour = "firebrick", linewidth = 0.8) +
  labs(title = "Residuals vs fitted", x = "Fitted FEV1", y = "Standardized residuals") +
  theme_minimal(base_size = 11)

p_qq <- ggplot(spirometry, aes(sample = rstandard(fit_lm))) +
  stat_qq(alpha = 0.6) +
  stat_qq_line(linewidth = 0.8) +
  labs(title = "Normal Q-Q of residuals", x = "Theoretical", y = "Sample") +
  theme_minimal(base_size = 11)

ggsave(
  file.path(fig_dir, "ch05_residual_diagnostics.png"),
  p_resid | p_qq,
  width = 9, height = 4, dpi = 150
)

if (requireNamespace("emmeans", quietly = TRUE)) {
  em <- emmeans::emmeans(fit_lm, ~ smoking)
  em_df <- as.data.frame(em)
  p_adj <- ggplot(em_df, aes(smoking, emmean)) +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.15) +
    labs(
      title = "Adjusted mean FEV1 by smoking (CASTOR)",
      subtitle = "From linear model adjusting age, sex, height (Ch 5)",
      x = "Smoking", y = "Estimated mean FEV1 (L)"
    ) +
    theme_minimal(base_size = 12)
  ggsave(file.path(fig_dir, "ch05_fev1_by_smoking_adjusted.png"), p_adj, width = 5.5, height = 4.5, dpi = 150)
}

# =============================================================================
# 5. Chapter 6 figures
# =============================================================================
logit_fit <- glm(
  exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
  data = exacerbation, family = binomial
)

forest_df <- tidy(logit_fit, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(term = str_replace_all(term, "_", " "))

p_forest <- ggplot(forest_df, aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_point(size = 3, colour = "steelblue") +
  scale_x_log10() +
  labs(
    title = "Adjusted odds ratios: 12-month exacerbation",
    subtitle = "Logistic regression (Ch 6); log scale",
    x = "Odds ratio (95% CI)", y = NULL
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(fig_dir, "ch06_logistic_forest.png"), p_forest, width = 7, height = 4.5, dpi = 150)

if ("person_years" %in% names(counts)) {
  pois_fit <- glm(
    exacerbations_12m ~ smoking + ics_adherence + offset(log(person_years)),
    data = counts, family = poisson
  )
} else {
  pois_fit <- glm(exacerbations_12m ~ smoking + ics_adherence, data = counts, family = poisson)
}

rr_df <- tidy(pois_fit, conf.int = TRUE, exponentiate = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(term = str_replace_all(term, "_", " "))

p_rr <- ggplot(rr_df, aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 1, linetype = "dashed", colour = "grey50") +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_point(size = 3, colour = "darkgreen") +
  scale_x_log10() +
  labs(
    title = "Rate ratios: exacerbation counts",
    subtitle = "Poisson GLM (Ch 6); log scale",
    x = "Rate ratio (95% CI)", y = NULL
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(fig_dir, "ch06_poisson_rate_ratio.png"), p_rr, width = 7, height = 3.5, dpi = 150)

# =============================================================================
# 6. Chapter 10 PCA figures
# =============================================================================
if (requireNamespace("factoextra", quietly = TRUE)) {
  X <- omics %>% select(starts_with("M"))
  pca <- prcomp(X, scale. = TRUE)

  p_scree <- factoextra::fviz_eig(pca, addlabels = TRUE, barfill = "steelblue", barcolor = "steelblue") +
    labs(title = "PCA scree plot, CASTOR marker panel")

  ggsave(file.path(fig_dir, "ch10_scree.png"), p_scree, width = 6, height = 4.5, dpi = 150)

  p_biplot <- factoextra::fviz_pca_ind(
    pca, habillage = omics$true_phenotype,
    addEllipses = TRUE, palette = "jco",
    title = "PCA: PC1 vs PC2 (true phenotype, teaching only)"
  )
  ggsave(file.path(fig_dir, "ch10_pca_biplot.png"), p_biplot, width = 7, height = 5, dpi = 150)
} else {
  message("Install factoextra for PCA figures: install.packages('factoextra')")
}

message("Handbook figures saved to ", fig_dir)
message("See volume-01/FIGURE_INDEX.md for the full list.")
