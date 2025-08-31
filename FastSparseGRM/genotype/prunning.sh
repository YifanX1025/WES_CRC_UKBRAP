#!/bin/bash

# Prunning selected genotype data
# Using dx run swiss-army-knife

dx run swiss-army-knife \
  -iin="CRC WGS:/GRM/chrall.bed" \
  -iin="CRC WGS:/GRM/chrall.bim" \
  -iin="CRC WGS:/GRM/chrall.fam" \
  -y --brief \
  -icmd="
  plink --bfile chrall --indep-pairwise 50 5 0.1 --out chrall.prunedlist && 
  plink --bfile chrall --extract chrall.prunedlist.prune.in --make-bed --out chrall_pruned
  " \
  --instance-type mem1_ssd1_v2_x8 \
  --name "chrall_prunning" \
  --destination "CRC\ WGS:/GRM/"
