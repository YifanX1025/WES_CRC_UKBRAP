# !/bin/bash
# https://docs.google.com/document/d/1-3PxZ7r5ZqOBQmr7i-LOPLbd2PpYuMBpv3p2k3AQ4Q0/edit?pli=1&tab=t.0
###### RUN NULL MODEL AND WAIT FOR IT TO COMPLETE ######

### CRC WES null model
pheno="CRC\ WGS:/STAAR/phenotype_covars_combined.csv"
path="CRC\ WGS:/STAAR/Nullmodel/"

dx run CRC\ WGS:/staarpipeline \
-ipheno_file=${pheno} \
-igrm_file=CRC\ WGS:/GRM/converted.sparseGRM.sGRM.RData \
-ipheno_id=eid \
-icovariates="age_c,age2_c,sex,age_c_sex,age2_c_sex,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10" \
-iphenotype=case_status \
-ioutfile="crc_wes_nullmodel" \
-itest_type="Null" \
--priority=normal \
--destination=${path} --instance-type="mem3_ssd1_v2_x4" --yes
