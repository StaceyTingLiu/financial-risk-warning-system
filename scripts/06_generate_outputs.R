
# Generate figures, risk regimes, and high-risk alert outputs

library(dplyr)
library(ggplot2)

preds <- read.csv("outputs/tables/walkforward_predictions.csv")
preds$date <- as.Date(preds$date)

# Use Random Forest probability as the main risk score
preds$risk_score <- preds$rf_prob

# Define risk regimes
preds$risk_regime <- cut(
  preds$risk_score,
  breaks = c(-Inf, 0.33, 0.66, Inf),
  labels = c("Low", "Medium", "High")
)

# Save high-risk alerts
alerts <- preds %>%
  filter(risk_regime == "High") %>%
  select(date, actual, risk_score, risk_regime, train_end_date)

dir.create("outputs/alerts", recursive = TRUE, showWarnings = FALSE)

write.csv(
  alerts,
  "outputs/alerts/high_risk_alerts.csv",
  row.names = FALSE
)

# Save risk-regime dataset
write.csv(
  preds,
  "outputs/tables/risk_regime_timeline.csv",
  row.names = FALSE
)

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

# Figure 1: Risk score timeline
p1 <- ggplot(preds, aes(x = date, y = risk_score)) +
  geom_line() +
  geom_hline(yintercept = 0.66, linetype = "dashed") +
  labs(
    title = "Financial Risk Early-Warning Score",
    subtitle = "Random Forest predicted probability of future 21-day stress event",
    x = "Date",
    y = "Predicted Stress Probability"
  ) +
  theme_minimal()

ggsave(
  "outputs/figures/risk_score_timeline.png",
  p1,
  width = 10,
  height = 5
)

# Figure 2: Risk regime classification
p2 <- ggplot(preds, aes(x = date, y = risk_score, color = risk_regime)) +
  geom_point(size = 1.5) +
  labs(
    title = "Risk Regime Classification",
    subtitle = "Low / Medium / High market-stress monitoring regimes",
    x = "Date",
    y = "Risk Score",
    color = "Risk Regime"
  ) +
  theme_minimal()

ggsave(
  "outputs/figures/risk_regime_classification.png",
  p2,
  width = 10,
  height = 5
)

# Figure 3: Actual stress events vs risk score
p3 <- ggplot(preds, aes(x = date)) +
  geom_line(aes(y = risk_score)) +
  geom_point(
    data = preds %>% filter(actual == 1),
    aes(y = risk_score),
    size = 2
  ) +
  labs(
    title = "Predicted Risk Score and Realized Stress Events",
    subtitle = "Dots show periods where the future 21-day drawdown-risk event occurred",
    x = "Date",
    y = "Risk Score"
  ) +
  theme_minimal()

ggsave(
  "outputs/figures/stress_event_overlay.png",
  p3,
  width = 10,
  height = 5
)

cat("Output generation completed successfully.\n")
cat("Created files:\n")
cat("outputs/alerts/high_risk_alerts.csv\n")
cat("outputs/tables/risk_regime_timeline.csv\n")
cat("outputs/figures/risk_score_timeline.png\n")
cat("outputs/figures/risk_regime_classification.png\n")
cat("outputs/figures/stress_event_overlay.png\n")