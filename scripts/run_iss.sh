#!/bin/sh 

TESTDIR=$1
BAMFILE=$2

mkdir $TESTDIR
cp ./carsonella/* ./$TESTDIR

# InSilicoSeq
iss generate --genomes ./$TESTDIR/genome.fa --model miseq --output ./$TESTDIR/reads -n 30k

# BWA
bwa index ./$TESTDIR/genome.fa &&\
     bwa mem ./$TESTDIR/genome.fa ./$TESTDIR/reads_R1.fastq \
     ./$TESTDIR/reads_R2.fastq > ./$TESTDIR/$BAMFILE.sam

# samtools sort
samtools view -S -b ./$TESTDIR/$BAMFILE.sam > ./$TESTDIR/$BAMFILE\_n.bam
samtools sort -o ./$TESTDIR/$BAMFILE.bam ./$TESTDIR/$BAMFILE\_n.bam

java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./$TESTDIR/$BAMFILE.bam -O ./$TESTDIR/$BAMFILE.bam.bai
      
rm ./$TESTDIR/$BAMFILE\_n* 
