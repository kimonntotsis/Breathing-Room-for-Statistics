# Schematic figures for Appendix A (R environment walkthrough)
# source("R/examples/generate_appendix_a_figures.R")

if (!exists("paths")) source("R/00_setup.R")

library(ggplot2)
library(patchwork)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

cols <- list(
  bg = "#F8FAFC",
  panel = "#FFFFFF",
  border = "#CBD5E1",
  accent = "#0C0D12",
  teal = "#3A9E92",
  muted = "#64748B",
  right = "#115E59",
  wrong = "#BE123C",
  code = "#1E293B",
  highlight = "#E0F2FE"
)

aa_theme <- function() {
  theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 13, colour = cols$accent, hjust = 0.5, margin = margin(b = 6)),
      plot.subtitle = element_text(size = 9.5, colour = cols$muted, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, colour = cols$muted, hjust = 0.5, lineheight = 0.95),
      plot.margin = margin(12, 14, 12, 14),
      plot.background = element_rect(fill = "#FFFFFF", colour = NA)
    )
}

aa_save <- function(p, name, w, h) {
  path <- file.path(fig_dir, name)
  ggsave(path, p, width = w, height = h, dpi = 200, bg = "white")
  invisible(path)
}

aa_rect_df <- function(xmin, xmax, ymin, ymax, fill = cols$panel) {
  data.frame(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = fill)
}

aa_draw_pane <- function(xmin, xmax, ymin, ymax, title, body_lines, header_col = cols$teal) {
  df <- aa_rect_df(xmin, xmax, ymin, ymax)
  header_h <- (ymax - ymin) * 0.14
  ggplot() +
    geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), fill = cols$panel, colour = cols$border, linewidth = 0.6) +
    geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymax - header_h, ymax = ymax), fill = header_col, colour = NA) +
    annotate("text", x = (xmin + xmax) / 2, y = ymax - header_h / 2, label = title, fontface = "bold", size = 3.4, colour = "#FFFFFF") +
    annotate("text", x = xmin + 0.04 * (xmax - xmin), y = seq(ymax - header_h - 0.06 * (ymax - ymin), ymin + 0.05 * (ymax - ymin), length.out = length(body_lines)),
             label = body_lines, hjust = 0, size = 2.7, colour = cols$code, family = "mono", lineheight = 0.85)
}

# 1. Install steps ----------------------------------------------------------------
draw_install_steps <- function(path) {
  steps <- tibble::tibble(
    step = 1:3,
    title = c("Install R", "Install Posit Desktop", "Get this handbook"),
    body = c(
      "cran.r-project.org\nPick macOS or Windows\nRun installer → open R once",
      "posit.co/download\nChoose Desktop (free)\nFormerly RStudio Desktop",
      "Git clone or ZIP from GitHub\nUnzip to a folder you\nwill remember"
    ),
    x = c(0.5, 3.7, 6.9)
  )
  p <- ggplot() +
    xlim(0, 10) + ylim(0, 4) +
    geom_rect(data = steps, aes(xmin = x, xmax = x + 2.8, ymin = 0.4, ymax = 3.6),
              fill = cols$panel, colour = cols$border, linewidth = 0.7) +
    geom_rect(data = steps, aes(xmin = x, xmax = x + 2.8, ymin = 3.0, ymax = 3.6),
              fill = cols$teal, colour = NA) +
    geom_text(data = steps, aes(x = x + 0.25, y = 3.3, label = paste0("Step ", step)), hjust = 0, fontface = "bold", size = 3.2, colour = "#FFFFFF") +
    geom_text(data = steps, aes(x = x + 0.25, y = 2.65, label = title), hjust = 0, fontface = "bold", size = 3.6, colour = cols$accent) +
    geom_text(data = steps, aes(x = x + 0.25, y = 1.55, label = body), hjust = 0, size = 3, colour = cols$muted, lineheight = 0.9) +
    labs(
      title = "Install order (about 15 minutes)",
      subtitle = "Install R first, then Posit Desktop, then download the repository",
      caption = "Screens in this appendix are labelled schematics — your menus may look slightly different."
    ) +
    aa_theme()
  aa_save(p, "appendix_a_install_steps.png", 10, 4.2)
}

# 2. Four-pane layout -------------------------------------------------------------
draw_posit_layout <- function(path) {
  p_script <- aa_draw_pane(0.2, 5.8, 3.2, 9.6, "Source (Script)",
    c("Edit .R files here", "Highlight code → Run", "Cmd/Ctrl + Enter"))
  p_console <- aa_draw_pane(6.0, 9.8, 3.2, 9.6, "Console",
    c("> commands run here", "> source(\"R/00_setup.R\")", "Errors print here"))
  p_env <- aa_draw_pane(0.2, 5.8, 0.4, 2.9, "Environment / History",
    c("Objects you created", "Prior commands"))
  p_files <- aa_draw_pane(6.0, 9.8, 0.4, 2.9, "Files / Plots / Packages",
    c("Files: project tree", "Plots: graphics pane", "Packages: install tab"))

  layout <- (p_script | p_console) / (p_env | p_files) +
    plot_layout(heights = c(2.2, 1)) +
    plot_annotation(
      title = "Posit Desktop: four panes to know",
      subtitle = "File → Open Project… sets the working directory; use the Files pane to confirm you see R/ and data/",
      caption = "Pane sizes are draggable. If Plots is hidden, click the Plots tab in the lower-right stack.",
      theme = theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0.5, colour = cols$accent),
        plot.subtitle = element_text(size = 10, hjust = 0.5, colour = cols$muted),
        plot.caption = element_text(size = 8.5, hjust = 0.5, colour = cols$muted)
      )
    )
  ggsave(path, layout, width = 10, height = 7.2, dpi = 200, bg = "white")
}

# 3. Open project -----------------------------------------------------------------
draw_open_project <- function(path) {
  menu <- c(
    "File",
    "  Open Project…  ← choose this",
    "  Open File…",
    "  ---",
    "Session",
    "  Restart R"
  )
  tree <- c(
    "Breathing-Room-for-Statistics/",
    "  R/",
    "  data/",
    "  volume-01/",
    "  README.md"
  )
  p_menu <- ggplot() +
    xlim(0, 10) + ylim(0, 10) +
    geom_rect(aes(xmin = 0.3, xmax = 4.5, ymin = 0.5, ymax = 9.5), fill = cols$panel, colour = cols$border, linewidth = 0.7) +
    annotate("text", x = 0.55, y = seq(8.8, 3.2, length.out = length(menu)), label = menu, hjust = 0, size = 3.2,
             colour = ifelse(grepl("Open Project", menu), cols$right, cols$accent), fontface = ifelse(grepl("Open Project", menu), "bold", "plain"), family = "mono", lineheight = 0.9) +
    labs(title = "Menu", tag = "1") +
    aa_theme() +
    theme(plot.tag = element_text(face = "bold", size = 12, colour = cols$teal))

  p_pick <- ggplot() +
    xlim(0, 10) + ylim(0, 10) +
    geom_rect(aes(xmin = 0.3, xmax = 9.5, ymin = 0.5, ymax = 9.5), fill = cols$panel, colour = cols$border, linewidth = 0.7) +
    geom_rect(aes(xmin = 0.3, xmax = 9.5, ymin = 8.5, ymax = 9.5), fill = cols$highlight, colour = NA) +
    annotate("text", x = 0.55, y = 9.0, label = "Select folder: Breathing-Room-for-Statistics", hjust = 0, size = 3.3, fontface = "bold", colour = cols$accent) +
    annotate("text", x = 0.55, y = seq(7.5, 4.5, length.out = length(tree)), label = tree, hjust = 0, size = 3.1, colour = cols$code, family = "mono", lineheight = 0.9) +
    annotate("rect", xmin = 0.45, xmax = 4.2, ymin = 4.35, ymax = 7.65, fill = NA, colour = cols$right, linewidth = 1) +
    labs(title = "Project folder", tag = "2") +
    aa_theme() +
    theme(plot.tag = element_text(face = "bold", size = 12, colour = cols$teal))

  panel <- p_menu | p_pick +
    plot_annotation(
      title = "Open the handbook as a project",
      subtitle = "File → Open Project… → select the repository root (not a chapter subfolder)",
      caption = "Optional: place a .Rproj file in the root; Posit will remember the project next time.",
      theme = theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5, colour = cols$muted),
        plot.caption = element_text(size = 8.5, hjust = 0.5, colour = cols$muted)
      )
    )
  ggsave(path, panel, width = 10, height = 4.8, dpi = 200, bg = "white")
}

# 4. Files pane checklist ---------------------------------------------------------
draw_project_tree <- function(path) {
  good <- c(
    "Breathing-Room-for-Statistics/",
    "  R/              ← scripts",
    "  data/           ← CSV datasets",
    "  volume-01/      ← chapters & figures",
    "  README.md"
  )
  p <- ggplot() +
    xlim(0, 10) + ylim(0, 6) +
    geom_rect(aes(xmin = 0.4, xmax = 9.6, ymin = 0.5, ymax = 5.5), fill = cols$panel, colour = cols$border, linewidth = 0.8) +
    geom_rect(aes(xmin = 0.4, xmax = 9.6, ymin = 4.7, ymax = 5.5), fill = cols$teal, colour = NA) +
    annotate("text", x = 0.7, y = 5.1, label = "Files pane (lower right) — you should see:", hjust = 0, fontface = "bold", size = 3.5, colour = "#FFFFFF") +
    annotate("text", x = 0.7, y = seq(4.0, 1.4, length.out = length(good)), label = good, hjust = 0, size = 3.3, colour = cols$code, family = "mono", lineheight = 0.9) +
    annotate("segment", x = 0.65, xend = 5.5, y = 3.55, yend = 3.55, colour = cols$right, linewidth = 0.8, arrow = arrow(length = unit(0.15, "cm"), type = "closed")) +
    labs(
      title = "Sanity check: correct working directory",
      subtitle = "If R/ is missing, you opened the wrong folder or need File → Open Project… again",
      caption = "Tip: click R/ in the Files pane, then More → Set As Working Directory is never required when the project is open correctly."
    ) +
    aa_theme()
  aa_save(p, "appendix_a_project_tree.png", 8.5, 4.6)
}

# 5. First successful run -----------------------------------------------------------
draw_first_run <- function(path) {
  lines <- c(
    "> source(\"R/00_setup.R\")",
    "Project root: .../Breathing-Room-for-Statistics",
    "All required packages found.",
    "",
    "> source(\"R/examples/ch04_comparing_groups.R\")",
    "Writing tables to volume-01/tables/ ...",
    "Done."
  )
  p <- ggplot() +
    xlim(0, 10) + ylim(0, 6) +
    geom_rect(aes(xmin = 0.4, xmax = 9.6, ymin = 0.5, ymax = 5.5), fill = "#0F172A", colour = cols$border, linewidth = 0.6) +
    geom_rect(aes(xmin = 0.4, xmax = 9.6, ymin = 5.0, ymax = 5.5), fill = "#334155", colour = NA) +
    annotate("text", x = 0.65, y = 5.25, label = "Console", hjust = 0, fontface = "bold", size = 3.3, colour = "#E2E8F0") +
    annotate("text", x = 0.65, y = seq(4.5, 1.0, length.out = length(lines)), label = lines, hjust = 0, size = 3.1,
             colour = ifelse(grepl("All required|Done", lines), "#6EE7B7", "#E2E8F0"), family = "mono", lineheight = 0.88) +
    labs(
      title = "First successful run",
      subtitle = "Run setup, then one chapter script; green lines mean you are ready for Appendix B",
      caption = "If you see Install missing packages: … run the install.packages() block in Appendix A once."
    ) +
    aa_theme()
  aa_save(p, "appendix_a_first_run.png", 8.5, 4.8)
}

# 6. Wrong vs right working directory ---------------------------------------------
draw_wd_panel <- function(kind) {
  is_wrong <- kind == "wrong"
  title <- if (is_wrong) "Wrong: home folder open" else "Right: project root open"
  tag <- if (is_wrong) "Avoid" else "Prefer"
  tag_col <- if (is_wrong) cols$wrong else cols$right
  tree <- if (is_wrong) {
    c("Documents/", "  thesis.docx", "Downloads/", "Desktop/")
  } else {
    c("Breathing-Room-for-Statistics/", "  R/", "  data/", "  volume-01/")
  }
  err <- if (is_wrong) {
    "Error: cannot open file\n'R/00_setup.R': No such file"
  } else {
    "Project root: .../Breathing-Room-for-Statistics\nAll required packages found."
  }
  err_col <- if (is_wrong) "#FCA5A5" else "#6EE7B7"

  ggplot() +
    xlim(0, 10) + ylim(0, 10) +
    geom_rect(aes(xmin = 0.4, xmax = 9.6, ymin = 5.2, ymax = 9.4), fill = cols$panel, colour = cols$border, linewidth = 0.6) +
    annotate("text", x = 0.6, y = 8.9, label = "Files pane", hjust = 0, fontface = "bold", size = 3.2, colour = cols$accent) +
    annotate("text", x = 0.6, y = seq(8.0, 5.8, length.out = length(tree)), label = tree, hjust = 0, size = 2.9, family = "mono", colour = cols$code, lineheight = 0.9) +
    geom_rect(aes(xmin = 0.4, xmax = 9.6, ymin = 0.6, ymax = 4.8), fill = "#0F172A", colour = cols$border, linewidth = 0.6) +
    annotate("text", x = 0.6, y = 4.2, label = "Console", hjust = 0, fontface = "bold", size = 3.1, colour = "#CBD5E1") +
    annotate("text", x = 0.6, y = 2.5, label = err, hjust = 0, size = 2.8, colour = err_col, family = "mono", lineheight = 0.9) +
    labs(tag = tag) +
    aa_theme() +
    theme(plot.tag = element_text(face = "bold", size = 11, colour = tag_col, hjust = 0.5))
}

draw_wd_pair <- function(path) {
  panel <- draw_wd_panel("wrong") | draw_wd_panel("right") +
    plot_annotation(
      title = "Working directory: most common beginner mistake",
      caption = "Fix: File → Open Project… and select Breathing-Room-for-Statistics (the folder that contains R/).",
      theme = theme(
        plot.title = element_text(face = "bold", size = 13, hjust = 0.5),
        plot.caption = element_text(size = 8.5, hjust = 0.5, colour = cols$muted)
      )
    )
  ggsave(path, panel, width = 10, height = 4.6, dpi = 200, bg = "white")
}

# Generate all --------------------------------------------------------------------
draw_install_steps(file.path(fig_dir, "appendix_a_install_steps.png"))
draw_posit_layout(file.path(fig_dir, "appendix_a_posit_layout.png"))
draw_open_project(file.path(fig_dir, "appendix_a_open_project.png"))
draw_project_tree(file.path(fig_dir, "appendix_a_project_tree.png"))
draw_first_run(file.path(fig_dir, "appendix_a_first_run.png"))
draw_wd_pair(file.path(fig_dir, "appendix_a_wd_pair.png"))

message("Appendix A figures saved to ", fig_dir)
