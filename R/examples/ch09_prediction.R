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
pred_vars <- c("smoking", "age", "fev1_percent_predicted", "prior_exacerbations")

set.seed(42)
idx <- sample(nrow(exac), floor(0.7 * nrow(exac)))
train <- exac[idx, ]
test <- exac[-idx, ]

# Helper: metrics at threshold 0.5
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

predict_test <- list()

# 1. Logistic regression
log_mod <- glm(form, data = train, family = binomial)
predict_test$logistic <- predict(log_mod, newdata = test, type = "response")

# 2. LASSO (glmnet)
x_train <- model.matrix(form, data = train)[, -1]
y_train <- train$exacerbation_12m
x_test <- model.matrix(form, data = test)[, -1]
cv_lasso <- glmnet::cv.glmnet(x_train, y_train, family = "binomial", alpha = 1)
predict_test$lasso <- as.vector(predict(cv_lasso, newx = x_test, s = "lambda.1se", type = "response"))

# 3. Classification tree
tree_mod <- rpart::rpart(form, data = train, method = "class",
                         control = rpart::rpart.control(cp = 0.01, minbucket = 10))
predict_test$tree <- predict(tree_mod, newdata = test, type = "prob")[, 2]

# 4. Random forest
rf_mod <- randomForest::randomForest(
  factor(exacerbation_12m) ~ smoking + age + fev1_percent_predicted + prior_exacerbations,
  data = train, ntree = 500
)
predict_test$random_forest <- predict(rf_mod, newdata = test, type = "prob")[, 2]

# --- Compare discrimination ---
results <- imap_dfr(predict_test, function(p, model) {
  roc_obj <- roc(test$exacerbation_12m, p, quiet = TRUE)
  tibble(
    model = model,
    auc = as.numeric(auc(roc_obj)),
    brier = brier(test$exacerbation_12m, p)
  )
})
print(results)

# --- Metrics at 0.5 for logistic ---
print(class_metrics(test$exacerbation_12m, predict_test$logistic))

# --- Calibration plot (logistic) — deciles ---
cal_df <- tibble(y = test$exacerbation_12m, pred = predict_test$logistic) %>%
  mutate(decile = ntile(pred, 10)) %>%
  group_by(decile) %>%
  summarise(
    mean_pred = mean(pred),
    obs_rate = mean(y),
    n = n(),
    .groups = "drop"
  )

p_cal <- ggplot(cal_df, aes(x = mean_pred, y = obs_rate)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey50") +
  geom_point(size = 3) +
  geom_line(linewidth = 0.8) +
  labs(
    x = "Mean predicted risk",
    y = "Observed event rate",
    title = "Calibration plot — logistic model (test set)"
  ) +
  coord_equal(xlim = c(0, max(cal_df$mean_pred) * 1.2), ylim = c(0, max(cal_df$obs_rate) * 1.2)) +
  theme_minimal(base_size = 12)

dir.create(file.path(paths$root, "volume-01", "figures"), showWarnings = FALSE, recursive = TRUE)
ggsave(file.path(paths$root, "volume-01", "figures", "ch09_calibration_logistic.png"),
       p_cal, width = 6, height = 5, dpi = 150)
print(p_cal)

# --- ROC overlay ---
roc_list <- imap(predict_test, ~ roc(test$exacerbation_12m, .x, quiet = TRUE))
if (requireNamespace("patchwork", quietly = TRUE)) {
  # simple AUC table already printed
}

message("Chapter 9 prediction shootout complete.")
