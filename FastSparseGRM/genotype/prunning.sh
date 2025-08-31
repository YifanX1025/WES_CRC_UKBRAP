#!/bin/bash

# Prunning selected genotype data
# Using dx run swiss-army-knife

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/chrall.bed" \
  -iin="CRC WGS:/GRM/chrall.bim" \
  -iin="CRC WGS:/GRM/chrall.fam" \
  -iin="CRC WGS:/GRM/chrall.pruned_r05.prune.in"\
  -y --brief \
  -icmd="
  plink --bfile chrall --extract chrall.pruned_r05.prune.in --make-bed --out chrall_pruned
  " \
  --instance-type mem1_ssd1_v2_x8 \
  --name "chrall_prunning" \
  --destination "CRC\ WGS:/GRM/"
