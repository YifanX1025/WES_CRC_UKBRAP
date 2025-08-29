#!/bin/bash
# Because I didn't extract FORMAT/DP data, I cannot use functions (Seq2SNP_wFilter and SNP2BED_wFilter) of R package FastSparseGRM.
# Instead of using R package and GDS files, I use plink to make .bed files.


################# STEP1 INSTALL PLINK #################

# Create a directory for binaries
mkdir -p ~/bin
cd ~/bin

# Download PLINK for Mac ARM64
curl -O https://s3.amazonaws.com/plink1-assets/plink_mac_20250819.zip
unzip plink_mac_20250819.zip
chmod +x plink

# Add to your PATH
echo 'export PATH=$PATH:~/bin' >> ~/.zshrc
source ~/.zshrc

# Test it works
plink --version



################# STEP2 MAKE BED FILE OF CHR14 AND EXTRACT SAMPLES #################

## The sample numbers are different in each chromosome VCF file.
## In chr 1-3,5,7,11,13,18-22, there are 469,555 samples.
## In chr 4,6,8-10,12,14-17, there are 469,392 samples.
## Select the less one, 469,392 samples .
## Extract the smallest VCF file which has 469,392 samples, chr14.

plink --vcf ukb23157_c14_merged_v1_staar_trimmed.vcf.gz --vcf-half-call missing --maf 0.01 --geno 0.1 --make-bed --out chr14_filtered

## The --vcf-half-call missing option treats half-calls (like "0/.") as completely missing genotypes.
## Alternative options for half-calls:

## --vcf-half-call missing - treat as missing (recommended)
## --vcf-half-call haploid - treat as haploid calls
## --vcf-half-call reference - assume missing allele is reference

# Extract chr14 sample IDs from the filtered BED file:
# Get sample IDs from chr14 (first two columns of .fam file)
cut -f1-2 chr14_filtered.fam > chr14_samples_plink.txt



################# STEP3 PROCESS ALL CHROMOSOMES WITH CONSISTENT SAMPLES #################

# Process each chromosome with chr14 sample list
for CHR in {1..22}; do
  echo "Processing chromosome ${CHR}..."
  
  plink --vcf ukb23157_c${CHR}_merged_v1_staar_trimmed.vcf.gz \
        --vcf-half-call missing \
        --keep chr14_samples_plink.txt \
        --maf 0.01 \
        --geno 0.1 \
        --make-bed \
        --out chr${CHR}_filtered
  
  echo "Chromosome ${CHR} completed"
done

# Verify sample consistency
# Check that all chromosomes have the same sample count
for i in {1..22}; do
  wc -l chr${i}_filtered.fam
done



################# STEP4 MERGE ALL CHROMOSOMES #################

# Create merge list
for i in {2..22}; do
  echo "chr${i}_filtered"
done > merge_list.txt

# Merge all chromosomes
plink --bfile chr1_filtered --merge-list merge_list.txt --make-bed --out chrall









