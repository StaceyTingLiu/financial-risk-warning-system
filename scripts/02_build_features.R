
# Build leakage-safe financial risk features using only historical information

library(dplyr)
library(zoo)

prices <- read.csv("data/raw/etf_adjusted_prices.csv")
prices$date <- as.Date(prices$date)

returns <- prices
returns[-1] <- lapply(prices[-1], function(x) c(NA, diff(log(x))))

spy_ret <- returns$SPY

features <- data.frame(
  date = prices$date,
  spy_return = spy_ret,
  
  rv_21 = rollapply(
    spy_ret^2,
    width = 21,
    FUN = function(x) sqrt(sum(x, na.rm = TRUE)),
    fill = NA,
    align = "right"
  ),
  
  rv_42 = rollapply(
    spy_ret^2,
    width = 42,
    FUN = function(x) sqrt(sum(x, na.rm = TRUE)),
    fill = NA,
    align = "right"
  ),
  
  rv_63 = rollapply(
    spy_ret^2,
    width = 63,
    FUN = function(x) sqrt(sum(x, na.rm = TRUE)),
    fill = NA,
    align = "right"
  ),
  
  momentum_21 = prices$SPY / dplyr::lag(prices$SPY, 21) - 1,
  momentum_63 = prices$SPY / dplyr::lag(prices$SPY, 63) - 1,
  
  ma_gap_21 = prices$SPY / rollmean(prices$SPY, 21, fill = NA, align = "right") - 1,
  ma_gap_63 = prices$SPY / rollmean(prices$SPY, 63, fill = NA, align = "right") - 1,
  
  vxx_return = returns$VXX,
  tlt_return = returns$TLT,
  gld_return = returns$GLD,
  qqq_return = returns$QQQ,
  iwm_return = returns$IWM
)

features <- na.omit(features)

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

write.csv(
  features,
  "data/processed/features.csv",
  row.names = FALSE
)

cat("Features saved to data/processed/features.csv\n")