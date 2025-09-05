# !/bin/bash

### CRC WES unconditional analysis for single
nullmodel="project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/Nullmodel/.Rdata"
path="project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/Single/"

for CHR in {1..22}; do
dx run project-GyJ14jjJxy674xQ2pGQ5G3K6:/staarpipeline --priority=normal \
-inullobj_file=${nullmodel} \
-iagds_file=project-GyJ14jjJxy674xQ2pGQ5G3K6:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr${CHR}.pass.annotated.gds \
-itest_type="Single" \
-iuser_cores=16 \
-ioutfile=crc_wes_single_chr${CHR} \
--destination=${path} --instance-type="mem3_ssd1_v2_x64" --yes
done
