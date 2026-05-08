
# Generate figures, risk regimes, and high-risk alert outputs


library(dplyr)
library(ggplot2)

# -----------------------------
# 1. Read predictions
# -----------------------------
preds <- read.csv("outputs/tables/walkforward_predictions.csv")

preds$date <- as.Date(preds$date)

if ("train_end_date" %in% names(preds)) {
  preds$train_end_date <- as.Date(preds$train_end_date)
}

# Use Random Forest probability as the main risk score
preds$risk_score <- preds$rf_prob

# -----------------------------
# 2. Define risk regimes
# -----------------------------
preds$risk_regime <- cut(
  preds$risk_score,
  breaks = c(-Inf, 0.33, 0.66, Inf),
  labels = c("Low", "Medium", "High")
)

# Force order for legend/colors
preds$risk_regime <- factor(
  preds$risk_regime,
  levels = c("Low", "Medium", "High")
)

# -----------------------------
# 3. Save outputs
# -----------------------------
dir.create("outputs/alerts", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

alerts <- preds %>%
  filter(risk_regime == "High") %>%
  select(date, actual, risk_score, risk_regime, train_end_date)

write.csv(
  alerts,
  "outputs/alerts/high_risk_alerts.csv",
  row.names = FALSE
)

write.csv(
  preds,
  "outputs/tables/risk_regime_timeline.csv",
  row.names = FALSE
)

# -----------------------------
# 4. Helper: save readable PNG
# -----------------------------
save_plot_png <- function(plot_obj, filename, width = 14, height = 7, res = 300) {
  if (capabilities("cairo")) {
    png(
      filename = filename,
      width = width,
      height = height,
      units = "in",
      res = res,
      bg = "white",
      type = "cairo"
    )
  } else {
    png(
      filename = filename,
      width = width,
      height = height,
      units = "in",
      res = res,
      bg = "white"
    )
  }
  
  print(plot_obj)
  dev.off()
}

# -----------------------------
# 5. Common theme
# -----------------------------
my_theme <- theme_bw(base_size = 18) +
  theme(
    plot.title = element_text(size = 20, face = "bold", color = "black"),
    plot.subtitle = element_text(size = 15, color = "black"),
    axis.title = element_text(size = 16, face = "bold", color = "black"),
    axis.text = element_text(size = 14, color = "black"),
    legend.title = element_text(size = 15, face = "bold", color = "black"),
    legend.text = element_text(size = 14, color = "black"),
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = "black"),
    plot.background = element_rect(fill = "white", color = "white"),
    legend.background = element_rect(fill = "white", color = "white"),
    legend.key = element_rect(fill = "white", color = "white"),
    panel.grid.major = element_line(color = "grey85", linewidth = 0.7),
    panel.grid.minor = element_line(color = "grey92", linewidth = 0.4),
    axis.line = element_line(color = "black", linewidth = 0.6)
  )

# Set common y-axis upper bound
ymax <- max(0.75, max(preds$risk_score, na.rm = TRUE))

# -----------------------------
# 6. Figure 1: Risk score timeline
# -----------------------------
p1 <- ggplot(preds, aes(x = date, y = risk_score)) +
  geom_line(color = "steelblue4", linewidth = 1.0) +
  geom_hline(
    yintercept = 0.66,
    color = "firebrick",
    linetype = "dashed",
    linewidth = 0.9
  ) +
  labs(
    title = "Financial Risk Early-Warning Score",
    subtitle = "Random Forest predicted probability of future 21-day stress event",
    x = "Date",
    y = "Predicted Stress Probability"
  ) +
  scale_y_continuous(limits = c(0, ymax)) +
  my_theme

save_plot_png(
  plot_obj = p1,
  filename = "outputs/figures/risk_score_timeline.png",
  width = 14,
  height = 7,
  res = 300
)

# -----------------------------
# 7. Figure 2: Risk regime classification
# -----------------------------
p2 <- ggplot(preds, aes(x = date, y = risk_score, color = risk_regime)) +
  geom_point(size = 2.3, alpha = 0.85) +
  scale_color_manual(
    values = c(
      "Low" = "forestgreen",
      "Medium" = "darkorange",
      "High" = "red3"
    )
  ) +
  labs(
    title = "Risk Regime Classification",
    subtitle = "Low / Medium / High market-stress monitoring regimes",
    x = "Date",
    y = "Risk Score",
    color = "Risk Regime"
  ) +
  scale_y_continuous(limits = c(0, ymax)) +
  my_theme

save_plot_png(
  plot_obj = p2,
  filename = "outputs/figures/risk_regime_classification.png",
  width = 14,
  height = 7,
  res = 300
)

# -----------------------------
# 8. Figure 3: Stress-event overlay
# -----------------------------
event_points <- preds %>%
  filter(actual == 1)

p3 <- ggplot(preds, aes(x = date, y = risk_score)) +
  geom_line(color = "darkcyan", linewidth = 1.0) +
  geom_point(
    data = event_points,
    aes(x = date, y = risk_score),
    color = "red3",
    size = 2.8,
    alpha = 0.9
  ) +
  labs(
    title = "Predicted Risk Score and Realized Stress Events",
    subtitle = "Red dots mark periods where the future 21-day drawdown-risk event occurred",
    x = "Date",
    y = "Risk Score"
  ) +
  scale_y_continuous(limits = c(0, ymax)) +
  my_theme

save_plot_png(
  plot_obj = p3,
  filename = "outputs/figures/stress_event_overlay.png",
  width = 14,
  height = 7,
  res = 300
)

# -----------------------------
# 9. Console message
# -----------------------------
cat("Output generation completed successfully.\n")
cat("Created files:\n")
cat("outputs/alerts/high_risk_alerts.csv\n")
cat("outputs/tables/risk_regime_timeline.csv\n")
cat("outputs/figures/risk_score_timeline.png\n")
cat("outputs/figures/risk_regime_classification.png\n")
cat("outputs/figures/stress_event_overlay.png\n")