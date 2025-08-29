#!/bin/bash

# Batch process chromosomes 1-22
for CHR in {1..22}
do
  echo "Processing chromosome ${CHR}..."
  
  R CMD BATCH --vanilla \
    "--args --gds.file /Volumes/T7/WES/FastSparseGRM/chr${CHR}.gds --min.AVGDP 0 --filterCat ALL --min.MAF 0.05 --max.miss 0.05 --removeSNPGDS TRUE --prefix.bed /Volumes/T7/WES/FastSparseGRM/chr${CHR}_snp" \
    modified_Seq2BED_wrapper.R \
    ../../modified_Seq2BED_wrapper_chr${CHR}.Rout
  
  # Check if the command succeeded
  if [ $? -eq 0 ]; then
    echo "Chromosome ${CHR} completed successfully"
  else
    echo "ERROR: Chromosome ${CHR} failed"
  fi
  
  echo "---"
done

echo "All chromosomes processed!"