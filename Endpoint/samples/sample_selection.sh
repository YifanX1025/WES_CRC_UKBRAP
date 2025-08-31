#!bin/bash

# 1) Extract IDs
## Grab EIDs where cancer_case == 0 (controls)
awk -F, 'NR>1 && $5==0 {print $1}' cancer/all_cancer_cases.csv | sort -u > controls_eids.txt

## Grab EIDs where colorectal_cancer_case == 1 (cases)
awk -F, 'NR>1 && $5==1 {print $1}' censoring/all_CRC_cases.csv | sort -u > crc_case_eids.txt

## Combine (union) into one list of EIDs
cat controls_eids.txt crc_case_eids.txt | sort -u > combined_eids.txt
wc -l controls_eids.txt crc_case_eids.txt combined_eids.txt   # counts

## Sanity-check there’s no overlap (should be zero)
comm -12 controls_eids.txt crc_case_eids.txt | wc -l

## Make a PLINK --keep file (FID IID; UKB usually FID=IID=EID)
awk '{print $1, $1}' combined_eids.txt > combined_fam.txt

awk '{print $1" "$2}' "ukb_qc_filtered_c22.fam" | sort -u > fam.ids
awk '{print $1" "$2}' "combined_fam.txt" | sort -u > pheno.ids

## Make a labeled phenotype CSV (0=control, 1=case)
{ echo "eid,is_crc_case";
  awk -F, 'NR>1 && $5==1 {print $1",1"}' censoring/all_CRC_cases.csv;
  awk -F, 'NR>1 && $5==0 {print $1",0"}' cancer/all_cancer_cases.csv;
} | awk -F, 'NR==1 || !seen[$1]++' > combined_labels.csv

# 2) Intersection (present in BOTH fam and phenotype)
comm -12 pheno.ids fam.ids > keep.ids

# 3) (Optional) remove withdrawn participants
if [ -s "${WITHDRAWN}" ]; then
  sort -u "${WITHDRAWN}" > withdrawn.ids
  comm -23 keep.ids withdrawn.ids > keep.nowithdrawn.ids
  mv keep.nowithdrawn.ids keep.ids
fi

# keep.ids now has one EID per line — perfect for aGDS:
# In R: seqSetFilter(g, sample.id = scan("keep.ids", what=""))

# 4) (Optional) also create a PLINK --keep (FID IID) from the same set
awk '{print $1, $1}' keep.ids > keep.plink.txt

# 5) Quick counts
echo "phenotype IDs:  $(wc -l < pheno.ids)"
echo ".fam IDs:       $(wc -l < fam.ids)"
echo "keep (both):    $(wc -l < keep.ids)"






