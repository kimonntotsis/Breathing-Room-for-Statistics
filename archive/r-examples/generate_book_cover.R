# Professional book cover: forest-plot lung silhouette + teal/gold weave threads
source("R/00_setup.R")

library(tidyverse)
library(grid)

set.seed(42)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

pal <- list(
  bg = "#0e1318",
  pearl = "#c8d2dc",
  pearl_dim = "#6e7d8a",
  teal = "#3a9e92",
  teal_glow = "#5ec4b8",
  gold = "#b8944f",
  gold_glow = "#d4b06a"
)

# Lung envelope: half-width at height y (0 = bottom, 1 = top)
lung_hw <- function(y) {
  y <- as.numeric(y)
  out <- numeric(length(y))
  tr <- y > 0.80
  out[tr] <- scales::rescale(y[tr], c(0.018, 0.032), c(0.80, 0.94))
  rel <- (y[!tr] - 0.06) / 0.74
  rel <- pmax(0, pmin(1, rel))
  out[!tr] <- 0.07 + 0.33 * sin(pi * rel)^1.08
  out
}

inside_lung <- function(x, y) abs(x - 0.5) <= lung_hw(y) * 1.02 && y >= 0.06 && y <= 0.93

forest_rows <- function(n = 160) {
  ys <- seq(0.07, 0.91, length.out = n)
  map_dfr(ys, function(y) {
    hw <- lung_hw(y)
    n_seg <- if (y > 0.78) 1L else sample(2:4, 1)
    map_dfr(seq_len(n_seg), function(j) {
      seg_hw <- runif(1, 0.04, 0.16) * hw
      est <- if (y > 0.78) {
        0.5
      } else {
        side <- sample(c(-1, 1), 1)
        0.5 + side * runif(1, 0.25, 0.82) * hw
      }
      tibble(
        y, est,
        x0 = est - seg_hw, x1 = est + seg_hw,
        alpha = 0.4 + runif(1, 0, 0.45)
      )
    })
  })
}

weave_curves <- function(n = 24) {
  map_dfr(seq_len(n), function(i) {
    y1 <- runif(1, 0.10, 0.88)
    y2 <- y1 + runif(1, -0.25, 0.25)
    y2 <- pmax(0.08, pmin(0.90, y2))
    x1 <- if (y1 > 0.78) runif(1, 0.47, 0.53) else {
      if (runif(1) > 0.5) runif(1, 0.18, 0.46) else runif(1, 0.54, 0.82)
    }
    x2 <- x1 + runif(1, -0.2, 0.2)
    x2 <- pmax(0.12, pmin(0.88, x2))
    if (!inside_lung(x1, y1) && !inside_lung(x2, y2)) return(NULL)
    tibble(
      id = i,
      colour = if (i %% 2 == 0) "teal" else "gold",
      x1, y1, x2, y2,
      curvature = runif(1, -0.35, 0.35)
    )
  }) |> filter(!is.null(id))
}

edge_mist <- function(n = 500) {
  tibble(
    x = runif(n, 0.08, 0.92),
    y = runif(n, 0.06, 0.92)
  ) |>
    mutate(
      hw = lung_hw(y),
      dist = pmax(0, abs(x - 0.5) - hw * 0.82),
      alpha = pmax(0, 1 - dist / 0.14)^2 * runif(n, 0.05, 0.35)
    ) |>
    filter(alpha > 0.02) |>
    mutate(
      colour = sample(c("teal", "gold", "pearl"), n(), replace = TRUE),
      size = runif(n(), 0.2, 0.7)
    )
}

# Micro-plot data embedded as geometry (not floating images)
km_data <- {
  t <- seq(0, 5, length.out = 35)
  bind_rows(
    tibble(t, s = exp(-0.2 * t), grp = "A"),
    tibble(t, s = exp(-0.38 * t), grp = "B")
  )
}

roc_data <- tibble(
  fpr = seq(0, 1, length.out = 40),
  tpr = seq(0, 1, length.out = 40)^0.62
)

spag_data <- {
  w <- seq(0, 52, by = 4)
  map_dfr(1:10, ~ tibble(
    week = w, fev1 = runif(1, 2, 2.8) - 0.008 * w + rnorm(length(w), 0, 0.05),
    id = .x
  ))
}

cal_data <- tibble(
  pred = seq(0.1, 0.9, length.out = 14),
  obs = seq(0.1, 0.9, length.out = 14) + rnorm(14, 0, 0.05)
)

heat_data <- expand_grid(x = 1:6, y = 1:6) |>
  mutate(val = matrix(runif(36), 6, 6)[cbind(y, x)])

dendro_data <- tribble(
  ~x0, ~y0, ~x1, ~y1,
  0.15, 0, 0.15, 0.4, 0.5, 0, 0.5, 0.55, 0.85, 0, 0.85, 0.4,
  0.15, 0.4, 0.5, 0.55, 0.5, 0.55, 0.85, 0.4,
  0.32, 0.55, 0.32, 0.78, 0.68, 0.55, 0.68, 0.78,
  0.32, 0.78, 0.68, 0.78, 0.5, 0.78, 0.5, 1
)

# Map unit-square micro-plots into lung coordinates
embed <- function(data, x0, y0, w, h) {
  data |>
    mutate(
      across(
        matches("^[xy]|^t$|^fpr$|^tpr$|^pred$|^obs$|^week$|^fev1$|^s$"),
        ~ .x,
        .names = "{.col}_raw"
      )
    )
}

transform_xy <- function(x, y, box) {
  list(
    x = box$x0 + x * box$w,
    y = box$y0 + y * box$h
  )
}

km_plot_data <- km_data |>
  mutate(
    x = 0.17 + 0.14 * t / 5,
    y = 0.62 + 0.10 * s
  )

roc_plot_data <- roc_data |>
  mutate(
    x = 0.70 + 0.12 * fpr,
    y = 0.63 + 0.10 * tpr
  )

roc_diag <- tibble(
  x = c(0.70, 0.82), y = c(0.63, 0.73)
)

spag_plot_data <- spag_data |>
  mutate(
    x = 0.14 + 0.16 * week / 52,
    y = 0.20 + 0.12 * (fev1 - 1.4) / 1.6
  )

cal_plot_data <- cal_data |>
  mutate(
    x = 0.68 + 0.12 * pred,
    y = 0.22 + 0.10 * obs
  )

cal_diag <- tibble(
  x = c(0.68, 0.80), y = c(0.22, 0.32)
)

heat_plot_data <- heat_data |>
  mutate(
    x = 0.24 + 0.08 * (x - 1) / 5,
    y = 0.40 + 0.08 * (y - 1) / 5,
    fill = val
  )

dendro_plot_data <- dendro_data |>
  mutate(
    x0p = 0.70 + 0.10 * x0, y0p = 0.38 + 0.12 * y0,
    x1p = 0.70 + 0.10 * x1, y1p = 0.38 + 0.12 * y1
  )

forest <- forest_rows()
weaves <- weave_curves()
mist <- edge_mist()

p <- ggplot() +
  theme_void() +
  theme(
    plot.background = element_rect(fill = pal$bg, colour = NA),
    plot.margin = margin(24, 24, 24, 24)
  ) +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), clip = "off") +
  # forest lung body
  geom_segment(
    data = forest,
    aes(x = x0, y = y, xend = x1, yend = y, alpha = alpha),
    colour = pal$pearl, linewidth = 0.32
  ) +
  geom_point(
    data = forest,
    aes(x = est, y = y, alpha = alpha),
    shape = 22, size = 0.65, colour = pal$pearl, fill = pal$bg, stroke = 0.25
  ) +
  # embedded micro-plots (same line weight as weave)
  geom_step(
    data = km_plot_data, aes(x = x, y = y, group = grp),
    colour = pal$teal_glow, linewidth = 0.35, alpha = 0.75, direction = "vh"
  ) +
  geom_line(
    data = roc_diag, aes(x, y),
    colour = pal$pearl_dim, linewidth = 0.2, alpha = 0.5
  ) +
  geom_line(
    data = roc_plot_data, aes(x, y),
    colour = pal$teal_glow, linewidth = 0.35, alpha = 0.75
  ) +
  geom_line(
    data = spag_plot_data, aes(x, y, group = id),
    colour = pal$pearl_dim, linewidth = 0.22, alpha = 0.55
  ) +
  geom_line(
    data = cal_diag, aes(x, y),
    colour = pal$pearl_dim, linewidth = 0.2, alpha = 0.45
  ) +
  geom_point(
    data = cal_plot_data, aes(x, y),
    colour = pal$gold_glow, size = 0.45, alpha = 0.7
  ) +
  geom_tile(
    data = heat_plot_data, aes(x, y, fill = fill),
    width = 0.08 / 6, height = 0.08 / 6, alpha = 0.85
  ) +
  scale_fill_gradient(low = "#1a2a32", high = pal$teal_glow, guide = "none") +
  geom_segment(
    data = dendro_plot_data,
    aes(x = x0p, y = y0p, xend = x1p, yend = y1p),
    colour = pal$gold, linewidth = 0.3, alpha = 0.7
  ) +
  # breath mist at lung perimeter
  geom_point(
    data = mist, aes(x, y, alpha = alpha, size = size, colour = colour),
    shape = 16
  ) +
  scale_colour_manual(
    values = c(teal = pal$teal_glow, gold = pal$gold_glow, pearl = pal$pearl),
    guide = "none"
  ) +
  scale_alpha_identity() +
  scale_size_identity() +
  guides(alpha = "none")

# weave threads as custom grobs
for (i in seq_len(nrow(weaves))) {
  row <- weaves[i, ]
  col <- if (row$colour == "teal") pal$teal else pal$gold
  cg <- curveGrob(
    x1 = row$x1, y1 = row$y1, x2 = row$x2, y2 = row$y2,
    curvature = row$curvature,
    default.units = "npc",
    gp = gpar(col = scales::alpha(col, 0.28), lwd = 1.4)
  )
  p <- p + annotation_custom(cg, xmin = 0, xmax = 1, ymin = 0, ymax = 1)
}

out <- file.path(fig_dir, "book-cover-weave-r-professional.png")
ggsave(out, p, width = 8, height = 8, dpi = 400, bg = pal$bg)
message("Saved: ", out)
