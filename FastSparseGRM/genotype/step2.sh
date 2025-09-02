# !/bin/bash

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/FastSparseGRM/extdata/getDivergence_wrapper.R" \
  -iin="CRC WGS:/GRM/" \
  -y --brief \
  -icmd="
        # Install R packages
        Rscript -e "install.packages(\"devtools\"); if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\", repos = \"https://cloud.r-project.org\"); BiocManager::install(version = \"3.20\", ask = FALSE); BiocManager::install(c(\"gdsfmt\", \"SNPRelate\", \"SeqArray\", \"SeqVarTools\")); install.packages(\"GMMAT\"); devtools::install_github(\"rounakdey/FastSparseGRM\")" &&
        

        # Run the divergence calculation
        R CMD BATCH --vanilla "--args --prefix.in <prefix.bedfile> --file.seg <output.king> --num_threads 8 --degree 4 --divThresh -0.02209709 --nRandomSNPs 0 --prefix.out output.divergence" getDivergence_wrapper.R getDivergence.Rout

  " \
  --instance-type mem2_ssd1_v2_x32 \
  --name "GRM_step1" \
  --destination "CRC\ WGS:/GRM/"
dx run swiss-army-knife -icmd='Rscript -e "install.packages(\"devtools\"); if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\", repos = \"https://cloud.r-project.org\"); BiocManager::install(version = \"3.20\", ask = FALSE); BiocManager::install(c(\"gdsfmt\", \"SNPRelate\", \"SeqArray\", \"SeqVarTools\")); install.packages(\"GMMAT\"); devtools::install_github(\"rounakdey/FastSparseGRM\"); library(FastSparseGRM); packageVersion(\"FastSparseGRM\")"' --tag="FastSparseGRM_install" --instance-type="mem1_ssd1_v2_x4"
