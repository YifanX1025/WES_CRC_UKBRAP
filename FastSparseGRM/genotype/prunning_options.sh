#!/bin/bash

# Prunning selected genotype data
# Using dx run swiss-army-knife

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/chrall.bed" \
  -iin="CRC WGS:/GRM/chrall.bim" \
  -iin="CRC WGS:/GRM/chrall.fam" \
  -y --brief \
  -icmd="
  # Try different pruning parameters to get ~200K variants
  echo 'Starting LD pruning with relaxed parameters...' && 
  
  # Option 1: Less stringent r² threshold (0.2 instead of 0.1)
  plink --bfile chrall --indep-pairwise 50 5 0.2 --out chrall.pruned_r02 && 
  
  # Check how many variants this gives us
  wc -l chrall.pruned_r02.prune.in && 
  echo 'Variants with r²=0.2 threshold:' && 
  
  # Option 2: Larger window, less stringent threshold
  plink --bfile chrall --indep-pairwise 100 10 0.3 --out chrall.pruned_r03 &&
  
  # Check variant count
  wc -l chrall.pruned_r03.prune.in && 
  echo 'Variants with window=100, step=10, r²=0.3:'
  
  # Option 3: Very relaxed for ~200K variants
  plink --bfile chrall --indep-pairwise 200 20 0.5 --out chrall.pruned_r05 &&
# 200 (window size in kb): PLINK examines variants within a 200 kilobase sliding window along each chromosome. 
# This is the physical distance range it considers when calculating linkage disequilibrium between variants.
# 20 (step size in variant count): After processing each window, PLINK moves forward by 20 variants before analyzing the next window. 
# This creates overlapping windows that ensure no variant pairs are missed.
# 0.5 (r² threshold): This is the linkage disequilibrium cutoff. PLINK removes one variant from any pair that has an r² correlation above 0.5. 
# An r² of 0.5 means the variants share 50% of their genetic information - they're moderately correlated but not highly redundant.
  
  # Check variant count
  wc -l chrall.pruned_r05.prune.in && 
  echo 'Variants with window=200, step=20, r²=0.5:'
  " \
  --instance-type mem1_ssd1_v2_x8 \
  --name "chrall_prunning" \
  --destination "CRC\ WGS:/GRM/"
