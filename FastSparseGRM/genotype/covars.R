# Load required library
library(dplyr)

# Read the input file (adjust file path and name as needed)
setwd("/Users/xingyifan/Desktop/CRC/endpoint_data/")
data <- read.csv("age_sex_ethnicity_PC1_10.csv")

# Check the structure of the data
str(data)
head(data)
colnames(data)[4:7] <- paste0("Ethnicity", 1:4)
colnames(data)[8:17] <- paste0("PC", 1:10)

# Rename
covar <- data %>%
  rename(eid=Participant.ID,
         age=Age.at.recruitment,
         sex=Sex,
         ethnicity=Ethnicity1) %>%
  mutate(ethnicity=ifelse(ethnicity==1001|2001|3001|4001,"White",
                          ifelse(ethnicity==1002|2002|3002|4002,"Mixed",
                                 ifelse(ethnicity==1003|2003|3003|4003,"Asian or Asian British",
                                        ifelse(ethnicity==2004|3004,"Black or Black British",
                                               ifelse(ethnicity==5,"Chinese",
                                                      ifelse(ethnicity==6,"Other ethnic group",NA)))))))

# Calculate mean-centered age variables
covars <- covar %>%
  # Keep only eid, age, and sex
  select(eid, age, sex, ethnicity, PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10) %>%
  
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
  select(eid, age_c, age2_c, sex, age_c_sex, age2_c_sex, ethnicity,
         PC1, PC2, PC3, PC4, PC5, PC6, PC7, PC8, PC9, PC10)

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

cat("\nData processing complete. Output saved to 'covars.csv'\n")
