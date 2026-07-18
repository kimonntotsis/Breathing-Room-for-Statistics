source("R/00_setup.R")
source("R/viz_handbook.R")

library(tidyverse)
library(broom)
library(pROC)
library(ggplot2)

exac <- read_csv(file.path(paths$data, "exacerbation.csv"), show_col_types = FALSE) %>%
  mutate(
    exacerbation_12m = as.integer(exacerbation_12m),
    smoking = as.integer(smoking)
  )

form <- exacerbation_12m ~ smoking + age + fev1_percent_predicted + prior_exacerbations

fig_dir <- file.path(paths$root, "volume-01", "figures")
tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

set.seed(42)
idx <- sample(nrow(exac), floor(0.7 * nrow(exac)))
train <- exac[idx, ]
test <- exac[-idx, ]

n_events_train <- sum(train$exacerbation_12m)
n_events_test <- sum(test$exacerbation_12m)
epv <- n_events_train / 4

message(sprintf(
  "CASTOR Ch 9: train n=%d (%d events), test n=%d (%d events), EPV≈%.1f",
  nrow(train), n_events_train, nrow(test), n_events_test, epv
))
message(
  "Teaching note: a single 70/30 split with few test events is unstable; ",
  "tuning uses 5-fold CV on train only; treat test metrics as illustrative."
)

class_metrics <- function(y, p, threshold = 0.5) {
  pred <- as.integer(p >= threshold)
  tp <- sum(pred == 1 & y == 1)
  tn <- sum(pred == 0 & y == 0)
  fp <- sum(pred == 1 & y == 0)
  fn <- sum(pred == 0 & y == 1)
  tibble(
    threshold = threshold,
    sensitivity = tp / (tp + fn),
    specificity = tn / (tn + fp),
    ppv = tp / (tp + fp),
    npv = tn / (tn + fn),
    accuracy = (tp + tn) / length(y)
  )
}

brier <- function(y, p) mean((y - p)^2)

auc_with_boot_ci <- function(y, p, B = 500, seed = 42) {
  if (length(unique(y)) < 2) {
    return(tibble(auc = NA_real_, auc_lo = NA_real_, auc_hi = NA_real_))
  }
  roc_obj <- roc(y, p, quiet = TRUE)
  auc_val <- as.numeric(auc(roc_obj))
  set.seed(seed)
  n <- length(y)
  boots <- numeric(0)
  for (b in seq_len(B)) {
    idx_b <- sample(n, n, replace = TRUE)
    y_b <- y[idx_b]
    if (length(unique(y_b)) < 2) next
    boots <- c(boots, as.numeric(auc(roc(y_b, p[idx_b], quiet = TRUE))))
  }
  if (length(boots) < 50) {
    return(tibble(auc = auc_val, auc_lo = NA_real_, auc_hi = NA_real_))
  }
  tibble(
    auc = auc_val,
    auc_lo = unname(quantile(boots, 0.025)),
    auc_hi = unname(quantile(boots, 0.975))
  )
}

cv_auc <- function(y, X, fit_fun, pred_fun, K = 5, seed = 42) {
  if (length(unique(y)) < 2) return(NA_real_)
  set.seed(seed)
  folds <- sample(rep(seq_len(K), length.out = length(y)))
  aucs <- numeric(0)
  for (k in seq_len(K)) {
    tr <- folds != k
    va <- folds == k
    if (length(unique(y[tr])) < 2 || length(unique(y[va])) < 2) next
    fit <- fit_fun(X[tr, , drop = FALSE], y[tr])
    p <- pred_fun(fit, X[va, , drop = FALSE])
    aucs <- c(aucs, as.numeric(auc(roc(y[va], p, quiet = TRUE))))
  }
  if (length(aucs) == 0) NA_real_ else mean(aucs)
}

x_train <- model.matrix(form, data = train)[, -1, drop = FALSE]
y_train <- train$exacerbation_12m
x_test <- model.matrix(form, data = test)[, -1, drop = FALSE]

predict_test <- list()

# 1. Logistic regression (no tuning)
log_mod <- glm(form, data = train, family = binomial)
predict_test$logistic <- predict(log_mod, newdata = test, type = "response")

# 2. LASSO: lambda by 5-fold CV on train
cv_lasso <- glmnet::cv.glmnet(x_train, y_train, family = "binomial", alpha = 1, nfolds = 5)
predict_test$lasso <- as.vector(
  predict(cv_lasso, newx = x_test, s = "lambda.1se", type = "response")
)

# 3. Classification tree: tune cp with 5-fold CV on train
cp_grid <- seq(0.001, 0.05, by = 0.005)
tree_cps <- vapply(cp_grid, function(cp) {
  cv_auc(
    y_train, x_train,
    fit_fun = function(X, y) {
      df <- as.data.frame(X)
      df$y <- factor(y)
      f <- as.formula(paste("y ~", paste(colnames(X), collapse = " + ")))
      rpart::rpart(f, data = df, method = "class",
                   control = rpart::rpart.control(cp = cp, minbucket = 10))
    },
    pred_fun = function(fit, Xnew) {
      predict(fit, as.data.frame(Xnew), type = "prob")[, 2]
    },
    K = 5, seed = 42
  )
}, numeric(1))
best_cp <- cp_grid[which.max(replace(tree_cps, is.na(tree_cps), -Inf))]
tree_mod <- rpart::rpart(
  form, data = train, method = "class",
  control = rpart::rpart.control(cp = best_cp, minbucket = 10)
)
predict_test$tree <- predict(tree_mod, newdata = test, type = "prob")[, 2]
message("Tree: cp tuned on train CV = ", signif(best_cp, 3))

# 4. Random forest: tune mtry with 5-fold CV on train
mtry_grid <- seq_len(ncol(x_train))
rf_mtry <- vapply(mtry_grid, function(m) {
  cv_auc(
    y_train, x_train,
    fit_fun = function(X, y) {
      randomForest::randomForest(x = X, y = factor(y), mtry = m, ntree = 300)
    },
    pred_fun = function(fit, Xnew) {
      predict(fit, Xnew, type = "prob")[, 2]
    },
    K = 5, seed = 42
  )
}, numeric(1))
best_mtry <- mtry_grid[which.max(replace(rf_mtry, is.na(rf_mtry), -Inf))]
rf_mod <- randomForest::randomForest(
  x = x_train, y = factor(y_train), mtry = best_mtry, ntree = 500
)
predict_test$random_forest <- predict(rf_mod, newdata = x_test, type = "prob")[, 2]
message("Random forest: mtry tuned on train CV = ", best_mtry)

# 5. Gradient boosting: small grid tuned on train CV
if (requireNamespace("xgboost", quietly = TRUE)) {
  xgb_grid <- expand.grid(max_depth = c(2, 3), eta = c(0.05, 0.1), stringsAsFactors = FALSE)
  xgb_scores <- apply(xgb_grid, 1, function(row) {
    cv_auc(
      y_train, x_train,
      fit_fun = function(X, y) {
        d <- xgboost::xgb.DMatrix(data = X, label = y)
        xgboost::xgb.train(
          params = list(objective = "binary:logistic", eval_metric = "logloss",
                        max_depth = as.integer(row["max_depth"]), eta = as.numeric(row["eta"]),
                        subsample = 0.8),
          data = d, nrounds = 100, verbose = 0
        )
      },
      pred_fun = function(fit, Xnew) {
        predict(fit, xgboost::xgb.DMatrix(data = Xnew))
      },
      K = 5, seed = 42
    )
  })
  best_xgb <- xgb_grid[which.max(replace(xgb_scores, is.na(xgb_scores), -Inf)), ]
  dtrain <- xgboost::xgb.DMatrix(data = x_train, label = y_train)
  dtest <- xgboost::xgb.DMatrix(data = x_test)
  xgb_mod <- xgboost::xgb.train(
    params = list(
      objective = "binary:logistic", eval_metric = "logloss",
      max_depth = as.integer(best_xgb$max_depth), eta = as.numeric(best_xgb$eta),
      subsample = 0.8
    ),
    data = dtrain, nrounds = 100, verbose = 0
  )
  predict_test$xgboost <- predict(xgb_mod, dtest)
  message("XGBoost: tuned max_depth = ", best_xgb$max_depth, ", eta = ", best_xgb$eta)
} else {
  message("Optional: install.packages('xgboost') for gradient boosting in the shootout.")
}

results <- imap_dfr(predict_test, function(p, model) {
  auc_with_boot_ci(test$exacerbation_12m, p) %>%
    mutate(
      model = model,
      brier = brier(test$exacerbation_12m, p),
      .before = 1
    )
})
print(results)

readr::write_csv(results, file.path(tab_dir, "ch09_model_comparison.csv"))

results_plot <- results %>%
  mutate(
    model = recode(model,
      logistic = "Logistic",
      lasso = "LASSO",
      tree = "Tree",
      random_forest = "Random forest",
      xgboost = "XGBoost"
    )
  )

p_auc <- plot_metric_dotplot(
  results_plot,
  y = "model",
  x = "auc",
  xmin = 0.35,
  title = "Test-set AUC by model (bootstrap CI)",
  subtitle = sprintf(
    "%d events in test set; tuning by 5-fold CV on train; constant models sit at 0.5",
    n_events_test
  ),
  xlab = "AUC (95% bootstrap CI)"
)

handbook_save(p_auc, file.path(fig_dir, "ch09_model_comparison.png"), 7.4, 4.2)

logistic_metrics <- class_metrics(test$exacerbation_12m, predict_test$logistic)
print(logistic_metrics)

# Calibration plot (logistic), adaptive bins for sparse events
n_test <- nrow(test)
n_bins <- if (n_events_test < 15) 3L else max(4L, min(5L, floor(n_test / 25L)))

cal_df <- tibble(y = test$exacerbation_12m, pred = predict_test$logistic) %>%
  mutate(bin = ntile(pred, n_bins)) %>%
  group_by(bin) %>%
  summarise(
    mean_pred = mean(pred),
    obs_rate = mean(y),
    n = n(),
    events = sum(y),
    se = sqrt(pmax(obs_rate * (1 - obs_rate) / n, 1e-6)),
    .groups = "drop"
  )

axis_max <- max(0.15, cal_df$mean_pred, cal_df$obs_rate + cal_df$se, na.rm = TRUE) * 1.15

p_cal <- plot_calibration(
  cal_df,
  pred = "mean_pred",
  obs = "obs_rate",
  n = "n",
  se = "se",
  title = "Calibration plot: logistic model (test set)",
  subtitle = sprintf(
    "%d events in test set (n = %d); %d risk bins; points sized by n",
    n_events_test, n_test, n_bins
  ),
  axis_max = axis_max
)

handbook_save(
  p_cal,
  file.path(fig_dir, "ch09_calibration_logistic.png"),
  6.8, 5.2
)

message("Chapter 9 prediction shootout complete.")
message("Table: volume-01/tables/ch09_model_comparison.csv")
