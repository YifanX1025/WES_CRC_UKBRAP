# !/bin/bash
path="project-GyJ14jjJxy674xQ2pGQ5G3K6:/STAAR/Unconditional_Single"


dx run CRC\ WGS:/staarpipelinesummary_varset \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr1.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr2.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr3.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr4.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr5.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr6.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr7.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr8.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr9.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr10.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr11.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr12.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr13.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr14.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr15.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr16.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr17.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr18.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr19.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr20.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr21.Rdata \
-iinfiles=CRC\ WGS:/STAAR/Single/crc_wes_single_chr22.Rdata \
-itest_type=Single \
-iinfile_prefix=crc_wes_single_chr \
-ioutfile=crc_wes \
-iagds_file_name=ukb.500k.wes.chr.pass.annotated.gds \
--destination=${path} --instance-type="mem2_ssd1_v2_x32" --yes
