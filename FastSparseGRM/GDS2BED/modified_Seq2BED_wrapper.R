library('optparse')
options(stringsAsFactors=F)

option_list <- list(
  make_option("--gds.file", type="character",default="",
    help="SeqArray GDS or aGDS file name"),
  make_option("--min.AVGDP", type="integer",default="10",
    help="Minimum average depth"),
  make_option("--filterCat", type="character",default="PASS",
    help="Category of variants to select based on the filter field"),
  make_option("--min.MAF", type="double",default="0.05",
    help="Minimum MAF"),
  make_option("--max.miss", type="double",default="0.05",
    help="Maximum missingness"),
  make_option("--removeSNPGDS", type="logical",default=TRUE,
    help="Whether to remove the intermediate SNPGDS"),
  make_option("--prefix.bed", type="character",default="",
    help="Prefix of the intermediate plink BED file output")
)

parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

gds.file<-opt$gds.file
min.AVGDP<-opt$min.AVGDP
filterCat<-opt$filterCat
min.MAF<-opt$min.MAF
max.miss<-opt$max.miss
removeSNPGDS<-opt$removeSNPGDS
prefix.bed<-opt$prefix.bed

library('FastSparseGRM')
library('SeqArray')
library('SNPRelate')

print(sessionInfo())

# Replace Seq2SNP_wFilter with custom implementation that skips AVGDP filtering
print("Converting SEQ GDS to SNP GDS format...")

# Open the sequence GDS file
gds <- seqOpen(gds.file)

# Apply chr14 sample filtering
chr14_samples_file <- "chr14_samples.txt"
if(file.exists(chr14_samples_file)) {
  print("Loading chr14 sample list...")
  chr14_samples <- read.table(chr14_samples_file, stringsAsFactors=FALSE)[,1]
  
  # Get current samples in this file
  current_samples <- seqGetData(gds, "sample.id")
  
  # Find intersection with chr14 samples (should be all chr14 samples if chr14 is minimal)
  samples_to_use <- intersect(current_samples, chr14_samples)
  
  print(paste("Total samples in file:", length(current_samples)))
  print(paste("Chr14 reference samples:", length(chr14_samples)))
  print(paste("Samples to use:", length(samples_to_use)))
  print(paste("Samples being excluded:", length(current_samples) - length(samples_to_use)))
  
  # Apply sample filter to match chr14
  seqSetFilter(gds, sample.id = samples_to_use)
  print("Sample filter applied to match chr14")
} else {
  print("No chr14_samples.txt file found - using all samples")
  print("Run extract_chr14_samples.R first to create the sample list")
}

# Check what filter categories are available
print("Checking available filter categories...")
filter_data <- seqGetData(gds, "annotation/filter")
filter_table <- table(filter_data)
print("Available filter categories:")
print(filter_table)

# Apply filter category if specified
if(filterCat != "" && filterCat != "ALL") {
  print(paste("Applying filter category:", filterCat))
  
  # Check if the requested filter category exists
  if(filterCat %in% names(filter_table)) {
    variant_sel <- filter_data == filterCat
    n_selected <- sum(variant_sel, na.rm = TRUE)
    print(paste("Number of variants with", filterCat, "filter:", n_selected))
    
    if(n_selected > 0) {
      seqSetFilter(gds, variant.sel = variant_sel)
      print("Filter applied successfully")
    } else {
      print(paste("WARNING: No variants found with filter category:", filterCat))
      print("Proceeding without filter...")
    }
  } else {
    print(paste("WARNING: Filter category", filterCat, "not found in data"))
    print("Available categories are:", paste(names(filter_table), collapse=", "))
    print("Proceeding without filter...")
  }
}

# Convert to SNP GDS format
SNPgds.file <- paste0(prefix.bed, "_snp.gds")
print(paste("Converting to SNP GDS format:", SNPgds.file))

# Use seqGDS2SNP to convert from SeqArray to SNPRelate format
seqGDS2SNP(gds, SNPgds.file, verbose=TRUE)

# Close the sequence GDS file
seqClose(gds)

print("Conversion to SNP GDS completed.")

# REPLACE SNP2BED_wFilter with direct SNPRelate functions to avoid dimension mismatch
print("Applying MAF and missingness filters using SNPRelate...")

tryCatch({
  # Open SNP GDS file
  snpgds <- snpgdsOpen(SNPgds.file)
  
  # Get variant information for filtering
  print("Calculating allele frequencies and missing rates...")
  freq_info <- snpgdsSNPRateFreq(snpgds, with.id=TRUE)
  allele_freq <- freq_info$AlleleFreq
  missing_rates <- freq_info$MissingRate
  
  # Calculate MAF
  maf_values <- pmin(allele_freq, 1 - allele_freq, na.rm=TRUE)
  
  # Get variant IDs and chromosome info
  snp_ids <- read.gdsn(index.gdsn(snpgds, "snp.id"))
  chromosomes <- read.gdsn(index.gdsn(snpgds, "snp.chromosome"))
  
  # Apply filtering criteria
  autosome_filter <- chromosomes %in% 1:22  # Exclude non-autosomal
  maf_pass <- !is.na(maf_values) & maf_values >= min.MAF
  miss_pass <- !is.na(missing_rates) & missing_rates <= max.miss
  
  # Combined filter
  variant_pass <- autosome_filter & maf_pass & miss_pass
  
  print(paste("Total variants:", length(snp_ids)))
  print(paste("Autosomal variants:", sum(autosome_filter)))
  print(paste("Variants passing MAF >=", min.MAF, ":", sum(maf_pass, na.rm=TRUE)))
  print(paste("Variants passing missing <=", max.miss, ":", sum(miss_pass, na.rm=TRUE)))
  print(paste("Variants passing ALL filters:", sum(variant_pass, na.rm=TRUE)))
  
  if(sum(variant_pass, na.rm=TRUE) > 0) {
    # Get SNP IDs that pass filters
    passing_snps <- snp_ids[variant_pass]
    
    print(paste("Converting", length(passing_snps), "variants to BED format..."))
    
    # Convert to BED format with filtered variants
    snpgdsGDS2BED(snpgds, paste0(prefix.bed, ".bed"), 
                  snp.id=passing_snps, 
                  verbose=TRUE)
    
    print("BED conversion completed successfully")
    
  } else {
    print("ERROR: No variants pass the specified filters")
    print("Consider relaxing your filtering criteria:")
    print(paste("  Current MAF threshold:", min.MAF))
    print(paste("  Current missing threshold:", max.miss))
    print("  Suggestion: Try --min.MAF 0.01 --max.miss 0.1")
  }
  
  # Close SNP GDS file
  snpgdsClose(snpgds)
  
  # Remove intermediate SNP GDS file if requested
  if(removeSNPGDS && file.exists(SNPgds.file)) {
    file.remove(SNPgds.file)
    print("Intermediate SNP GDS file removed")
  }
  
}, error = function(e) {
  print(paste("SNPRelate conversion failed:", e$message))
  print("This should not happen with direct SNPRelate functions")
  
  # Clean up
  if(exists("snpgds")) {
    tryCatch(snpgdsClose(snpgds), error=function(e) {})
  }
  if(removeSNPGDS && file.exists(SNPgds.file)) {
    file.remove(SNPgds.file)
    print("Intermediate SNP GDS file removed")
  }
})

print("Process completed!")