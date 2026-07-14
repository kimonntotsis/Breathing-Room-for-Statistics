source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(glmnet)

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

prot <- read_csv(file.path(paths$data, "proteomics_olink_like.csv"), show_col_types = FALSE)
feat <- names(prot)[grepl("^Prot_", names(prot))]

mat_raw <- prot %>%
  select(all_of(feat)) %>%
  as.matrix()

miss_frac <- colMeans(is.na(mat_raw))
feat_use <- names(sort(miss_frac))[1:min(200, length(feat))]
mat_raw <- mat_raw[, feat_use, drop = FALSE]

impute_train_medians <- function(x_train, x_test) {
  meds <- apply(x_train, 2, function(col) median(col, na.rm = TRUE))
  meds[is.na(meds)] <- 0
  imp <- function(x) {
    x2 <- x
    for (j in seq_along(meds)) {
      x2[, j][is.na(x2[, j])] <- meds[j]
    }
    x2
  }
  list(train = imp(x_train), test = imp(x_test), medians = meds)
}

y_all <- ifelse(prot$group == "case", 1L, 0L)

set.seed(42)
fold_id <- sample(rep(1:5, length.out = length(y_all)))
outer_folds <- split(seq_along(y_all), fold_id)

auc_vec <- function(y_true, p_hat) {
  o <- order(p_hat)
  y <- y_true[o]
  n1 <- sum(y == 1)
  n0 <- sum(y == 0)
  if (n1 == 0 || n0 == 0) return(NA_real_)
  ranks <- rank(p_hat[o], ties.method = "average")
  (sum(ranks[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

auc_outer <- map_dbl(outer_folds, function(test_idx) {
  train_idx <- setdiff(seq_along(y_all), test_idx)
  imp <- impute_train_medians(mat_raw[train_idx, , drop = FALSE], mat_raw[test_idx, , drop = FALSE])
  x_train <- imp$train
  x_test <- imp$test
  y_train <- y_all[train_idx]

  cv_fit <- cv.glmnet(
    x_train, y_train,
    family = "binomial",
    alpha = 0.5,
    nfolds = 5
  )
  pred <- predict(cv_fit, x_test, s = "lambda.min", type = "response")[, 1]
  auc_vec(y_all[test_idx], pred)
})

auc_summary <- tibble(
  fold = seq_along(auc_outer),
  auc = auc_outer
)
write_csv(auc_summary, file.path(tab_dir, "ch17_elastic_net_cv_auc.csv"))

mean_auc <- mean(auc_outer, na.rm = TRUE)

p_cv <- ggplot(auc_summary, aes(fold, auc)) +
  geom_col(fill = handbook_cols$intervention, alpha = 0.88, width = 0.62, colour = "white") +
  geom_hline(yintercept = mean_auc, linetype = "dashed", colour = handbook_cols$accent, linewidth = 0.8) +
  geom_text(
    aes(label = sprintf("%.2f", auc)),
    vjust = -0.35, size = 3.1, colour = "#475569"
  ) +
  scale_y_continuous(limits = c(0, 1), expand = expansion(mult = c(0, 0.08))) +
  labs(
    title = "Elastic net proteomics: nested CV AUC (CASTOR-HD)",
    subtitle = sprintf(
      "Mean outer-fold AUC = %.3f (%d proteins, median impute within folds)",
      mean_auc, length(feat_use)
    ),
    x = "Outer fold",
    y = "AUC"
  ) +
  handbook_theme(12)

handbook_save(p_cv, file.path(fig_dir, "ch17_elastic_net_nested_cv.png"), 7.0, 4.6)

message("Ch 17 elastic net: mean AUC = ", round(mean_auc, 3),
        " (p = ", length(feat_use), " proteins)")
