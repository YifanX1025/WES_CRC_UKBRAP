library('SeqArray')

# Extract sample IDs from chr14.gds
chr14_file <- "/Volumes/T7/WES/FastSparseGRM/chr14.gds"

print("Extracting sample list from chr14.gds...")

# Open chr14 GDS file
gds <- seqOpen(chr14_file)

# Get sample IDs
chr14_samples <- seqGetData(gds, "sample.id")
print(paste("Number of samples in chr14:", length(chr14_samples)))

# Close the file
seqClose(gds)

# Save the sample list
write.table(chr14_samples, "chr14_samples.txt", 
           row.names=FALSE, col.names=FALSE, quote=FALSE)

print("Sample IDs from chr14 saved to chr14_samples.txt")

# Verify against other chromosomes (optional check)
print("\nChecking sample counts in other chromosome files:")
base_path <- "/Volumes/T7/WES/FastSparseGRM/"

for(chr in c(1:13, 15:22)) {  # Skip chr14 since we're using it as reference
  gds_file <- paste0(base_path, "chr", chr, ".gds")
  
  if(file.exists(gds_file)) {
    gds <- seqOpen(gds_file)
    samples <- seqGetData(gds, "sample.id")
    seqClose(gds)
    
    # Check overlap with chr14 samples
    common_count <- length(intersect(samples, chr14_samples))
    print(paste("Chr", chr, ":", length(samples), "total samples,", 
                common_count, "overlap with chr14"))
    
    if(common_count < length(chr14_samples)) {
      missing_count <- length(chr14_samples) - common_count
      print(paste("  WARNING: Chr", chr, "missing", missing_count, "samples from chr14"))
    }
  }
}