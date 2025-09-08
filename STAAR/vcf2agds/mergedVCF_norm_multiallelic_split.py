#!/usr/bin/env python3

import subprocess

# DNAnexus job tag and project ID
job_tag = 'filtered'
proj_id = 'project-GyJ14jjJxy674xQ2pGQ5G3K6'

# for exome analysis
dx_ex_vcf_path = f"{proj_id}:/Step2_vcf_merged_500k/"
# create vcf output folder
dx_vcf_out_path = f"{proj_id}:/Step2_vcf_merged_500k/{job_tag}/"

# DNAnexus resources
dx_resource_path = f"{proj_id}:/GRCh38_resources/"
diff_bed = 'GRCh38_alldifficultregions.bed.gz'
ref_genome = 'GRCh38_full_analysis_set_plus_decoy_hla.fa'

# Process chromosomes 1-22
for chr_num in range(1, 23):
    print(f'Processing chromosome {chr_num}')
    
    # Define input and output files
    vcf_file = f"ukb23157_c{chr_num}_merged_v1_staar_trimmed.vcf.gz"
    vcf_outfile = f"c{chr_num}_norm_multi_split.vcf.gz"
    
    # Build bcftools commands for filtering and normalizing variants
    # 1. View the input VCF with basic filters
    bcftools_cmd1 = f"bcftools view -Ou --max-alleles 5 -T ^{diff_bed} --threads 4 {vcf_file}"
    # 2. Normalize and split multiallelic variants first
    bcftools_cmd2 = f"bcftools norm -Ou -m - -f {ref_genome} --threads 4"
    # 3. Fill tags after normalization (so statistics are calculated correctly)
    bcftools_cmd3 = f"bcftools +fill-tags -Oz --threads 4 -- -t all -o {vcf_outfile}"
    
    # 4. Index the output VCF (uses multiple threads by default)
    bcftools_cmd4 = f"bcftools index -t --threads 4 {vcf_outfile}"
    
    # Chain the commands together
    bcftools_pipeline = " | ".join([bcftools_cmd1, bcftools_cmd2, bcftools_cmd3])
    bcftools_command = " && ".join([bcftools_pipeline, bcftools_cmd4])
    
    # Prepare DNAnexus input files
    dx_inputs = []
    dx_inputs.append(f'-iin="{dx_ex_vcf_path}/{vcf_file}"')
    dx_inputs.append(f'-iin="{dx_ex_vcf_path}/{vcf_file}.tbi"')
    dx_inputs.append(f'-iin="{dx_resource_path}/{diff_bed}"')
    dx_inputs.append(f'-iin="{dx_resource_path}/{ref_genome}"')
    dx_inputs.append(f'-iin="{dx_resource_path}/{ref_genome}.fai"')
    
    dx_input_str = ' '.join(dx_inputs)
    
    # Build the final dx command
    dx_command = (f'dx run swiss-army-knife --instance-type mem1_ssd1_v2_x8 -y --brief '
                 f'{dx_input_str} -icmd="{bcftools_command}" '
                 f'--destination {dx_vcf_out_path} --tag "{job_tag}"')
    
    print(f'Running command for chromosome {chr_num}')
    print(f'Command: {dx_command}')
    
    try:
        subprocess.run(dx_command, shell=True, check=True)
        print(f'Successfully processed chromosome {chr_num}')
    except subprocess.CalledProcessError as e:
        print(f'Error processing chromosome {chr_num}: {e}')
        break

print('VCF normalization and splitting completed!')
