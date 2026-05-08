

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

# Common theme for readability
my_theme <- theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 18, face = "bold"),
    plot.subtitle = element_text(size = 14),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 13),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 13),
    panel.grid.major = element_line(linewidth = 0.6),
    panel.grid.minor = element_line(linewidth = 0.3),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
    legend.key = element_rect(fill = "white", color = NA)
  )

# Figure 1: Risk score timeline
p1 <- ggplot(preds, aes(x = date, y = risk_score)) +
  geom_line(linewidth = 0.8) +
  geom_hline(yintercept = 0.66, linetype = "dashed", linewidth = 0.8) +
  labs(
    title = "Financial Risk Early-Warning Score",
    subtitle = "Random Forest predicted probability of future 21-day stress event",
    x = "Date",
    y = "Predicted Stress Probability"
  ) +
  my_theme

ggsave(
  "outputs/figures/risk_score_timeline.png",
  plot = p1,
  width = 12,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Figure 2: Risk regime classification
p2 <- ggplot(preds, aes(x = date, y = risk_score, color = risk_regime)) +
  geom_point(size = 2) +
  labs(
    title = "Risk Regime Classification",
    subtitle = "Low / Medium / High market-stress monitoring regimes",
    x = "Date",
    y = "Risk Score",
    color = "Risk Regime"
  ) +
  my_theme

ggsave(
  "outputs/figures/risk_regime_classification.png",
  plot = p2,
  width = 12,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Figure 3: Actual stress events vs risk score
p3 <- ggplot(preds, aes(x = date)) +
  geom_line(aes(y = risk_score), linewidth = 0.8) +
  geom_point(
    data = preds %>% filter(actual == 1),
    aes(y = risk_score),
    size = 2.5
  ) +
  labs(
    title = "Predicted Risk Score and Realized Stress Events",
    subtitle = "Dots show periods where the future 21-day drawdown-risk event occurred",
    x = "Date",
    y = "Risk Score"
  ) +
  my_theme

ggsave(
  "outputs/figures/stress_event_overlay.png",
  plot = p3,
  width = 12,
  height = 6,
  dpi = 300,
  bg = "white"
)

cat("Output generation completed successfully.\n")
cat("Created files:\n")
cat("outputs/alerts/high_risk_alerts.csv\n")
cat("outputs/tables/risk_regime_timeline.csv\n")
cat("outputs/figures/risk_score_timeline.png\n")
cat("outputs/figures/risk_regime_classification.png\n")
cat("outputs/figures/stress_event_overlay.png\n")