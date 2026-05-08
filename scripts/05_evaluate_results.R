
# Evaluate model warning performance

library(dplyr)
library(pROC)
library(PRROC)

preds <- read.csv("outputs/tables/walkforward_predictions.csv")
preds$date <- as.Date(preds$date)

evaluate_model <- function(actual, prob, model_name) {
  
  roc_obj <- roc(actual, prob, quiet = TRUE)
  roc_auc <- as.numeric(auc(roc_obj))
  
  pr_obj <- pr.curve(
    scores.class0 = prob[actual == 1],
    scores.class1 = prob[actual == 0],
    curve = TRUE
  )
  
  threshold <- quantile(prob, 0.90, na.rm = TRUE)
  alert <- ifelse(prob >= threshold, 1, 0)
  
  true_positive <- sum(alert == 1 & actual == 1)
  false_positive <- sum(alert == 1 & actual == 0)
  false_negative <- sum(alert == 0 & actual == 1)
  true_negative <- sum(alert == 0 & actual == 0)
  
  hit_rate <- ifelse(
    true_positive + false_negative == 0,
    NA,
    true_positive / (true_positive + false_negative)
  )
  
  precision <- ifelse(
    true_positive + false_positive == 0,
    NA,
    true_positive / (true_positive + false_positive)
  )
  
  false_alarm_rate <- ifelse(
    false_positive + true_negative == 0,
    NA,
    false_positive / (false_positive + true_negative)
  )
  
  data.frame(
    model = model_name,
    roc_auc = round(roc_auc, 4),
    pr_auc = round(pr_obj$auc.integral, 4),
    threshold_90pct = round(threshold, 4),
    hit_rate = round(hit_rate, 4),
    precision = round(precision, 4),
    false_alarm_rate = round(false_alarm_rate, 4),
    total_alerts = sum(alert),
    true_positives = true_positive,
    false_positives = false_positive,
    false_negatives = false_negative,
    true_negatives = true_negative
  )
}

summary_table <- rbind(
  evaluate_model(preds$actual, preds$logit_prob, "Logistic Regression"),
  evaluate_model(preds$actual, preds$rf_prob, "Random Forest"),
  evaluate_model(preds$actual, preds$xgb_prob, "XGBoost")
)

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)

write.csv(
  summary_table,
  "outputs/tables/model_evaluation_summary.csv",
  row.names = FALSE
)

cat("Model evaluation completed successfully.\n")
cat("Output file: outputs/tables/model_evaluation_summary.csv\n")
print(summary_table)