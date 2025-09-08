rm(list=ls())
gc()

##########################################################################
#           Input - Command Line Arguments
##########################################################################
args <- commandArgs(TRUE)

### Command line arguments
chr <- as.numeric(args[1])                    # Chromosome number
dir_favordb <- args[2]                        # FAVOR database directory
dir_geno <- args[3]                          # GDS file directory
gds_file_name_1 <- args[4]                   # GDS file prefix
gds_file_name_2 <- args[5]                   # GDS file suffix
output_path <- args[6]                       # Output directory

### Check if all arguments are provided
if(length(args) != 6) {
    stop("Usage: Rscript script.R <chr> <dir_favordb> <dir_geno> <gds_prefix> <gds_suffix> <output_path>")
}

###########################################################################
#           Main Function 
###########################################################################
### Make directory
system(paste0("mkdir -p ", output_path, "chr", chr))

### R packages
library(gdsfmt)
library(SeqArray)
library(SeqVarTools)

### List available FAVOR database files for this chromosome
favor_files <- list.files(dir_favordb, pattern = paste0("chr", chr, "_.*\\.csv$"), full.names = TRUE)
print(paste("Found FAVOR database files:", length(favor_files)))
print(favor_files)

## Open GDS file
gds.path <- paste0(dir_geno, gds_file_name_1, chr, gds_file_name_2)
genofile <- seqOpen(gds.path)
CHR <- as.numeric(seqGetData(genofile, "chromosome"))
position <- as.integer(seqGetData(genofile, "position"))
REF <- as.character(seqGetData(genofile, "$ref"))
ALT <- as.character(seqGetData(genofile, "$alt"))
VarInfo_genome <- paste0(CHR, "-", position, "-", REF, "-", ALT)
seqClose(genofile)

## Process each FAVOR database file
for(kk in 1:length(favor_files)) {
    print(paste("Processing file", kk, "of", length(favor_files)))
    
    # Read FAVOR database file
    tryCatch({
        favor_data <- read.csv(favor_files[kk], header = TRUE, stringsAsFactors = FALSE)
        print(paste("Loaded", nrow(favor_data), "variants from", basename(favor_files[kk])))
        
        # If FAVOR data has position information, you can filter VarInfo accordingly
        # This assumes FAVOR data has columns like "POS" or similar
        # You may need to adjust based on actual FAVOR file structure
        
        if("POS" %in% colnames(favor_data)) {
            min_pos <- min(favor_data$POS, na.rm = TRUE)
            max_pos <- max(favor_data$POS, na.rm = TRUE)
            
            VarInfo <- VarInfo_genome[(position >= min_pos) & (position <= max_pos)]
        } else {
            # If no position info, use all variants (you may want to modify this)
            VarInfo <- VarInfo_genome
        }
        
        VarInfo <- data.frame(VarInfo = VarInfo)
        
        # Write output
        output_file <- paste0(output_path, "chr", chr, "/VarInfo_chr", chr, "_", kk, ".csv")
        write.csv(VarInfo, output_file, quote = FALSE, row.names = FALSE)
        print(paste("Written", nrow(VarInfo), "variants to", basename(output_file)))
        
    }, error = function(e) {
        print(paste("Error processing file", favor_files[kk], ":", e$message))
    })
}

print("Processing complete!")
