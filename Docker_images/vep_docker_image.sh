#!/bin/bash
# vep_docker_image.sh - Example script to save my customised VEP Docker image on UKB RAP
# Instance type selection - mem3_ssd1_v2_x16
# Priority: High - to avoid spot instance interruption
# Size of Docker image: 230GB


echo "Starting VEP..."


#################### STEP1 PULL AND EXECUTE A DOCKER CONTAINER ####################
# First pull original VEP Docker container ensemblorg/ensembl-vep
## Docker is always not running after finish one job, but I want to keep it awake all the time
## Give the container a name: wes_vep
docker run -d --name wes_vep ensemblorg/ensembl-vep tail -f /dev/null
## Install all plugins and databases that can be uses for human variant annotation, restricted to GRCh38
docker exec wes_vep INSTALL.pl -a acfp --PLUGINS all -s homo_sapiens -y GRCh38


# Then Execute the the Docker container wes_vep as a root user
docker exec -u root -it wes_vep bash



#################### STEP2 INSTALL USEFUL PACKAGES ####################
apt-get update
apt install -y wget curl git unzip vim nano samtools tabix sqlite3 \
  libdbi-perl libdbd-sqlite3-perl build-essential libperl-dev libbigwig-dev \
  libcurl4-openssl-dev libssl-dev zlib1g-dev
  
cpan install DBI DBD::SQLite
cpan install Bio::DB::BigFile

## Confirm samtools works
# samtools faidx /data/homo_sapiens/114_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz 1:1000000-1000020



#################### STEP3 UPDATE PLUGIN FILES ####################
cd /plugins
## Create directories for plugins
mkdir -p CADD AlphaMissense pLI SpliceAI


## Loftee - choose grch38 branch to avoid some conflicts (e.g. different SQL databases and different versions of GERP conservation scores)
git clone --single-branch --branch grch38 https://github.com/konradjk/loftee.git

### Copy everything in loftee folder to plugins folder
# This is a necessary step to use loftee plugin in VEP
cp -r /plugins/loftee/* /plugins/ # Maybe move is better

### Download needed files of loftee plugins
cd /plugins/loftee
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/gerp_conservation_scores.homo_sapiens.GRCh38.bw
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz.fai
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz.gzi
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/loftee.sql.gz
gunzip loftee.sql.gz



## CADD - I use only basic annotation database of CADD, but you can choose others including all annotations
cd /plugins/CADD
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/whole_genome_SNVs.tsv.gz
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/whole_genome_SNVs.tsv.gz.tbi
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/gnomad.genomes.r4.0.indel.tsv.gz
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/gnomad.genomes.r4.0.indel.tsv.gz.tbi


## AlphaMissense
cd /plugins/AlphaMissense
wget -c https://storage.cloud.google.com/dm_alphamissense/AlphaMissense_hg38.tsv.gz
wget -c https://storage.cloud.google.com/dm_alphamissense/AlphaMissense_hg38.tsv.gz.tbi


## pLI - I've modified the pLI_values.txt myself before, just copy it
## SpliceAI - Need some authencation of a website, previously downloaded files so just copy them
### Exit Docker container wes_vep, and copy files from project folder
exit
docker cp /mnt/project/vep/pLI/pLI_values.txt wes_vep:/plugins/pLI
docker cp /mnt/project/vep/SpliceAI/spliceai_scores.raw.indel.hg38.vcf.gz wes_vep:/plugins/SpliceAI
docker cp /mnt/project/vep/SpliceAI/spliceai_scores.raw.indel.hg38.vcf.gz.tbi wes_vep:/plugins/SpliceAI
docker cp /mnt/project/vep/SpliceAI/spliceai_scores.raw.snv.hg38.vcf.gz wes_vep:/plugins/SpliceAI
docker cp /mnt/project/vep/SpliceAI/spliceai_scores.raw.snv.hg38.vcf.gz.tbi wes_vep:/plugins/SpliceAI



#################### STEP4 COMMIT DOCKER CONTAINER ####################
# Add a commit message and author info
docker commit \
  --message "VEP with loftee, CADD, AlphaMissense, pLI and SpliceAI" \
  --author "example <example@example.com>" \
  wes_vep \
  my_vep_complete:v1.0




#################### STEP5 SAVE DOCKER IMAGE ####################
## Check Docker images
docker images
## Install pv to check the save process
apt-get update
apt-get install -y pv
## Save Docker image
docker save my_vep_complete:v1.0 | pv | gzip > my_vep_complete_v1.0.tar.gz
## After all done, upload the image to my UKB project
dx upload my_vep_complete_v1.0.tar.gz --destination projectID:/vep/images/


echo "Done!"

