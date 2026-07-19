# Generate all handbook figures (navigation, chapters 4–6, 10)
source("R/00_setup.R")

library(tidyverse)
library(broom)
library(patchwork)

source("R/viz_handbook.R")

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

fc_styles_dark <- tibble::tribble(
  ~kind,    ~fill,     ~border,   ~text,     ~fontface,
  "start",  "#141820", "#3A9E92", "#E8EDF2", "bold",
  "decide", "#151B24", "#5EC4B8", "#C8D2DC", "bold",
  "cat",    "#12161D", "#6E7D8A", "#B8C4CE", "bold",
  "method", "#10141A", "#4A5A6A", "#DDE4EA", "plain",
  "warn",   "#1A1218", "#E879A8", "#F5C2D9", "bold",
  "omics",  "#14101E", "#8B7EC8", "#D4CFF0", "plain",
  "report", "#131820", "#64748B", "#B8C4CE", "plain",
  "foot",   "#0F1318", "#3A4555", "#9AA8B5", "plain",
  "stop",   "#1A1014", "#E85D75", "#F8B4C0", "bold"
)

fc_styles_handbook <- tibble::tribble(
  ~kind,    ~fill,     ~border,   ~text,     ~fontface,
  "start",  "#FFFFFF", "#3A9E92", "#0C0D12", "bold",
  "decide", "#FFFFFF", "#5EC4B8", "#1E293B", "bold",
  "cat",    "#FAFBFC", "#9AA8B5", "#334155", "bold",
  "method", "#FFFFFF", "#C8D2DC", "#334155", "plain",
  "warn",   "#FFFBFC", "#E879A8", "#9F1239", "bold",
  "omics",  "#FDFCFF", "#8B7EC8", "#4C3D6E", "plain",
  "report", "#F8FAFC", "#64748B", "#334155", "plain",
  "foot",   "#FFFFFF", "#DDE4EA", "#64748B", "plain",
  "stop",   "#FFF8F8", "#E85D75", "#9F1239", "bold",
  "header", "#F4F6F8", "#0C0D12", "#0C0D12", "bold"
)

fc_pearl_lanes <- tibble::tribble(
  ~x, ~w, ~fill, ~border,
  18, 28, "#F0FAF9", "#5EC4B8",
  50, 28, "#EEF2FF", "#818CF8",
  82, 28, "#FFF1F2", "#FDA4AF"
)

fc_theme <- function(theme = c("light", "dark", "handbook", "pearl")) {
  if (theme[[1]] == "dark") {
    list(
      styles = fc_styles_dark,
      bg = "#0C0D12",
      title = "#E8EDF2",
      subtitle = "#9AA8B5",
      caption = "#6E7D8A",
      edge = "#5A6A78",
      accent = "#E85D75",
      stripe = FALSE,
      text_size = 2.55,
      dpi = 250
    )
  } else if (theme[[1]] == "handbook") {
    list(
      styles = fc_styles_handbook,
      bg = "#FFFFFF",
      title = "#0C0D12",
      subtitle = "#64748B",
      caption = "#9AA8B5",
      edge = "#C8D2DC",
      accent = "#E85D75",
      stripe = TRUE,
      text_size = 2.75,
      dpi = 320,
      lanes = NULL
    )
  } else if (theme[[1]] == "pearl") {
    list(
      styles = tibble::tribble(
        ~kind,    ~fill,     ~border,   ~text,     ~fontface,
        "start",  "#F7FAFC", "#3A9E92", "#0C0D12", "bold",
        "decide", "#EFF6F5", "#3A9E92", "#134E4A", "bold",
        "cat",    "#FFFFFF", "#3A9E92", "#134E4A", "bold",
        "method", "#FFFFFF", "#C8D2DC", "#334155", "plain",
        "warn",   "#FEF2F2", "#BE123C", "#9F1239", "bold",
        "omics",  "#F6F4FA", "#7C6EAD", "#3D3556", "plain",
        "report", "#F3F5F7", "#4A5568", "#1E293B", "plain",
        "foot",   "#F8FAFC", "#94A3B8", "#64748B", "plain",
        "header", "#F8FAFC", "#CBD5E1", "#94A3B8", "plain",
        "stop",   "#FFF8F8", "#E85D75", "#9F1239", "bold"
      ),
      bg = "#FFFFFF",
      title = "#0C0D12",
      subtitle = "#64748B",
      caption = "#94A3B8",
      edge = "#CBD5E1",
      accent = "#BE123C",
      stripe = FALSE,
      text_size = 2.65,
      dpi = 320,
      lanes = fc_pearl_lanes
    )
  } else {
    list(
      styles = fc_styles,
      bg = "#F8FAFC",
      title = "#0F172A",
      subtitle = "#64748B",
      caption = "#94A3B8",
      edge = "#94A3B8",
      accent = "#F43F5E",
      stripe = FALSE,
      text_size = 2.55,
      dpi = 250
    )
  }
}

fc_node <- function(id, x, y, label, w, kind = "method", styles = fc_styles) {
  n <- stringr::str_count(label, "\n") + 1L
  h <- 5.5 + n * 3.1
  sty <- styles[styles$kind == kind, , drop = FALSE]
  dplyr::bind_cols(
    tibble::tibble(id = id, x = x, y = y, w = w, h = h, label = label, kind = kind),
    sty |> dplyr::select(-kind)
  )
}

fc_stack <- function(specs, x, y_top, gap = 2.4, styles = fc_styles) {
  y <- y_top
  out <- list()
  for (s in specs) {
    n <- stringr::str_count(s$label, "\n") + 1L
    h <- 5.5 + n * 3.1
    y <- y - h / 2
    out[[length(out) + 1L]] <- fc_node(s$id, x, y, s$label, s$w, s$kind, styles = styles)
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

fc_save <- function(nodes, edges, title, subtitle, caption, path, w_in, h_in,
                    accent_edges = NULL, theme = c("light", "dark", "handbook", "pearl"),
                    lane_ymin = NULL, lane_ymax = NULL) {
  th <- fc_theme(theme)
  nodes <- nodes |>
    dplyr::mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2,
      stripe_w = dplyr::case_when(
        kind %in% c("header", "foot") ~ 0,
        isTRUE(th$stripe) ~ 1.1,
        TRUE ~ 0
      )
    )

  y_lo <- min(nodes$ymin) - 3
  y_hi <- max(nodes$ymax) + 3
  if (!is.null(accent_edges) && nrow(accent_edges) > 0) {
    y_lo <- min(y_lo, accent_edges$ymid, accent_edges$yend, na.rm = TRUE) - 2
  }
  if (!is.null(lane_ymin)) {
    y_lo <- min(y_lo, lane_ymin - 2)
  }

  p <- ggplot2::ggplot() +
    ggplot2::theme_void(base_family = "sans") +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = th$bg, colour = NA),
      plot.margin = ggplot2::margin(18, 14, 14, 14),
      plot.title = ggplot2::element_text(
        face = "bold", size = 16, colour = th$title, hjust = 0.5, margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 9, colour = th$subtitle, hjust = 0.5, margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = 7.5, colour = th$caption, hjust = 0.5, margin = ggplot2::margin(t = 8)
      )
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption) +
    ggplot2::coord_cartesian(xlim = c(0, 100), ylim = c(y_lo, y_hi), clip = "off")

  if (!is.null(th$lanes) && !is.null(lane_ymin) && !is.null(lane_ymax)) {
    lanes <- th$lanes |>
      dplyr::mutate(
        xmin = x - w / 2, xmax = x + w / 2,
        ymin = lane_ymin, ymax = lane_ymax
      )
    p <- p +
      ggplot2::geom_rect(
        data = lanes,
        ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
        fill = lanes$fill, colour = lanes$border, linewidth = 0.35, alpha = 0.55
      )
  }

  if (nrow(edges) > 0) {
    if ("xmid" %in% names(edges)) {
      p <- p +
        ggplot2::geom_segment(
          data = edges, ggplot2::aes(x = x, y = y, xend = xmid, yend = ymid),
          colour = th$edge, linewidth = 0.45, lineend = "round"
        ) +
        ggplot2::geom_segment(
          data = edges, ggplot2::aes(x = xmid, y = ymid, xend = xend, yend = yend),
          colour = th$edge, linewidth = 0.45, lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.14, "cm"), type = "closed")
        )
    } else {
      p <- p +
        ggplot2::geom_segment(
          data = edges, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
          colour = th$edge, linewidth = 0.45, lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.14, "cm"), type = "closed")
        )
    }
  }

  if (!is.null(accent_edges) && nrow(accent_edges) > 0) {
    if ("xmid" %in% names(accent_edges)) {
      p <- p +
        ggplot2::geom_segment(
          data = accent_edges, ggplot2::aes(x = x, y = y, xend = xmid, yend = ymid),
          colour = th$accent, linewidth = 0.5, linetype = "22", lineend = "round"
        ) +
        ggplot2::geom_segment(
          data = accent_edges, ggplot2::aes(x = xmid, y = ymid, xend = xend, yend = yend),
          colour = th$accent, linewidth = 0.5, linetype = "22", lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
        )
    } else {
      p <- p +
        ggplot2::geom_segment(
          data = accent_edges, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
          colour = th$accent, linewidth = 0.5, linetype = "22", lineend = "round",
          arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
        )
    }
  }

  p <- p +
    ggplot2::geom_rect(
      data = nodes, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = nodes$fill, colour = nodes$border, linewidth = 0.5
    )

  if (isTRUE(th$stripe)) {
    stripes <- nodes |> dplyr::filter(stripe_w > 0)
    p <- p +
      ggplot2::geom_rect(
        data = stripes,
        ggplot2::aes(xmin = xmin, xmax = xmin + stripe_w, ymin = ymin, ymax = ymax),
        fill = stripes$border, colour = NA
      )
  }

  p <- p +
    ggplot2::geom_text(
      data = nodes, ggplot2::aes(x = x, y = y, label = label),
      size = th$text_size, lineheight = 0.88, colour = nodes$text,
      fontface = nodes$fontface, family = "sans"
    )

  ggplot2::ggsave(path, p, width = w_in, height = h_in, dpi = th$dpi, bg = th$bg)
}

# =============================================================================
# 1. Method decision tree (handbook navigation)
# =============================================================================
draw_method_decision_tree <- function(path) {
  th <- fc_theme("pearl")
  sty <- th$styles

  top <- fc_stack(
    list(
      list(id = "e1", label = "1. Write estimand\nCh 1", w = 34, kind = "start"),
      list(id = "e2", label = "2. Outcome type?\nCh 2 · Appendix B", w = 38, kind = "decide")
    ),
    x = 50, y_top = 97, gap = 3.2, styles = sty
  )
  branch_top <- min(top$y - top$h / 2) - 2
  col1 <- fc_stack(
    list(
      list(id = "c1", label = "Continuous\nFEV1 · scores · 6MWD", w = 26, kind = "cat"),
      list(id = "m1a", label = "2 independent groups\nWelch t · Mann-Whitney", w = 26, kind = "method"),
      list(id = "m1b", label = "Paired design\npaired t-test", w = 26, kind = "method"),
      list(id = "m1c", label = "Adjust covariates\nlinear · ANCOVA · Ch 5", w = 26, kind = "method")
    ),
    x = 18, y_top = branch_top, gap = 3, styles = sty
  )
  col2 <- fc_stack(
    list(
      list(id = "c2", label = "Binary\nexacerbation Y/N", w = 26, kind = "cat"),
      list(id = "m2a", label = "2 independent groups\nchi-square · Fisher", w = 26, kind = "method"),
      list(id = "m2b", label = "Paired binary\nMcNemar", w = 26, kind = "method"),
      list(id = "m2c", label = "Adjust covariates\nlogistic · Firth · Ch 6", w = 26, kind = "method")
    ),
    x = 50, y_top = branch_top, gap = 3, styles = sty
  )
  col3 <- fc_stack(
    list(
      list(id = "c3", label = "Count\nevents per follow-up", w = 26, kind = "cat"),
      list(id = "m3a", label = "Never t-test\non counts", w = 26, kind = "warn"),
      list(id = "m3b", label = "Poisson / mod. Poisson\noffset if needed · Ch 6", w = 26, kind = "method"),
      list(id = "m3c", label = "Overdispersion\nnegative binomial", w = 26, kind = "method")
    ),
    x = 82, y_top = branch_top, gap = 3, styles = sty
  )
  col_min <- min(c(col1$y - col1$h / 2, col2$y - col2$h / 2, col3$y - col3$h / 2))
  lane_ymin <- min(col1$y - col1$h / 2, col3$y - col3$h / 2) - 1.5
  lane_ymax <- max(top$y + top$h / 2, col1$y + col1$h / 2) + 1

  band_y <- col_min - 7
  pill_y <- col_min - 15
  band <- fc_node(
    "band", 50, band_y, "Handbook routes · after method choice",
    w = 84, kind = "header", styles = sty
  )
  omics <- fc_node(
    "omics", 22, pill_y,
    "Discovery & omics\nCh 10–17 · DE · FDR · batch",
    w = 26, kind = "omics", styles = sty
  )
  report <- fc_node(
    "report", 50, pill_y,
    "Report & limits · Ch 8\neffect · 95% CI · n\nCONSORT 2025 · TRIPOD+AI",
    w = 26, kind = "report", styles = sty
  )
  extra <- fc_node(
    "extra", 78, pill_y,
    "Advanced topics\nCh 18–22 · MI · causal · mediation",
    w = 26, kind = "foot", styles = sty
  )
  bottom <- dplyr::bind_rows(band, omics, report, extra)
  nodes <- dplyr::bind_rows(top, col1, col2, col3, bottom)

  merge_y <- col_min - 2.5
  ends <- nodes |> dplyr::filter(id %in% c("m1c", "m2c", "m3c"))
  bus_down <- ends |>
    dplyr::transmute(x, y = y - h / 2 - 0.4, xend = x, yend = merge_y)
  bus_h <- tibble::tibble(
    x = min(ends$x), y = merge_y, xend = max(ends$x), yend = merge_y
  )
  bus_up <- tibble::tibble(
    x = 50, y = merge_y, xend = 50, yend = band$y + band$h / 2 + 0.4
  )
  bus <- dplyr::bind_rows(bus_down, bus_h, bus_up)

  edges <- dplyr::bind_rows(
    fc_edges("e1", "e2", nodes),
    fc_branch_edges("e2", c("c1", "c2", "c3"), nodes, drop = 1.2),
    fc_edges(c("c1", "m1a", "m1b"), c("m1a", "m1b", "m1c"), nodes),
    fc_edges(c("c2", "m2a", "m2b"), c("m2a", "m2b", "m2c"), nodes),
    fc_edges(c("c3", "m3a", "m3b"), c("m3a", "m3b", "m3c"), nodes),
    bus
  )

  fc_save(
    nodes, edges,
    title = "Method decision tree",
    subtitle = "CASTOR: question first, method second · pick test or model by outcome type",
    caption = "Appendix B · METHOD_MAP · analysis_pipeline.png",
    path = path, w_in = 10, h_in = 7.8,
    theme = "pearl",
    lane_ymin = lane_ymin, lane_ymax = lane_ymax
  )
}

draw_method_decision_tree(file.path(fig_dir, "method_decision_tree_r.png"))

# Published assets (FROZEN — do not overwrite from R):
#   analysis_pipeline.png      ← select-illustrated-luxe-ch22-preview-4096
#   method_decision_tree.png   ← select-tree-luxe-routes-modern-4096
# See volume-01/figures/PUBLISHED_NAVIGATION_FIGURES.md

# =============================================================================
# 1b. CASTOR analysis pipeline (process before method choice)
# =============================================================================
draw_analysis_pipeline <- function(path, theme = "handbook") {
  th <- fc_theme(theme)
  sty <- th$styles

  spine <- fc_stack(
    list(
      list(id = "s1", label = "1  Clinical question\nWhat would change practice?\nCh 1; PICO", w = 30, kind = "start"),
      list(id = "s2", label = "2  Estimand + population\nWho; contrast; when\nCh 1–2", w = 30, kind = "start"),
      list(id = "s3", label = "3  Describe the sample\nTable 1; plots; missingness\nCh 3", w = 30, kind = "decide"),
      list(id = "s4", label = "4  Choose method\nOutcome type + design\nAppendix B; METHOD_MAP", w = 30, kind = "cat"),
      list(id = "s5", label = "5  Fit model / test in R\nPrespecified script\nAppendix A", w = 30, kind = "method"),
      list(id = "s6", label = "6  Diagnostics + sensitivity\nAssumptions; MI; alternatives\nCh 7; 20", w = 30, kind = "omics"),
      list(id = "s7", label = "7  Report estimate + 95% CI\nn; limitations; guidelines\nCh 8", w = 30, kind = "report"),
      list(id = "s8", label = "8  State what was NOT proven\nStop: do not over-claim", w = 30, kind = "stop")
    ),
    x = 26, y_top = 95, gap = 1.85, styles = sty
  )

  route_top <- spine$y[spine$id == "s4"] + 12
  route_hdr <- fc_node("rhdr", 68, route_top + 5.5, "Handbook routes\n(from step 4)", 36, "header", styles = sty)

  col1 <- fc_stack(
    list(
      list(id = "b1", label = "Describe & compare\nCh 3–4", w = 17, kind = "decide"),
      list(id = "b2", label = "Regression; GLM\nCh 5–7", w = 17, kind = "method"),
      list(id = "b3", label = "Report & predict\nCh 8–9", w = 17, kind = "cat"),
      list(id = "b4", label = "Discovery & cases\nCh 10–12", w = 17, kind = "omics")
    ),
    x = 54, y_top = route_top, gap = 1.25, styles = sty
  )

  col2 <- fc_stack(
    list(
      list(id = "b5", label = "Omics; screens\nCh 13–17", w = 17, kind = "omics"),
      list(id = "b6", label = "Longitudinal; survival\nCh 18–19", w = 17, kind = "method"),
      list(id = "b7", label = "Missing; causal; mediation\nCh 20–22", w = 17, kind = "report"),
      list(id = "b8", label = "Routers & paths\nApp B; I; J; K", w = 17, kind = "foot")
    ),
    x = 82, y_top = route_top, gap = 1.25, styles = sty
  )

  loop_y <- min(spine$y - spine$h / 2) - 4.5
  loop <- fc_node("loop", 26, loop_y, "Estimand ≠ design?\nReturn to steps 1–2", 30, "warn", styles = sty)
  nodes <- dplyr::bind_rows(spine, route_hdr, col1, col2, loop)

  s4 <- nodes |> dplyr::filter(id == "s4")
  accent <- tibble::tibble(
    x = s4$x - s4$w / 2,
    y = s4$y,
    xmid = 10,
    ymid = loop$y + loop$h / 2 + 0.8,
    xend = loop$x - loop$w / 2,
    yend = loop$y + loop$h / 2 + 0.4
  )

  edges <- dplyr::bind_rows(
    fc_edges(paste0("s", 1:7), paste0("s", 2:8), nodes),
    fc_branch_edges("s4", c(col1$id, col2$id), nodes, drop = 2.2)
  )

  fc_save(
    nodes, edges,
    title = "Analysis pipeline",
    subtitle = "Question first ;  method second ;  report what you did not prove",
    caption = "Ch 1–22 + appendices ;  regenerate: source(\"R/examples/generate_figures.R\")",
    path = path, w_in = 7.8, h_in = 10.8,
    accent_edges = accent,
    theme = theme
  )
}

draw_analysis_pipeline_modern <- function(path) {
  steps <- tibble::tribble(
    ~id, ~n, ~title, ~detail, ~fill, ~border, ~text,
    "s1", 1L, "Clinical question", "What would change practice?\nCh 1; PICO",
      "#FFFBEB", "#F59E0B", "#78350F",
    "s2", 2L, "Estimand + population", "Who; contrast; when\nCh 1–2",
      "#FFF7ED", "#F97316", "#7C2D12",
    "s3", 3L, "Describe the sample", "Table 1; plots; missingness\nCh 3",
      "#EFF6FF", "#3B82F6", "#1E3A8A",
    "s4", 4L, "Choose method", "Outcome type + design\nAppendix B",
      "#ECFDF5", "#10B981", "#065F46",
    "s5", 5L, "Fit model / test in R", "Prespecified script\nAppendix A",
      "#F0FDFA", "#14B8A6", "#134E4A",
    "s6", 6L, "Diagnostics + sensitivity", "Assumptions; MI; alternatives\nCh 7; 20",
      "#F5F3FF", "#8B5CF6", "#4C1D95",
    "s7", 7L, "Report estimate + 95% CI", "n; limitations; guidelines\nCh 8",
      "#F8FAFC", "#64748B", "#334155",
    "s8", 8L, "State what was NOT proven", "Stop: do not over-claim",
      "#FEF2F2", "#EF4444", "#991B1B"
  )

  routes <- tibble::tribble(
    ~id, ~label, ~fill, ~border, ~text,
    "r1", "Describe & compare\nCh 3–4", "#EFF6FF", "#3B82F6", "#1E3A8A",
    "r2", "Regression & prediction\nCh 5–9", "#ECFDF5", "#10B981", "#065F46",
    "r3", "Discovery & omics\nCh 10–17", "#F5F3FF", "#8B5CF6", "#4C1D95",
    "r4", "Longitudinal & survival\nCh 18–19", "#F0FDFA", "#14B8A6", "#134E4A",
    "r5", "Missing; causal; mediation\nCh 20–22; App B I J K", "#F8FAFC", "#64748B", "#334155"
  )

  w_spine <- 46
  w_route <- 28
  x_spine <- 36
  x_route <- 78
  gap <- 2.6
  y <- 88

  spine <- purrr::map_dfr(seq_len(nrow(steps)), function(i) {
    s <- steps[i, ]
    n_lines <- stringr::str_count(s$detail, "\n") + 1L
    h <- 7.5 + n_lines * 2.8
    y <<- y - h / 2
    out <- tibble::tibble(
      id = s$id, n = s$n, title = s$title, detail = s$detail,
      x = x_spine, y = y, w = w_spine, h = h,
      fill = s$fill, border = s$border, text = s$text
    )
    y <<- y - h / 2 - gap
    out
  })

  route_y <- spine$y[spine$id == "s4"] + 6
  routes_xy <- purrr::map_dfr(seq_len(nrow(routes)), function(i) {
    r <- routes[i, ]
    h <- 9.5
    route_y <<- route_y - h / 2
    out <- tibble::tibble(
      id = r$id, label = r$label, x = x_route, y = route_y, w = w_route, h = h,
      fill = r$fill, border = r$border, text = r$text
    )
    route_y <<- route_y - h / 2 - 1.8
    out
  })

  loop_h <- 10
  loop_y <- min(spine$y - spine$h / 2) - loop_h / 2 - 3
  loop <- tibble::tibble(
    id = "loop", label = "Estimand ≠ design?\nReturn to steps 1–2",
    x = x_spine, y = loop_y, w = w_spine, h = loop_h,
    fill = "#FEF2F2", border = "#EF4444", text = "#991B1B"
  )

  nodes <- spine |>
    dplyr::mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2,
      label = paste0(title, "\n", detail),
      shadow = "#E2E8F080"
    )
  routes_xy <- routes_xy |>
    dplyr::mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2,
      shadow = "#E2E8F060"
    )
  loop <- loop |>
    dplyr::mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2,
      shadow = "#E2E8F060"
    )

  spine_edges <- purrr::map2_dfr(steps$id[-nrow(steps)], steps$id[-1], function(a, b) {
    na <- nodes |> dplyr::filter(id == a)
    nb <- nodes |> dplyr::filter(id == b)
    tibble::tibble(x = na$x, y = na$ymin - 0.2, xend = nb$x, yend = nb$ymax + 0.2)
  })

  s4 <- nodes |> dplyr::filter(id == "s4")
  route_edges <- purrr::map_dfr(routes_xy$id, function(rid) {
    nr <- routes_xy |> dplyr::filter(id == rid)
    tibble::tibble(
      x = s4$x + s4$w / 2 + 0.3, y = s4$y,
      xmid = (s4$x + s4$w / 2 + nr$x - nr$w / 2) / 2,
      ymid = nr$y, xend = nr$xmin - 0.3, yend = nr$y
    )
  })

  accent <- tibble::tibble(
    x = s4$xmin, y = s4$y,
    xmid = 8, ymid = loop$y + 1,
    xend = loop$xmin, yend = loop$y + loop$h / 4
  )

  badge <- nodes |>
    dplyr::transmute(x = xmin + 3.8, y = y, n = n, border = border)

  y_lo <- min(loop$ymin, routes_xy$ymin) - 4
  y_hi <- max(nodes$ymax) + 6

  p <- ggplot2::ggplot() +
    ggplot2::theme_void(base_family = "sans") +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#FFFFFF", colour = NA),
      plot.margin = ggplot2::margin(20, 16, 14, 16),
      plot.title = ggplot2::element_text(
        face = "bold", size = 18, colour = "#0C0D12", hjust = 0.5, margin = ggplot2::margin(b = 3)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 10, colour = "#64748B", hjust = 0.5, margin = ggplot2::margin(b = 12)
      ),
      plot.caption = ggplot2::element_text(size = 8, colour = "#94A3B8", hjust = 0.5, margin = ggplot2::margin(t = 10))
    ) +
    ggplot2::labs(
      title = "CASTOR analysis pipeline",
      subtitle = "Question first · method second · report what you did not prove",
      caption = "Ch 1–22 + appendices · regenerate: source(\"R/examples/generate_figures.R\")"
    ) +
    ggplot2::coord_cartesian(xlim = c(0, 100), ylim = c(y_lo, y_hi), clip = "off") +
    ggplot2::geom_rect(
      data = nodes,
      ggplot2::aes(xmin = xmin + 0.45, xmax = xmax + 0.45, ymin = ymin - 0.45, ymax = ymax - 0.45),
      fill = "#CBD5E133", colour = NA
    ) +
    ggplot2::geom_rect(
      data = routes_xy,
      ggplot2::aes(xmin = xmin + 0.35, xmax = xmax + 0.35, ymin = ymin - 0.35, ymax = ymax - 0.35),
      fill = "#CBD5E122", colour = NA
    ) +
    ggplot2::geom_rect(
      data = nodes, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = nodes$fill, colour = nodes$border, linewidth = 0.9
    ) +
    ggplot2::geom_rect(
      data = routes_xy, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = routes_xy$fill, colour = routes_xy$border, linewidth = 0.65
    ) +
    ggplot2::geom_rect(
      data = loop, ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = loop$fill, colour = loop$border, linewidth = 0.7, linetype = "22"
    ) +
    ggplot2::geom_segment(
      data = spine_edges, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
      colour = "#94A3B8", linewidth = 0.55,
      arrow = grid::arrow(length = grid::unit(0.16, "cm"), type = "closed")
    ) +
    ggplot2::geom_segment(
      data = route_edges, ggplot2::aes(x = x, y = y, xend = xmid, yend = ymid),
      colour = "#CBD5E1", linewidth = 0.45
    ) +
    ggplot2::geom_segment(
      data = route_edges, ggplot2::aes(x = xmid, y = ymid, xend = xend, yend = yend),
      colour = "#CBD5E1", linewidth = 0.45,
      arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
    ) +
    ggplot2::geom_segment(
      data = accent, ggplot2::aes(x = x, y = y, xend = xmid, yend = ymid),
      colour = "#EF4444", linewidth = 0.55, linetype = "22"
    ) +
    ggplot2::geom_segment(
      data = accent, ggplot2::aes(x = xmid, y = ymid, xend = xend, yend = yend),
      colour = "#EF4444", linewidth = 0.55, linetype = "22",
      arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
    ) +
    ggplot2::geom_point(
      data = badge, ggplot2::aes(x = x, y = y),
      shape = 21, size = 4.2, fill = "#FFFFFF", colour = badge$border, stroke = 1.1
    ) +
    ggplot2::geom_text(
      data = badge, ggplot2::aes(x = x, y = y, label = n),
      size = 3.1, fontface = "bold", colour = "#0C0D12"
    ) +
    ggplot2::geom_text(
      data = nodes, ggplot2::aes(x = x + 2.5, y = y, label = label),
      size = 2.85, lineheight = 0.9, colour = nodes$text, hjust = 0.5
    ) +
    ggplot2::geom_text(
      data = routes_xy, ggplot2::aes(x = x, y = y, label = label),
      size = 2.55, lineheight = 0.88, colour = routes_xy$text, fontface = "bold"
    ) +
    ggplot2::geom_text(
      data = loop, ggplot2::aes(x = x, y = y, label = label),
      size = 2.6, lineheight = 0.88, colour = loop$text, fontface = "bold"
    ) +
    ggplot2::annotate(
      "text", x = x_route, y = max(routes_xy$ymax) + 3.2,
      label = "Handbook routes", size = 3.4, fontface = "bold", colour = "#0C0D12"
    )

  ggplot2::ggsave(path, p, width = 8.2, height = 11.2, dpi = 320, bg = "#FFFFFF")
}

draw_analysis_pipeline(file.path(fig_dir, "analysis_pipeline_r.png"))
draw_analysis_pipeline_modern(file.path(fig_dir, "analysis_pipeline_r_modern.png"))
draw_analysis_pipeline_modern(file.path(paths$root, "archive", "figures", "fallbacks", "analysis_pipeline_r_modern.png"))

# Published asset: volume-01/figures/analysis_pipeline.png (FROZEN — see PUBLISHED_NAVIGATION_FIGURES.md)

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
  geom_tile(colour = "white", linewidth = 0.9) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.1, colour = "#334155") +
  scale_fill_manual(values = c("#E0F2FE", "#BAE6FD", "#7DD3FC"), guide = "none") +
  labs(title = "Continuous outcomes") +
  handbook_theme(10) +
  theme(axis.text = element_blank(), axis.title = element_blank(), panel.grid = element_blank())

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
  geom_tile(colour = "white", linewidth = 0.9) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.1, colour = "#334155") +
  scale_fill_manual(values = c("#D1FAE5", "#A7F3D0", "#6EE7B7"), guide = "none") +
  labs(title = "Binary / categorical outcomes") +
  handbook_theme(10) +
  theme(axis.text = element_blank(), axis.title = element_blank(), panel.grid = element_blank())

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
  geom_tile(colour = "white", linewidth = 0.9) +
  geom_text(aes(label = paste0(use_when, "\n", outcome)), size = 3.1, colour = "#334155") +
  scale_fill_manual(values = c("#FFE4E6", "#D1FAE5", "#A7F3D0"), guide = "none") +
  labs(title = "Count outcomes") +
  handbook_theme(10) +
  theme(axis.text = element_blank(), axis.title = element_blank(), panel.grid = element_blank())

p_panel <- p_cont / p_bin / p_count +
  plot_annotation(
    title = "Method comparison panel",
    subtitle = "Full tables: volume-01/appendix-b-quick-reference.md"
  )

ggsave(file.path(fig_dir, "method_comparison_panel.png"), p_panel, width = 9, height = 8, dpi = 180)

# =============================================================================
# 3. Chapter 4 figures
# =============================================================================
p_ch04_box <- plot_raincloud(
  spirometry, "group", "fev1", fill = "group",
  title = "Raincloud: FEV1 by trial arm (CASTOR)",
  subtitle = "Violin + box + jitter + mean diamond; Welch t-test estimand (Ch 4)",
  xlab = NULL, ylab = "FEV1 (L)"
)

handbook_save(p_ch04_box, file.path(fig_dir, "ch04_fev1_by_group.png"), 6.8, 4.8)

p_ch04_paired <- plot_dumbbell(
  bronchodilator, "patient_id", "fev1_pre", "fev1_post",
  title = "Dumbbell plot: bronchodilator response",
  subtitle = "Each grey segment is one patient; black diamonds = arm means",
  xlab = "FEV1 (L)", ylab = NULL
)

handbook_save(p_ch04_paired, file.path(fig_dir, "ch04_paired_bronchodilator.png"), 7, 4.2)

exac_flow <- exacerbation %>%
  mutate(
    smoking_lab = if_else(smoking, "Smoker", "Non-smoker"),
    event_lab = if_else(exacerbation_12m, "Exacerbation", "No event")
  )

p_ch04_bar <- plot_alluvial_flow(
  exac_flow, "smoking_lab", "event_lab",
  title = "Alluvial flow: smoking to 12-month exacerbation",
  subtitle = "Width = participant count; use with denominator in text (Ch 4, 6)"
)

handbook_save(p_ch04_bar, file.path(fig_dir, "ch04_exacerbation_by_smoking.png"), 6.8, 4.8)

# =============================================================================
# 4. Chapter 5 figures
# =============================================================================
fit_lm <- lm(fev1 ~ smoking + age + sex + height_cm, data = spirometry)

p_resid_panel <- plot_residual_panel(
  fit_lm,
  title_resid = "Residuals vs fitted (hexbin)",
  title_qq = "Normal Q-Q of residuals"
)

handbook_save(
  p_resid_panel,
  file.path(fig_dir, "ch05_residual_diagnostics.png"),
  9.2, 4.2
)

if (requireNamespace("emmeans", quietly = TRUE)) {
  em <- emmeans::emmeans(fit_lm, ~ smoking)
  em_df <- as.data.frame(em)
  p_adj <- plot_emmeans_dot(
    em_df, x = "smoking", estimate = "emmean", lower = "lower.CL", upper = "upper.CL",
    title = "Adjusted mean FEV1 by smoking (emmeans)",
    subtitle = "Dot-and-whisker from linear model: age, sex, height (Ch 5)",
    xlab = "Smoking", ylab = "Estimated mean FEV1 (L)"
  )
  handbook_save(p_adj, file.path(fig_dir, "ch05_fev1_by_smoking_adjusted.png"), 5.8, 4.6)
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

p_forest <- plot_forest_ratio(
  forest_df,
  title = "Adjusted odds ratios: 12-month exacerbation",
  subtitle = "Logistic regression (Ch 6); exponentiated coefficients",
  xlab = "Odds ratio (95% CI, log scale)"
)

handbook_save(p_forest, file.path(fig_dir, "ch06_logistic_forest.png"), 7.2, 4.6)

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

p_rr <- plot_forest_ratio(
  rr_df,
  title = "Rate ratios: exacerbation counts",
  subtitle = "Poisson GLM with offset (Ch 6)",
  xlab = "Rate ratio (95% CI, log scale)",
  point_color = handbook_cols$nonsmoker
)

handbook_save(p_rr, file.path(fig_dir, "ch06_poisson_rate_ratio.png"), 7.2, 3.8)

# =============================================================================
# 6. Chapter 10 PCA figures
# =============================================================================
X <- omics %>% dplyr::select(dplyr::starts_with("M"))
pca <- prcomp(X, scale. = TRUE)

p_scree <- plot_scree(
  pca,
  title = "PCA scree plot: CASTOR marker panel",
  subtitle = "Bars = variance per PC; line = cumulative (teaching only)"
)
handbook_save(p_scree, file.path(fig_dir, "ch10_scree.png"), 6.8, 4.6)

pca_scores <- tibble(
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  phenotype = omics$true_phenotype
)
p_biplot <- plot_pca_scores(
  pca_scores,
  title = "PCA: PC1 vs PC2 (true phenotype)",
  subtitle = "Ellipses = 68% normal contours; labels are for teaching only",
  xlab = sprintf("PC1 (%.0f%%)", 100 * summary(pca)$importance[2, 1]),
  ylab = sprintf("PC2 (%.0f%%)", 100 * summary(pca)$importance[2, 2])
)
handbook_save(p_biplot, file.path(fig_dir, "ch10_pca_biplot.png"), 7.2, 5.2)

message("Handbook figures saved to ", fig_dir)
message("See volume-01/FIGURE_INDEX.md for the full list.")

source(file.path(paths$r, "examples", "generate_viz_pairs.R"))
source(file.path(paths$r, "examples", "generate_appendix_a_figures.R"))
