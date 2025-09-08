# !/bin/bash

dx run swiss-army-knife \
  -icmd="
  apt-get update && apt-get -y install git && 
  git clone https://github.com/xihaoli/STAAR.git
  " \
  --instance-type "mem1_ssd1_v2_x2" \
  --name "staar_git" \
  --destination "CRC WGS:/STAAR/" \
  --yes \
  --brief \
  --priority normal
