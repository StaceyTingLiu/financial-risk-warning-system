# Technical Report: Leakage-Safe AI System for Financial Risk Early Warning and Market-Stress Monitoring

## 1. Executive Summary

This project develops a leakage-safe AI-based financial risk early-warning system for market-stress monitoring and decision support. The system uses historical ETF market data, volatility indicators, cross-asset signals, and machine-learning models to estimate the probability of future drawdown-risk events.

The project is designed as a practical implementation of financial risk-monitoring research. It does not aim to create a trading-alpha strategy or guarantee investment returns. Instead, it focuses on reliable warning design, realistic evaluation, and interpretable outputs that can support risk-monitoring decisions.

The system produces a risk score timeline, low/medium/high risk-regime classifications, high-risk alert records, model evaluation tables, and visualization outputs. The first version compares Logistic Regression and Random Forest models under a walk-forward evaluation framework.

## 2. Problem Statement

Financial institutions, investors, and risk managers need tools that can identify elevated market risk before severe drawdowns occur. Traditional risk-monitoring methods often rely on historical volatility, realized drawdowns, or fixed stress indicators. These methods are useful, but they may not fully capture changing market conditions across equity, bond, commodity, volatility, and sector signals.

Machine-learning models can help integrate multiple signals, but financial prediction systems are especially vulnerable to data leakage. If future information enters feature construction, preprocessing, model tuning, or threshold selection, the backtest may appear stronger than it would be in real time.

Therefore, the central problem is not only whether a model can predict future stress events, but whether it can do so under a realistic, leakage-safe evaluation design.

## 3. Objective

The objective of this project is to build a reproducible financial risk early-warning system that estimates future drawdown-risk conditions using only information available at the time of prediction.

The system has four main goals:

1. Construct financial risk features from ETF market data.
2. Define a future drawdown-risk target over a 21-trading-day horizon.
3. Train and evaluate models using a leakage-safe walk-forward design.
4. Generate practical outputs, including risk scores, risk regimes, alerts, figures, and evaluation metrics.

The project demonstrates how AI-based financial risk research can be translated into a practical decision-support framework.

## 4. Data and Asset Universe

The system uses daily adjusted price data downloaded from Yahoo Finance through the `quantmod` package in R.

The main market benchmark is SPY, which represents broad U.S. equity-market exposure. The project also includes cross-asset and sector ETF predictors.

The asset universe includes:

- SPY: S&P 500 ETF
- QQQ: Nasdaq-100 ETF
- IWM: Russell 2000 ETF
- TLT: Long-term U.S. Treasury ETF
- GLD: Gold ETF
- VXX: Volatility-linked ETF
- XLC, XLY, XLP, XLE, XLF, XLV, XLI, XLK, XLB, XLU, XLRE: U.S. sector ETFs

This asset universe allows the system to capture equity-market behavior, cross-asset stress signals, volatility-related movement, and sector-level information.

## 5. Feature Engineering

The feature-engineering script constructs historical variables using only past and current information. The main features include:

- SPY daily log return
- 21-day realized volatility
- 42-day realized volatility
- 63-day realized volatility
- 21-day momentum
- 63-day momentum
- 21-day moving-average gap
- 63-day moving-average gap
- VXX return
- TLT return
- GLD return
- QQQ return
- IWM return

The realized-volatility variables summarize recent market instability. The momentum and moving-average-gap variables capture trend and deviation from recent price levels. The cross-asset return variables provide information about volatility, bonds, gold, growth stocks, and small-cap stocks.

All features are constructed before the future target is defined. This helps preserve the timing discipline of the system.

## 6. Target Variable Construction

The target variable is a future 21-trading-day drawdown-risk event.

For each date, the system looks ahead over the next 21 trading days and calculates the worst future drawdown from the current SPY price. If the future drawdown is less than or equal to -8%, the observation is labeled as a stress event.

The binary target is defined as:

- `1`: future 21-day drawdown is less than or equal to -8%
- `0`: future 21-day drawdown does not reach the -8% stress threshold

This target is designed for early-warning monitoring. It asks whether current market conditions indicate elevated risk of a meaningful future equity drawdown.

## 7. Leakage-Safe Walk-Forward Design

The project uses a walk-forward evaluation design. This is important because financial data are time-dependent, and random train/test splitting can create unrealistic results.

The walk-forward process works as follows:

1. The model trains on an initial historical training window.
2. The model predicts the next out-of-sample testing window.
3. The training window expands forward.
4. The process repeats until the end of the sample.

The system also applies training-only preprocessing. Specifically, feature means and standard deviations are calculated only from the training data and then applied to the test data. This prevents test-period information from entering the scaling process.

This design supports realistic out-of-sample evaluation and reduces the risk of look-ahead bias.

## 8. Model Set

The first version of the system includes two models:

### Logistic Regression

Logistic Regression serves as a simple and interpretable baseline model. It estimates the probability of a future stress event using a linear relationship between features and the log-odds of the target.

### Random Forest

Random Forest is included as a nonlinear machine-learning model. It can capture interaction effects and nonlinear relationships among volatility, momentum, and cross-asset predictors.

The first version intentionally keeps the model set simple. A clean and credible benchmark comparison is more useful than an overly complex system with many unstable models.

Future versions may add:

- XGBoost
- Penalized Logistic Regression
- LSTM or attention-based deep learning models

## 9. Evaluation Metrics

The system evaluates warning performance using several metrics:

### ROC-AUC

ROC-AUC measures the model’s ability to rank stress events above non-stress events across different thresholds.

### PR-AUC

PR-AUC is useful when stress events are relatively rare. It focuses on precision and recall performance for the positive stress-event class.

### Hit Rate

Hit rate measures the proportion of actual stress events that were successfully flagged by the alert rule.

### Precision

Precision measures the proportion of alerts that corresponded to actual stress events.

### False-Alarm Rate

False-alarm rate measures how often the system generated alerts during non-stress periods.

Together, these metrics evaluate both statistical classification performance and operational warning usefulness.

## 10. Results

The system produces several output files:

- `outputs/tables/walkforward_predictions.csv`
- `outputs/tables/model_evaluation_summary.csv`
- `outputs/tables/risk_regime_timeline.csv`
- `outputs/alerts/high_risk_alerts.csv`
- `outputs/figures/risk_score_timeline.png`
- `outputs/figures/risk_regime_classification.png`
- `outputs/figures/stress_event_overlay.png`

The risk-score timeline shows how predicted stress probability changes over time. The risk-regime classification converts model probabilities into low, medium, and high risk regimes. The stress-event overlay compares predicted risk scores with realized stress-event periods.

These outputs allow users to examine whether the model generates elevated risk scores around periods of future drawdown risk.

## 11. Practical Use Case

The system can support financial risk monitoring by providing a structured early-warning signal. A risk manager or analyst could use the system to monitor whether market conditions are shifting toward a higher-risk regime.

Possible practical applications include:

- Market-stress monitoring
- Risk dashboard construction
- De-risking discussion support
- Portfolio risk review
- Scenario-analysis preparation
- Financial decision-support research

The system should not be used as a standalone trading strategy. Its purpose is to support risk awareness and decision-making, not to guarantee profitable investment decisions.

## 12. Limitations

This project has several limitations.

First, the current system uses ETF market data only. It does not include macroeconomic releases, earnings information, credit spreads, option-implied measures, or intraday market data.

Second, the current target definition uses a fixed 21-day horizon and an 8% drawdown threshold. Different horizons or thresholds may produce different results.

Third, the model set is limited to Logistic Regression and Random Forest in the first version. More models can be added in future versions, but they should be evaluated under the same leakage-safe design.

Fourth, the system is designed for research and decision support. It does not guarantee accurate prediction of future market stress and should not be interpreted as investment advice.

## 13. Conclusion

This project implements a leakage-safe AI-based financial risk early-warning system for market-stress monitoring. It combines ETF data, financial feature engineering, future drawdown-risk target construction, walk-forward machine-learning evaluation, and practical alert generation.

The main contribution of the project is not only model prediction, but the construction of a realistic and reproducible risk-monitoring pipeline. By emphasizing leakage-safe design, operational warning metrics, and interpretable outputs, the project demonstrates how AI-based financial risk research can be translated into a practical decision-support system.