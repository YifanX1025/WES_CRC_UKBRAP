#!/bin/bash

# Filter samples in GDS files using keep.ids
# Using dx run swiss-army-knife with R

dx run swiss-army-knife \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr1.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr2.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr3.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr4.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr5.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr6.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr7.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr8.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr9.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr10.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr11.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr12.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr13.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr14.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr15.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr16.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr17.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr18.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr19.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr20.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr21.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr22.pass.annotated.gds" \
  -iin="CRC WGS:/UKB_500k_WGS_aGDS/keep.ids" \
  -y --brief \
  -icmd='
    # Load required R libraries
    Rscript -e "
    library(SeqArray)
    library(data.table)
    
    # Read the keep list
    keep_samples <- fread(\"keep.ids\", header=FALSE)
    keep_ids <- keep_samples\$V1
    
    cat(\"Number of samples to keep:\", length(keep_ids), \"\n\")
    
    # Process each chromosome
    for (chr in 1:22) {
      cat(\"Processing chromosome\", chr, \"\n\")
      
      # Find the input GDS file
      input_file <- list.files(pattern=paste0(\"ukb.500k.wgs.chr\", chr, \".pass.annotated.gds\"), 
                               full.names=TRUE, recursive=TRUE)[1]
      
      if (is.na(input_file)) {
        cat(\"Warning: Could not find file for chromosome\", chr, \"\n\")
        next
      }
      
      # Open the GDS file
      gds <- seqOpen(input_file)
      
      # Get all sample IDs in the file
      all_samples <- seqGetData(gds, \"sample.id\")
      
      # Find samples that are in both the GDS file and keep list
      samples_to_keep <- intersect(all_samples, keep_ids)
      
      cat(\"Chromosome\", chr, \": keeping\", length(samples_to_keep), \"out of\", length(all_samples), \"samples\n\")
      
      # Create filtered GDS file
      output_file <- paste0(\"ukb.500k.wgs.chr\", chr, \".pass.annotated.filtered.gds\")
      
      # Apply sample filter and save
      seqSetFilter(gds, sample.id=samples_to_keep)
      seqExport(gds, output_file, fmt=\"gds\")
      
      # Close the file
      seqClose(gds)
      
      cat(\"Completed chromosome\", chr, \"\n\")
    }
    
    cat(\"Sample filtering completed for all chromosomes\n\")
    "
  ' \
  --instance-type mem3_ssd1_v2_x16 \
  --name "UKB_GDS_sample_filter" \
  --destination "CRC\ WGS:/UKB_500k_WGS_aGDS/filtered/"