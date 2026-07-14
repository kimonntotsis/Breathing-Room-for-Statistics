source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(cluster)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# Adjusted Rand index (agreement of two partitions; 0 = chance, 1 = perfect)
adjusted_rand <- function(x, y) {
  x <- as.integer(factor(x))
  y <- as.integer(factor(y))
  n <- length(x)
  tab <- table(x, y)
  sum_comb <- function(v) sum(choose(v, 2))
  a <- sum_comb(tab)
  b <- sum_comb(rowSums(tab))
  c <- sum_comb(colSums(tab))
  d <- choose(n, 2)
  if (d == 0) return(NA_real_)
  (a - b * c / d) / ((b + c) / 2 - b * c / d)
}

# Map bootstrap cluster labels to reference partition (avoids label switching)
align_labels <- function(ref, boot) {
  ref <- as.integer(factor(ref))
  boot <- as.integer(factor(boot))
  k_vals <- sort(unique(boot))
  mapping <- integer(max(k_vals))
  for (b in k_vals) {
    tab <- table(ref[boot == b])
    mapping[b] <- as.integer(names(which.max(tab)))
  }
  mapping[boot]
}

# Per-patient bootstrap cluster stability (Hennig-style item stability)
bootstrap_item_stability <- function(X, k = 2, B = 300, nstart = 10) {
  n <- nrow(X)
  fit <- kmeans(X, centers = k, nstart = 25)
  cl_orig <- fit$cluster
  agree <- numeric(n)
  appear <- numeric(n)
  for (b in seq_len(B)) {
    idx <- sample.int(n, n, replace = TRUE)
    boot <- kmeans(X[idx, , drop = FALSE], centers = k, nstart = nstart)
    cl_boot <- align_labels(cl_orig[idx], boot$cluster)
    for (i in unique(idx)) {
      wh <- which(idx == i)
      appear[i] <- appear[i] + 1
      if (cl_boot[wh[1]] == cl_orig[i]) agree[i] <- agree[i] + 1
    }
  }
  agree / pmax(appear, 1)
}

omics <- read_csv(file.path(paths$data, "marker_panel.csv"), show_col_types = FALSE)
X <- as.matrix(scale(omics %>% select(starts_with("M"))))

set.seed(2)
k <- 2

# --- k-means -------------------------------------------------------------------
km <- kmeans(X, centers = k, nstart = 25)
message("k-means vs true_phenotype (teaching only):")
print(table(Predicted = km$cluster, True = omics$true_phenotype))

pca11 <- prcomp(X, center = FALSE, scale. = FALSE)
pca_df <- tibble(
  PC1 = pca11$x[, 1],
  PC2 = pca11$x[, 2],
  cluster = factor(km$cluster),
  true_phenotype = omics$true_phenotype
)

p_km <- plot_cluster_pca(
  pca_df,
  label = "true_phenotype",
  title = "CASTOR: k-means (k = 2) on marker panel",
  subtitle = "Colour = cluster assignment; shape = true phenotype (teaching only)",
  xlab = sprintf("PC1 (%.0f%%)", 100 * summary(pca11)$importance[2, 1]),
  ylab = sprintf("PC2 (%.0f%%)", 100 * summary(pca11)$importance[2, 2])
)
handbook_save(p_km, file.path(fig_dir, "ch11_kmeans_clusters.png"), 7.4, 5.2)

# --- Silhouette for k = 2:6 ----------------------------------------------------
sil <- sapply(2:6, function(kk) {
  cl <- kmeans(X, centers = kk, nstart = 25)$cluster
  mean(silhouette(cl, dist(X))[, 3])
})
names(sil) <- 2:6
message("Mean silhouette by k:")
print(round(sil, 3))

sil_df <- tibble(k = as.integer(names(sil)), silhouette = as.numeric(sil))
p_sil <- ggplot(sil_df, aes(k, silhouette)) +
  geom_col(fill = handbook_cols$intervention, alpha = 0.82, width = 0.65) +
  geom_line(colour = handbook_cols$accent, linewidth = 0.9, group = 1) +
  geom_point(size = 2.8, colour = handbook_cols$accent) +
  scale_x_continuous(breaks = 2:6) +
  labs(
    title = "CASTOR: mean silhouette width by k",
    subtitle = "Peak suggests plausible k; confirm with stability and biology",
    x = "Number of clusters (k)", y = "Mean silhouette"
  ) +
  handbook_theme()
handbook_save(p_sil, file.path(fig_dir, "ch11_silhouette_k.png"), 6.4, 4.2)

# --- Hierarchical + PAM --------------------------------------------------------
hc <- hclust(dist(X), method = "ward.D2")
cl_hc <- cutree(hc, k = k)
pam_fit <- pam(X, k = k)
cl_pam <- pam_fit$clustering

# --- Method shootout -----------------------------------------------------------
shootout <- tibble(
  comparison = c(
    "k-means vs hierarchical",
    "k-means vs PAM",
    "hierarchical vs PAM",
    "k-means vs true_phenotype (teaching)",
    "k-means vs processing_batch"
  ),
  adjusted_RI = c(
    adjusted_rand(km$cluster, cl_hc),
    adjusted_rand(km$cluster, cl_pam),
    adjusted_rand(cl_hc, cl_pam),
    adjusted_rand(km$cluster, omics$true_phenotype),
    adjusted_rand(km$cluster, omics$processing_batch)
  )
)
message("Method shootout (adjusted Rand index):")
print(shootout)

# --- Bootstrap stability -------------------------------------------------------
set.seed(42)
item_stab <- bootstrap_item_stability(X, k = k, B = 200)
message(sprintf(
  "Bootstrap item stability: mean = %.2f, min = %.2f",
  mean(item_stab), min(item_stab)
))

# --- Cluster on 5 PCs vs all markers -------------------------------------------
pca <- prcomp(X, center = FALSE, scale. = FALSE)
X_pc5 <- pca$x[, 1:5, drop = FALSE]
km_pc <- kmeans(X_pc5, centers = k, nstart = 25)$cluster
message(sprintf(
  "k-means on 5 PCs vs all markers: ARI = %.3f",
  adjusted_rand(km$cluster, km_pc)
))

# --- Batch confounding check ---------------------------------------------------
message("Cluster vs processing batch (watch for technical confounding):")
print(table(Cluster = km$cluster, Batch = omics$processing_batch))

# --- Cluster profiles (mean z-scored M1–M5) ------------------------------------
profile <- omics %>%
  mutate(cluster = factor(km$cluster)) %>%
  select(cluster, M1:M5) %>%
  pivot_longer(-cluster, names_to = "marker", values_to = "value") %>%
  group_by(cluster, marker) %>%
  summarise(mean_value = mean(value), .groups = "drop")

p_prof <- plot_radar(
  profile, "cluster", "marker", "mean_value",
  title = "Radar profiles: mean marker levels by cluster",
  subtitle = "Spider plot on z-scored M1–M5 (teaching only)"
)
handbook_save(p_prof, file.path(fig_dir, "ch11_cluster_profiles.png"), 6.8, 5.4)

p_heat <- plot_profile_heatmap(
  profile, "cluster", "marker", "mean_value",
  title = "Cluster centroid heatmap (M1–M5)",
  subtitle = "Complements radar; easier to read small differences"
)
handbook_save(p_heat, file.path(fig_dir, "ch11_cluster_heatmap.png"), 6.2, 3.8)

# --- Dendrogram (Ward.D2) ----------------------------------------------------
p_dend <- plot_dendrogram_handbook(
  hc, k = k,
  title = "CASTOR: hierarchical clustering (Ward.D2)",
  subtitle = "Dashed line = k = 2 cut; compare with k-means partition"
)
handbook_save(p_dend, file.path(fig_dir, "ch11_dendrogram.png"), 8.2, 4.6)

message("Chapter 11 clustering complete. Figures saved to volume-01/figures/.")
