# Simplify VCF files for chromosomes 1-22 using swiss-army-knife
import subprocess

# Configuration
chromosomes = list(range(1, 23))  # 1 to 22
files_processed = []
files_failed = []

# DNAnexus paths - update these according to your project
dx_input_path = "project-GyJ14jjJxy674xQ2pGQ5G3K6:/Step2_vcf_merged_500k/filtered/"  # Input VCF directory
dx_output_path = "project-GyJ14jjJxy674xQ2pGQ5G3K6:/Step2_vcf_merged_500k_simplified_normalised/filtered/"  # Output destination
tag_str = "bcftools_simplify_vcfs"

print("=" * 60)
print("SIMPLIFYING VCF FILES FOR CHROMOSOMES 1-22")
print("=" * 60)

for chrom in chromosomes:
    chrom_str = str(chrom)

    # Input and output file names
    input_vcf = f"c{chrom_str}_norm_multi_split.vcf.gz"
    input_index = f"c{chrom_str}_norm_multi_split.vcf.gz.tbi"
    output_vcf = f"c{chrom_str}_merged_simplified.vcf.gz"
    output_index = f"c{chrom_str}_merged_simplified.vcf.gz.tbi"

    print(f"Processing chromosome {chrom_str}: {input_vcf} -> {output_vcf}")

    try:
        # Instance type - mem1_ssd1_v2_x2 should be sufficient for bcftools operations
        mem_level = "mem1_ssd1_v2_x2"

        # BCFtools command pipeline - FIXED: Using escaped quotes for proper shell execution
        bcftools_cmd = (
            f'echo \\"=== Processing chromosome {chrom_str} ===\\" && '
            f'pwd && ls -la && '
            f'echo \\"Input files available:\\" && '
            f'ls -la {input_vcf} && '

            # BCFtools pipeline: view -G | annotate 
            f'bcftools view -G {input_vcf} | '
            f'bcftools annotate -Oz -x INFO,ID,QUAL,FILTER > {output_vcf} && '

            # Create index
            f'bcftools index -t {output_vcf} && '

            # Verify outputs
            f'echo \\"Output files created:\\" && '
            f'ls -la {output_vcf}* && '
            f'echo \\"File sizes:\\" && '
            f'du -h {output_vcf}* && '
            f'echo \\"=== Chromosome {chrom_str} completed successfully ===\\"'
        )

        # Input file specification
        dx_input_str = (
            f'-iin="{dx_input_path}{input_vcf}" '
            f'-iin="{dx_input_path}{input_index}"'
        )

        # Final dx command
        dx_command = (
            f'dx run app-swiss-army-knife '
            f'--instance-type {mem_level} '
            f'--priority normal '
            f'-y --brief '
            f'{dx_input_str} '
            f'-icmd="{bcftools_cmd}" '
            f'--destination {dx_output_path} '
            f'--tag "{tag_str}" '
            f'--name "BCFtools_simplify_chr{chrom_str}" '
            f'--property chromosome={chrom_str}'
        )

        print(f"Instance type: {mem_level}")
        print("✅ BCFtools view -G (remove genotypes)")
        print("✅ BCFtools annotate -x INFO,ID,QUAL,FILTER (remove fields)")
        print("✅ BGzip compression + tabix indexing")
        print("-" * 40)

        print(f"Submitting job for chromosome {chrom_str}...")

        # Execute the command - using ! for Jupyter notebook execution
        subprocess.run(dx_command, shell=True, check=True)

        print(f"✅ Successfully submitted chromosome {chrom_str}")
        files_processed.append(chrom_str)

    except Exception as e:
        print(f"❌ Exception processing chromosome {chrom_str}: {str(e)}")
        files_failed.append(chrom_str)

    print("=" * 60)

print("\n" + "=" * 60)
print("PROCESSING SUMMARY")
print("=" * 60)
print(f'Chromosomes successfully submitted: {len(files_processed)}')
print(f'Chromosomes that failed: {len(files_failed)}')

if files_processed:
    print(f'\n✅ Successfully processed chromosomes: {", ".join(files_processed)}')

if files_failed:
    print(f'\n❌ Failed chromosomes: {", ".join(files_failed)}')

print(f"\n📊 All jobs submitted with tag: {tag_str}")
print(f"🔍 Monitor progress with: dx find jobs --tag {tag_str}")
print(f"📁 Output files will be saved to: {dx_output_path}")

# Additional monitoring commands
print("\n" + "=" * 60)
print("USEFUL MONITORING COMMANDS")
print("=" * 60)
print(f"# Check job status:")
print(f"dx find jobs --tag {tag_str} --state running")
print(f"dx find jobs --tag {tag_str} --state done")
print(f"dx find jobs --tag {tag_str} --state failed")
print("")
print(f"# Check output files:")
print(f"dx ls {dx_output_path}")
print("")
print(f"# Download a specific file:")
print(f"dx download {dx_output_path}c1_merged_simplified.vcf.gz")
print("=" * 60)
