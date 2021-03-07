#!/bin/sh 

TESTDIR=$1
BAMFILE=$2
TESTCONFIG=$3
TESTPREFIX=$4

# bamSurgeon
addindel.py -v $TESTCONFIG -f ./$TESTDIR/$BAMFILE.bam -r ./$TESTDIR/genome.fa \
-o ./$TESTDIR/testregion_mut$TESTPREFIX.bam  --picardjar ./picard/build/libs/picard.jar --aligner mem --seed 1234

# sort
samtools sort -o ./$TESTDIR/$BAMFILE\_mut$TESTPREFIX.bam ./$TESTDIR/testregion_mut$TESTPREFIX.bam

mv testregion_mut.addindel.test_indel.vcf  ./$TESTDIR/mut.vcf 

# indexing
java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./$TESTDIR/$BAMFILE\_mut$TESTPREFIX.bam -O ./$TESTDIR/$BAMFILE\_mut$TESTPREFIX.bam.bai

samtools fastq -@ 1 ./$TESTDIR/$BAMFILE\_mut$TESTPREFIX.bam \
-1 ./$TESTDIR/$BAMFILE\_mut${TESTPREFIX}_R1.fastq.gz \
-2 ./$TESTDIR/$BAMFILE\_mut${TESTPREFIX}_R2.fastq.gz


# delete garbage
rm -r addindel*
rm *addindel*   
