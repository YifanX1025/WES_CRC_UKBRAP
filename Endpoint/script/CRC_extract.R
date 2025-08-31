#### Endpoint data extraction
# Load the packages

library(dplyr)
library(tidyr)
library(tidyverse)

# Set the default path

setwd("/Users/xingyifan/Desktop/CRC/endpoint data/raw_data")

# Import datasets (raw data)


# Censoring  ------------------------------------

#Import selected censoring variables

selected_censoring_variables <- read.csv("censoring_variables.csv")

### Death endpoint

selected_censoring_variables$death_ep <- 1
selected_censoring_variables$death_ep[is.na(selected_censoring_variables$date_of_death)] <- 0

table(selected_censoring_variables$death_ep, useNA = "ifany")

### Censoring date

# Date lost to follow-up (priority 1)

selected_censoring_variables$end_date <- selected_censoring_variables$date_lost_to_follow_up

# Death date (priority 2)

selected_censoring_variables$end_date[is.na(selected_censoring_variables$date_lost_to_follow_up)] <- selected_censoring_variables$date_of_death[is.na(selected_censoring_variables$date_lost_to_follow_up)]

# Study end date based on location using index of multiple deprivation (priority 3) 

# End dates set depending on data sources used (amend if using Cancer Registry only)

selected_censoring_variables$end_date[is.na(selected_censoring_variables$end_date) & !is.na(selected_censoring_variables$index_of_multiple_deprivation_wales)]   <-"2022-05-31"    # (cancer registry only 2016-12-31)
selected_censoring_variables$end_date[is.na(selected_censoring_variables$end_date) & !is.na(selected_censoring_variables$index_of_multiple_deprivation_scotland)]<-"2022-08-31"    # (cancer registry only 2021-11-31)
selected_censoring_variables$end_date[is.na(selected_censoring_variables$end_date) & !is.na(selected_censoring_variables$index_of_multiple_deprivation_england)] <-"2022-10-31"    # (cancer registry only 2020-12-31)

# Study end date based on location using uk assessment centre (priority 4) 

selected_censoring_variables$end_date[is.na(selected_censoring_variables$end_date) & selected_censoring_variables$ukb_assessment_centre %in% c(11003,11022,11023)]<-"2022-05-31"   # Wales centres    (cancer registry only 2016-12-31)
selected_censoring_variables$end_date[is.na(selected_censoring_variables$end_date) & selected_censoring_variables$ukb_assessment_centre %in% c(11004,11005)]<-"2022-08-31"         # Scotland centres (cancer registry only 2021-11-31)
selected_censoring_variables$end_date[is.na(selected_censoring_variables$end_date)]<-"2022-10-31"                                                          # England centres  (cancer registry only 2020-12-31)

data_censoring<-selected_censoring_variables 


# CANCER REGISTRY ---------------------------------------------------------



# 40006 ICD-10: Diagnoses           (MULTI-CATEGORICAL)
# 40013 ICD-9:  Diagnoses           (MULTI-CATEGORICAL)
# 40005 ICD-10: Date of diagnoses   (MULTI-CATEGORICAL)
# 41270 ICD-10: Diagnoses           (MULTI-CATEGORICAL)
# 41271 ICD-9:  Diagnoses           (MULTI-CATEGORICAL)
# 41280 ICD-10: Date of diagnoses   (MULTI-CATEGORICAL)
# 41281 ICD-9:  Date of diagnoses   (MULTI-CATEGORICAL)

# Import cancer registry data

cancer_reg_icd9 <- read.csv("cancer_reg_icd9.csv")
cancer_reg_icd10 <- read.csv("cancer_reg_icd10.csv")
cancer_reg_icd10_date <- read.csv("cancer_reg_icd10_date.csv")

data_cr <- merge(cancer_reg_icd10,cancer_reg_icd9,all.x = T)
data_cr <- merge(data_cr,cancer_reg_icd10_date,all.x = T)
data_cr <- merge(data_censoring,data_cr,all.x = T)

var<-names(data_cr)[grep("date_of_cancer_diagnosis",names(data_cr))]

for (i in var){
  
  data_cr[[i]][is.na(data_cr[[i]])]<-data_cr$end_date[is.na(data_cr[[i]])]
  
}

write.csv(data_cr,"../censoring/data_cr.csv",row.names = F)


# HOSPITAL INPATIENT ------------------------------------------------------

# Field 41270 ICD-10: Diagnoses         (MULTI-CATEGORICAL) 
# Field 41271 ICD-9:  Diagnoses         (MULTI-CATEGORICAL) 
# Field 41280 ICD-10: Date of diagnoses (MULTI-CATEGORICAL) 
# Field 41281 ICD-9:  Date of diagnoses (MULTI-CATEGORICAL) 

# Import hes data

hes_icd10_9 <- read.csv("hes_icd10_9.csv")
hes_icd9_date <- read.csv("hes_icd9_date.csv")
hes_icd10_date <- read.csv("hes_icd10_date.csv")

data_hes <- merge(hes_icd10_9,hes_icd10_date,all.x = T)
data_hes <- merge(data_hes,hes_icd9_date,all.x = T)
data_hes <- merge(data_censoring,data_hes,all.x = T)

var<-names(data_hes)[grep("date_of_first_in_patient_diagnosis_icd10.0.|date_of_first_in_patient_diagnosis_icd9.0.",names(data_hes))]

for (i in var){
  
  data_hes[[i]][is.na(data_hes[[i]])]<-data_hes$end_date[is.na(data_hes[[i]])]
  
}

write.csv(data_hes,"../censoring/data_hes.csv",row.names = F)


# Selected baseline variables ---------------------------------------------

# Field 34    year_of_birth_baseline (duplicated in dataset)
# Field 31    sex
# Field 189   townsend_deprivation_index_at_recruitment (missing in dataset)
# Field 21003 age_when_attended_assessment_centre (rename as age_at_study_date)
# Field 21000 ethnic_background
# Field 1289  cooked_vegetable_intake
# Field 1299  salad_raw_vegetable_intake
# Field 3436  age_started_smoking_in_current_smokers
# Field 2867  age_started_smoking_in_former_smokers
# Field 20116 smoking_status    
# Field 20160 ever_smoked  
# Field 20001 cancer_code_self_reported                     # MULTI-CATEGORICAL (coding 3)
# Field 20002 non_cancer_illness_code_self_reported         # MULTI-CATEGORICAL (coding 6)
# Field 20004 operation_code                                # MULTI-CATEGORICAL (coding 5)

selected_baseline_variables <- read.csv("selected_baseline_variables.csv")
cancer_diagnosed_by_doctor <- read.csv("cancer_diagnosed_by_doctor.csv")
operation_code <- read.csv("operation_code.csv")
cancer_code_self_reported <- read.csv("cancer_code_self_reported.csv")
non_cancer_illness_code_self_reported <- read.csv("non_cancer_illness_code_self_reported.csv")

data <- merge(selected_baseline_variables,cancer_code_self_reported,all.x = T)
data <- merge(data,cancer_diagnosed_by_doctor,all.x = T)
data <- merge(data,operation_code,all.x = T)
data <- merge(data,non_cancer_illness_code_self_reported,all.x = T)

data <- data %>%
  select(grep(str_c(c("eid",
                      "sex.0.0",
                      "age_when_attended_assessment_centre.0.0",
                      "ethnic_background.0.",
                      "year_of_birth_baseline.0.0",
                      "cooked_vegetable_intake.0.",
                      "salad_raw_vegetable_intake.0.",
                      "age_started_smoking_in_current_smokers.0.",
                      "age_started_smoking_in_former_smokers.0.",
                      "smoking_status.0.",
                      "ever_smoked.0.",
                      "cancer_diagnosed_by_doctor.0.0",
                      "operation_code.0",
                      "cancer_code_self_reported.0",
                      "non_cancer_illness_code_self_reported.0"),
                    collapse="|"),names(data)))

data <- data %>% 
  rename(sex                           = sex.0.0,
         age_at_study_date             = age_when_attended_assessment_centre.0.0,
         year_of_birth                 = year_of_birth_baseline.0.0,
         ethnic_background             = ethnic_background.0.0,
         cancer_diagnosed_by_doctor    = cancer_diagnosed_by_doctor.0.0)


write.csv(data,"../censoring/data.csv",row.names = F)


# Cancer registry - incident disease --------------------------------------

data_cr <- read.csv("../censoring/data_cr.csv")

d1<-c(disease="colon_cancer",                                icd10="^C18")  # Colon cancer
d2<-c(disease="rectal_cancer",                               icd10="^C20")  # Rectum cancer
d3<-c(disease="rectosigmoid_junction_cancer",                icd10="^C19")  # Rectosigmoid junction cancer 
d4<-c(disease="colorectal_cancer",                           icd10="^C18|^C20|^C19")    # Colorectal cancer 

dd<-as.data.frame(rbind(d1,d2,d3,d4))

# ICD-10 diagnosis

for(i in 1:nrow(dd)) {   # Loop through each disease
  
  disease_name <- dd$disease[i]
  icd10_pattern <- dd$icd10[i]
  
  # Initialize variables
  data_cr[[paste0(disease_name, "_inc_cr")]] <- 0
  data_cr[[paste0(disease_name, "_inc_date_cr")]] <- data_cr$end_date
  
  # Get all columns matching "type_of_cancer_icd10"
  icd10_columns <- grep("type_of_cancer_icd10", names(data_cr), value=TRUE)
  
  for(ii in seq_along(icd10_columns)) {  # Loop through ICD-10 columns
    icd10_col <- icd10_columns[ii]
    diagnosis_date_col <- gsub("type_of_cancer_icd10", "date_of_cancer_diagnosis", icd10_col)
    
    if (diagnosis_date_col %in% names(data_cr)) {
      
      # Find matching cases using grepl()
      match_idx <- grepl(icd10_pattern, data_cr[[icd10_col]]) & (data_cr[[diagnosis_date_col]] > data_cr$study_date)
      
      # Assign 1 to incident cases
      data_cr[[paste0(disease_name, "_inc_cr")]][match_idx] <- 1
      
      # Assign earliest diagnosis date
      data_cr[[paste0(disease_name, "_inc_date_cr")]][match_idx & 
                                                        (data_cr[[diagnosis_date_col]] < data_cr[[paste0(disease_name, "_inc_date_cr")]])] <- 
        data_cr[[diagnosis_date_col]][match_idx]
    }
  }
  # Convert to factor
  data_cr[[paste0(disease_name, "_inc_cr")]] <- as.factor(data_cr[[paste0(disease_name, "_inc_cr")]])
  
  # Print summary table
  print(paste("Disease:", disease_name))
  print(table(data_cr[[paste0(disease_name, "_inc_cr")]], useNA="ifany"))
}



# Cancer registry - prevalent disease -------------------------------------

d1<-c(disease="colon_cancer",                         icd9="^153",                    icd10="^C18")  # Colon cancer
d2<-c(disease="rectal_cancer",                        icd9="1541",                    icd10="^C20")  # Rectum cancer
d3<-c(disease="rectosigmoid_junction_cancer",         icd9="1540",                    icd10="^C19")  # Rectosigmoid junction cancer 
d4<-c(disease="colorectal_cancer",                    icd9="^153|1541|1540",          icd10="^C18|^C20|^C19")    # Colorectal cancer 

dd<-as.data.frame(rbind(d1,d2,d3,d4))

for(i in 1:length(dd$disease)){
  
  
  data_cr[[paste0(dd$disease[i],"_prev_cr")]]<-0
  
  for(ii in 0:(length(grep("type_of_cancer_icd10",names(data_cr),value=TRUE))-1)){
    
    data_cr[[paste0(dd$disease[i],"_prev_cr")]][(data_cr[[paste0("type_of_cancer_icd10.",ii,".0")]] %in% unique(grep(dd$icd10[i],data_cr[[paste0("type_of_cancer_icd10.",ii,".0")]],value=TRUE))) &
                                                  data_cr[[paste0("date_of_cancer_diagnosis.",ii,".0")]] < data_cr$study_date]<-1
    
    
    print(table(data_cr[[paste0(dd$disease[i],"_prev_cr")]],useNA="ifany"))
    
  }
  
  
  for(ii in 0:(length(grep("type_of_cancer_icd9",names(data_cr),value=TRUE))-1)){
    
    data_cr[[paste0(dd$disease[i],"_prev_cr")]][(data_cr[[paste0("type_of_cancer_icd9.",ii,".0")]] %in% unique(grep(dd$icd9[i],data_cr[[paste0("type_of_cancer_icd9.",ii,".0")]],value=TRUE)))]<-1
    
    
    print(table(data_cr[[paste0(dd$disease[i],"_prev_cr")]],useNA="ifany"))
    
  }
  
  data_cr[[paste0(dd$disease[i],"_prev_cr")]]<-as.factor(data_cr[[paste0(dd$disease[i],"_prev_cr")]])
  
}

data_cr<-data_cr %>% select(grep(str_c(c("eid","inc_cr","inc_date_cr","prev_cr"),collapse="|"),names(data_cr)))

colon_cr <- subset(data_cr, select = c(eid,
                                       colon_cancer_inc_cr,
                                       colon_cancer_inc_date_cr,
                                       colon_cancer_prev_cr))

rectal_cr <- subset(data_cr, select = c(eid,
                                        rectal_cancer_inc_cr,
                                        rectal_cancer_inc_date_cr,
                                        rectal_cancer_prev_cr))

rectosigmoid_junction_cr <- subset(data_cr, select = c(eid,
                                                       rectosigmoid_junction_cancer_inc_cr,
                                                       rectosigmoid_junction_cancer_inc_date_cr,
                                                       rectosigmoid_junction_cancer_prev_cr))

colorectal_cr <- subset(data_cr, select = c(eid,
                                            colorectal_cancer_inc_cr,
                                            colorectal_cancer_inc_date_cr,
                                            colorectal_cancer_prev_cr))

write.csv(colon_cr,"../censoring/colon_cr.csv",row.names = F)
write.csv(rectal_cr,"../censoring/rectal_cr.csv",row.names = F)
write.csv(rectosigmoid_junction_cr,"../censoring/rectosigmoid_junction_cr.csv",row.names = F)
write.csv(colorectal_cr,"../censoring/colorectal_cr.csv",row.names = F)


# Hospital inpatient - incident diseases ----------------------------------

d1<-c(disease="colon_cancer",                         icd9="^153",                    icd10="^C18")  # Colon cancer
d2<-c(disease="rectal_cancer",                        icd9="1541",                    icd10="^C20")  # Rectum cancer
d3<-c(disease="rectosigmoid_junction_cancer",         icd9="1540",                    icd10="^C19")  # Rectosigmoid junction cancer 
d4<-c(disease="colorectal_cancer",                    icd9="^153|1541|1540",          icd10="^C18|^C20|^C19")    # Colorectal cancer 


dd<-as.data.frame(rbind(d1,d2,d3,d4))

for(i in 1:length(dd$disease)){
  
  data_hes[[paste0(dd$disease[i],"_inc_hip")]]<-0
  data_hes[[paste0(dd$disease[i],"_inc_date_hip")]]<-data_hes$end_date
  
  # ICD-10 diagnosis (incident)
  
  for(ii in 0:(length(grep("diagnoses_icd10.0.",names(data_hes),value=TRUE))-1)){
    
    data_hes[[paste0(dd$disease[i],"_inc_hip")]][(data_hes[[paste0("diagnoses_icd10.0.",ii)]] %in% unique(grep(dd$icd10[i],data_hes[[paste0("diagnoses_icd10.0.",ii)]],value=TRUE))) &
                                                   data_hes[[paste0("date_of_first_in_patient_diagnosis_icd10.0.",ii)]] > data_hes$study_date]<-1
    
    data_hes[[paste0(dd$disease[i],"_inc_date_hip")]][(data_hes[[paste0("diagnoses_icd10.0.",ii)]] %in% unique(grep(dd$icd10[i],data_hes[[paste0("diagnoses_icd10.0.",ii)]],value=TRUE))) &
                                                        data_hes[[paste0("date_of_first_in_patient_diagnosis_icd10.0.",ii)]] > data_hes$study_date & 
                                                        data_hes[[paste0("date_of_first_in_patient_diagnosis_icd10.0.",ii)]] < data_hes[[paste0(dd$disease[i],"_inc_date_hip")]]]<-data_hes[[paste0("date_of_first_in_patient_diagnosis_icd10.0.",ii)]][(data_hes[[paste0("diagnoses_icd10.0.",ii)]] %in% unique(grep(dd$icd10[i],data_hes[[paste0("diagnoses_icd10.0.",ii)]],value=TRUE))) &
                                                                                                                                                                                                                                                          data_hes[[paste0("date_of_first_in_patient_diagnosis_icd10.0.",ii)]] > data_hes$study_date & 
                                                                                                                                                                                                                                                          data_hes[[paste0("date_of_first_in_patient_diagnosis_icd10.0.",ii)]] < data_hes[[paste0(dd$disease[i],"_inc_date_hip")]]]
    
    print(table(data_hes[[paste0(dd$disease[i],"_inc_hip")]],useNA="ifany"))
    
  }
  
  # ICD-9 diagnosis (incident)  
  
  for(ii in 0:(length(grep("diagnoses_icd9.0.",names(data_hes),value=TRUE))-1)){
    
    data_hes[[paste0(dd$disease[i],"_inc_hip")]][(data_hes[[paste0("diagnoses_icd9.0.",ii)]] %in% unique(grep(dd$icd9[i],data_hes[[paste0("diagnoses_icd9.0.",ii)]],value=TRUE))) &
                                                   data_hes[[paste0("date_of_first_in_patient_diagnosis_icd9.0.",ii)]] > data_hes$study_date]<-1
    
    data_hes[[paste0(dd$disease[i],"_inc_date_hip")]][(data_hes[[paste0("diagnoses_icd9.0.",ii)]] %in% unique(grep(dd$icd9[i],data_hes[[paste0("diagnoses_icd9.0.",ii)]],value=TRUE))) &
                                                        data_hes[[paste0("date_of_first_in_patient_diagnosis_icd9.0.",ii)]] > data_hes$study_date & 
                                                        data_hes[[paste0("date_of_first_in_patient_diagnosis_icd9.0.",ii)]] < data_hes[[paste0(dd$disease[i],"_inc_date_hip")]]]<-data_hes[[paste0("date_of_first_in_patient_diagnosis_icd9.0.",ii)]][(data_hes[[paste0("diagnoses_icd9.0.",ii)]] %in% unique(grep(dd$icd9[i],data_hes[[paste0("diagnoses_icd9.0.",ii)]],value=TRUE))) &
                                                                                                                                                                                                                                                        data_hes[[paste0("date_of_first_in_patient_diagnosis_icd9.0.",ii)]] > data_hes$study_date & 
                                                                                                                                                                                                                                                        data_hes[[paste0("date_of_first_in_patient_diagnosis_icd9.0.",ii)]] < data_hes[[paste0(dd$disease[i],"_inc_date_hip")]]]
    
    
    print(table(data_hes[[paste0(dd$disease[i],"_inc_hip")]],useNA="ifany"))
    
  }
  
}



# Hospital inpatient - prevalent diseases ---------------------------------

d1<-c(disease="colon_cancer",                         icd9="^153",                    icd10="^C18")  # Colon cancer
d2<-c(disease="rectal_cancer",                        icd9="1541",                    icd10="^C20")  # Rectum cancer
d3<-c(disease="rectosigmoid_junction_cancer",         icd9="1540",                    icd10="^C19")  # Rectosigmoid junction cancer 
d4<-c(disease="colorectal_cancer",                    icd9="^153|1541|1540",          icd10="^C18|^C20|^C19")    # Colorectal cancer 


dd<-as.data.frame(rbind(d1,d2,d3,d4))

for(i in 1:length(dd$disease)){
  
  data_hes[[paste0(dd$disease[i],"_prev_hip")]]<-0
  
  # ICD-10 diagnosis (prevalent)
  
  for(ii in 0:(length(grep("diagnoses_icd10.0.",names(data_hes),value=TRUE))-1)){
    
    data_hes[[paste0(dd$disease[i],"_prev_hip")]][(data_hes[[paste0("diagnoses_icd10.0.",ii)]] %in% unique(grep(dd$icd10[i],data_hes[[paste0("diagnoses_icd10.0.",ii)]],value=TRUE))) &
                                                    data_hes[[paste0("date_of_first_in_patient_diagnosis_icd10.0.",ii)]] <= data_hes$study_date]<-1
    
    print(table(data_hes[[paste0(dd$disease[i],"_prev_hip")]],useNA="ifany"))
    
  }
  
  # ICD-9 diagnosis (prevalent)  
  
  for(ii in 0:(length(grep("diagnoses_icd9.0.",names(data_hes),value=TRUE))-1)){
    
    data_hes[[paste0(dd$disease[1],"_prev_hip")]][(data_hes[[paste0("diagnoses_icd9.0.",ii)]] %in% unique(grep(dd$icd9[i],data_hes[[paste0("diagnoses_icd9.0.",ii)]],value=TRUE))) &
                                                    data_hes[[paste0("date_of_first_in_patient_diagnosis_icd9.0.",ii)]] <= data_hes$study_date]<-1
    
    print(table(data_hes[[paste0(dd$disease[i],"_prev_hip")]],useNA="ifany"))
    
  }
  
  data_hes[[paste0(dd$disease[i],"_prev_hip")]]<-as.factor(data_hes[[paste0(dd$disease[i],"_prev_hip")]])
  
}

data_hes<-data_hes %>% select(grep(str_c(c("eid","inc_hip","inc_date_hip","prev_hip"),collapse="|"),names(data_hes)))

colon_hes <- subset(data_hes, select = c(eid,
                                         colon_cancer_inc_hip,
                                         colon_cancer_inc_date_hip,
                                         colon_cancer_prev_hip))

rectal_hes <- subset(data_hes, select = c(eid,
                                          rectal_cancer_inc_hip,
                                          rectal_cancer_inc_date_hip,
                                          rectal_cancer_prev_hip))

rectosigmoid_junction_hes <- subset(data_hes, select = c(eid,
                                                         rectosigmoid_junction_cancer_inc_hip,
                                                         rectosigmoid_junction_cancer_inc_date_hip,
                                                         rectosigmoid_junction_cancer_prev_hip))

colorectal_hes <- subset(data_hes, select = c(eid,
                                              colorectal_cancer_inc_hip,
                                              colorectal_cancer_inc_date_hip,
                                              colorectal_cancer_prev_hip))

write.csv(colon_hes,"../censoring/colon_hes.csv",row.names = F)
write.csv(rectal_hes,"../censoring/rectal_hes.csv",row.names = F)
write.csv(rectosigmoid_junction_hes,"../censoring/rectosigmoid_junction_hes.csv",row.names = F)
write.csv(colorectal_hes,"../censoring/colorectal_hes.csv",row.names = F)

# Cancer - self-reported --------------------------------------------------

table(data$cancer_code_self_reported.0.0)

disease <- c("colon_sigmoid_cancer", "rectal_cancer", "colorectal_cancer")

for(i in 1:length(disease)){  
  
  code <- switch(disease[i], 
                 colon_sigmoid_cancer   = c(1022),
                 rectal_cancer          = c(1023),
                 colorectal_cancer      = c(1020, 1022, 1023))
  
  data[[paste0(disease[i],"_sr")]]<-0
  for(ii in 0:(length(grep("cancer_code_self_reported",names(data)))-1)) {
    data[[paste0(disease[i],"_sr")]][data[[paste0("cancer_code_self_reported.0.",ii)]] %in% code]<-1
    print(table(data[[paste0(disease[i],"_sr")]],useNA="ifany"))
  }
}


# Non-cancer illnesses - self-reported ------------------------------------

table(data$non_cancer_illness_code_self_reported.0.0)
grep("non_cancer_illness_code_self_reported",names(data),value=TRUE)

disease<-c("asthma","diabetes","duodenal_ulcer","gall_dis","gallstones","cholecystitis","copd")                     

for(i in 1:length(disease)){
  
  code <- switch(disease[i],
                 asthma                     = c(1111),  
                 diabetes                   = c(1220),  
                 duodenal_ulcer             = c(1457), 
                 gall_dis                   = c(1161), 
                 gallstones                 = c(1162),
                 cholecystitis              = c(1163),
                 copd                       = c(1112))            
  
  data[[paste0(disease[i],"_sr")]]<-0
  for(ii in 0:(length(grep("non_cancer_illness_code_self_reported",names(data)))-1)) {
    data[[paste0(disease[i],"_sr")]][data[[paste0("non_cancer_illness_code_self_reported.0.",ii)]] %in% c(code)]<-1
    print(table(data[[paste0(disease[i],"_sr")]],useNA="ifany"))
  }
  
}


# Operations - self reported ----------------------------------------------

grep("operation_code",names(data),value=TRUE)

disease<-c("large_bowel_resection_colostomy","rectal_or_colon_polypectomy","colectomy_hemicolectomy","rectal_sigmoid_resection",
           "abdominal_pelvic_adhesion_surgery","colostomy_surgery","colostomy_formation","colostomy_reversal",
           "anterior_resection","abdomino_perineal_resection_ap_resection")

for(i in 1:length(disease)){
  
  code<-switch(disease[i],
               large_bowel_resection_colostomy = c(1461),
               rectal_or_colon_polypectomy = c(1463), 
               colectomy_hemicolectomy = c(1464), 
               rectal_sigmoid_resection = c(1465),
               abdominal_pelvic_adhesion_surgery = c(1485),
               colostomy_surgery = c(1574),
               colostomy_formation = c(1575),
               colostomy_reversal = c(1576),
               anterior_resection = c(1577),
               abdomino_perineal_resection_ap_resection = c(1578))  
  
  data[[paste0(disease[i],"_op")]]<-0
  for(ii in 0:(length(grep("operation_code",names(data)))-1)) {
    data[[paste0(disease[i],"_op")]][data[[paste0("operation_code.0.",ii)]] %in% code]<-1
    print(table(data[[paste0(disease[i],"_op")]],useNA="ifany"))
  }
}

data_list <- list(data_censoring,
                  data_cr,
                  data_hes,
                  data)      

data<- data_list %>% reduce(inner_join, by='eid')

rm(data_censoring)
rm(data_hes)
rm(data_cr)

# Composite prevalent illnesses (cancer) ---------------------------------------

data$colorectal_cancer_prev<-0
data$colorectal_cancer_prev[data$colorectal_cancer_prev_hip==1 | 
                              data$colorectal_cancer_sr==1 |
                              data$colorectal_cancer_prev_cr==1]<-1
table(data$colorectal_cancer_prev,useNA = "ifany")

prevalent_CRC_cases <- subset(data,select = c(eid,
                                              sex,
                                              age_at_study_date,
                                              ethnic_background,
                                              colorectal_cancer_prev))

write.csv(prevalent_CRC_cases,"../censoring/prevalent_CRC_cases.csv",row.names = F)



# Composite incident illness - colorectal cancer --------------------------

# Update incident colorectal cancer to include hospital inpatient diagnosis of colorectal cancer (ICD9 and ICD10)  

table(data$colorectal_cancer_inc_cr,useNA="ifany")

# Before promoting from cause of death, ensure the person is not already a prevalent case:
# Update incident colorectal cancer cases if underlying cause of death (ICD10) is colorectal cancer 

data$cause_of_death_CRC<-0
data$cause_of_death_CRC[grep("^C18|^C20|^C19",data$cause_of_death)]<-1

table(data$cause_of_death_CRC)

# Define incident CRC only in participants without prevalent CRC
data$colorectal_cancer_inc <- 0
data$colorectal_cancer_inc[(
  (data$colorectal_cancer_inc_cr == 1 | data$colorectal_cancer_inc_hip == 1 | data$cause_of_death_CRC == 1) &
    data$colorectal_cancer_prev == 0)] <- 1

# Assign the incident CRC date
data$colorectal_cancer_inc_date <- NA
data$colorectal_cancer_inc_date[data$colorectal_cancer_inc == 1] <- pmin(
  data$colorectal_cancer_inc_date_cr[data$colorectal_cancer_inc == 1],
  data$colorectal_cancer_inc_date_hip[data$colorectal_cancer_inc == 1],
  data$date_of_death[data$colorectal_cancer_inc == 1 & data$cause_of_death_CRC == 1],
  na.rm = TRUE
)

data$colorectal_cancer_inc <- as.factor(data$colorectal_cancer_inc)

table(data$colorectal_cancer_inc,useNA="ifany")

summary(data$colorectal_cancer_inc_date[data$colorectal_cancer_inc==1])

incident_CRC_cases <- subset(data,select = c(eid,
                                             sex,
                                             age_at_study_date,
                                             ethnic_background,
                                             colorectal_cancer_inc))

write.csv(incident_CRC_cases,"../censoring/incident_CRC_cases.csv",row.names = F)



# Double-Check the Overlap in R -------------------------------------------

incident_eids <- data$eid[data$colorectal_cancer_inc == 1]
prevalent_eids <- data$eid[data$colorectal_cancer_prev == 1]

# Intersect
overlap_eids <- intersect(incident_eids, prevalent_eids)
length(overlap_eids)  # Should be 0

# View overlapping rows
data[data$eid %in% overlap_eids, c("eid", "colorectal_cancer_inc", "colorectal_cancer_prev", "colorectal_cancer_inc_date", "study_date", "date_of_death")]

# Drop overlapping EIDs from incident cases
data$colorectal_cancer_inc[data$eid %in% overlap_eids] <- 0
data$colorectal_cancer_inc_date[data$eid %in% overlap_eids] <- NA

# These comparisons should be reliable only if all dates are proper Date types
str(data$study_date)
str(data$colorectal_cancer_inc_date_cr)


# Composite all colorectal cancer -----------------------------------------

data$colorectal_cancer_case <- 0
data$colorectal_cancer_case[data$colorectal_cancer_inc==1 |
                              data$colorectal_cancer_prev==1] <- 1
table(data$colorectal_cancer_case,useNA = "ifany")

all_CRC_cases <- subset(data,select = c(eid,
                                        sex,
                                        age_at_study_date,
                                        ethnic_background,
                                        colorectal_cancer_case))
table(all_CRC_cases$colorectal_cancer_case,useNA = "ifany")

write.csv(all_CRC_cases,"../censoring/all_CRC_cases.csv",row.names = F)










