# !/bin/bash

for chr in {1..22}; do
  dx run swiss-army-knife \
    -iin="ukb23157_c${chr}_merged_v1_staar_trimmed.vcf.gz" \
    -iin="ukb23157_c${chr}_merged_v1_staar_trimmed.vcf.gz.tbi" \
    -icmd="
      echo 'Processing chromosome $chr...' && 
      gzcat ukb23157_c${chr}_merged_v1_staar_trimmed.vcf.gz | awk 'BEGIN{OFS="\t"} /^#/ {print} !/^#/ {if($7==".") $7="PASS"; print}' | bgzip > ukb23157_c${chr}_merged_v1_staar_trimmed_fixed.vcf.gz && 
      tabix -p vcf ukb23157_c${chr}_merged_v1_staar_trimmed_fixed.vcf.gz
    " \
    --instance-type mem1_ssd1_v2_x2 \
    --name "fix_vcf_chr${chr}" \
    --destination "CRC WGS:/Step2_vcf_merged_500k/filtered/"
    -y --brief --priority normal
done
