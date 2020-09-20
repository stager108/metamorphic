#!/bin/sh 

TESTDIR=$1
BAMFILE=$2
TESTCONFIG=$3

# bamSurgeon
addindel.py -v $TESTCONFIG -f ./$TESTDIR/$BAMFILE.bam -r ./$TESTDIR/genome.fa \
-o ./$TESTDIR/testregion_mut.bam  --picardjar ./picard/build/libs/picard.jar --aligner mem --seed 1234

# sort
samtools sort -o ./$TESTDIR/$BAMFILE\_mut.bam ./$TESTDIR/testregion_mut.bam

mv testregion_mut.addindel.test_indel.vcf  ./$TESTDIR/mut.vcf 

# indexing
java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./$TESTDIR/$BAMFILE\_mut.bam -O ./$TESTDIR/$BAMFILE\_mut.bam.bai

# delete garbage
rm -r addindel*
rm *addindel*  
