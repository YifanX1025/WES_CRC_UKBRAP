# !/bin/bash

### CRC WES unconditional analysis for single
nullmodel="CRC WGS:/STAAR/Nullmodel/.Rdata"
path="CRC WGS:/STAAR/Single/"

for CHR in {1..22}; do
dx run CRC\ WGS:/staarpipeline --priority=normal \
-inullobj_file=${nullmodel} \
-iagds_file=CRC\ WGS:/UKB_500k_WGS_aGDS/ukb.500k.wgs.chr${CHR}.pass.annotated.gds \
-itest_type=Single \
-iuser_cores=16 \
-ioutfile=crc_wes_single_chr${CHR} \
--destination=${path} --instance-type="mem3_ssd1_v2_x64" --yes
done
