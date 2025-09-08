#!/usr/bin/env python3

import subprocess
import sys
import time

def run_dx_command(command, chr_num):
    """Execute dx command and handle errors"""
    print(f'\n=== Processing chromosome {chr_num} ===')
    print(f'Command: {command}')
    
    try:
        # Run the command and capture output
        result = subprocess.run(command, shell=True, check=True, 
                              capture_output=True, text=True)
        
        # Extract job ID from output
        job_id = result.stdout.strip()
        print(f'✓ Job submitted successfully for chromosome {chr_num}')
        print(f'  Job ID: {job_id}')
        return job_id
        
    except subprocess.CalledProcessError as e:
        print(f'✗ Error submitting job for chromosome {chr_num}:')
        print(f'  Return code: {e.returncode}')
        print(f'  Error: {e.stderr}')
        return None

def main():
    # DNAnexus job tag and project ID
    job_tag = 'filtered'
    proj_id = 'project-GyJ14jjJxy674xQ2pGQ5G3K6'
    
    # Paths
    dx_ex_vcf_path = f"{proj_id}:/Step2_vcf_merged_500k/"
    dx_vcf_out_path = f"{proj_id}:/Step2_vcf_merged_500k/{job_tag}/"
    dx_resource_path = f"{proj_id}:/GRCh38_resources/"
    
    # Resource files
    diff_bed = 'GRCh38_alldifficultregions.bed.gz'
    ref_genome = 'GRCh38_full_analysis_set_plus_decoy_hla.fa'
    
    # Check if user wants to process specific chromosomes
    if len(sys.argv) > 1:
        chromosomes = [int(x) for x in sys.argv[1:]]
        print(f"Processing specified chromosomes: {chromosomes}")
    else:
        chromosomes = list(range(1, 23))
        print("Processing all chromosomes 1-22")
    
    # Store job IDs for monitoring
    submitted_jobs = []
    
    # Process each chromosome
    for chr_num in chromosomes:
        print(f'\n--- Preparing chromosome {chr_num} ---')
        
        # Define input and output files
        vcf_file = f"ukb23157_c{chr_num}_merged_v1_staar_trimmed.vcf.gz"
        vcf_outfile = f"c{chr_num}_norm_multi_split.vcf.gz"
        
        # Build bcftools commands (using 8 threads)
        bcftools_cmd1 = f"bcftools view -Ou --max-alleles 5 -T ^{diff_bed} --threads 8 {vcf_file}"
        bcftools_cmd2 = f"bcftools norm -Ou -m - -f {ref_genome} --threads 8"
        bcftools_cmd3 = f"bcftools +fill-tags -Oz --threads 8 -- -t all -o {vcf_outfile}"
        bcftools_cmd4 = f"bcftools index -t --threads 8 {vcf_outfile}"
        
        # Chain commands
        bcftools_pipeline = " | ".join([bcftools_cmd1, bcftools_cmd2, bcftools_cmd3])
        bcftools_command = " && ".join([bcftools_pipeline, bcftools_cmd4])
        
        # Prepare DNAnexus input files
        dx_inputs = [
            f'-iin="{dx_ex_vcf_path}/{vcf_file}"',
            f'-iin="{dx_ex_vcf_path}/{vcf_file}.tbi"',
            f'-iin="{dx_resource_path}/{diff_bed}"',
            f'-iin="{dx_resource_path}/{ref_genome}"',
            f'-iin="{dx_resource_path}/{ref_genome}.fai"'
        ]
        dx_input_str = ' '.join(dx_inputs)
        
        # Build dx command
        dx_command = (f'dx run swiss-army-knife --instance-type mem1_ssd1_v2_x8 '
                     f'-y --brief {dx_input_str} -icmd="{bcftools_command}" '
                     f'--destination {dx_vcf_out_path} --tag "{job_tag}" '
                     f'--name "vcf_norm_chr{chr_num}"')
        
        # Submit job
        job_id = run_dx_command(dx_command, chr_num)
        if job_id:
            submitted_jobs.append((chr_num, job_id))
        else:
            print(f"Failed to submit chromosome {chr_num}. Continuing with others...")
            
        # Small delay to avoid overwhelming the API
        time.sleep(1)
    
    # Summary
    print(f'\n=== SUBMISSION SUMMARY ===')
    print(f'Successfully submitted: {len(submitted_jobs)} jobs')
    print(f'Failed submissions: {len(chromosomes) - len(submitted_jobs)}')
    
    if submitted_jobs:
        print(f'\nSubmitted jobs:')
        for chr_num, job_id in submitted_jobs:
            print(f'  Chromosome {chr_num}: {job_id}')
        
        print(f'\nMonitor jobs with:')
        print(f'  dx watch {" ".join([job_id for _, job_id in submitted_jobs])}')
        
        print(f'\nCheck job status:')
        for chr_num, job_id in submitted_jobs:
            print(f'  dx describe {job_id}  # Chromosome {chr_num}')

if __name__ == "__main__":
    main()