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
  -icmd="
    # First, explore the filesystem and install R in a safe location
    echo 'Current working directory and filesystem exploration:' && 
    pwd && 
    ls -la && 
    echo 'Home directory contents:' && 
    ls -la \$HOME && 
    
    # Use home directory for R installation (safer, no sudo needed)
    export R_HOME=\$HOME/R-4.5.1 && 
    
    echo 'Installing system dependencies (if possible)...' && 
    # Try to install dependencies, but continue if it fails
    apt-get update && apt-get install -y build-essential gfortran libreadline-dev libx11-dev libxt-dev libcurl4-openssl-dev libssl-dev libxml2-dev libbz2-dev liblzma-dev libpcre2-dev zlib1g-dev || echo 'Some dependencies may not be installable, continuing anyway...' &&
    
    echo 'Downloading and installing R 4.5.1 in home directory...' && 
    cd \$HOME && 
    wget https://cran.r-project.org/src/base/R-4/R-4.5.1.tar.gz && 
    tar -xzf R-4.5.1.tar.gz &&
    cd R-4.5.1 && 
    
    # Configure R to install in home directory (no sudo needed)
    ./configure --prefix=\$R_HOME --enable-R-shlib --with-blas --with-lapack && 
    make -j\$(nproc) && 
    make install && 
    
    # Add new R to PATH
    export PATH=\$R_HOME/bin:\$PATH && 
    
    echo 'R installation completed. Version:' && 
    \$R_HOME/bin/R --version && 
    
    # Install R packages with the new R version
    echo 'Installing R packages...' && 
    \$R_HOME/bin/Rscript -e \"
    # Install BiocManager for R 4.5 (Bioconductor 3.21)
    if (!requireNamespace('BiocManager', quietly = TRUE)) {
      install.packages('BiocManager', repos = 'https://cloud.r-project.org')
    }
    
    # Install Bioconductor 3.21 (compatible with R 4.5)
    BiocManager::install(version = '3.21', ask = FALSE)
    
    # Install required packages
    BiocManager::install(c('SeqArray', 'gdsfmt', 'data.table'), ask = FALSE) 
    
    cat('Package installation completed.\\n')
    \" && 
    
    # Process GDS files with the new R installation
    echo 'Starting GDS file processing...' && 
    \$R_HOME/bin/Rscript -e \"
    library(SeqArray)
    library(data.table)
    
    # Read the keep list - handle different possible formats
    keep_file <- list.files(pattern='keep.ids', full.names=TRUE, recursive=TRUE)[1]
    
    if (file.exists(keep_file)) {
      # Try reading as single column first
      keep_samples <- tryCatch({
        fread(keep_file, header=FALSE, col.names='sample_id')
      }, error = function(e) {
        # If that fails, try as whitespace-separated
        read.table(keep_file, header=FALSE, stringsAsFactors=FALSE)[,1, drop=FALSE]
      })
      
      keep_ids <- as.character(keep_samples[[1]])
      cat('Number of samples to keep:', length(keep_ids), '\\n')
    } else {
      stop('Could not find keep.ids file')
    }
    
    # Process each chromosome
    for (chr in 1:22) {
      cat('\\n=== Processing chromosome', chr, '===\\n')
      
      # Find the input GDS file
      input_file <- list.files(pattern=paste0('ukb.500k.wgs.chr', chr, '.pass.annotated.gds'), 
                         full.names=TRUE, recursive=TRUE)[1]
      
      if (is.na(input_file) || !file.exists(input_file)) {
        cat('Warning: Could not find GDS file for chromosome', chr, '\\n')
        next
      }
      
      cat('Found file:', basename(input_file), '\\n')
      
      # Open the GDS file
      gds <- seqOpen(input_file, readonly=TRUE)
      
      # Get all sample IDs in the file
      all_samples <- seqGetData(gds, 'sample.id')
      cat('Total samples in chr', chr, ':', length(all_samples), '\\n')
      
      # Find samples that are in both the GDS file and keep list
      samples_to_keep <- intersect(all_samples, keep_ids)
      cat('Samples to keep for chr', chr, ':', length(samples_to_keep), '\\n')
      
      if (length(samples_to_keep) == 0) {
        cat('Warning: No samples to keep for chromosome', chr, '\\n')
        seqClose(gds)
        next
      }
      
      # Create output filename
      output_file <- paste0('ukb.500k.wgs.chr', chr, '.pass.annotated.filtered.gds')
      
      # Set sample filter
      seqSetFilter(gds, sample.id=samples_to_keep, verbose=TRUE)
      
      # Get variant count after filtering
      n_variants <- length(seqGetData(gds, 'variant.id'))
      cat('Variants in filtered chr', chr, ':', n_variants, '\\n')
      
      # Export filtered GDS
      cat('Exporting filtered file...\\n')
      seqExport(gds, output_file, fmt='gds', verbose=TRUE)
      
      # Close the file
      seqClose(gds)
      
      cat('Completed chromosome', chr, '- Output:', output_file, '\\n')
    }
    
    cat('\\nSample filtering completed for all chromosomes\\n')
    \"
  " \
  --instance-type mem3_ssd1_v2_x16 \
  --name "UKB_GDS_sample_filter" \
  --destination "CRC\ WGS:/UKB_500k_WGS_aGDS/filtered/"
