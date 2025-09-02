# !/bin/bash

dx run swiss-army-knife -icmd='Rscript -e "install.packages(\"devtools\"); if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\", repos = \"https://cloud.r-project.org\"); BiocManager::install(version = \"3.20\", ask = FALSE); BiocManager::install(c(\"gdsfmt\", \"SNPRelate\", \"SeqArray\", \"SeqVarTools\")); install.packages(\"GMMAT\"); devtools::install_github(\"rounakdey/FastSparseGRM\"); library(FastSparseGRM); packageVersion(\"FastSparseGRM\")"' --tag="FastSparseGRM_install" --instance-type="mem1_ssd1_v2_x4"
