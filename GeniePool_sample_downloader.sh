#!/bin/tcsh

# argument #1 -> SRA accession ID
# argument #2 -> Paired-end or Single-end sequencing. "PAIRED" for paired-end, "SINGLE" for single-end
# argument #3 -> reference genome. "38" for hg38, "19" for hg19
# Examples:
# sh GeniePool_sample_downloader.sh SRR14140307 SINGLE 38
# sh GeniePool_sample_downloader.sh SRR2125263 PAIRED 19

GeniePoolTools/sratoolkit.2.11.0/bin/prefetch $1
cd $1

if ( "$2" == "PAIRED" ) then
    ../GeniePoolTools/sratoolkit.2.11.0/bin/fastq-dump --split-files $1.sra
    rm -f $1.sra
    find . -type f ! -name '*.fastq' -delete
    java -jar ../GeniePoolTools/Trimmomatic-0.39/trimmomatic-0.39.jar PE $1_1.fastq $1_2.fastq $1_forward_paired.fq.gz $1_forward_unpaired.fq.gz $1_reverse_paired.fq.gz $1_reverse_unpaired.fq.gz ILLUMINACLIP:../GeniePoolTools/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36
    rm -f $1_1.fastq $1_2.fastq $1_forward_unpaired.fq.gz $1_reverse_unpaired.fq.gz
    java -Xmx8G -jar ../GeniePoolTools/picard.jar FastqToSam \
        FASTQ=$1_forward_paired.fq.gz\
        FASTQ2=$1_reverse_paired.fq.gz\
        OUTPUT=$1.unmapped.bam\
        READ_GROUP_NAME=H0164.2\
        SAMPLE_NAME=$1\
        LIBRARY_NAME=illumina\
        PLATFORM_UNIT=H0164ALXX140820.2\
        PLATFORM=illumina\
        SEQUENCING_CENTER=unknown\
        TMP_DIR=tmp_$1\
        RUN_DATE=2021-04-06T15:49:15
    rm -f $1_forward_paired.fq.gz $1_reverse_paired.fq.gz
else if ( "$2" == "SINGLE" ) then
    ../GeniePoolTools/sratoolkit.2.11.0/bin/fastq-dump $1.sra
    rm -f $1.sra
    find . -type f ! -name '*.fastq' -delete
    java -jar ../GeniePoolTools/Trimmomatic-0.39/trimmomatic-0.39.jar SE $1.fastq $1.fq.gz ILLUMINACLIP:../GeniePoolTools/Trimmomatic-0.39/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36
    rm -f $1.fastq
    java -Xmx8G -jar ../GeniePoolTools/picard.jar FastqToSam \
        FASTQ=$1.fq.gz\
        OUTPUT=$1.unmapped.bam\
        READ_GROUP_NAME=H0164.2\
        SAMPLE_NAME=$1\
        LIBRARY_NAME=illumina\
        PLATFORM_UNIT=H0164ALXX140820.2\
        PLATFORM=illumina\
        SEQUENCING_CENTER=unknown\
        TMP_DIR=tmp_$1\
        RUN_DATE=2021-04-06T15:49:15
    rm -f $1.fq.gz
else
    echo "Please specify PE for paired-end or SE for single end as second parameter"
endif

rm -rf tmp_$1

java -Xmx8G -jar ../GeniePoolTools/picard.jar MarkIlluminaAdapters \
    I=$1.unmapped.bam\
    O=$1_markilluminaadapters.bam\
    M=$1_markilluminaadapters_metrics.txt

java -Xmx8G -jar ../GeniePoolTools/picard.jar SamToFastq \
    I=$1_markilluminaadapters.bam\
    FASTQ=$1_samtofastq_interleaved.fq\
    CLIPPING_ATTRIBUTE=XT\
    CLIPPING_ACTION=2\
    INTERLEAVE=true\
    NON_PF=true

../GeniePoolTools/bwa/bwa mem -M -t 7 -p ../GeniePoolTools/references/hg$3.fa $1_samtofastq_interleaved.fq > $1_bwa_mem.sam
rm -f $1_samtofastq_interleaved.fq

cd ..
java -Xmx16G -jar GeniePoolTools/picard.jar MergeBamAlignment \
    R=GeniePoolTools/references/hg$3.fa\
    UNMAPPED_BAM=$1/$1.unmapped.bam\
    ALIGNED_BAM=$1/$1_bwa_mem.sam\
    O=$1/$1_mergebamalignment.bam\
    CREATE_INDEX=true\
    ADD_MATE_CIGAR=true\
    CLIP_ADAPTERS=false\
    CLIP_OVERLAPPING_READS=true\
    INCLUDE_SECONDARY_ALIGNMENTS=true\
    MAX_INSERTIONS_OR_DELETIONS=-1\
    PRIMARY_ALIGNMENT_STRATEGY=MostDistant\
    ATTRIBUTES_TO_RETAIN=XS

cd $1
rm -f $1.unmapped.bam $1_bwa_mem.sam $1_samtofastq_interleaved.fq $1_markilluminaadapters.bam $1_markilluminaadapters_metrics.txt

mv $1_mergebamalignment.bam $1.bam
mv $1_mergebamalignment.bai $1.bai

cd ..
GeniePoolTools/gatk-4.2.0.0/gatk --java-options "-Xmx4g" HaplotypeCaller \
   -R GeniePoolTools/references/hg$3.fa\
   -I $1/$1.bam\
   -O $1/$1.vcf.gz

mv $1/$1.vcf.gz completed/$1.vcf.gz
rm -rf $1
echo "Done processing sample $1"