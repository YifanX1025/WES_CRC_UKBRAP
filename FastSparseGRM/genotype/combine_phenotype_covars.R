# Load required library
library(dplyr)

# Set working directory (adjust as needed)
setwd("/Users/xingyifan/Desktop/CRC/endpoint_data/")

# Step 1: Read the files
# Read combined_labels.csv
labels <- read.csv("combined_labels.csv")

# Read keep.txt (file with eid numbers, no header)
keep_ids <- read.table("keep.txt", header = FALSE, col.names = "eid")

# Read covars.csv
covars <- read.csv("covars.csv")

# Step 2: Check the data structure
cat("Structure of labels data:\n")
str(labels)
head(labels)

cat("\nStructure of keep_ids:\n")
str(keep_ids)
head(keep_ids)

cat("\nStructure of covars data:\n")
str(covars)
head(covars)

# Step 3: Generate phenotype file
# Filter labels to keep only rows with eids in keep.txt
# and rename is_crc_case to case_status
phenotype <- labels %>%
  # Keep only rows where eid is in the keep list
  filter(eid %in% keep_ids$eid) %>%
  # Rename the column
  rename(case_status = is_crc_case) %>%
  # Select relevant columns
  select(eid, case_status)

cat("\nPhenotype data after filtering and renaming:\n")
str(phenotype)
head(phenotype)
cat("Number of individuals in phenotype file:", nrow(phenotype), "\n")

# Step 4: Combine phenotype with covariates
# Inner join to keep only individuals present in both datasets
final_data <- phenotype %>%
  inner_join(covars, by = "eid")

# Alternative: Left join if you want to keep all phenotype individuals
# final_data <- phenotype %>%
#   left_join(covars, by = "eid")

# Step 5: Check the final combined dataset
cat("\nFinal combined dataset:\n")
str(final_data)
head(final_data)
summary(final_data)

cat("\nNumber of individuals in final dataset:", nrow(final_data), "\n")
cat("Number of cases:", sum(final_data$case_status == 1, na.rm = TRUE), "\n")
cat("Number of controls:", sum(final_data$case_status == 0, na.rm = TRUE), "\n")

# Step 6: Export the final dataset
write.csv(final_data, "phenotype_covars_combined.csv", row.names = FALSE, quote = FALSE)

# Optional: Check for any missing data
cat("\nMissing data summary:\n")
sapply(final_data, function(x) sum(is.na(x)))

cat("\nData processing complete. Final dataset saved to 'phenotype_covars_combined.csv'\n")
cat("Final dataset columns:", colnames(final_data), "\n")
