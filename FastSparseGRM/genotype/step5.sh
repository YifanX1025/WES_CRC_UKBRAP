# !/bin/bash

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/chrall_pruned.bed" \
  -iin="CRC WGS:/GRM/chrall_pruned.bim" \
  -iin="CRC WGS:/GRM/chrall_pruned.fam" \
  -iin="CRC WGS:/GRM/output.seg" \
  -iin="CRC WGS:/GRM/output.segments.gz" \
  -iin="CRC WGS:/GRM/outputallsegs.txt" \
  -iin="CRC WGS:/GRM/" \
  -iin="CRC WGS:/GRM/" \
  -iin="CRC WGS:/GRM/" \
  -iin="CRC WGS:/GRM/FastSparseGRM/extdata/calcSparseGRM_wrapper.R" \
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
    R CMD BATCH --vanilla '--args --prefix.in chrall_pruned --prefix.out output.sparseGRM --file.train output.unrelated.unrels --file.score output.pca.score --file.seg output.seg --num_threads 24 --no_pcs 20 --block.size 5000 --max.related.block 5000 --KINGformat.out FALSE --degree 4' calcSparseGRM_wrapper.R calcSparseGRM.Rout && 
    tail -n 200 calcSparseGRM.Rout || true
  ' \
  --instance-type mem2_ssd1_v2_x32 \
  --name "GRM_step5" \
  --destination "CRC WGS:/GRM/" \
  --priority high
