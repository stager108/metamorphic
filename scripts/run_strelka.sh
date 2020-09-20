#!/bin/sh 

TESTDIR=$1
NORMAL=$2
TUMOR=$3

mkdir ./$TESTDIR/manta
mkdir ./$TESTDIR/strelka

python2 /soft/manta-1.5.0.centos6_x86_64/bin/configManta.py --exome \
--normalBam ./$TESTDIR/$NORMAL.bam \
--tumorBam ./$TESTDIR/$TUMOR.bam \
--referenceFasta ./$TESTDIR/genome.fa \
--runDir ./$TESTDIR/manta

python2 ./$TESTDIR/manta/runWorkflow.py -m local

python2 /soft/strelka-2.8.2.centos5_x86_64/bin/configureStrelkaSomaticWorkflow.py --exome \
--normalBam ./$TESTDIR/$NORMAL.bam  \
--tumorBam ./$TESTDIR/$TUMOR.bam \
--referenceFasta ./$TESTDIR/genome.fa  \
--indelCandidates ./$TESTDIR/manta/results/variants/candidateSmallIndels.vcf.gz \
--runDir ./$TESTDIR/strelka

python2 ./$TESTDIR/strelka/runWorkflow.py -m local
 
