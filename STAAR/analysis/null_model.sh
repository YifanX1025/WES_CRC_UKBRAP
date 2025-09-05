# !/bin/bash
# https://docs.google.com/document/d/1-3PxZ7r5ZqOBQmr7i-LOPLbd2PpYuMBpv3p2k3AQ4Q0/edit?pli=1&tab=t.0
###### RUN NULL MODEL AND WAIT FOR IT TO COMPLETE ######

### Example: TOPMed lipids F8 null model
pheno="CRC WGS:/STAAR/phenotype_covars_combined.csv"
path="CRC WGS:/STAAR"

dx run Commons_Tools:/staarpipeline_v0.9.6 \
-ipheno_file=${pheno} \
-igrm_file=cdbg:/GRMs/freeze.8/pcrelate_kinshipMatrix_sparseDeg4_v2.Rda \
-ipheno_id=sample.id \
-icovariates="age,age2,sex,group,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11" \
-ihet_vars="group" \
-iphenotype=LDL_ADJ.norm \
-ioutfile="LDL_F8_nullmodel" \
-itest_type="Null" \
--priority=low \
--destination=${path} --instance-type="mem3_ssd1_v2_x4" --yes
