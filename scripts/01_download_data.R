


# 01_download_data.R
# Download ETF adjusted prices for the financial risk warning system

library(quantmod)

symbols <- c(
  "SPY", "QQQ", "IWM", "TLT", "GLD", "VXX",
  "XLC", "XLY", "XLP", "XLE", "XLF", "XLV",
  "XLI", "XLK", "XLB", "XLU", "XLRE"
)

start_date <- "2015-01-01"
end_date <- Sys.Date()

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

getSymbols(symbols, src = "yahoo", from = start_date, to = end_date)

price_list <- list()

for (sym in symbols) {
  adjusted_price <- Ad(get(sym))
  colnames(adjusted_price) <- sym
  price_list[[sym]] <- adjusted_price
}

prices <- do.call(merge, price_list)
prices <- na.omit(prices)

write.csv(
  data.frame(date = index(prices), coredata(prices)),
  "data/raw/etf_adjusted_prices.csv",
  row.names = FALSE
)

cat("Data downloaded successfully.\n")