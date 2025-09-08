# !/bin/bash


# CHR1
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr1 && 
  wget -c -O chr1.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170506 && 
  tar -xzf chr1.tar.gz -C favordb_chr1 --strip-components=7 && 
  ls -la favordb_chr1
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr1" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR2
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr2 && 
  wget -c -O chr2.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170501 && 
  tar -xzf chr2.tar.gz -C favordb_chr2 --strip-components=7 && 
  ls -la favordb_chr2
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr2" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR3
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr3 && 
  wget -c -O chr3.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170502 && 
  tar -xzf chr3.tar.gz -C favordb_chr3 --strip-components=7 && 
  ls -la favordb_chr3
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr3" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR4
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr4 && 
  wget -c -O chr4.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170521 && 
  tar -xzf chr4.tar.gz -C favordb_chr4 --strip-components=7 && 
  ls -la favordb_chr4
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr4" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR5
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr5 && 
  wget -c -O chr5.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170511 && 
  tar -xzf chr5.tar.gz -C favordb_chr5 --strip-components=7 && 
  ls -la favordb_chr5
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr5" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR6
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr6 && 
  wget -c -O chr6.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170516 && 
  tar -xzf chr6.tar.gz -C favordb_chr6 --strip-components=7 && 
  ls -la favordb_chr6
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr6" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR7
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr7 && 
  wget -c -O chr7.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170505 && 
  tar -xzf chr7.tar.gz -C favordb_chr7 --strip-components=7 && 
  ls -la favordb_chr7
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr7" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR8
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr8 && 
  wget -c -O chr8.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170513 && 
  tar -xzf chr8.tar.gz -C favordb_chr8 --strip-components=7 && 
  ls -la favordb_chr8
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr8" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR9
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr9 && 
  wget -c -O chr9.tar.gz https://dataverse.harvard.edu/api/access/datafile/6165867 && 
  tar -xzf chr9.tar.gz -C favordb_chr9 --strip-components=7 && 
  ls -la favordb_chr9
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr9" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR10
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr10 && 
  wget -c -O chr10.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170507 && 
  tar -xzf chr10.tar.gz -C favordb_chr10 --strip-components=7 && 
  ls -la favordb_chr10
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr10" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR11
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr11 && 
  wget -c -O chr11.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170517 && 
  tar -xzf chr11.tar.gz -C favordb_chr11 --strip-components=7 && 
  ls -la favordb_chr11
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr11" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR12
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr12 && 
  wget -c -O chr12.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170520 && 
  tar -xzf chr12.tar.gz -C favordb_chr12 --strip-components=7 && 
  ls -la favordb_chr12
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr12" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR13
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr13 && 
  wget -c -O chr13.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170503 && 
  tar -xzf chr13.tar.gz -C favordb_chr13 --strip-components=7 && 
  ls -la favordb_chr13
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr13" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR14
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr14 && 
  wget -c -O chr14.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170509 && 
  tar -xzf chr14.tar.gz -C favordb_chr14 --strip-components=7 && 
  ls -la favordb_chr14
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr14" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR15
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr15 && 
  wget -c -O chr15.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170515 && 
  tar -xzf chr15.tar.gz -C favordb_chr15 --strip-components=7 && 
  ls -la favordb_chr15
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr15" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR16
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr16 && 
  wget -c -O chr16.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170518 && 
  tar -xzf chr16.tar.gz -C favordb_chr16 --strip-components=7 && 
  ls -la favordb_chr16
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr16" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR17
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr17 && 
  wget -c -O chr17.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170510 && 
  tar -xzf chr17.tar.gz -C favordb_chr17 --strip-components=7 && 
  ls -la favordb_chr17
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr17" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR18
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr18 && 
  wget -c -O chr18.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170508 && 
  tar -xzf chr18.tar.gz -C favordb_chr18 --strip-components=7 && 
  ls -la favordb_chr18
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr18" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR19
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr19 && 
  wget -c -O chr19.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170514 && 
  tar -xzf chr19.tar.gz -C favordb_chr19 --strip-components=7 && 
  ls -la favordb_chr19
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr19" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR20
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr20 && 
  wget -c -O chr20.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170512 && 
  tar -xzf chr20.tar.gz -C favordb_chr20 --strip-components=7 && 
  ls -la favordb_chr20
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr20" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR21
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr21 && 
  wget -c -O chr21.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170519 && 
  tar -xzf chr21.tar.gz -C favordb_chr21 --strip-components=7 && 
  ls -la favordb_chr21
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr21" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high


# CHR22
dx run swiss-army-knife \
  -icmd="
  mkdir -p favordb_chr22 && 
  wget -c -O chr22.tar.gz https://dataverse.harvard.edu/api/access/datafile/6170504 && 
  tar -xzf chr22.tar.gz -C favordb_chr22 --strip-components=7 && 
  ls -la favordb_chr22
  " \
  --instance-type "mem2_ssd2_v2_x16" \
  --name "favordb_chr22" \
  --destination "CRC WGS:/FAVORDB/" \
  --yes \
  --brief \
  --priority high
