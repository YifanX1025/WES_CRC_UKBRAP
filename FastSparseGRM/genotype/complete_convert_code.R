# Load required library
library(dplyr)

# Set working directory
setwd("/Users/xingyifan/Desktop/CRC/endpoint_data/")

# Read the CSV file
data <- read.csv("PC1_20.csv")

# Read keep.txt (file with eid numbers, no header)
keep_ids <- read.table("keep.txt", header = FALSE, col.names = "eid")

# Check the structure
str(data)
head(data)
cat("Number of IDs in keep.txt:", nrow(keep_ids), "\n")

# Convert to output.pca.score format
pca_format <- data %>%
  # Filter to keep only IDs in keep.txt
  filter(Participant.ID %in% keep_ids$eid) %>%
  # Select only the ID and PC columns
  select(Participant.ID, 
         starts_with("Genetic.principal.components")) %>%
  # Remove rows with missing PC data (like participant 2626613)
  filter(!is.na(`Genetic.principal.components...Array.1`)) %>%
  # Sort by Participant.ID in ascending order
  arrange(Participant.ID) %>%
  # Rename ID column to match format (duplicate ID in first two columns)
  mutate(ID1 = Participant.ID,
         ID2 = Participant.ID) %>%
  # Reorder columns to match output.pca.score format
  select(ID1, ID2, everything(), -Participant.ID)

# Check the result
head(pca_format)
str(pca_format)

# Write to space-separated file without quotes and without column names
write.table(pca_format, 
            "converted.pca.score", 
            sep = " ",           # Space separated
            quote = FALSE,       # No quotes
            row.names = FALSE,   # No row names
            col.names = FALSE)   # No column names (header)

# Optional: Check the output format
cat("First few lines of converted file:\n")
readLines("converted.pca.score", n = 5)

cat("\nConversion complete! File saved as 'age_sex_PC1_10_converted.pca.score'\n")
cat("Format: space-separated, no header, duplicate ID columns, PC values\n")
cat("Number of samples in final file:", nrow(pca_format), "\n")
cat("Filtered to keep only samples with IDs in keep.txt and sorted in ascending order\n")
