# GeniePool_setup.sh
Downloads and installs all prerequisites for downloading and preprocessing SRA data to VCF files, like a Docker container.

# SRAs.csv
SRA regarding whole-exome-sequencing data from obtained from SRA. the "Run" column values can be served as input for the GeniePool_sample_downloader.sh script.

# GeniePool_sample_downloader.sh
A script for downloading and preprocessing SRA data to VCF files.
arguments:
1 - SRA accession
2 - SINGLE/PAIRED, for specifying if sample was sequences using single-end or paired-end sequencing.
3 - 19/38, for specifying if data will be aligned to hg19 or hg38.
e.g.:
sh GeniePool_sample_downloader.sh SRR14140307 SINGLE 19 ==> downloads sample SRR14140307 for single-end sequencing aligned to hg19
sh GeniePool_sample_downloader.sh SRR2125263 PAIRED 38 ==> downloads sample SRR2125263 for paired-end sequencing aligned to hg38
