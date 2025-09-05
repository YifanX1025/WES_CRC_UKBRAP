# !/bin/bash
### CRC WES unconditional analysis for single
nullmodel="CRC WGS:/STAAR/.Rdata"
path="CRC WGS:/STAAR/"

for CHR in {1..22}; do
dx run staarpipeline --priority=low \
-inullobj_file=${nullmodel} \
-iagds_file=cdbg:/Genotypes/freeze.8/DP0/AGDS_uncompressed/freeze.8.chr${CHR}.pass_and_fail.gtonly.minDP0.gds \
-itest_type=Single \
-iuser_cores=16 \
-ioutfile=LDL_F8_single_chr${CHR} \
--destination=${path} --instance-type="mem3_ssd1_v2_x64" --yes
done
