#!/bin/bash

# Merge UKB genetic data across chromosomes 1-22 with sample filtering
# Using dx run swiss-army-knife

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/chr1/ukb_qc_filtered_c1.bed" \
  -iin="CRC WGS:/GRM/chr1/ukb_qc_filtered_c1.bim" \
  -iin="CRC WGS:/GRM/chr1/ukb_qc_filtered_c1.fam" \
  -iin="CRC WGS:/GRM/chr2/ukb_qc_filtered_c2.bed" \
  -iin="CRC WGS:/GRM/chr2/ukb_qc_filtered_c2.bim" \
  -iin="CRC WGS:/GRM/chr2/ukb_qc_filtered_c2.fam" \
  -iin="CRC WGS:/GRM/chr3/ukb_qc_filtered_c3.bed" \
  -iin="CRC WGS:/GRM/chr3/ukb_qc_filtered_c3.bim" \
  -iin="CRC WGS:/GRM/chr3/ukb_qc_filtered_c3.fam" \
  -iin="CRC WGS:/GRM/chr4/ukb_qc_filtered_c4.bed" \
  -iin="CRC WGS:/GRM/chr4/ukb_qc_filtered_c4.bim" \
  -iin="CRC WGS:/GRM/chr4/ukb_qc_filtered_c4.fam" \
  -iin="CRC WGS:/GRM/chr5/ukb_qc_filtered_c5.bed" \
  -iin="CRC WGS:/GRM/chr5/ukb_qc_filtered_c5.bim" \
  -iin="CRC WGS:/GRM/chr5/ukb_qc_filtered_c5.fam" \
  -iin="CRC WGS:/GRM/chr6/ukb_qc_filtered_c6.bed" \
  -iin="CRC WGS:/GRM/chr6/ukb_qc_filtered_c6.bim" \
  -iin="CRC WGS:/GRM/chr6/ukb_qc_filtered_c6.fam" \
  -iin="CRC WGS:/GRM/chr7/ukb_qc_filtered_c7.bed" \
  -iin="CRC WGS:/GRM/chr7/ukb_qc_filtered_c7.bim" \
  -iin="CRC WGS:/GRM/chr7/ukb_qc_filtered_c7.fam" \
  -iin="CRC WGS:/GRM/chr8/ukb_qc_filtered_c8.bed" \
  -iin="CRC WGS:/GRM/chr8/ukb_qc_filtered_c8.bim" \
  -iin="CRC WGS:/GRM/chr8/ukb_qc_filtered_c8.fam" \
  -iin="CRC WGS:/GRM/chr9/ukb_qc_filtered_c9.bed" \
  -iin="CRC WGS:/GRM/chr9/ukb_qc_filtered_c9.bim" \
  -iin="CRC WGS:/GRM/chr9/ukb_qc_filtered_c9.fam" \
  -iin="CRC WGS:/GRM/chr10/ukb_qc_filtered_c10.bed" \
  -iin="CRC WGS:/GRM/chr10/ukb_qc_filtered_c10.bim" \
  -iin="CRC WGS:/GRM/chr10/ukb_qc_filtered_c10.fam" \
  -iin="CRC WGS:/GRM/chr11/ukb_qc_filtered_c11.bed" \
  -iin="CRC WGS:/GRM/chr11/ukb_qc_filtered_c11.bim" \
  -iin="CRC WGS:/GRM/chr11/ukb_qc_filtered_c11.fam" \
  -iin="CRC WGS:/GRM/chr12/ukb_qc_filtered_c12.bed" \
  -iin="CRC WGS:/GRM/chr12/ukb_qc_filtered_c12.bim" \
  -iin="CRC WGS:/GRM/chr12/ukb_qc_filtered_c12.fam" \
  -iin="CRC WGS:/GRM/chr13/ukb_qc_filtered_c13.bed" \
  -iin="CRC WGS:/GRM/chr13/ukb_qc_filtered_c13.bim" \
  -iin="CRC WGS:/GRM/chr13/ukb_qc_filtered_c13.fam" \
  -iin="CRC WGS:/GRM/chr14/ukb_qc_filtered_c14.bed" \
  -iin="CRC WGS:/GRM/chr14/ukb_qc_filtered_c14.bim" \
  -iin="CRC WGS:/GRM/chr14/ukb_qc_filtered_c14.fam" \
  -iin="CRC WGS:/GRM/chr15/ukb_qc_filtered_c15.bed" \
  -iin="CRC WGS:/GRM/chr15/ukb_qc_filtered_c15.bim" \
  -iin="CRC WGS:/GRM/chr15/ukb_qc_filtered_c15.fam" \
  -iin="CRC WGS:/GRM/chr16/ukb_qc_filtered_c16.bed" \
  -iin="CRC WGS:/GRM/chr16/ukb_qc_filtered_c16.bim" \
  -iin="CRC WGS:/GRM/chr16/ukb_qc_filtered_c16.fam" \
  -iin="CRC WGS:/GRM/chr17/ukb_qc_filtered_c17.bed" \
  -iin="CRC WGS:/GRM/chr17/ukb_qc_filtered_c17.bim" \
  -iin="CRC WGS:/GRM/chr17/ukb_qc_filtered_c17.fam" \
  -iin="CRC WGS:/GRM/chr18/ukb_qc_filtered_c18.bed" \
  -iin="CRC WGS:/GRM/chr18/ukb_qc_filtered_c18.bim" \
  -iin="CRC WGS:/GRM/chr18/ukb_qc_filtered_c18.fam" \
  -iin="CRC WGS:/GRM/chr19/ukb_qc_filtered_c19.bed" \
  -iin="CRC WGS:/GRM/chr19/ukb_qc_filtered_c19.bim" \
  -iin="CRC WGS:/GRM/chr19/ukb_qc_filtered_c19.fam" \
  -iin="CRC WGS:/GRM/chr20/ukb_qc_filtered_c20.bed" \
  -iin="CRC WGS:/GRM/chr20/ukb_qc_filtered_c20.bim" \
  -iin="CRC WGS:/GRM/chr20/ukb_qc_filtered_c20.fam" \
  -iin="CRC WGS:/GRM/chr21/ukb_qc_filtered_c21.bed" \
  -iin="CRC WGS:/GRM/chr21/ukb_qc_filtered_c21.bim" \
  -iin="CRC WGS:/GRM/chr21/ukb_qc_filtered_c21.fam" \
  -iin="CRC WGS:/GRM/chr22/ukb_qc_filtered_c22.bed" \
  -iin="CRC WGS:/GRM/chr22/ukb_qc_filtered_c22.bim" \
  -iin="CRC WGS:/GRM/chr22/ukb_qc_filtered_c22.fam" \
  -iin="CRC WGS:/GRM/keep.plink.txt" \
  -y --brief \
  -icmd="
    # Create merge list for PLINK
    echo 'Creating merge list...' &&
    
    # Create list of chromosome files for merging (excluding chr1 as base)
    for chr in {2..22}; do
        echo \'ukb_qc_filtered_c\${chr}\' >> merge_list.txt
    done &&
    
    # Merge all chromosomes using PLINK
    echo 'Merging chromosomes 1-22...'
    plink --bfile ukb_qc_filtered_c1 \
          --merge-list merge_list.txt \
          --keep keep.plink.txt \
          --make-bed \
          --out chrall &&
    
    echo 'Merge completed!' &&
    
    # Optional: Generate summary statistics
    echo 'Generating summary...' &&
    plink --bfile chrall \
          --freq \
          --missing \
          --hardy \
          --out chrall_qc
  " \
  --instance-type mem1_ssd1_v2_x8 \
  --name "UKB_merge_chr1-22_filtered" \
  --destination "CRC\ WGS:/GRM/"
