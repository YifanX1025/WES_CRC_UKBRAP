#!/usr/bin/env python3

import pandas as pd
import gzip
import re
import os
import time
import glob

def parse_vep_vcf(vcf_path):
    """Parse VEP-annotated VCF file and extract CSQ information"""
    csq_fields = []
    rows = []

    open_fn = gzip.open if vcf_path.endswith('.gz') else open

    with open_fn(vcf_path, 'rt') as f:
        for line in f:
            if line.startswith("##INFO=<ID=CSQ"):
                match = re.search(r'Format: (.+)">', line)
                if match:
                    csq_fields = match.group(1).split("|")
            elif line.startswith("#CHROM"):
                header = line.strip().split('\t')
                col_idx = {col: i for i, col in enumerate(header)}
            elif not line.startswith("#"):
                parts = line.strip().split('\t')
                chrom = parts[col_idx["#CHROM"]]
                pos = parts[col_idx["POS"]]
                ref = parts[col_idx["REF"]]
                alt = parts[col_idx["ALT"]]
                info = parts[col_idx["INFO"]]

                info_dict = dict(
                    [kv.split("=", 1) if "=" in kv else (kv, "") for kv in info.split(";")]
                )

                csq_values = info_dict.get("CSQ", "").split(",")
                for csq_entry in csq_values:
                    csq_data = csq_entry.split("|")
                    if len(csq_data) == len(csq_fields):
                        entry = dict(zip(csq_fields, csq_data))
                        entry["CHROM"] = chrom
                        entry["POS"] = pos
                        entry["REF"] = ref
                        entry["ALT"] = alt
                        rows.append(entry)

    df = pd.DataFrame(rows)

    # Reorder columns to place CHROM, POS, REF, ALT first
    front_cols = ["CHROM", "POS", "REF", "ALT"]
    all_cols = front_cols + [col for col in df.columns if col not in front_cols]

    return df[all_cols]

def main():
    base_dir = "/Volumes/T7/WES/wes_vep/vep_annotation"
    
    print("=== VCF to CSV conversion for chromosomes 1-22 ===")
    print("Method: Python pandas with PICK=1 filtering")
    print("")
    
    # Track totals
    total_processed = 0
    total_failed = 0
    total_variants = 0
    total_csv_rows = 0
    start_time = time.time()
    
    # Process each chromosome
    for chrom in range(1, 23):
        print(f"=== Processing chromosome {chrom} ===")
        
        vcf_file = os.path.join(base_dir, f"c{chrom}_simp_norm_vep.vcf")
        csv_file = os.path.join(base_dir, f"c{chrom}_simp_norm_vep.csv")
        
        if os.path.exists(vcf_file):
            try:
                print(f"  Processing {vcf_file}...")
                
                # Parse VCF and filter for PICK=1
                df_vep = parse_vep_vcf(vcf_file)
                df_filtered = df_vep[df_vep['PICK'] == '1']
                
                # Save to CSV
                df_filtered.to_csv(csv_file, index=False)
                
                # Report results
                csv_rows = len(df_filtered)
                file_size = f"{os.path.getsize(csv_file) / (1024*1024):.1f}MB"
                print(f"  ✅ Saved: {csv_file}")
                print(f"  📊 Rows: {csv_rows:,}, Size: {file_size}")
                
                total_variants += len(df_vep)
                total_csv_rows += csv_rows
                total_processed += 1
                
            except Exception as e:
                print(f"  ❌ Error processing {vcf_file}: {str(e)}")
                total_failed += 1
        else:
            print(f"  ❌ Skipping: {vcf_file} not found")
            total_failed += 1
        
        print("")
    
    # Processing summary
    end_time = time.time()
    duration = int(end_time - start_time)
    
    print("=========================================")
    print("=== CONVERSION COMPLETE ===")
    print("=========================================")
    print(f"Successfully processed: {total_processed} chromosomes")
    print(f"Failed:                {total_failed} chromosomes")
    print(f"Total processing time:  {duration} seconds")
    print(f"Total original consequences: {total_variants:,}")
    print(f"Total PICK=1 rows in CSV: {total_csv_rows:,}")
    
    if total_variants > 0:
        percentage = (total_csv_rows / total_variants) * 100
        print(f"PICK=1 represents {percentage:.1f}% of all consequences")
    
    # Show created files
    print("\n=== Files created ===")
    csv_files = glob.glob(os.path.join(base_dir, "c*_simp_norm_vep.csv"))
    for csv_file in sorted(csv_files):
        size = f"{os.path.getsize(csv_file) / (1024*1024):.1f}MB"
        filename = os.path.basename(csv_file)
        print(f"{size:>8} {filename}")
    
    print("\n=== CSV files created ===")
    for csv_file in sorted(csv_files):
        size = f"{os.path.getsize(csv_file) / (1024*1024):.1f}MB"
        filename = os.path.basename(csv_file)
        print(f"{size:>8} {filename}")

if __name__ == "__main__":
    main()