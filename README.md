# Financial Risk Warning System

Leakage-safe AI system for financial risk early warning, volatility monitoring, and market-stress detection.

## Short Description

This project implements a leakage-safe AI-based financial risk early-warning system for market-stress monitoring. It combines ETF market data, realized-volatility features, cross-asset indicators, walk-forward machine-learning models, and operational warning metrics to estimate future drawdown-risk conditions.

The project is designed as a practical decision-support system rather than a trading-alpha strategy.

## Project Overview

This repository provides a reproducible pipeline for building a financial risk early-warning system. The system downloads ETF market data, constructs financial risk features, defines a future drawdown-risk target, trains machine-learning models under a walk-forward design, evaluates model performance, and generates risk-regime outputs, high-risk alerts, and visualization figures.

The main goal is to demonstrate how AI and machine-learning methods can be implemented in a realistic financial risk-monitoring framework while avoiding look-ahead bias and data leakage.

## Motivation

Financial markets can experience sudden drawdowns, volatility spikes, and stress regimes. Risk managers, analysts, and financial institutions need tools that can help identify elevated market-risk conditions before large losses occur.

However, many financial machine-learning pipelines are vulnerable to unrealistic evaluation because of:

- random train/test splits on time-series data
- future information entering feature construction
- test-period information entering scaling or preprocessing
- model calibration based on unavailable future data
- overly optimistic backtesting results

This project addresses these concerns by using a leakage-safe walk-forward evaluation design.

## Asset Universe

The system uses SPY as the main U.S. equity-market benchmark and includes cross-asset and sector ETF predictors.

The asset universe includes:

- SPY
- QQQ
- IWM
- TLT
- GLD
- VXX
- XLC
- XLY
- XLP
- XLE
- XLF
- XLV
- XLI
- XLK
- XLB
- XLU
- XLRE

## Methodology

The project pipeline has six main steps:

1. Download ETF adjusted price data.
2. Construct historical volatility, momentum, moving-average, and cross-asset return features.
3. Define a future 21-trading-day drawdown-risk stress-event target.
4. Train Logistic Regression, Random Forest, and XGBoost models using a walk-forward design.
5. Evaluate performance using ROC-AUC, PR-AUC, hit rate, precision, and false-alarm rate.
6. Generate risk scores, risk regimes, high-risk alerts, and visualization figures.

## Leakage-Safe Design

The system follows several leakage-safe principles:

- chronological training and testing
- walk-forward model estimation
- training-only feature scaling
- no random train/test split
- no test-period information used in preprocessing
- alerts generated only from information available at the prediction date

This design helps reduce the risk of look-ahead bias and makes the evaluation closer to a realistic real-time monitoring setting.

## Models

The current version includes:

- Logistic Regression
- Random Forest
- XGBoost

Logistic Regression serves as a simple and interpretable baseline model. Random Forest provides a nonlinear machine-learning benchmark. XGBoost adds a modern gradient-boosting benchmark for comparison.

Future extensions may include:

- Penalized Logistic Regression
- GARCH or GJR-GARCH volatility benchmarks
- LSTM or attention-based deep learning models
- additional robustness checks across horizons and stress thresholds

## Repository Structure

```text
financial-risk-warning-system/
|-- README.md
|-- run_pipeline.R
|-- requirements_R.txt
|-- data/
|   |-- raw/
|   `-- processed/
|-- scripts/
|   |-- 01_download_data.R
|   |-- 02_build_features.R
|   |-- 03_define_target.R
|   |-- 04_walkforward_models.R
|   |-- 05_evaluate_results.R
|   `-- 06_generate_outputs.R
|-- outputs/
|   |-- figures/
|   |-- tables/
|   `-- alerts/
|-- report/
|   `-- technical_report.md
`-- app/