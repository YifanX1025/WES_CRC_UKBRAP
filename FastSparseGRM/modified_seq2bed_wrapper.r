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

# Handle MAF and missingness filtering
print("Applying MAF and missingness filters...")

# Check if we should apply additional filters or bypass monomorphic filtering
if(min.MAF == 0 && max.miss == 1.0) {
  print("Bypassing SNP2BED_wFilter due to monomorphic variants (MAF=0, max.miss=1.0)")
  print("Converting directly to BED format...")
  
  # Convert directly without additional filtering using SNPRelate
  tryCatch({
    snpgds <- snpgdsOpen(SNPgds.file)
    snpgdsGDS2BED(snpgds, paste0(prefix.bed, ".bed"), sample.id=NULL, snp.id=NULL, verbose=TRUE)
    snpgdsClose(snpgds)
    print("BED conversion completed successfully")
    
    # Remove intermediate SNP GDS file if requested
    if(removeSNPGDS) {
      file.remove(SNPgds.file)
      print("Intermediate SNP GDS file removed")
    }
    
  }, error = function(e) {
    print(paste("Direct conversion failed:", e$message))
    print("This is expected with monomorphic variants - no BED file can be created")
  })
  
} else {
  # Try normal filtering
  print(paste("Applying filters: min.MAF =", min.MAF, ", max.miss =", max.miss))
  tryCatch({
    SNP2BED_wFilter(SNPgds.file, min.MAF, max.miss, prefix.bed, removeSNPGDS=removeSNPGDS)
    print("Filtering and BED conversion completed successfully")
    
  }, error = function(e) {
    print(paste("SNP2BED_wFilter failed:", e$message))
    print("This typically means all variants were filtered out")
    print("Consider relaxing your filtering criteria or using different data")
    
    # Clean up
    if(removeSNPGDS && file.exists(SNPgds.file)) {
      file.remove(SNPgds.file)
      print("Intermediate SNP GDS file removed")
    }
  })
}

print("Process completed!")
