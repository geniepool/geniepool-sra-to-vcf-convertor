mkdir GeniePoolTools
cd GeniePoolTools
mkdir bwa
wget -O bwa-0.7.17.tar.bz2 https://sourceforge.net/projects/bio-bwa/files/latest/download
tar xjf bwa-0.7.17.tar.bz2 --one-top-level=bwa --strip-components 1
rm -f bwa*.tar.bz2
cd bwa
make
cd ..

wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.39.zip
gunzip Trimmomatic-0.39.zip.gz
unzip Trimmomatic-0.39.zip
rm -f Trimmomatic-0.39.zip

wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.11.0/sratoolkit.2.11.0-ubuntu64.tar.gz 
gunzip sratoolkit.2.11.0-ubuntu64.tar.gz
tar -xvf sratoolkit.2.11.0-ubuntu64.tar
rm -f sratoolkit.2.11.0-ubuntu64.tar
mv sratoolkit.2.11.0-ubuntu64 sratoolkit.2.11.0

wget https://github.com/broadinstitute/picard/releases/download/2.25.1/picard.jar

wget https://github.com/broadinstitute/gatk/releases/download/4.2.0.0/gatk-4.2.0.0.zip
unzip gatk-4.2.0.0.zip
rm -f gatk-4.2.0.0.zip

mkdir "references"
cd "references"
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fa.gz
../bwa/bwa index hg38.fa
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/bigZips/hg19.fa.gz
gunzip hg19.fa.gz
../bwa/bwa index hg19.fa
cd ..

java -jar picard.jar CreateSequenceDictionary \
    R=references/hg38.fa \
    O=references/hg38.dict

java -jar picard.jar CreateSequenceDictionary \
    R=references/hg19.fa \
    O=references/hg19.dict
mkdir samtools
wget https://github.com/samtools/samtools/releases/download/1.12/samtools-1.12.tar.bz2
tar xjf samtools-1.12.tar.bz2 --one-top-level=samtools --strip-components 1
rm -f samtools-1.12.tar.bz2
cd samtools
make
cd ..
samtools/samtools faidx references/hg38.fa
samtools/samtools faidx references/hg19.fa

cd ..
mkdir "completed"

#Examples:
#sh GeniePool_sample_downloader.sh SRR14140307 SINGLE 19 ==> downloads sample SRR14140307 for single-end sequencing aligned to hg19
#sh GeniePool_sample_downloader.sh SRR2125263 PAIRED 38 ==> downloads sample SRR2125263 for paired-end sequencing aligned to hg38