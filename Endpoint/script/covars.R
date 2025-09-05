# Load required library
library(dplyr)

# Read the input file (adjust file path and name as needed)
setwd("/Users/xingyifan/Desktop/CRC/endpoint_data/raw_data/")
data <- read.csv("age_sex_family_history.csv")

# Check the structure of the data
str(data)
head(data)

# Rename
covar <- subset(data, select = c(Participant.ID,
                                 Age.at.recruitment,
                                 Sex)) %>%
  rename(eid=Participant.ID,
         age=Age.at.recruitment,
         sex=Sex)

# Calculate mean-centered age variables
covars <- covar %>%
  # Keep only eid, age, and sex
  select(eid, age, sex) %>%
  
  # Calculate overall mean age
  mutate(
    # Mean-centered age (overall)
    age_c = age - mean(age, na.rm = TRUE),
    
    # Mean-centered age squared (overall)
    age2_c = age_c^2
  ) %>%
  
  # Group by sex to calculate sex-specific means
  group_by(sex) %>%
  mutate(
    # Mean-centered age by sex
    age_c_sex = age - mean(age, na.rm = TRUE),
    
    # Mean-centered age squared by sex
    age2_c_sex = age_c_sex^2
  ) %>%
  
  # Ungroup to remove grouping
  ungroup() %>%
  
  # Select final variables in desired order
  select(eid, age_c, age2_c, sex, 
         age_c_sex, age2_c_sex)

# View the processed data
head(covars)
summary(covars)

# Export to CSV file
write.csv(covars, "covars.csv", row.names = FALSE)

# Optional: Print some summary statistics
cat("Overall mean age:", mean(covar$age, na.rm = TRUE), "\n")
cat("Mean age by sex:\n")
covar %>%
  group_by(sex) %>%
  summarise(mean_age = mean(age, na.rm = TRUE)) %>%
  print()

cat("\nData processing complete. Output saved to 'mean_centered_age_data.csv'\n")
