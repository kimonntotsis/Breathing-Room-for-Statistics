# Method decision tree design options (local previews — not published asset)
source("R/00_setup.R")
library(tidyverse)

fig_dir <- file.path(paths$root, "volume-01", "figures")
opts_dir <- file.path(paths$root, "archive", "figures", "pipeline-options")
dir.create(opts_dir, showWarnings = FALSE, recursive = TRUE)

# --- Flowchart helpers (subset of generate_figures.R) -----------------------------
fc_node <- function(id, x, y, label, w, kind, styles) {
  n <- stringr::str_count(label, "\n") + 1L
  h <- 5.5 + n * 3.1
  sty <- styles[styles$kind == kind, , drop = FALSE]
  bind_cols(
    tibble(id = id, x = x, y = y, w = w, h = h, label = label, kind = kind),
    sty |> select(-kind)
  )
}

fc_stack <- function(specs, x, y_top, gap = 2.4, styles) {
  y <- y_top
  out <- list()
  for (s in specs) {
    n <- stringr::str_count(s$label, "\n") + 1L
    h <- 5.5 + n * 3.1
    y <- y - h / 2
    out[[length(out) + 1L]] <- fc_node(s$id, x, y, s$label, s$w, s$kind, styles)
    y <- y - h / 2 - gap
  }
  bind_rows(out)
}

fc_edges <- function(from, to, nodes) {
  from <- as.character(from)
  to <- as.character(to)
  map2_dfr(from, to, function(a, b) {
    na <- nodes |> filter(id == a)
    nb <- nodes |> filter(id == b)
    if (nrow(na) == 0L || nrow(nb) == 0L) {
      return(tibble(x = NA_real_, y = NA_real_, xend = NA_real_, yend = NA_real_))
    }
    tibble(
      x = na$x[[1]], y = na$y[[1]] - na$h[[1]] / 2 - 0.4,
      xend = nb$x[[1]], yend = nb$y[[1]] + nb$h[[1]] / 2 + 0.4
    )
  }) |> filter(!is.na(x))
}

fc_branch_edges <- function(from_id, to_ids, nodes, drop = 0.6) {
  na <- nodes |> filter(id == from_id)
  branch_y <- na$y[[1]] - na$h[[1]] / 2 - drop
  map_dfr(to_ids, function(b) {
    nb <- nodes |> filter(id == b)
    if (nrow(nb) == 0L) {
      return(tibble(x = NA_real_, y = NA_real_, xend = NA_real_, yend = NA_real_, xmid = NA_real_, ymid = NA_real_))
    }
    tibble(
      x = na$x[[1]], y = branch_y, xend = nb$x[[1]], yend = nb$y[[1]] + nb$h[[1]] / 2 + 0.4,
      xmid = nb$x[[1]], ymid = branch_y
    )
  }) |> filter(!is.na(x))
}

tree_palettes <- list(
  handbook = list(
    name = "Handbook (current R)",
    bg = "#FFFFFF", title = "#0C0D12", subtitle = "#64748B", caption = "#94A3B8",
    edge = "#C8D2DC", accent = "#E85D75", stripe = TRUE, text_size = 2.75, dpi = 320,
    styles = tribble(
      ~kind,    ~fill,     ~border,   ~text,     ~fontface,
      "start",  "#FFFFFF", "#3A9E92", "#0C0D12", "bold",
      "decide", "#FFFFFF", "#5EC4B8", "#1E293B", "bold",
      "cat",    "#FAFBFC", "#9AA8B5", "#334155", "bold",
      "method", "#FFFFFF", "#C8D2DC", "#334155", "plain",
      "warn",   "#FFFBFC", "#E879A8", "#9F1239", "bold",
      "omics",  "#FDFCFF", "#8B7EC8", "#4C3D6E", "plain",
      "report", "#F8FAFC", "#64748B", "#334155", "plain",
      "foot",   "#FFFFFF", "#DDE4EA", "#64748B", "plain"
    ),
    lanes = NULL
  ),
  pearl = list(
    name = "Pearl lane map",
    bg = "#FFFFFF", title = "#0C0D12", subtitle = "#64748B", caption = "#94A3B8",
    edge = "#CBD5E1", accent = "#BE123C", stripe = FALSE, text_size = 2.65, dpi = 320,
    styles = tribble(
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
      "optional", "#FFFFFF", "#C8D2DC", "#64748B", "plain"
    ),
    lanes = tribble(
      ~x, ~w, ~fill, ~border,
      18, 28, "#F0FAF9", "#5EC4B8",
      50, 28, "#EEF2FF", "#818CF8",
      82, 28, "#FFF1F2", "#FDA4AF"
    )
  ),
  slate = list(
    name = "Slate editorial",
    bg = "#FFFFFF", title = "#0F172A", subtitle = "#64748B", caption = "#94A3B8",
    edge = "#CBD5E1", accent = "#DC2626", stripe = FALSE, text_size = 2.65, dpi = 320,
    styles = tribble(
      ~kind,    ~fill,     ~border,   ~text,     ~fontface,
      "start",  "#F8FAFC", "#0F172A", "#0F172A", "bold",
      "decide", "#EEF2FF", "#4338CA", "#312E81", "bold",
      "cat",    "#FFFFFF", "#4338CA", "#312E81", "bold",
      "method", "#FFFFFF", "#CBD5E1", "#334155", "plain",
      "warn",   "#FEF2F2", "#DC2626", "#991B1B", "bold",
      "omics",  "#FAF5FF", "#7C3AED", "#4C1D95", "plain",
      "report", "#F8FAFC", "#475569", "#1E293B", "plain",
      "foot",   "#F1F5F9", "#94A3B8", "#64748B", "plain"
    ),
    lanes = tribble(
      ~x, ~w, ~fill, ~border,
      18, 28, "#ECFEFF", "#0891B2",
      50, 28, "#EEF2FF", "#4338CA",
      82, 28, "#FEF2F2", "#F87171"
    )
  ),
  copper = list(
    name = "Copper luxe",
    bg = "#FEFDFB", title = "#1C1917", subtitle = "#78716C", caption = "#A8A29E",
    edge = "#D6D3D1", accent = "#BE123C", stripe = FALSE, text_size = 2.65, dpi = 320,
    styles = tribble(
      ~kind,    ~fill,     ~border,   ~text,     ~fontface,
      "start",  "#FFFBEB", "#B45309", "#78350F", "bold",
      "decide", "#ECFDF5", "#047857", "#064E3B", "bold",
      "cat",    "#FFFFFF", "#B45309", "#78350F", "bold",
      "method", "#FFFFFF", "#D6D3D1", "#44403C", "plain",
      "warn",   "#FEF2F2", "#BE123C", "#881337", "bold",
      "omics",  "#FAF5FF", "#7E22CE", "#581C87", "plain",
      "report", "#F5F5F4", "#44403C", "#292524", "plain",
      "foot",   "#FAFAF9", "#A8A29E", "#78716C", "plain"
    ),
    lanes = tribble(
      ~x, ~w, ~fill, ~border,
      18, 28, "#ECFDF5", "#047857",
      50, 28, "#FFFBEB", "#B45309",
      82, 28, "#FEF2F2", "#BE123C"
    )
  ),
  dark = list(
    name = "Dark pearl",
    bg = "#0C0D12", title = "#E8EDF2", subtitle = "#9AA8B5", caption = "#6E7D8A",
    edge = "#4A5A6A", accent = "#E879A8", stripe = FALSE, text_size = 2.65, dpi = 320,
    styles = tribble(
      ~kind,    ~fill,     ~border,   ~text,     ~fontface,
      "start",  "#141820", "#3A9E92", "#E8EDF2", "bold",
      "decide", "#151B24", "#5EC4B8", "#C8D2DC", "bold",
      "cat",    "#12161D", "#6E7D8A", "#B8C4CE", "bold",
      "method", "#10141A", "#4A5A6A", "#DDE4EA", "plain",
      "warn",   "#1A1218", "#E879A8", "#F5C2D9", "bold",
      "omics",  "#14101E", "#8B7EC8", "#D4CFF0", "plain",
      "report", "#131820", "#64748B", "#B8C4CE", "plain",
      "foot",   "#0F1318", "#3A4555", "#9AA8B5", "plain"
    ),
    lanes = tribble(
      ~x, ~w, ~fill, ~border,
      18, 28, "#101820", "#3A9E92",
      50, 28, "#12101E", "#8B7EC8",
      82, 28, "#181018", "#E879A8"
    )
  )
)

tree_nodes_edges <- function(styles, footer = c("stack", "converge", "routes")) {
  footer <- match.arg(footer)
  top <- fc_stack(
    list(
      list(id = "e1", label = "1. Write estimand\nCh 1", w = 34, kind = "start"),
      list(id = "e2", label = "2. Outcome type?\nCh 2 · Appendix B", w = 38, kind = "decide")
    ),
    x = 50, y_top = 97, gap = 3.2, styles = styles
  )
  branch_top <- min(top$y - top$h / 2) - 2
  col1 <- fc_stack(
    list(
      list(id = "c1", label = "Continuous\nFEV₁ · scores · 6MWD", w = 26, kind = "cat"),
      list(id = "m1a", label = "2 independent groups\nWelch t · Mann-Whitney", w = 26, kind = "method"),
      list(id = "m1b", label = "Paired design\npaired t-test", w = 26, kind = "method"),
      list(id = "m1c", label = "Adjust covariates\nlinear · ANCOVA · Ch 5", w = 26, kind = "method")
    ),
    x = 18, y_top = branch_top, gap = 3, styles = styles
  )
  col2 <- fc_stack(
    list(
      list(id = "c2", label = "Binary\nexacerbation Y/N", w = 26, kind = "cat"),
      list(id = "m2a", label = "2 independent groups\nχ² · Fisher", w = 26, kind = "method"),
      list(id = "m2b", label = "Paired binary\nMcNemar", w = 26, kind = "method"),
      list(id = "m2c", label = "Adjust covariates\nlogistic · Firth · Ch 6", w = 26, kind = "method")
    ),
    x = 50, y_top = branch_top, gap = 3, styles = styles
  )
  col3 <- fc_stack(
    list(
      list(id = "c3", label = "Count\nevents per follow-up", w = 26, kind = "cat"),
      list(id = "m3a", label = "Never t-test\non counts", w = 26, kind = "warn"),
      list(id = "m3b", label = "Poisson GLM\noffset if needed", w = 26, kind = "method"),
      list(id = "m3c", label = "Overdispersion\nnegative binomial", w = 26, kind = "method")
    ),
    x = 82, y_top = branch_top, gap = 3, styles = styles
  )
  col_min <- min(c(col1$y - col1$h / 2, col2$y - col2$h / 2, col3$y - col3$h / 2))
  lane_ymin <- min(col1$y - col1$h / 2, col3$y - col3$h / 2) - 1.5
  lane_ymax <- max(top$y + top$h / 2, col1$y + col1$h / 2) + 1

  if (footer == "stack") {
    bottom <- fc_stack(
      list(
        list(id = "omics", label = "Many features / omics · Ch 10–17\nDE+FDR · batch · flow · screen · pipeline", w = 78, kind = "omics"),
        list(id = "report", label = "Report effect · 95% CI · n · limitations\nCONSORT · STROBE · TRIPOD · Ch 8", w = 72, kind = "report"),
        list(id = "extra", label = "Ch 18–21 · longitudinal · survival · missing data · causal", w = 68, kind = "foot")
      ),
      x = 50, y_top = col_min - 2, gap = 2.6, styles = styles
    )
    nodes <- bind_rows(top, col1, col2, col3, bottom)
    edges <- bind_rows(
      fc_edges("e1", "e2", nodes),
      fc_branch_edges("e2", c("c1", "c2", "c3"), nodes, drop = 1.2),
      fc_edges(c("c1", "m1a", "m1b", "m1c"), c("m1a", "m1b", "m1c", "omics"), nodes),
      fc_edges(c("c2", "m2a", "m2b", "m2c"), c("m2a", "m2b", "m2c", "omics"), nodes),
      fc_edges(c("c3", "m3a", "m3b", "m3c"), c("m3a", "m3b", "m3c", "omics"), nodes),
      fc_edges(c("omics", "report"), c("report", "extra"), nodes)
    )
  } else if (footer == "converge") {
    report_y <- col_min - 7
    tag_y <- report_y - 8.5
    opt_y <- tag_y - 7.5
    report <- fc_node(
      "report", 50, report_y,
      "3. Report effect · 95% CI · n · limitations\nCONSORT · STROBE · TRIPOD · Ch 8",
      w = 76, kind = "report", styles = styles
    )
    tag <- fc_node("tag", 50, tag_y, "Parallel routes (not every analysis)", w = 42, kind = "header", styles = styles)
    omics <- fc_node(
      "omics", 28, opt_y,
      "High-dimensional · Ch 10–17\nDE · FDR · batch · flow",
      w = 34, kind = "optional", styles = styles
    )
    extra <- fc_node(
      "extra", 72, opt_y,
      "Advanced · Ch 18–21\nlongitudinal · survival · missing · causal",
      w = 34, kind = "optional", styles = styles
    )
    bottom <- bind_rows(report, tag, omics, extra)
    nodes <- bind_rows(top, col1, col2, col3, bottom)
    merge_y <- col_min - 3.5
    ends <- nodes |> filter(id %in% c("m1c", "m2c", "m3c"))
    bus_down <- ends |>
      transmute(x, y = y - h / 2 - 0.4, xend = x, yend = merge_y)
    bus_h <- tibble(
      x = min(ends$x), y = merge_y, xend = max(ends$x), yend = merge_y
    )
    bus_up <- tibble(
      x = 50, y = merge_y, xend = 50, yend = report$y + report$h / 2 + 0.4
    )
    bus <- bind_rows(bus_down, bus_h, bus_up)
    edges <- bind_rows(
      fc_edges("e1", "e2", nodes),
      fc_branch_edges("e2", c("c1", "c2", "c3"), nodes, drop = 1.2),
      fc_edges(c("c1", "m1a", "m1b"), c("m1a", "m1b", "m1c"), nodes),
      fc_edges(c("c2", "m2a", "m2b"), c("m2a", "m2b", "m2c"), nodes),
      fc_edges(c("c3", "m3a", "m3b"), c("m3a", "m3b", "m3c"), nodes),
      bus
    )
  } else {
    # footer == "routes": three equal pills in one row (pipeline handbook-routes style)
    band_y <- col_min - 5
    pill_y <- col_min - 10
    band <- fc_node("band", 50, band_y, "Handbook routes · after method choice", w = 84, kind = "header", styles = styles)
    omics <- fc_node(
      "omics", 22, pill_y,
      "Discovery & omics\nCh 10–17 · DE · FDR · batch",
      w = 26, kind = "omics", styles = styles
    )
    report <- fc_node(
      "report", 50, pill_y,
      "Report & limits\nCh 8 · CI · n · CONSORT",
      w = 26, kind = "report", styles = styles
    )
    extra <- fc_node(
      "extra", 78, pill_y,
      "Advanced topics\nCh 18–21 · MI · causal",
      w = 26, kind = "foot", styles = styles
    )
    bottom <- bind_rows(band, omics, report, extra)
    nodes <- bind_rows(top, col1, col2, col3, bottom)
    merge_y <- col_min - 2.5
    ends <- nodes |> filter(id %in% c("m1c", "m2c", "m3c"))
    bus_down <- ends |>
      transmute(x, y = y - h / 2 - 0.4, xend = x, yend = merge_y)
    bus_h <- tibble(
      x = min(ends$x), y = merge_y, xend = max(ends$x), yend = merge_y
    )
    bus_up <- tibble(
      x = 50, y = merge_y, xend = 50, yend = band$y + band$h / 2 + 0.4
    )
    bus <- bind_rows(bus_down, bus_h, bus_up)
    edges <- bind_rows(
      fc_edges("e1", "e2", nodes),
      fc_branch_edges("e2", c("c1", "c2", "c3"), nodes, drop = 1.2),
      fc_edges(c("c1", "m1a", "m1b"), c("m1a", "m1b", "m1c"), nodes),
      fc_edges(c("c2", "m2a", "m2b"), c("m2a", "m2b", "m2c"), nodes),
      fc_edges(c("c3", "m3a", "m3b"), c("m3a", "m3b", "m3c"), nodes),
      bus
    )
  }

  nodes <- nodes |>
    mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2
    )
  list(nodes = nodes, edges = edges, lane_ymin = lane_ymin, lane_ymax = lane_ymax, footer = footer)
}

fc_save_tree <- function(nodes, edges, pal, path, w_in = 7.2, h_in = 12.5, lane_ymin = NULL, lane_ymax = NULL) {
  nodes <- nodes |>
    mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2,
      stripe_w = if_else(kind %in% c("header", "foot"), 0, if (isTRUE(pal$stripe)) 1.1 else 0)
    )
  y_lo <- min(nodes$ymin) - 3
  y_hi <- max(nodes$ymax) + 3
  if (!is.null(lane_ymin)) y_lo <- min(y_lo, lane_ymin - 2)

  p <- ggplot() +
    theme_void(base_family = "sans") +
    theme(
      plot.background = element_rect(fill = pal$bg, colour = NA),
      plot.margin = margin(18, 14, 14, 14),
      plot.title = element_text(face = "bold", size = 16, colour = pal$title, hjust = 0.5, margin = margin(b = 4)),
      plot.subtitle = element_text(size = 9, colour = pal$subtitle, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 7.5, colour = pal$caption, hjust = 0.5, margin = margin(t = 8))
    ) +
    labs(
      title = "Method decision tree",
      subtitle = "After steps 1–3 of the CASTOR pipeline · pick test or model by outcome type",
      caption = "Appendix B · METHOD_MAP · analysis pipeline (Fig 6)"
    ) +
    coord_cartesian(xlim = c(0, 100), ylim = c(y_lo, y_hi), clip = "off")

  if (!is.null(pal$lanes) && !is.null(lane_ymin) && !is.null(lane_ymax)) {
    lanes <- pal$lanes |>
      mutate(
        xmin = x - w / 2, xmax = x + w / 2,
        ymin = lane_ymin, ymax = lane_ymax
      )
    p <- p +
      geom_rect(
        data = lanes, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
        fill = lanes$fill, colour = lanes$border, linewidth = 0.35, alpha = 0.55
      )
  }

  if (nrow(edges) > 0) {
    if ("xmid" %in% names(edges)) {
      p <- p +
        geom_segment(data = edges, aes(x = x, y = y, xend = xmid, yend = ymid),
                     colour = pal$edge, linewidth = 0.45, lineend = "round") +
        geom_segment(data = edges, aes(x = xmid, y = ymid, xend = xend, yend = yend),
                     colour = pal$edge, linewidth = 0.45, lineend = "round",
                     arrow = arrow(length = unit(0.14, "cm"), type = "closed"))
    } else {
      p <- p +
        geom_segment(data = edges, aes(x = x, y = y, xend = xend, yend = yend),
                     colour = pal$edge, linewidth = 0.45, lineend = "round",
                     arrow = arrow(length = unit(0.14, "cm"), type = "closed"))
    }
  }

  p <- p +
    geom_rect(
      data = nodes, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
      fill = nodes$fill, colour = nodes$border,
      linewidth = 0.5,
      linetype = if_else(nodes$kind == "optional", "22", "solid")
    )

  if (isTRUE(pal$stripe)) {
    stripes <- nodes |> filter(stripe_w > 0)
    p <- p +
      geom_rect(data = stripes, aes(xmin = xmin, xmax = xmin + stripe_w, ymin = ymin, ymax = ymax),
                fill = stripes$border, colour = NA)
  }

  p <- p +
    geom_text(data = nodes, aes(x = x, y = y, label = label),
              size = pal$text_size, lineheight = 0.88, colour = nodes$text,
              fontface = nodes$fontface, family = "sans")

  ggsave(path, p, width = w_in, height = h_in, dpi = pal$dpi, bg = pal$bg)
}

draw_tree_flow <- function(pal_key, path, footer = c("stack", "converge", "routes")) {
  footer <- match.arg(footer)
  pal <- tree_palettes[[pal_key]]
  ne <- tree_nodes_edges(pal$styles, footer = footer)
  fc_save_tree(ne$nodes, ne$edges, pal, path, lane_ymin = ne$lane_ymin, lane_ymax = ne$lane_ymax)
}

# --- Matrix layout --------------------------------------------------------------
draw_tree_matrix <- function(path, pal_key = "pearl") {
  pal <- tree_palettes[[pal_key]]
  df <- tribble(
    ~design, ~continuous, ~binary, ~count, ~row_kind,
    "2 independent groups", "Welch t · Mann-Whitney\nCh 4", "χ² · Fisher\nCh 4", "Poisson GLM\nCh 6", "method",
    "Paired design", "paired t-test\nCh 4", "McNemar\nCh 4", "—", "method",
    "Adjust covariates", "linear · ANCOVA\nCh 5", "logistic · Firth\nCh 6", "negative binomial\nCh 6", "method",
    "Many features / omics", "Ch 10–17 · DE+FDR · batch · flow", "Ch 10–17 · DE+FDR · batch · flow", "Ch 10–17 · DE+FDR · batch · flow", "omics"
  ) |>
    pivot_longer(c(continuous, binary, count), names_to = "outcome", values_to = "method") |>
    mutate(
      outcome = factor(outcome, levels = c("continuous", "binary", "count"),
                       labels = c("Continuous", "Binary", "Count")),
      design = factor(design, levels = unique(design)),
      fill = case_when(
        row_kind == "omics" ~ "#F6F4FA",
        outcome == "Count" & str_detect(method, "Poisson|binomial") ~ "#FFFFFF",
        outcome == "Count" & method == "—" ~ "#FEF2F2",
        outcome == "Continuous" ~ "#F0FAF9",
        outcome == "Binary" ~ "#EEF2FF",
        TRUE ~ "#FFFFFF"
      ),
      border = case_when(
        row_kind == "omics" ~ "#7C6EAD",
        outcome == "Count" ~ "#FDA4AF",
        outcome == "Continuous" ~ "#5EC4B8",
        outcome == "Binary" ~ "#818CF8",
        TRUE ~ "#C8D2DC"
      )
    )

  warn <- tibble(x = 3, y = 2, label = "Never t-test\non counts")

  p <- ggplot(df, aes(outcome, design)) +
    geom_tile(aes(fill = fill), colour = "white", linewidth = 1.2) +
    geom_text(aes(label = method), size = 2.85, lineheight = 0.88, colour = "#334155") +
    annotate("rect", xmin = 2.55, xmax = 3.45, ymin = 1.55, ymax = 2.45,
             fill = "#FEF2F2", colour = "#BE123C", linewidth = 0.6) +
    geom_text(data = warn, aes(x = x, y = y, label = label),
              size = 3.1, colour = "#9F1239", fontface = "bold", lineheight = 0.9) +
    scale_fill_identity() +
    theme_void(base_family = "sans") +
    theme(
      plot.background = element_rect(fill = pal$bg, colour = NA),
      plot.margin = margin(18, 14, 14, 14),
      plot.title = element_text(face = "bold", size = 16, colour = pal$title, hjust = 0.5),
      plot.subtitle = element_text(size = 9, colour = pal$subtitle, hjust = 0.5, margin = margin(b = 8)),
      plot.caption = element_text(size = 7.5, colour = pal$caption, hjust = 0.5, margin = margin(t = 8)),
      axis.text.x = element_text(size = 11, face = "bold", colour = c("#134E4A", "#312E81", "#9F1239")),
      axis.text.y = element_text(size = 9, face = "bold", colour = "#475569", hjust = 1)
    ) +
    labs(
      title = "Method decision tree",
      subtitle = "Design × outcome matrix · Appendix B quick lookup",
      caption = "Start with estimand (Ch 1) and outcome type (Ch 2) · then report (Ch 8) · Ch 18–21 advanced",
      x = NULL, y = NULL
    ) +
    coord_fixed(ratio = 0.95, clip = "off")

  ggsave(path, p, width = 8.5, height = 7.2, dpi = 320, bg = pal$bg)
}

# --- Metro (horizontal lanes) ---------------------------------------------------
draw_tree_metro <- function(path, pal_key = "pearl") {
  pal <- tree_palettes[[pal_key]]
  lane_y <- c(continuous = 72, binary = 50, count = 28)
  lane_col <- c(continuous = "#3A9E92", binary = "#6366F1", count = "#E879A8")
  stations <- tribble(
    ~lane, ~x, ~label, ~kind,
    "continuous", 8,  "Continuous\nFEV₁ · scores", "cat",
    "continuous", 28, "Welch t\nMann-Whitney", "method",
    "continuous", 48, "paired t", "method",
    "continuous", 68, "linear · ANCOVA\nCh 5", "method",
    "binary", 8,  "Binary\nY/N", "cat",
    "binary", 28, "χ² · Fisher", "method",
    "binary", 48, "McNemar", "method",
    "binary", 68, "logistic · Firth\nCh 6", "method",
    "count", 8,  "Count\nevents", "cat",
    "count", 28, "Never t-test", "warn",
    "count", 48, "Poisson + offset", "method",
    "count", 68, "neg. binomial", "method"
  ) |>
    mutate(y = lane_y[lane]) |>
    left_join(pal$styles, by = "kind")

  hub <- tribble(
    ~x, ~y, ~label, ~fill, ~border, ~text,
    88, 50, "Omics hub\nCh 10–17", "#F6F4FA", "#7C6EAD", "#3D3556",
    88, 22, "Report · Ch 8\nCONSORT · STROBE", "#F3F5F7", "#4A5568", "#1E293B",
    88, 8,  "Ch 18–21", "#F8FAFC", "#94A3B8", "#64748B"
  )

  start <- tribble(
    ~x, ~y, ~label, ~fill, ~border, ~text,
    4, 88, "1. Estimand\nCh 1", "#F7FAFC", "#3A9E92", "#0C0D12",
    50, 88, "2. Outcome type?\nCh 2 · App B", "#EFF6F5", "#3A9E92", "#134E4A"
  )

  p <- ggplot() +
    theme_void(base_family = "sans") +
    theme(
      plot.background = element_rect(fill = pal$bg, colour = NA),
      plot.margin = margin(18, 14, 14, 14),
      plot.title = element_text(face = "bold", size = 16, colour = pal$title, hjust = 0.5),
      plot.subtitle = element_text(size = 9, colour = pal$subtitle, hjust = 0.5),
      plot.caption = element_text(size = 7.5, colour = pal$caption, hjust = 0.5, margin = margin(t = 8))
    ) +
    labs(
      title = "Method decision tree",
      subtitle = "Metro router · three outcome lines converge at omics hub",
      caption = "Appendix B · METHOD_MAP"
    ) +
    coord_cartesian(xlim = c(0, 100), ylim = c(2, 94), clip = "off")

  for (nm in names(lane_y)) {
    p <- p +
      geom_segment(aes(x = 6, xend = 82, y = lane_y[[nm]], yend = lane_y[[nm]]),
                   colour = lane_col[[nm]], linewidth = 2.2, alpha = 0.25, inherit.aes = FALSE) +
      annotate("text", x = 2, y = lane_y[[nm]], label = nm, angle = 90, size = 3.2,
               fontface = "bold", colour = lane_col[[nm]])
  }

  seg <- stations |>
    arrange(y, x) |>
    group_by(y) |>
    mutate(xend = lead(x), yend = y) |>
    filter(!is.na(xend))

  p <- p +
    geom_segment(data = seg, aes(x = x + 6, y = y, xend = xend - 6, yend = yend),
                 colour = pal$edge, linewidth = 0.5,
                 arrow = arrow(length = unit(0.12, "cm"), type = "closed")) +
    geom_label(data = stations, aes(x = x, y = y, label = label),
               fill = stations$fill, colour = stations$border, size = 2.5,
               label.size = 0.4, lineheight = 0.85, fontface = stations$fontface) +
    geom_segment(aes(x = 50, xend = 50, y = 86, yend = 78), colour = pal$edge, linewidth = 0.5,
                 arrow = arrow(length = unit(0.12, "cm"), type = "closed"), inherit.aes = FALSE) +
    geom_label(data = start, aes(x = x, y = y, label = label),
               fill = start$fill, colour = start$border, size = 2.8,
               label.size = 0.4, lineheight = 0.85, fontface = "bold") +
    geom_segment(data = stations |> filter(x == 68),
                 aes(x = x + 8, y = y, xend = 84, yend = 50),
                 colour = pal$edge, linewidth = 0.45, linetype = "22",
                 arrow = arrow(length = unit(0.1, "cm"), type = "closed")) +
    geom_label(data = hub, aes(x = x, y = y, label = label),
               fill = hub$fill, colour = hub$border, size = 2.4,
               label.size = 0.35, lineheight = 0.85)

  ggsave(path, p, width = 10, height = 6.8, dpi = 320, bg = pal$bg)
}

# --- Generate all options -------------------------------------------------------
message("Writing decision-tree options to ", opts_dir)
draw_tree_flow("handbook", file.path(opts_dir, "select-tree-handbook.png"))
draw_tree_flow("pearl", file.path(opts_dir, "select-tree-pearl.png"))
draw_tree_flow("pearl", file.path(opts_dir, "select-tree-pearl-v3.png"), footer = "routes")
draw_tree_flow("slate", file.path(opts_dir, "select-tree-slate.png"))
draw_tree_flow("copper", file.path(opts_dir, "select-tree-copper.png"))
draw_tree_flow("dark", file.path(opts_dir, "select-tree-dark.png"))
draw_tree_matrix(file.path(opts_dir, "select-tree-matrix.png"), "pearl")
draw_tree_metro(file.path(opts_dir, "select-tree-metro.png"), "pearl")

writeLines(c(
  "# Method decision tree: pick one",
  "",
  "Open side by side in `pipeline-options/`. Reply with the filename stem (e.g. **pearl**, **matrix**).",
  "",
  "| Reply | File | Style |",
  "|-------|------|-------|",
  "| **handbook** | `select-tree-handbook.png` | Current R flowchart (white, left stripe) |",
  "| **pearl** | `select-tree-pearl.png` | Pearl lane tints · matches pipeline pearl |",
  "| **slate** | `select-tree-slate.png` | Cool indigo/cyan editorial |",
  "| **copper** | `select-tree-copper.png` | Warm stone/copper luxe |",
  "| **dark** | `select-tree-dark.png` | Dark pearl (slides / screen) |",
  "| **matrix** | `select-tree-matrix.png` | Design × outcome lookup table |",
  "| **metro** | `select-tree-metro.png` | Horizontal transit-map router |",
  "| **luxe-pearl** | `select-tree-luxe-pearl.png` | Illustrated pearl lanes · fine-line icons (AI) |",
  "| **luxe-metro** | `select-tree-luxe-metro.png` | Illustrated horizontal metro (AI) |",
  "| **original** | `select-tree-original-luxe.png` | Current published figure (beaver + watermarks) |",
  "",
  "Published asset `method_decision_tree.png` is **not** overwritten until you approve.",
  "",
  "Regenerate: `source(\"R/examples/draw_decision_tree_options.R\")`"
), file.path(opts_dir, "TREE-SELECT.md"))

message("Done. See pipeline-options/TREE-SELECT.md")
