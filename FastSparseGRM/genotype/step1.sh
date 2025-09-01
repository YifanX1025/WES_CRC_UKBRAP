# !/bin/bash

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/chrall_pruned.bed" \
  -iin="CRC WGS:/GRM/chrall_pruned.bim" \
  -iin="CRC WGS:/GRM/chrall_pruned.fam" \
  -y --brief \
  -icmd="
    apt-get update && apt-get -y install git && 
    git clone https://github.com/rounakdey/FastSparseGRM.git && 
    cd /home/dnanexus/out/out && cp ./FastSparseGRM/extdata/king . &&
    chmod +x king && ./king -b chrall_pruned.bed --ibdseg --degree 4 --cpus 24 --prefix output
  " \
  --instance-type mem2_ssd1_v2_x32 \
  --name "GRM_step1" \
  --destination "CRC\ WGS:/GRM/"
