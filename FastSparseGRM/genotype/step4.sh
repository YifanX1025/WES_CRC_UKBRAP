# !/bin/bash

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/chrall_pruned.bed" \
  -iin="CRC WGS:/GRM/chrall_pruned.bim" \
  -iin="CRC WGS:/GRM/chrall_pruned.fam" \
  -iin="CRC WGS:/GRM/output.seg" \
  -iin="CRC WGS:/GRM/output.segments.gz" \
  -iin="CRC WGS:/GRM/outputallsegs.txt" \
  -iin="CRC WGS:/GRM/output.divergence.div" \
  -iin="CRC WGS:/GRM/" \
  -iin="CRC WGS:/GRM/" \
  -iin="CRC WGS:/GRM/" \
  -iin="CRC WGS:/GRM/FastSparseGRM/extdata/runPCA_wrapper.R" \
  -y --brief \
  -icmd='
    # Install R packages with dependencies
    Rscript -e "
      install.packages(c(\"devtools\", \"optparse\", \"data.table\", \"Matrix\"));
      if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\", repos = \"https://cloud.r-project.org\");
      BiocManager::install(version = \"3.20\", ask = FALSE);
      BiocManager::install(c(\"gdsfmt\", \"SNPRelate\", \"SeqArray\", \"SeqVarTools\"));
      install.packages(\"GMMAT\");
      devtools::install_github(\"rounakdey/FastSparseGRM\");
      library(FastSparseGRM);
      packageVersion(\"FastSparseGRM\")
    " &&
    pwd && ls -la && cd /home/dnanexus/out/out && 
    # Run the divergence calculation
    R  CMD BATCH --vanilla "--args --prefix.in chrall_pruned --file.unrels output.unrelated.unrels --prefix.out output.pca --no_pcs 20 --num_threads 24 --no_iter 15" runPCA_wrapper.R runPCA.Rout && 
    tail -n 200 runPCA.Rout || true
  ' \
  --instance-type mem2_ssd1_v2_x32 \
  --name "GRM_step4" \
  --destination "CRC WGS:/GRM/" \
  --priority high
