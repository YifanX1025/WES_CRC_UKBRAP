#!/usr/bin/env python3

from io import StringIO
import numpy as np
import pandas as pd
from subprocess import call, check_output, CalledProcessError
import time
import sys

# Configuration parameters
tag_str = 'genotype_filter_qc'  # DNAnexus job tag

# Project paths
project_path = 'project-GyJ14jjJxy674xQ2pGQ5G3K6:/'

# Input genotype path (corrected path)
dx_geno_path = project_path + "Bulk/Genotype Results/Genotype calls/"

# Output path for QC'd files
dx_out_path = project_path + "GRM/"


# QC parameters (easily adjustable)
QC_PARAMS = {
    'maf': 0.05,                # Minor allele frequency
    'geno': 0.05,               # Variant missingness
    'mind': 0.05,               # Sample missingness  
    'hwe': '1e-5 0.001',        # Hardy-Weinberg p-value
    'instance_type': 'mem2_ssd1_v2_x8'
}

print("="*60)
print("UKB GENOTYPE QC FILTERING PIPELINE")
print("="*60)
print(f"Project: {project_path}")
print(f"Input path: {dx_geno_path}")
print(f"Output path: {dx_out_path}")
print(f"QC Parameters: {QC_PARAMS}")
print("="*60)

# Create output folder
try:
    print("Creating output directory...")
    result = check_output(f'dx mkdir -p {dx_out_path}', shell=True, text=True)
    print("✓ Output directory created successfully")
except CalledProcessError as e:
    print(f"⚠ Output directory may already exist: {e}")

# Verify sample file exists
sample_file = "chr14_samples_plink.txt"
try:
    result = check_output(f'dx ls {dx_out_path}{sample_file}', shell=True, text=True)
    print(f"✓ Sample file found: {sample_file}")
except CalledProcessError:
    print(f"❌ ERROR: Sample file not found at {dx_out_path}{sample_file}")
    print("Please upload your sample file first!")
    sys.exit(1)

# Define chromosomes to process (1-22)
chromosomes = list(range(1, 22))
print(f"Processing {len(chromosomes)} chromosomes: {chromosomes}")

# Process each chromosome
chromosomes_processed = []
chromosomes_failed = []
job_ids = []

for chrom in chromosomes:
    chrom_str = str(chrom)
    
    # Input and output file names
    input_bed = f"ukb22418_c{chrom_str}_b0_v2.bed"
    input_bim = f"ukb22418_c{chrom_str}_b0_v2.bim"
    input_fam = f"ukb22418_c{chrom_str}_b0_v2.fam"
    sample_id = sample_file
    output_prefix = f"ukb_qc_filtered_c{chrom_str}"
    
    print(f"\n{'='*50}")
    print(f"Processing Chromosome {chrom_str}")
    print(f"{'='*50}")
    
    # Check if input files exist
    input_files_exist = True
    for input_file in [input_bed, input_bim, input_fam]:
        try:
            check_output(f'dx ls "{dx_geno_path}{input_file}"', shell=True, text=True)
            print(f"✓ Found: {input_file}")
        except CalledProcessError:
            print(f"❌ Missing: {input_file}")
            input_files_exist = False
    
    if not input_files_exist:
        print(f"⚠ Skipping chromosome {chrom_str} - missing input files")
        chromosomes_failed.append(chrom_str)
        continue
    
    try:
        # Enhanced PLINK2 command with comprehensive QC
        plink_cmd = (
            f"echo 'Starting QC for chromosome {chrom_str}...' && "
            f"mkdir -p chr{chrom_str} && "
            f"plink2 "
            f"--bed {input_bed} "
            f"--bim {input_bim} "
            f"--fam {input_fam} "
            f"--keep {sample_id} "
            f"--maf {QC_PARAMS['maf']} "
            f"--geno {QC_PARAMS['geno']} "
            f"--mind {QC_PARAMS['mind']} "
            f"--hwe {QC_PARAMS['hwe']} "
            f"--autosome "
            f"--snps-only "
            f"--rm-dup exclude-all "
            f"--max-alleles 2 "
            f"--make-bed "
            f"--out chr{chrom_str}/{output_prefix} && "
            f"echo 'QC completed for chromosome {chrom_str}' && "
            f"echo 'Generating QC report...' && "
            f"plink2 --bfile chr{chrom_str}/{output_prefix} "
            f"--freq --missing --hardy "
            f"--out chr{chrom_str}/{output_prefix}_qc_report && "
            f"echo 'Final file check:' && "
            f"ls -la chr{chrom_str}/{output_prefix}.* && "
            f"echo 'Variants: ' $(wc -l < chr{chrom_str}/{output_prefix}.bim) && "
            f"echo 'Samples: ' $(wc -l < chr{chrom_str}/{output_prefix}.fam)"
        )
        
        # Input files for dx command
        dx_input_str = (
            f'-iin="{dx_geno_path}{input_bed}" '
            f'-iin="{dx_geno_path}{input_bim}" '
            f'-iin="{dx_geno_path}{input_fam}" '
            f'-iin="{dx_out_path}{sample_id}"'
        )
        
        # Final dx command with enhanced options
        dx_command = (
            f'dx run app-swiss-army-knife '
            f'--instance-type {QC_PARAMS["instance_type"]} '
            f'--priority normal '
            f'-y --brief '
            f'{dx_input_str} '
            f'-icmd="{plink_cmd}" '
            f'--destination {dx_out_path} '
            f'--tag "{tag_str}" '
            f'--tag "chromosome_{chrom_str}" '
            f'--name "qc_filter_chr{chrom_str}" '
            f'--property chromosome={chrom_str} '
            f'--property qc_maf={QC_PARAMS["maf"]} '
            f'--property qc_geno={QC_PARAMS["geno"]} '
            f'--property qc_mind={QC_PARAMS["mind"]}'
        )
        
        print(f"Submitting job for chromosome {chrom_str}...")
        print(f"Instance type: {QC_PARAMS['instance_type']}")
        print(f"Command: {plink_cmd[:100]}...")
        
        # Execute the command and capture job ID
        result = check_output(dx_command, shell=True, text=True)
        job_id = result.strip()
        job_ids.append(job_id)
        
        print(f"✓ Job submitted successfully: {job_id}")
        chromosomes_processed.append(chrom_str)
        
        # Small delay to avoid overwhelming the system
        time.sleep(2)
        
    except CalledProcessError as e:
        print(f"❌ Failed to process chromosome {chrom_str}: {str(e)}")
        chromosomes_failed.append(chrom_str)
    except Exception as e:
        print(f"❌ Unexpected error for chromosome {chrom_str}: {str(e)}")
        chromosomes_failed.append(chrom_str)

# Final summary
print("\n" + "="*60)
print("PROCESSING SUMMARY")
print("="*60)
print(f'✓ Chromosomes successfully submitted: {len(chromosomes_processed)}/{len(chromosomes)}')
print(f'❌ Chromosomes that failed: {len(chromosomes_failed)}')

if chromosomes_processed:
    print(f'\n📋 Processed chromosomes: {", ".join(chromosomes_processed)}')

if chromosomes_failed:
    print(f'\n⚠ Failed chromosomes: {", ".join(chromosomes_failed)}')
    print("You may want to retry these manually.")

if job_ids:
    print(f'\n🆔 Job IDs submitted:')
    for i, job_id in enumerate(job_ids, 1):
        print(f'  {i:2d}. {job_id}')

print(f"\n🏷 All jobs tagged with: {tag_str}")
print(f"📊 QC Parameters applied:")
for param, value in QC_PARAMS.items():
    if param != 'instance_type':
        print(f"   {param.upper()}: {value}")

print(f"\n📁 Output location: {dx_out_path}")

print("\n" + "="*60)
print("MONITORING COMMANDS")
print("="*60)
print(f"Monitor all jobs:     dx find jobs --tag {tag_str}")
print(f"Monitor running:      dx find jobs --tag {tag_str} --state running")
print(f"Monitor completed:    dx find jobs --tag {tag_str} --state done")
print(f"Monitor failed:       dx find jobs --tag {tag_str} --state failed")
print(f"Watch specific job:   dx watch <job_id>")
print(f"List output files:    dx ls {dx_out_path}")

# Create a monitoring script
monitoring_script = f"""#!/bin/bash
echo "=== QC Job Monitoring ==="
echo "Tag: {tag_str}"
echo "Output path: {dx_out_path}"
echo ""

echo "Job Status Summary:"
echo "Running:   $(dx find jobs --tag {tag_str} --state running --brief | wc -l)"
echo "Done:      $(dx find jobs --tag {tag_str} --state done --brief | wc -l)"
echo "Failed:    $(dx find jobs --tag {tag_str} --state failed --brief | wc -l)"
echo ""

echo "Completed Output Files:"
dx ls {dx_out_path} | grep "ukb_qc_filtered_c.*\\.bed" | wc -l
echo "/22 chromosome files completed"

echo ""
echo "To check specific chromosome:"
echo "dx ls {dx_out_path} | grep ukb_qc_filtered_c1"
echo ""
echo "To download results:"
echo "dx download {dx_out_path} -r"
"""

with open('monitor_qc_jobs.sh', 'w') as f:
    f.write(monitoring_script)

print(f"\n📝 Monitoring script created: monitor_qc_jobs.sh")
print("   Run with: bash monitor_qc_jobs.sh")

print("\n✅ All jobs submitted successfully!")
print("Your QC-filtered genotype files will be ready for the FastSparseGRM pipeline.")