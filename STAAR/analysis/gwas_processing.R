# GWAS Data Processing Script
# Filter variants with p-value < 5e-8 and create known variant list

setwd("/Users/xingyifan/Library/CloudStorage/OneDrive-Nexus365/Yifan/meeting materials/2025/SEP/10")
# Load required libraries
library(readr)
library(dplyr)

# Read the TSV file
gwas_data <- read_tsv("gwas-association-downloaded_2025-09-11-MONDO_0005575-withChildTraits.tsv")

# Display basic information about the dataset
cat("Dataset dimensions:", nrow(gwas_data), "rows x", ncol(gwas_data), "columns\n")
cat("Column names:\n")
print(colnames(gwas_data))

# Check the P-VALUE column data type and format
cat("\nP-VALUE column summary:\n")
print(summary(gwas_data$`P-VALUE`))

# Handle different P-VALUE formats (scientific notation, text, etc.)
# Convert P-VALUE to numeric, handling various formats
gwas_data$P_VALUE_numeric <- as.numeric(gwas_data$`P-VALUE`)

# For cases where P-VALUE might be in text format like "1E-6"
gwas_data$P_VALUE_numeric <- ifelse(is.na(gwas_data$P_VALUE_numeric) & !is.na(gwas_data$`P-VALUE`),
                                   as.numeric(gwas_data$`P-VALUE`),
                                   gwas_data$P_VALUE_numeric)

# Filter variants with p-value < 5e-8
significant_variants <- gwas_data %>%
  filter(!is.na(P_VALUE_numeric) & P_VALUE_numeric < 5e-8) %>%
  filter(!is.na(SNPS) & SNPS != "" & SNPS != "NR") %>%  # Remove rows with missing or "NR" SNPs
  select(SNPS) %>%
  distinct()  # Remove duplicates

# Display results
cat("\nNumber of significant variants (p < 5e-8):", nrow(significant_variants), "\n")

# Show first few variants
cat("\nFirst 10 significant variants:\n")
print(head(significant_variants, 10))

# Check for any missing values
cat("\nMissing values check:\n")
cat("Missing SNPS:", sum(is.na(significant_variants$SNPS)), "\n")

# Write the filtered data to CSV file
output_filename <- "known_varlist_rsID.csv"
write_csv(significant_variants, output_filename)

cat("\nFiltered data saved to:", output_filename, "\n")

# Optional: Display chromosome distribution
cat("\nChromosome distribution of significant variants:\n")
chr_distribution <- significant_variants %>%
  count(CHR, sort = TRUE)
print(chr_distribution)

# Optional: Check for variants with extremely low p-values
extremely_significant <- gwas_data %>%
  filter(!is.na(P_VALUE_numeric) & P_VALUE_numeric < 1e-10) %>%
  nrow()

cat("\nNumber of variants with p < 1e-10:", extremely_significant, "\n")

# Summary statistics
cat("\nSummary:\n")
cat("- Total variants in dataset:", nrow(gwas_data), "\n")
cat("- Variants with valid p-values:", sum(!is.na(gwas_data$P_VALUE_numeric)), "\n")
cat("- Variants with p < 5e-8:", nrow(significant_variants), "\n")
cat("- Output file:", output_filename, "\n")
cat("- Columns in output: SNPS \n")
