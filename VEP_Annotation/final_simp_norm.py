#!/usr/bin/env python3


from io import StringIO
import numpy as np
import pandas as pd
from subprocess import call, run

# Configuration parameters

tag_str = 'VEP_WES_ANNOTATION'  # DNAnexus job tag

# Project paths
project_path = 'project-GyJ14jjJxy674xQ2pGQ5G3K6:/'

# Input VCF path (your merged files)
dx_vcf_path = project_path + "Step2_vcf_merged_500k_simplified_normalised/filtered/"

# Output VEP annotation path
dx_vep_out_path = project_path + "Step2_vcf_merged_500k_simplified_normalised/filtered/"

# Docker image path
dx_image_path = project_path + "vep/images/"


# Define chromosomes to process (1-22)
chromosomes = list(range(1, 23))

print(f"Processing chromosome {chromosomes}")

# Process each chromosome
chromosomes_processed = []
chromosomes_failed = []

for chrom in chromosomes:
    chrom_str = str(chrom)

    # Input and output file names
    input_vcf = f"c{chrom_str}_merged_simplified.vcf.gz"
    input_index = f"c{chrom_str}_merged_simplified.vcf.gz.tbi"
    vep_image_file = f"my_vep_complete_v3.0.tar.gz"  # My VEP Docker image
    output_vcf = f"c{chrom_str}_simp_norm_vep.vcf"

    print(f"Processing chromosome {chrom_str}: {input_vcf} -> {output_vcf}")

    try:
        # Instance type - upgraded for memory safety
        mem_level = "mem3_ssd3_x8"

        # CORRECTED: Understanding multiple input file locations
        vep_cmd = (
            # Debug - show where files actually are
            f"pwd && whoami && id && ls -la && "
            f"echo '=== Loading Docker image ===' && "
            f"docker load -i {vep_image_file} && "
            f"docker images && "
            
            # Simple approach: Direct Docker run with file mounts
            f"echo '=== Running VEP with proper multiple input handling ===' && "
            f"docker run "
            f"--user root "  # Root for permissions
            f"--rm "
            f"-v /home/dnanexus/out/out:/tmp:rw "                           # Output to /home/dnanexus/out/out directly
            f"-w /tmp "
            f"my_vep_complete:v3.0 "
            f"bash -c '"
            
            # VEP command - now with correct understanding of file locations
            f"echo \\\"Running as: $(whoami)\\\" && "
            f"echo \\\"Files available:\\\" && "
            f"ls -la /tmp/ && "
            f"pwd && whoami && id && ls -la && "
            
            # Run VEP with direct file references
            f"vep "
            f"--input_file {input_vcf} "
            f"--output_file {output_vcf} "           # Direct to /home/dnanexus/out/out
            f"--format vcf "
            f"--vcf "
            f"--offline "
            f"--allele_number "
            f"--cache "
            f"--dir_cache /opt/vep/.vep "
            f"--species homo_sapiens "
            f"--assembly GRCh38 "
            f"--flag_pick_allele_gene "
            f"--fork 8 "
            f"--force_overwrite "
            f"--no_check_variants_order "
            f"--check_existing "
            f"--fasta /data/homo_sapiens/114_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz "
            f"--no_stats "
            f"--everything "
            f"--plugin LoF,loftee_path:/plugins/loftee,human_ancestor_fa:/plugins/loftee/human_ancestor.fa.gz,conservation_file:/plugins/loftee/loftee.sql,gerp_bigwig:/plugins/loftee/gerp_conservation_scores.homo_sapiens.GRCh38.bw "
            f"--plugin CADD,snv=/plugins/CADD/whole_genome_SNVs.tsv.gz,indels=/plugins/CADD/gnomad.genomes.r4.0.indel.tsv.gz "
            f"--plugin AlphaMissense,file=/plugins/AlphaMissense/AlphaMissense_hg38.tsv.gz "
            f"--plugin pLI "
            f"--plugin SpliceAI,snv=/plugins/SpliceAI/spliceai_scores.raw.snv.hg38.vcf.gz,indel=/plugins/SpliceAI/spliceai_scores.raw.indel.hg38.vcf.gz "
            f"--buffer_size 5000 "
            f"--verbose && "

            f"echo \\\"Success! Output files:\\\" && "
            f"ls -la {output_vcf}' && "
            
            f"echo '=== VEP completed successfully ===' && "
            f"ls -la /home/dnanexus/out/out/{output_vcf}"
        )

        # Multiple input files (creates numbered subdirectories)
        dx_input_str = (
            f'-iin="{dx_vcf_path}{input_vcf}" '          
            f'-iin="{dx_vcf_path}{input_index}" '        
            f'-iin="{dx_image_path}{vep_image_file}" '   
        )

        # Final dx command
        dx_command = (
            f'dx run app-swiss-army-knife '
            f'--instance-type {mem_level} '
            f'--priority normal '
            f'-y --brief '
            f'{dx_input_str} '
            f'-icmd="{vep_cmd}" '
            f'--destination {dx_vep_out_path} '
            f'--tag "{tag_str}" '
            f'--name "VEP_chr{chrom_str}_fork8_buffer5000" '
            f'--property chromosome={chrom_str}'
        )


        print("Instance type: mem3_ssd3_x8")
        print("✅ Root user, 8 fork, 5000 buffer, no stats")
        print("✅ Direct /tmp output (no copying)")
        print("✅ Clean mount strategy")
        print("=" * 60)

        print(f"Submitting job for chromosome {chrom_str}...")

        # Execute the command
        subprocess.run(dx_command, shell=True, check=True)

        chromosomes_processed.append(chrom_str)

    except Exception as e:
        print(f"Failed to process chromosome {chrom_str}: {str(e)}")
        chromosomes_failed.append(chrom_str)

print("\n" + "=" * 50)
print("PROCESSING SUMMARY")
print("=" * 50)
print(f'Chromosomes successfully submitted: {len(chromosomes_processed)}')
print(f'Chromosomes that failed: {len(chromosomes_failed)}')

if chromosomes_processed:
    print(f'\nProcessed chromosomes: {", ".join(chromosomes_processed)}')

if chromosomes_failed:
    print(f'\nFailed chromosomes: {", ".join(chromosomes_failed)}')

print(f"\nAll jobs submitted with tag: {tag_str}")
print(f"Monitor progress with: dx find jobs --tag {tag_str}")
print("   but VEP needed path corrections!")
