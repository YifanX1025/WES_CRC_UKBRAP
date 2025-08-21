#!/bin/bash
# vep_docker_image.sh - Example script to save my customised VEP Docker image on UKB RAP



echo "Starting VEP..."


# First pull original VEP Docker container ensemblorg/ensembl-vep
## Docker is always not running after finish one job, but I want to keep it awake all the time
## Give the container a name: wes_vep
docker run -d --name wes_vep ensemblorg/ensembl-vep tail -f /dev/null
## Install all plugins and databases that can be uses for human variant annotation, restricted to GRCh38
docker exec wes_vep INSTALL.pl -a acfp --PLUGINS all -s homo_sapiens -y GRCh38


# Then Execute the the Docker container wes_vep as a root user
docker exec -u root -it wes_vep bash


# Install all packages might be useful
apt-get update
apt install -y wget curl git unzip vim nano samtools tabix sqlite3 libdbi-perl \
  libdbd-sqlite3-perl build-essential libperl-dev libbigwig-dev \
  libcurl4-openssl-dev libssl-dev zlib1g-dev
  
cpan install DBI DBD::SQLite
cpan install Bio::DB::BigFile

## Confirm samtools works
# samtools faidx /data/homo_sapiens/114_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz 1:1000000-1000020


# Update some plugins files
## Loftee - choose grch38 branch to avoid some conflicts (e.g. different SQL databases and different versions of GERP conservation scores)
cd /plugins
git clone --single-branch --branch grch38 https://github.com/konradjk/

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


## CADD - I use only basic annotation database of CADD, but you can choose others including all annotations
mkdir -p /plugins/CADD
cd /plugins/CADD
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/whole_genome_SNVs.tsv.gz
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/whole_genome_SNVs.tsv.gz.tbi
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/gnomad.genomes.r4.0.indel.tsv.gz
wget -c https://krishna.gs.washington.edu/download/CADD/v1.7/GRCh38/gnomad.genomes.r4.0.indel.tsv.gz.tbi


## 























echo "Done!"

