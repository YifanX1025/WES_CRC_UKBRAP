#!/bin/bash
# normalisation.sh - Normalise simplified pVCF files



# Download the FASTA file used in VEP for normalising simplified pVCF files
wget -c https://ftp.ensembl.org/pub/release-114/fasta/homo_sapiens/dna_index/Homo_sapiens.GRCh38.dna.toplevel.fa.gz
wget -c https://ftp.ensembl.org/pub/release-114/fasta/homo_sapiens/dna_index/Homo_sapiens.GRCh38.dna.toplevel.fa.gz.fai
wget -c https://ftp.ensembl.org/pub/release-114/fasta/homo_sapiens/dna_index/Homo_sapiens.GRCh38.dna.toplevel.fa.gz.gzi

# Normalisation
for c in {1..22}; do
    bcftools annotate \
        --rename-chrs chr2ensembl.tsv \
        -Oz -o c${c}_nochr.vcf.gz c${c}_merged_simplified.vcf.gz && \
    gzcat c${c}_nochr.vcf.gz | \
    bcftools norm -f Homo_sapiens.GRCh38.dna.toplevel.fa.gz -m -any -c w | \
    bgzip > c${c}_simp_norm.vcf.gz && \
    bcftools index -t c${c}_simp_norm.vcf.gz
done
