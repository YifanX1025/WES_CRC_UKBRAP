#!/usr/bin/env python3

import pandas as pd
import gzip
import re
import os
import time
import glob


def parse_vep_vcf_chunked(vcf_path, chunk_size=10000):
    """Parse VEP-annotated VCF file in chunks and extract CSQ information"""
    csq_fields = []

    open_fn = gzip.open if vcf_path.endswith('.gz') else open

    # First pass: get CSQ format and header info
    col_idx = {}
    with open_fn(vcf_path, 'rt') as f:
        for line in f:
            if line.startswith("##INFO=<ID=CSQ"):
                match = re.search(r'Format: (.+)">', line)
                if match:
                    csq_fields = match.group(1).split("|")
            elif line.startswith("#CHROM"):
                header = line.strip().split('\t')
                col_idx = {col: i for i, col in enumerate(header)}
                break

    if not csq_fields or not col_idx:
        raise ValueError("Could not parse VCF header or CSQ format")

    # Second pass: process variants in chunks
    chunk_rows = []
    chunk_count = 0

    with open_fn(vcf_path, 'rt') as f:
        # Skip header lines
        for line in f:
            if line.startswith("#CHROM"):
                break

        # Process variant lines
        for line in f:
            if line.startswith("#"):
                continue

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

                    # Only keep PICK=1 entries
                    if entry.get("PICK") == "1":
                        chunk_rows.append(entry)

            # Yield chunk when it reaches desired size
            if len(chunk_rows) >= chunk_size:
                chunk_count += 1
                print(f"    Processing chunk {chunk_count} ({len(chunk_rows)} PICK=1 entries)...")

                df_chunk = pd.DataFrame(chunk_rows)
                front_cols = ["CHROM", "POS", "REF", "ALT"]
                all_cols = front_cols + [col for col in df_chunk.columns if col not in front_cols]
                yield df_chunk[all_cols]

                chunk_rows = []

        # Yield remaining rows
        if chunk_rows:
            chunk_count += 1
            print(f"    Processing final chunk {chunk_count} ({len(chunk_rows)} PICK=1 entries)...")

            df_chunk = pd.DataFrame(chunk_rows)
            front_cols = ["CHROM", "POS", "REF", "ALT"]
            all_cols = front_cols + [col for col in df_chunk.columns if col not in front_cols]
            yield df_chunk[all_cols]


def process_vcf_to_csv(vcf_file, csv_file, chunk_size=10000):
    """Process VCF file in chunks and save filtered results to CSV"""
    print(f"  Processing {vcf_file} in chunks of {chunk_size}...")

    first_chunk = True
    total_rows = 0

    for chunk_df in parse_vep_vcf_chunked(vcf_file, chunk_size):
        if first_chunk:
            # Write header and first chunk
            chunk_df.to_csv(csv_file, index=False, mode='w')
            first_chunk = False
        else:
            # Append subsequent chunks without header
            chunk_df.to_csv(csv_file, index=False, mode='a', header=False)

        total_rows += len(chunk_df)

    return total_rows


def main():
    base_dir = "/Volumes/T7/WES/wes_vep/vep_annotation"
    chunk_size = 5000  # Adjust this based on your system's memory

    print("=== VCF to CSV conversion for chromosomes 1-22 ===")
    print(f"Method: Chunked processing with chunk size {chunk_size}")
    print("Filtering: PICK=1 entries only")
    print("")

    # Track totals
    total_processed = 0
    total_failed = 0
    total_csv_rows = 0
    start_time = time.time()

    # Process each chromosome
    for chrom in range(1, 23):  # Changed back to 1-22
        print(f"=== Processing chromosome {chrom} ===")

        vcf_file = os.path.join(base_dir, f"c{chrom}_simp_norm_vep.vcf")
        csv_file = os.path.join(base_dir, f"c{chrom}_simp_norm_vep.csv")

        if os.path.exists(vcf_file):
            try:
                # Process with chunking
                csv_rows = process_vcf_to_csv(vcf_file, csv_file, chunk_size)

                # Report results
                file_size = f"{os.path.getsize(csv_file) / (1024 * 1024):.1f}MB"
                print(f"  Saved: {csv_file}")
                print(f"  PICK=1 rows: {csv_rows:,}, Size: {file_size}")

                total_csv_rows += csv_rows
                total_processed += 1

            except Exception as e:
                print(f"  Error processing {vcf_file}: {str(e)}")
                total_failed += 1
        else:
            print(f"  Skipping: {vcf_file} not found")
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
    print(f"Total PICK=1 rows in CSV: {total_csv_rows:,}")

    # Show created files
    print("\n=== Files created ===")
    csv_files = glob.glob(os.path.join(base_dir, "c*_simp_norm_vep.csv"))
    for csv_file in sorted(csv_files):
        if os.path.exists(csv_file):
            size = f"{os.path.getsize(csv_file) / (1024 * 1024):.1f}MB"
            filename = os.path.basename(csv_file)
            print(f"{size:>8} {filename}")


if __name__ == "__main__":
    main()
