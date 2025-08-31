
library(dplyr)
library(tidyr)
library(tidyverse)

# Set the default path

setwd("/Users/xingyifan/Desktop/CRC/endpoint data/censoring/")

# Load CRC datasets
inc_crc_df <- read.csv("incident_CRC_cases.csv")
pre_crc_df <- read.csv("prevalent_CRC_cases.csv")
all_crc_df <- read.csv("all_CRC_cases.csv")

# Load control dataset
all_cancer_df <- read.csv("../cancer/all_cancer_cases.csv")

inc_crc <- subset(inc_crc_df,colorectal_cancer_inc==1) %>%
  mutate(ethnic_background=ifelse(ethnic_background==1001,"White",
                                  ifelse(ethnic_background==1002,"White",
                                         ifelse(ethnic_background==1003,"White",
                                                ifelse(ethnic_background==1,"White","Not_white")))))

pre_crc <- subset(pre_crc_df,colorectal_cancer_prev==1) %>%
  mutate(ethnic_background=ifelse(ethnic_background==1001,"White",
                                  ifelse(ethnic_background==1002,"White",
                                         ifelse(ethnic_background==1003,"White",
                                                ifelse(ethnic_background==1,"White","Not_white")))))

all_crc <- subset(all_crc_df,colorectal_cancer_case==1) %>%
  mutate(ethnic_background=ifelse(ethnic_background==1001,"White",
                                  ifelse(ethnic_background==1002,"White",
                                         ifelse(ethnic_background==1003,"White",
                                                ifelse(ethnic_background==1,"White","Not_white")))))


ctrl <- subset(all_cancer_df,cancer_case!=1)
ctrl <- ctrl %>%
  mutate(ethnic_background=ifelse(ethnic_background==1001,"White",
                                  ifelse(ethnic_background==1002,"White",
                                         ifelse(ethnic_background==1003,"White",
                                                ifelse(ethnic_background==1,"White","Not_white")))))


inc_ctrl <- ctrl %>%
  rename(colorectal_cancer_inc=cancer_case)
inc_df <- rbind(inc_crc,inc_ctrl)
table(inc_df$ethnic_background)
prop.table(table(inc_df$ethnic_background))



pre_ctrl <- ctrl %>%
  rename(colorectal_cancer_prev=cancer_case)
pre_df <- rbind(pre_crc,pre_ctrl)

table(pre_df$ethnic_background)
prop.table(table(pre_df$ethnic_background))


all_ctrl <- ctrl %>%
  rename(colorectal_cancer_case=cancer_case)
all_df <- rbind(all_crc,all_ctrl)

table(all_df$ethnic_background)
prop.table(table(all_df$ethnic_background))


# variant carriers --------------------------------------------------------

carrier <- read.csv("/Users/xingyifan/Library/CloudStorage/OneDrive-Nexus365/Yifan's DPhil Project/PhD Project/WES/Patho_variant_patient_mapping/patient_variant.csv")


caucasian <- read.csv("../Caucasian.csv")
caucasian <- caucasian %>%
  rename(eid=Participant.ID,
         ethnicity=Genetic.ethnic.grouping)
caucasian <- caucasian %>%
  mutate(ethnicity=ifelse(is.na(caucasian$ethnicity)==T,"Not Caucasian","Caucasian"))

ethnicity <- inner_join(carrier,caucasian,by='eid')
table(ethnicity$ethnicity)

inc_ethnicity <- inner_join(ethnicity,inc_crc,by='eid')
table(inc_ethnicity$ethnic_background)
table(inc_ethnicity$ethnicity)


pre_ethnicity <- inner_join(ethnicity,pre_crc,by='eid')
table(pre_ethnicity$ethnic_background)
table(pre_ethnicity$ethnicity)


all_ethnicity <- inner_join(ethnicity,all_crc,by='eid')
table(all_ethnicity$ethnic_background)
table(all_ethnicity$ethnicity)


ctrl_ethnicity <- inner_join(ethnicity,ctrl,by='eid')
table(ctrl_ethnicity$ethnic_background)
table(ctrl_ethnicity$ethnicity)
















