source("R/00_setup.R")

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

predict_test <- list()

# 1. Logistic regression
log_mod <- glm(form, data = train, family = binomial)
predict_test$logistic <- predict(log_mod, newdata = test, type = "response")

# 2. LASSO (glmnet): lambda chosen by CV on train only
x_train <- model.matrix(form, data = train)[, -1]
y_train <- train$exacerbation_12m
x_test <- model.matrix(form, data = test)[, -1]
cv_lasso <- glmnet::cv.glmnet(x_train, y_train, family = "binomial", alpha = 1)
predict_test$lasso <- as.vector(
  predict(cv_lasso, newx = x_test, s = "lambda.1se", type = "response")
)

# 3. Classification tree
tree_mod <- rpart::rpart(
  form, data = train, method = "class",
  control = rpart::rpart.control(cp = 0.01, minbucket = 10)
)
predict_test$tree <- predict(tree_mod, newdata = test, type = "prob")[, 2]

# 4. Random forest
rf_mod <- randomForest::randomForest(
  factor(exacerbation_12m) ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
  data = train, ntree = 500
)
predict_test$random_forest <- predict(rf_mod, newdata = test, type = "prob")[, 2]

# 5. Gradient boosting (optional)
if (requireNamespace("xgboost", quietly = TRUE)) {
  dtrain <- xgboost::xgb.DMatrix(data = x_train, label = y_train)
  dtest <- xgboost::xgb.DMatrix(data = x_test)
  xgb_mod <- xgboost::xgb.train(
    params = list(
      objective = "binary:logistic",
      eval_metric = "logloss",
      max_depth = 3,
      eta = 0.1,
      subsample = 0.8
    ),
    data = dtrain,
    nrounds = 100,
    verbose = 0
  )
  predict_test$xgboost <- predict(xgb_mod, dtest)
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

tab_dir <- file.path(paths$root, "volume-01", "tables")
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)
readr::write_csv(results, file.path(tab_dir, "ch09_model_comparison.csv"))

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

p_cal <- ggplot(cal_df, aes(x = mean_pred, y = obs_rate)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey50") +
  geom_errorbar(
    aes(ymin = pmax(0, obs_rate - se), ymax = pmin(1, obs_rate + se)),
    width = 0.008, linewidth = 0.6, colour = "grey30"
  ) +
  geom_point(aes(size = n), colour = "#1f4e79") +
  scale_size_continuous(
    range = c(3, 8),
    breaks = sort(unique(cal_df$n)),
    labels = sort(unique(cal_df$n))
  ) +
  labs(
    x = "Mean predicted risk",
    y = "Observed event rate",
    title = "Calibration plot: logistic model (test set)",
    subtitle = sprintf(
      "%d events in test set (n = %d); %d risk bins",
      n_events_test, n_test, n_bins
    )
  ) +
  coord_cartesian(xlim = c(0, axis_max), ylim = c(0, axis_max)) +
  theme_minimal(base_size = 12)

fig_dir <- file.path(paths$root, "volume-01", "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
ggsave(
  file.path(fig_dir, "ch09_calibration_logistic.png"),
  p_cal, width = 6, height = 5, dpi = 150
)

message("Chapter 9 prediction shootout complete.")
message("Table: volume-01/tables/ch09_model_comparison.csv")
