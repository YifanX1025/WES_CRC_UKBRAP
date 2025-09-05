# !/bin/bash
### CRC WES unconditional analysis for gene-centric coding
nullmodel="project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/Nullmodel/.Rdata"
path="project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/Gene_Centric_Coding/"

for CHR in {1..22}; do
dx run project-GyJ14jjJxy674xQ2pGQ5G3K6:/staarpipeline --priority=normal \
-inullobj_file=${nullmodel} \
-iagds_file=project-GyJ14jjJxy674xQ2pGQ5G3K6:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr${CHR}.pass.annotated.gds \
-iannotation_name_catalog_file=project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/Annotation_name_catalog.csv \
-itest_type="Gene_Centric_Coding" \
-iuser_cores=40 \
-ioutfile=crc_wes_gene_centric_coding_chr${CHR} \
-iannotation_dir=annotation/info/FunctionalAnnotation \
--destination=${path} --instance-type=mem3_ssd1_v2_x48 --yes
done
