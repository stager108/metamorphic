#!/bin/sh 

TESTDIR=$1
FASTAFILE=$2
OUTPUTPREFIX=$3
SIZE=$4

mkdir $TESTDIR

# InSilicoSeq
iss generate --genomes ${FASTAFILE} --model miseq --output /root/${TESTDIR}/reads -n ${SIZE}k

mv /root/${TESTDIR}/reads_R1.fastq /root/${TESTDIR}/${OUTPUTPREFIX}_R1.fastq
mv /root/${TESTDIR}/reads_R2.fastq /root/${TESTDIR}/${OUTPUTPREFIX}_R2.fastq
