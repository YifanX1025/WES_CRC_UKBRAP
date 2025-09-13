# !/bin/bash
# https://docs.google.com/document/d/1-3PxZ7r5ZqOBQmr7i-LOPLbd2PpYuMBpv3p2k3AQ4Q0/edit?pli=1&tab=t.0
###### RUN NULL MODEL AND WAIT FOR IT TO COMPLETE ######

# Define variables with proper quoting
pheno="project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/age_sex_ethnicity_PC1_10/phenotype_covars_combined.csv"
path="project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/age_sex_ethnicity_PC1_10/Nullmodel/"
grm_file="project-GyJ14jjJxy674xQ2pGQ5G3K6:/GRM/converted.sparseGRM.sGRM.RData"

# Run the dx command with proper quoting
dx run project-GyJ14jjJxy674xQ2pGQ5G3K6:/staarpipeline \
-ipheno_file=${pheno} \
-igrm_file=${grm_file} \
-ipheno_id=eid \
-icovariates="age_c,age2_c,sex,ethnicity,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
-iphenotype=case_status \
-ioutfile="crc_wes_nullmodel" \
-itest_type="Null" \
--priority=normal \
--destination=${path} \
--instance-type="mem3_ssd1_v2_x4" \
--yes
