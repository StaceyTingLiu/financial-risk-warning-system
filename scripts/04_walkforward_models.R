
# 04_walkforward_models.R
# Leakage-safe walk-forward model training
# Models: Logistic Regression, Random Forest, XGBoost

library(dplyr)
library(randomForest)
library(xgboost)

dataset <- read.csv("data/processed/model_dataset.csv")
dataset$date <- as.Date(dataset$date)

feature_cols <- c(
  "spy_return",
  "rv_21", "rv_42", "rv_63",
  "momentum_21", "momentum_63",
  "ma_gap_21", "ma_gap_63",
  "vxx_return", "tlt_return", "gld_return",
  "qqq_return", "iwm_return"
)

target_col <- "stress_event_21"

# Walk-forward settings
initial_train_size <- 1000
test_window <- 63

results <- data.frame()

for (start_idx in seq(initial_train_size, nrow(dataset) - test_window, by = test_window)) {
  
  train_data <- dataset[1:start_idx, ]
  test_data <- dataset[(start_idx + 1):(start_idx + test_window), ]
  
  x_train <- train_data[, feature_cols]
  y_train <- train_data[, target_col]
  
  x_test <- test_data[, feature_cols]
  y_test <- test_data[, target_col]
  
  # Leakage-safe scaling:
  # mean and sd are calculated only from training data
  train_mean <- sapply(x_train, mean, na.rm = TRUE)
  train_sd <- sapply(x_train, sd, na.rm = TRUE)
  
  # Avoid division by zero
  train_sd[train_sd == 0] <- 1
  
  x_train_scaled <- as.data.frame(scale(x_train, center = train_mean, scale = train_sd))
  x_test_scaled <- as.data.frame(scale(x_test, center = train_mean, scale = train_sd))
  
  train_model_df <- data.frame(
    stress_event_21 = y_train,
    x_train_scaled
  )
  
  test_model_df <- data.frame(
    stress_event_21 = y_test,
    x_test_scaled
  )
  
  # -----------------------------
  # Model 1: Logistic Regression
  # -----------------------------
  logit_model <- glm(
    stress_event_21 ~ .,
    data = train_model_df,
    family = binomial
  )
  
  logit_prob <- predict(
    logit_model,
    newdata = test_model_df,
    type = "response"
  )
  
  # -----------------------------
  # Model 2: Random Forest
  # -----------------------------
  rf_model <- randomForest(
    as.factor(stress_event_21) ~ .,
    data = train_model_df,
    ntree = 300
  )
  
  rf_prob <- predict(
    rf_model,
    newdata = test_model_df,
    type = "prob"
  )[, 2]
  
  # -----------------------------
  # Model 3: XGBoost
  # -----------------------------
  xgb_train <- xgb.DMatrix(
    data = as.matrix(x_train_scaled),
    label = y_train
  )
  
  xgb_test <- xgb.DMatrix(
    data = as.matrix(x_test_scaled),
    label = y_test
  )
  
  xgb_params <- list(
    objective = "binary:logistic",
    eval_metric = "logloss",
    max_depth = 3,
    eta = 0.05,
    subsample = 0.8,
    colsample_bytree = 0.8
  )
  
  xgb_model <- xgb.train(
    params = xgb_params,
    data = xgb_train,
    nrounds = 100,
    verbose = 0
  )
  
  xgb_prob <- predict(
    xgb_model,
    newdata = xgb_test
  )
  
  # -----------------------------
  # Save fold results
  # -----------------------------
  fold_results <- data.frame(
    date = test_data$date,
    actual = y_test,
    logit_prob = logit_prob,
    rf_prob = rf_prob,
    xgb_prob = xgb_prob,
    train_end_date = train_data$date[nrow(train_data)]
  )
  
  results <- rbind(results, fold_results)
  
  cat("Finished fold ending at:", as.character(train_data$date[nrow(train_data)]), "\n")
}

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

write.csv(
  results,
  "outputs/tables/walkforward_predictions.csv",
  row.names = FALSE
)

cat("Walk-forward model predictions saved successfully.\n")
cat("Output file: outputs/tables/walkforward_predictions.csv\n")
cat("Number of prediction rows:", nrow(results), "\n")
cat("Models included: Logistic Regression, Random Forest, XGBoost\n")