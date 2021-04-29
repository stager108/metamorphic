#!/bin/sh 

TESTDIR=$1
BAMFILE=$2
OUTPUTFILE=$3
TESTCONFIG=$4
TESTPREFIX=$5
GENOME=$6
DONOR=$7

# bamSurgeon
addsv.py -v ${TESTCONFIG} -f ${TESTDIR}/${BAMFILE}.bam -r ${GENOME} \
-o ${TESTDIR}/${TESTPREFIX}testregion_mut.bam --donorbam ${DONOR} --aligner mem --seed 1234

# sort
samtools sort -o ${TESTDIR}/${OUTPUTFILE}.bam ${TESTDIR}/${TESTPREFIX}testregion_mut.bam

mv ${TESTPREFIX}testregion_mut.addindel.test_indel.vcf  ${TESTDIR}/${TESTPREFIX}mut.vcf 

# indexing
java -jar /root/picard/build/libs/picard.jar BuildBamIndex \
      -I ${TESTDIR}/${OUTPUTFILE}.bam -O ${TESTDIR}/${OUTPUTFILE}.bam.bai
      
# delete garbage
rm -r addsv*
rm *addsv*   
