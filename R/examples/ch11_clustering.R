source("R/00_setup.R")

library(tidyverse)
library(cluster)

if (!requireNamespace("factoextra", quietly = TRUE)) {
  stop("Install factoextra: install.packages('factoextra')")
}

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

p_km <- factoextra::fviz_cluster(
  km, data = X, geom = "point",
  habillage = omics$true_phenotype, palette = "jco",
  main = "CASTOR: k-means (k = 2) coloured by true phenotype"
)
ggsave(file.path(fig_dir, "ch11_kmeans_clusters.png"), p_km, width = 7, height = 5, dpi = 120)

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
  geom_line() + geom_point(size = 2) +
  scale_x_continuous(breaks = 2:6) +
  labs(
    title = "CASTOR: mean silhouette width by k",
    x = "Number of clusters (k)", y = "Mean silhouette"
  )
ggsave(file.path(fig_dir, "ch11_silhouette_k.png"), p_sil, width = 6, height = 4, dpi = 120)

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

p_prof <- ggplot(profile, aes(marker, mean_value, fill = cluster)) +
  geom_col(position = "dodge") +
  labs(
    title = "CASTOR: mean marker levels by k-means cluster (M1–M5)",
    x = NULL, y = "Mean (z-scored)", fill = "Cluster"
  )
ggsave(file.path(fig_dir, "ch11_cluster_profiles.png"), p_prof, width = 7, height = 4, dpi = 120)

# --- Dendrogram (sample if needed — n=120 is fine) -----------------------------
png(file.path(fig_dir, "ch11_dendrogram.png"), width = 800, height = 500, res = 120)
plot(hc, labels = FALSE, main = "CASTOR: hierarchical clustering (Ward.D2)")
rect.hclust(hc, k = k, border = "red")
dev.off()

message("Chapter 11 clustering complete. Figures saved to volume-01/figures/.")
