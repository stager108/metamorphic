#!/bin/sh 

TESTDIR=$1
BAMFILE=$2
OUTPUTFILE=$3
TESTCONFIG=$4
TESTPREFIX=$5
GENOME=$6

# bamSurgeon
addindel.py -v ${TESTCONFIG} -f ./${TESTDIR}/${BAMFILE}.bam -r ${GENOME} \
-o ./${TESTDIR}/${TESTPREFIX}testregion_mut.bam  --picardjar ./picard/build/libs/picard.jar --aligner mem --seed 1234

# sort
samtools sort -o ./${TESTDIR}/${OUTPUTFILE}.bam ./${TESTPREFIX}/${TESTDIR}testregion_mut.bam

mv ./${TESTPREFIX}testregion_mut.addindel.test_indel.vcf  ./${TESTDIR}/${TESTPREFIX}mut.vcf 

# indexing
java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./${TESTDIR}/${OUTPUTFILE}.bam -O ./${TESTDIR}/${OUTPUTFILE}.bam.bai

# delete garbage
rm -r addindel*
rm *addindel*   
