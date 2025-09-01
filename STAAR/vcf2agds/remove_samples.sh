# !/bin/bash
# Only keep samples in intersections of GRM, WES and phenotype samples.

# Submit 22 parallel jobs to filter samples from VCF files (one job per chromosome)

for chr in {1..22}; do
    echo "Submitting job for chromosome $chr..."
    
    dx run swiss-army-knife \
      -iin="CRC WGS:/Step2_vcf_merged_500k/ukb23157_c${chr}_merged_v1_staar_trimmed.vcf.gz" \
      -iin="CRC WGS:/Step2_vcf_merged_500k/ukb23157_c${chr}_merged_v1_staar_trimmed.vcf.gz.tbi" \
      -iin="CRC WGS:/UKB_500k_WGS_aGDS/keep.ids" \
      -y --brief \
      -icmd="
        # Set output directory
        input_vcf=\"ukb23157_c${chr}_merged_v1_staar_trimmed.vcf.gz\"
        input_index=\"ukb23157_c${chr}_merged_v1_staar_trimmed.vcf.gz.tbi\"
        keep_file=\"keep.ids\"
        output_file=\"chr${chr}.filtered.vcf.gz\"
        
        # Filter samples using bcftools
        echo 'Filtering samples for chromosome ${chr}...'
        bcftools view -S \$keep_file \$input_vcf -O z -o \$output_file
        
        # Index the filtered VCF
        bcftools index -t \$output_file
        
        # Report statistics
        echo 'Original samples:' \$(bcftools query -l \$input_vcf | wc -l)
        echo 'Filtered samples:' \$(bcftools query -l \$output_file | wc -l)
        echo 'Variants:' \$(bcftools view -H \$output_file | wc -l)
        echo 'Completed chromosome ${chr}'
        
        # List output files
        ls -lh *.vcf.gz*
      " \
      --instance-type mem1_ssd1_v2_x8 \
      --name "UKB_VCF_filter_chr${chr}" \
      --destination "CRC WGS:/Step2_vcf_merged_500k/filtered/" \
      --priority normal
      
    echo "Job submitted for chromosome $chr"
done

echo "All 22 jobs submitted!"
