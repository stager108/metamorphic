#!/bin/sh 

TESTDIR=$1
FASTAFILE=$2
BAMFILE=$3
SIZE=$4
GENOME=genome.fa

mkdir $TESTDIR
cp /root/carsonella/* /root/$TESTDIR

# InSilicoSeq
iss generate --genomes /root/$TESTDIR/$FASTAFILE --model miseq --output /root/$TESTDIR/reads -n ${SIZE}k

# BWA
bwa index /root/$TESTDIR/$GENOME &&\
     bwa mem /root/$TESTDIR/$GENOME /root/$TESTDIR/reads_R1.fastq \
     /root/$TESTDIR/reads_R2.fastq > /root/$TESTDIR/$BAMFILE.sam

# samtools sort
samtools view -S -b /root/$TESTDIR/$BAMFILE.sam > /root/$TESTDIR/${BAMFILE}_n.bam
samtools sort -o /root/$TESTDIR/$BAMFILE.bam /root/$TESTDIR/${BAMFILE}_n.bam

java -jar /root/picard/build/libs/picard.jar BuildBamIndex \
      -I /root/$TESTDIR/$BAMFILE.bam -O /root/$TESTDIR/$BAMFILE.bam.bai
      
rm /root/$TESTDIR/${BAMFILE}_n* 
