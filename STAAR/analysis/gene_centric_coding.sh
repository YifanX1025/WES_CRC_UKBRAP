# !/bin/bash
### CRC WES unconditional analysis for gene-centric coding
nullmodel="CRC WGS:/STAAR/Nullmodel/.Rdata"
path="CRC WGS:/STAAR/Gene_Centric_Coding/"

for CHR in {1..22}; do
dx run CRC\ WGS:/staarpipeline --priority=low \
-inullobj_file=${nullmodel} \
-iagds_file=CRC\ WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr${CHR}.pass.annotated.gds \
-iannotation_name_catalog_file=cdbg_lipids_staartopmed:/TOPMed_lipids_F8_staarpipeline/Annotation_name_catalog.csv \
-itest_type=Gene_Centric_Coding \
-iuser_cores=40 \
-ioutfile=LDL_F8_gene_centric_coding_chr${CHR} \
-iannotation_dir=annotation/info/FunctionalAnnotation \
--destination=${path} --instance-type="mem3_ssd1_v2_x48" --yes
done
