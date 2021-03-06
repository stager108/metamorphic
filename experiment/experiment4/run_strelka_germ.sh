#!/bin/sh 

TESTDIR=$1
NORMAL=$2
TESTPREFIX=$3
GENOME=$4

mkdir ${TESTDIR}/strelka

python2 /soft/strelka-2.8.2.centos5_x86_64/bin/configureStrelkaGermlineWorkflow.py --exome \
--bam ${TESTDIR}/${NORMAL}.bam  \
--referenceFasta ${GENOME}  \
--runDir ${TESTDIR}/strelka

python2 ${TESTDIR}/strelka/runWorkflow.py -m local
 
gzip -d ${TESTDIR}/strelka/results/variants/variants.vcf.gz 
mv ${TESTDIR}/strelka/results/variants/variants.vcf ${TESTDIR}/${TESTPREFIX}_germ.vcf

rm -r ${TESTDIR}/strelka
