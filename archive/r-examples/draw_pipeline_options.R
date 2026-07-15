# Generate pipeline design options (modern palettes + niche statistical icons)
source("R/00_setup.R")
library(tidyverse)

fig_dir <- file.path(paths$root, "volume-01", "figures")
opts_dir <- file.path(paths$root, "archive", "figures", "pipeline-options")
dir.create(opts_dir, showWarnings = FALSE, recursive = TRUE)

# --- Palettes -----------------------------------------------------------------
pipeline_palettes <- list(
  pearl = list(
    name = "Pearl & teal (cover match)",
    bg = "#FFFFFF",
    title = "#0C0D12",
    subtitle = "#64748B",
    caption = "#94A3B8",
    edge = "#C8D2DC",
    accent = "#E85D75",
    steps = tribble(
      ~id, ~n, ~title, ~detail, ~fill, ~border, ~text, ~icon,
      "s1", 1L, "Clinical question", "What would change practice?\nCh 1; PICO", "#F7FAFC", "#3A9E92", "#0C0D12", "pico",
      "s2", 2L, "Estimand + population", "Who; contrast; when\nCh 1–2", "#F4F7F9", "#5EC4B8", "#1E293B", "estimand",
      "s3", 3L, "Describe the sample", "Table 1; plots; missingness\nCh 3", "#F2F6FA", "#6E7D8A", "#334155", "describe",
      "s4", 4L, "Choose method", "Outcome type + design\nAppendix B", "#EFF6F5", "#3A9E92", "#134E4A", "method",
      "s5", 5L, "Fit model / test in R", "Prespecified script\nAppendix A", "#F0FAF9", "#2D8F86", "#134E4A", "code",
      "s6", 6L, "Diagnostics + sensitivity", "Assumptions; MI; alternatives\nCh 7; 20", "#F6F4FA", "#7C6EAD", "#3D3556", "diagnostics",
      "s7", 7L, "Report estimate + 95% CI", "n; limitations; guidelines\nCh 8", "#F3F5F7", "#4A5568", "#1E293B", "report",
      "s8", 8L, "State what was NOT proven", "Stop: do not over-claim", "#FDF5F6", "#D45B6A", "#7F1D1D", "limits"
    ),
    routes = tribble(
      ~id, ~label, ~fill, ~border, ~text, ~icon,
      "r1", "Describe & compare\nCh 3–4", "#F2F6FA", "#6E7D8A", "#334155", "compare",
      "r2", "Regression & prediction\nCh 5–9", "#EFF6F5", "#3A9E92", "#134E4A", "regression",
      "r3", "Discovery & omics\nCh 10–17", "#F6F4FA", "#7C6EAD", "#3D3556", "omics",
      "r4", "Longitudinal & survival\nCh 18–19", "#F0FAF9", "#2D8F86", "#134E4A", "survival",
      "r5", "Missing; causal; routers\nCh 20–21; App B I J K", "#F3F5F7", "#4A5568", "#1E293B", "causal"
    )
  ),
  slate = list(
    name = "Slate editorial",
    bg = "#FFFFFF",
    title = "#0F172A",
    subtitle = "#64748B",
    caption = "#94A3B8",
    edge = "#CBD5E1",
    accent = "#DC2626",
    steps = tribble(
      ~id, ~n, ~title, ~detail, ~fill, ~border, ~text, ~icon,
      "s1", 1L, "Clinical question", "What would change practice?\nCh 1; PICO", "#F8FAFC", "#0F172A", "#0F172A", "pico",
      "s2", 2L, "Estimand + population", "Who; contrast; when\nCh 1–2", "#F1F5F9", "#334155", "#1E293B", "estimand",
      "s3", 3L, "Describe the sample", "Table 1; plots; missingness\nCh 3", "#EEF2FF", "#4338CA", "#312E81", "describe",
      "s4", 4L, "Choose method", "Outcome type + design\nAppendix B", "#ECFEFF", "#0891B2", "#164E63", "method",
      "s5", 5L, "Fit model / test in R", "Prespecified script\nAppendix A", "#F0FDF4", "#059669", "#065F46", "code",
      "s6", 6L, "Diagnostics + sensitivity", "Assumptions; MI; alternatives\nCh 7; 20", "#FAF5FF", "#7C3AED", "#4C1D95", "diagnostics",
      "s7", 7L, "Report estimate + 95% CI", "n; limitations; guidelines\nCh 8", "#F8FAFC", "#475569", "#1E293B", "report",
      "s8", 8L, "State what was NOT proven", "Stop: do not over-claim", "#FEF2F2", "#B91C1C", "#7F1D1D", "limits"
    ),
    routes = tribble(
      ~id, ~label, ~fill, ~border, ~text, ~icon,
      "r1", "Describe & compare\nCh 3–4", "#EEF2FF", "#4338CA", "#312E81", "compare",
      "r2", "Regression & prediction\nCh 5–9", "#ECFEFF", "#0891B2", "#164E63", "regression",
      "r3", "Discovery & omics\nCh 10–17", "#FAF5FF", "#7C3AED", "#4C1D95", "omics",
      "r4", "Longitudinal & survival\nCh 18–19", "#F0FDF4", "#059669", "#065F46", "survival",
      "r5", "Missing; causal; routers\nCh 20–21; App B I J K", "#F8FAFC", "#475569", "#1E293B", "causal"
    )
  ),
  copper = list(
    name = "Copper luxe",
    bg = "#FEFDFB",
    title = "#1C1917",
    subtitle = "#78716C",
    caption = "#A8A29E",
    edge = "#D6D3D1",
    accent = "#BE123C",
    steps = tribble(
      ~id, ~n, ~title, ~detail, ~fill, ~border, ~text, ~icon,
      "s1", 1L, "Clinical question", "What would change practice?\nCh 1; PICO", "#FFFBEB", "#B45309", "#78350F", "pico",
      "s2", 2L, "Estimand + population", "Who; contrast; when\nCh 1–2", "#FFF7ED", "#C2410C", "#7C2D12", "estimand",
      "s3", 3L, "Describe the sample", "Table 1; plots; missingness\nCh 3", "#F5F5F4", "#57534E", "#292524", "describe",
      "s4", 4L, "Choose method", "Outcome type + design\nAppendix B", "#ECFDF5", "#047857", "#064E3B", "method",
      "s5", 5L, "Fit model / test in R", "Prespecified script\nAppendix A", "#F0F9FF", "#0369A1", "#0C4A6E", "code",
      "s6", 6L, "Diagnostics + sensitivity", "Assumptions; MI; alternatives\nCh 7; 20", "#FAF5FF", "#7E22CE", "#581C87", "diagnostics",
      "s7", 7L, "Report estimate + 95% CI", "n; limitations; guidelines\nCh 8", "#F5F5F4", "#44403C", "#292524", "report",
      "s8", 8L, "State what was NOT proven", "Stop: do not over-claim", "#FEF2F2", "#BE123C", "#881337", "limits"
    ),
    routes = tribble(
      ~id, ~label, ~fill, ~border, ~text, ~icon,
      "r1", "Describe & compare\nCh 3–4", "#F5F5F4", "#57534E", "#292524", "compare",
      "r2", "Regression & prediction\nCh 5–9", "#ECFDF5", "#047857", "#064E3B", "regression",
      "r3", "Discovery & omics\nCh 10–17", "#FAF5FF", "#7E22CE", "#581C87", "omics",
      "r4", "Longitudinal & survival\nCh 18–19", "#F0F9FF", "#0369A1", "#0C4A6E", "survival",
      "r5", "Missing; causal; routers\nCh 20–21; App B I J K", "#FFFBEB", "#B45309", "#78350F", "causal"
    )
  )
)

icon_grob <- function(kind, col = "#0C0D12", lwd = 0.8) {
  g <- grid::gpar(col = col, lwd = lwd, fill = NA)
  gf <- grid::gpar(col = col, lwd = lwd * 0.7, fill = scales::alpha(col, 0.12))
  switch(kind,
    pico = grid::gTree(children = grid::gList(
      grid::rectGrob(0.18, 0.22, 0.64, 0.56, gp = gf),
      grid::textGrob("P", 0.32, 0.5, gp = grid::gpar(col = col, fontsize = 7, fontface = "bold")),
      grid::textGrob("I", 0.5, 0.5, gp = grid::gpar(col = col, fontsize = 7, fontface = "bold")),
      grid::textGrob("?", 0.68, 0.5, gp = grid::gpar(col = col, fontsize = 8, fontface = "bold"))
    )),
    estimand = grid::gTree(children = grid::gList(
      grid::circleGrob(0.5, 0.5, 0.28, gp = g),
      grid::segmentsGrob(c(0.5, 0.22), c(0.5, 0.5), c(0.78, 0.5), c(0.78, 0.5), gp = g),
      grid::circleGrob(0.22, 0.5, 0.05, gp = grid::gpar(col = col, fill = col)),
      grid::textGrob(expression(theta), 0.5, 0.5, gp = grid::gpar(col = col, fontsize = 9))
    )),
    describe = grid::gTree(children = grid::gList(
      grid::segmentsGrob(c(0.2, 0.35, 0.5, 0.65, 0.8), rep(0.25, 5),
                         c(0.2, 0.35, 0.5, 0.65, 0.8), c(0.75, 0.55, 0.7, 0.45, 0.35), gp = g),
      grid::rectGrob(0.18, 0.2, 0.64, 0.62, gp = g)
    )),
    method = grid::gTree(children = grid::gList(
      grid::circleGrob(0.5, 0.78, 0.07, gp = grid::gpar(col = col, fill = col)),
      grid::segmentsGrob(c(0.5, 0.35, 0.5), c(0.71, 0.55), c(0.28, 0.72, 0.5), c(0.55, 0.28, 0.28), gp = g),
      grid::circleGrob(c(0.28, 0.72), c(0.28, 0.28), 0.06, gp = grid::gpar(col = col, fill = col)),
      grid::circleGrob(0.5, 0.28, 0.06, gp = grid::gpar(col = col, fill = col))
    )),
    code = grid::gTree(children = grid::gList(
      grid::rectGrob(0.15, 0.2, 0.7, 0.6, gp = g),
      grid::textGrob("</>", 0.5, 0.5, gp = grid::gpar(col = col, fontsize = 8, fontface = "bold"))
    )),
    diagnostics = grid::gTree(children = grid::gList(
      grid::segmentsGrob(c(0.2, 0.75), c(0.2, 0.75), c(0.8, 0.25), c(0.8, 0.25), gp = g),
      grid::pointsGrob(runif(12, 0.22, 0.78), runif(12, 0.28, 0.72), pch = 16, size = grid::unit(0.5, "mm"), gp = grid::gpar(col = col))
    )),
    report = grid::gTree(children = grid::gList(
      grid::segmentsGrob(c(0.25, 0.55, 0.75), rep(0.5, 3), c(0.35, 0.65, 0.65), rep(0.5, 3), gp = g),
      grid::rectGrob(0.32, 0.42, 0.06, 0.16, gp = grid::gpar(col = col, fill = col)),
      grid::rectGrob(0.62, 0.42, 0.06, 0.16, gp = grid::gpar(col = col, fill = col))
    )),
    limits = grid::gTree(children = grid::gList(
      grid::rectGrob(0.2, 0.25, 0.6, 0.5, gp = grid::gpar(col = col, lwd = 1.1, linetype = "22")),
      grid::textGrob("!", 0.5, 0.5, gp = grid::gpar(col = col, fontsize = 10, fontface = "bold"))
    )),
    compare = grid::gTree(children = grid::gList(
      grid::segmentsGrob(c(0.3, 0.7), c(0.35, 0.35), c(0.3, 0.7), c(0.65, 0.65), gp = g),
      grid::circleGrob(c(0.3, 0.7), c(0.5, 0.5), 0.08, gp = grid::gpar(col = col, fill = scales::alpha(col, 0.15)))
    )),
    regression = grid::gTree(children = grid::gList(
      grid::pointsGrob(runif(8, 0.22, 0.78), runif(8, 0.28, 0.72), pch = 16, size = grid::unit(0.45, "mm"), gp = grid::gpar(col = col)),
      grid::segmentsGrob(c(0.22, 0.78), c(0.28, 0.72), c(0.78, 0.28), c(0.78, 0.28), gp = g)
    )),
    omics = grid::gTree(children = grid::gList(
      grid::rectGrob(seq(0.22, 0.62, 0.2), rep(0.22, 3), 0.16, 0.16, gp = gf),
      grid::rectGrob(seq(0.22, 0.62, 0.2), rep(0.42, 3), 0.16, 0.16, gp = gf),
      grid::rectGrob(seq(0.22, 0.62, 0.2), rep(0.62, 3), 0.16, 0.16, gp = gf)
    )),
    survival = grid::gTree(children = grid::gList(
      grid::segmentsGrob(c(0.2, 0.2, 0.45, 0.45, 0.7), c(0.75, 0.75, 0.6, 0.45, 0.35),
                         c(0.45, 0.7, 0.7, 0.7, 0.7), c(0.75, 0.6, 0.45, 0.35, 0.35), gp = g)
    )),
    causal = grid::gTree(children = grid::gList(
      grid::circleGrob(c(0.28, 0.72, 0.5), c(0.72, 0.72, 0.28), 0.07, gp = grid::gpar(col = col, fill = col)),
      grid::segmentsGrob(c(0.28, 0.5), c(0.72, 0.72), c(0.5, 0.5), c(0.5, 0.28), gp = g),
      grid::segmentsGrob(c(0.5, 0.5), c(0.72, 0.5), c(0.72, 0.28), c(0.28, 0.28), gp = g)
    )),
    grid::textGrob("?", 0.5, 0.5, gp = grid::gpar(col = col, fontsize = 8))
  )
}

draw_pipeline_option <- function(pal, path) {
  steps <- pal$steps
  routes <- pal$routes
  w_spine <- 44
  w_route <- 27
  x_spine <- 36
  x_route <- 78
  gap <- 2.5
  y <- 88

  spine <- purrr::map_dfr(seq_len(nrow(steps)), function(i) {
    s <- steps[i, ]
    n_lines <- stringr::str_count(s$detail, "\n") + 1L
    h <- 8 + n_lines * 2.7
    y <<- y - h / 2
    out <- tibble::tibble(
      id = s$id, n = s$n, title = s$title, detail = s$detail, icon = s$icon,
      x = x_spine, y = y, w = w_spine, h = h,
      fill = s$fill, border = s$border, text = s$text
    )
    y <<- y - h / 2 - gap
    out
  })

  route_y <- spine$y[spine$id == "s4"] + 5
  routes_xy <- purrr::map_dfr(seq_len(nrow(routes)), function(i) {
    r <- routes[i, ]
    h <- 9.8
    route_y <<- route_y - h / 2
    out <- tibble::tibble(
      id = r$id, label = r$label, icon = r$icon,
      x = x_route, y = route_y, w = w_route, h = h,
      fill = r$fill, border = r$border, text = r$text
    )
    route_y <<- route_y - h / 2 - 1.7
    out
  })

  loop_h <- 10
  loop_y <- min(spine$y - spine$h / 2) - loop_h / 2 - 3
  loop <- tibble::tibble(
    id = "loop", label = "Estimand ≠ design?\nReturn to steps 1–2",
    x = x_spine, y = loop_y, w = w_spine, h = loop_h,
    fill = "#FEF2F2", border = pal$accent, text = "#7F1D1D"
  )

  nodes <- spine |>
    mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2,
      label = paste0(title, "\n", detail),
      icon_x = xmin + 5.2, icon_y = y
    )
  routes_xy <- routes_xy |>
    mutate(
      xmin = x - w / 2, xmax = x + w / 2,
      ymin = y - h / 2, ymax = y + h / 2,
      icon_x = xmin + 3.8, icon_y = y
    )
  loop <- loop |>
    mutate(xmin = x - w / 2, xmax = x + w / 2, ymin = y - h / 2, ymax = y + h / 2)

  spine_edges <- purrr::map2_dfr(steps$id[-nrow(steps)], steps$id[-1], function(a, b) {
    na <- nodes |> filter(id == a)
    nb <- nodes |> filter(id == b)
    tibble(x = na$x, y = na$ymin - 0.2, xend = nb$x, yend = nb$ymax + 0.2)
  })

  s4 <- nodes |> filter(id == "s4")
  route_edges <- purrr::map_dfr(routes_xy$id, function(rid) {
    nr <- routes_xy |> filter(id == rid)
    tibble(
      x = s4$x + s4$w / 2 + 0.3, y = s4$y,
      xmid = (s4$x + s4$w / 2 + nr$x - nr$w / 2) / 2,
      ymid = nr$y, xend = nr$xmin - 0.3, yend = nr$y
    )
  })

  accent <- tibble(
    x = s4$xmin, y = s4$y, xmid = 8, ymid = loop$y + 1,
    xend = loop$xmin, yend = loop$y + loop$h / 4
  )

  badge <- nodes |> transmute(x = icon_x - 2.2, y = icon_y, n = n, border = border)

  y_lo <- min(loop$ymin, routes_xy$ymin) - 4
  y_hi <- max(nodes$ymax) + 6

  p <- ggplot() +
    theme_void(base_family = "sans") +
    theme(
      plot.background = element_rect(fill = pal$bg, colour = NA),
      plot.margin = margin(20, 16, 14, 16),
      plot.title = element_text(face = "bold", size = 18, colour = pal$title, hjust = 0.5, margin = margin(b = 3)),
      plot.subtitle = element_text(size = 10, colour = pal$subtitle, hjust = 0.5, margin = margin(b = 12)),
      plot.caption = element_text(size = 8, colour = pal$caption, hjust = 0.5, margin = margin(t = 10))
    ) +
    labs(
      title = "Analysis pipeline",
      subtitle = "Question first ;  method second ;  report what you did not prove",
      caption = paste0(pal$name, " ;  Ch 1–21 + appendices")
    ) +
    coord_cartesian(xlim = c(0, 100), ylim = c(y_lo, y_hi), clip = "off") +
    geom_rect(
      data = nodes,
      aes(xmin = xmin + 0.4, xmax = xmax + 0.4, ymin = ymin - 0.4, ymax = ymax - 0.4),
      fill = "#CBD5E128", colour = NA
    ) +
    geom_rect(
      data = routes_xy,
      aes(xmin = xmin + 0.3, xmax = xmax + 0.3, ymin = ymin - 0.3, ymax = ymax - 0.3),
      fill = "#CBD5E118", colour = NA
    ) +
    geom_rect(data = nodes, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = nodes$fill, colour = nodes$border, linewidth = 0.85) +
    geom_rect(data = routes_xy, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = routes_xy$fill, colour = routes_xy$border, linewidth = 0.6) +
    geom_rect(data = loop, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
              fill = loop$fill, colour = loop$border, linewidth = 0.7, linetype = "22") +
    geom_segment(data = spine_edges, aes(x = x, y = y, xend = xend, yend = yend),
                 colour = pal$edge, linewidth = 0.55,
                 arrow = arrow(length = unit(0.16, "cm"), type = "closed")) +
    geom_segment(data = route_edges, aes(x = x, y = y, xend = xmid, yend = ymid), colour = pal$edge, linewidth = 0.4) +
    geom_segment(data = route_edges, aes(x = xmid, y = ymid, xend = xend, yend = yend),
                 colour = pal$edge, linewidth = 0.4,
                 arrow = arrow(length = unit(0.12, "cm"), type = "closed")) +
    geom_segment(data = accent, aes(x = x, y = y, xend = xmid, yend = ymid),
                 colour = pal$accent, linewidth = 0.55, linetype = "22") +
    geom_segment(data = accent, aes(x = xmid, y = ymid, xend = xend, yend = yend),
                 colour = pal$accent, linewidth = 0.55, linetype = "22",
                 arrow = arrow(length = unit(0.12, "cm"), type = "closed")) +
    geom_point(data = badge, aes(x = x, y = y), shape = 21, size = 3.6,
               fill = "#FFFFFF", colour = badge$border, stroke = 1) +
    geom_text(data = badge, aes(x = x, y = y, label = n), size = 2.9, fontface = "bold", colour = pal$title) +
    geom_text(data = nodes, aes(x = x + 3, y = y, label = label),
              size = 2.8, lineheight = 0.9, colour = nodes$text, hjust = 0.5) +
    geom_text(data = routes_xy, aes(x = x + 2.2, y = y, label = label),
              size = 2.45, lineheight = 0.88, colour = routes_xy$text, fontface = "bold", hjust = 0.5) +
    geom_text(data = loop, aes(x = x, y = y, label = label),
              size = 2.55, lineheight = 0.88, colour = loop$text, fontface = "bold") +
    annotate("text", x = x_route, y = max(routes_xy$ymax) + 3,
             label = "Handbook routes", size = 3.3, fontface = "bold", colour = pal$title)

  icon_size <- 0.85
  for (i in seq_len(nrow(nodes))) {
    row <- nodes[i, ]
    cg <- icon_grob(row$icon, col = row$border, lwd = 1)
    p <- p + annotation_custom(
      cg,
      xmin = row$icon_x - icon_size, xmax = row$icon_x + icon_size,
      ymin = row$icon_y - icon_size, ymax = row$icon_y + icon_size
    )
  }
  for (i in seq_len(nrow(routes_xy))) {
    row <- routes_xy[i, ]
    cg <- icon_grob(row$icon, col = row$border, lwd = 0.9)
    p <- p + annotation_custom(
      cg,
      xmin = row$icon_x - 0.7, xmax = row$icon_x + 0.7,
      ymin = row$icon_y - 0.7, ymax = row$icon_y + 0.7
    )
  }

  ggsave(path, p, width = 8.4, height = 11.4, dpi = 320, bg = pal$bg)
  message("Saved: ", path)
}

purrr::iwalk(pipeline_palettes, function(pal, key) {
  draw_pipeline_option(pal, file.path(opts_dir, paste0("select-", key, ".png")))
})

writeLines(
  c(
    "# Pipeline: pick one",
    "",
    "| File | Palette | Vibe |",
    "|------|---------|------|",
    "| `select-pearl.png` | Pearl & teal | Matches book cover; restrained luxury |",
    "| `select-slate.png` | Slate editorial | Nature/Lancet-style; cool indigo accents |",
    "| `select-copper.png` | Copper luxe | Warm stone + copper; editorial premium |",
    "",
    "Each has niche statistical icons inside steps and handbook routes.",
    "Reply with **pearl**, **slate**, or **copper** to install as `analysis_pipeline.png`."
  ),
  file.path(opts_dir, "SELECT.md")
)
