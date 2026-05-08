# run_pipeline.R
# Run the full financial risk warning system pipeline

source("scripts/01_download_data.R")
source("scripts/02_build_features.R")
source("scripts/03_define_target.R")
source("scripts/04_walkforward_models.R")
source("scripts/05_evaluate_results.R")
source("scripts/06_generate_outputs.R")

cat("Full pipeline completed successfully.\n")