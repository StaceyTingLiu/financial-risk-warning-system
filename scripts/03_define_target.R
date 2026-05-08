
# Define future drawdown-risk target for early-warning prediction

library(dplyr)

prices <- read.csv("data/raw/etf_adjusted_prices.csv")
features <- read.csv("data/processed/features.csv")

prices$date <- as.Date(prices$date)
features$date <- as.Date(features$date)

# Prediction horizon: next 21 trading days
horizon <- 21

# Stress event definition:
# 1 means SPY experiences at least an 8% drawdown within the next 21 trading days
drawdown_threshold <- -0.08

future_drawdown <- rep(NA, nrow(prices))

for (i in 1:(nrow(prices) - horizon)) {
  current_price <- prices$SPY[i]
  future_prices <- prices$SPY[(i + 1):(i + horizon)]
  min_future_price <- min(future_prices, na.rm = TRUE)
  
  future_drawdown[i] <- min_future_price / current_price - 1
}

target_df <- data.frame(
  date = prices$date,
  future_drawdown_21 = future_drawdown,
  stress_event_21 = ifelse(future_drawdown <= drawdown_threshold, 1, 0)
)

dataset <- features %>%
  left_join(target_df, by = "date") %>%
  na.omit()

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

write.csv(
  dataset,
  "data/processed/model_dataset.csv",
  row.names = FALSE
)

cat("Target variable created successfully.\n")
cat("Model dataset saved to data/processed/model_dataset.csv\n")
cat("Number of observations:", nrow(dataset), "\n")
cat("Number of stress events:", sum(dataset$stress_event_21), "\n")
cat("Stress event rate:", round(mean(dataset$stress_event_21), 4), "\n")