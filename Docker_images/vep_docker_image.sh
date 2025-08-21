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



echo "Done!"

