#!/bin/sh 

TESTCONFIG=$1
TESTDIR=tmp_test_dir

mkdir $TESTDIR
cp ./carsonella/genome.fa ./$TESTDIR
cp ./carsonella/genome.fa.fai ./$TESTDIR

# InSilicoSeq
iss generate --genomes ./$TESTDIR/genome.fa --model miseq --output ./$TESTDIR/reads -n 30k

# BWA
bwa index ./$TESTDIR/genome.fa &&\
     bwa mem ./$TESTDIR/genome.fa ./$TESTDIR/reads_R1.fastq \
     ./$TESTDIR/reads_R2.fastq > ./$TESTDIR/aln.sam

# samtools sort
samtools view -S -b ./$TESTDIR/aln.sam > ./$TESTDIR/aln_n.bam
samtools sort -o ./$TESTDIR/aln.bam ./$TESTDIR/aln_n.bam

java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./$TESTDIR/aln.bam -O ./$TESTDIR/aln.bam.bai

# bamSurgeon
addindel.py -v $TESTCONFIG -f ./$TESTDIR/aln.bam -r ./$TESTDIR/genome.fa \
-o ./$TESTDIR/testregion_mut.bam  --picardjar ./picard/build/libs/picard.jar --aligner mem --seed 1234

# sort
samtools sort -o ./$TESTDIR/mut.bam ./$TESTDIR/testregion_mut.bam

mv testregion_mut.addindel.test_indel.vcf  ./$TESTDIR/mut.vcf 

# indexing
java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./$TESTDIR/mut.bam -O ./$TESTDIR/mut.bam.bai

# delete garbage
rm -r addindel*
rm *addindel* 

mkdir ./$TESTDIR/manta
mkdir ./$TESTDIR/strelka

python2 /soft/manta-1.5.0.centos6_x86_64/bin/configManta.py --exome \
--normalBam ./$TESTDIR/aln.bam \
--tumorBam ./$TESTDIR/mut.bam \
--referenceFasta ./$TESTDIR/genome.fa \
--runDir ./$TESTDIR/manta

python2 ./$TESTDIR/manta/runWorkflow.py -m local

python2 /soft/strelka-2.8.2.centos5_x86_64/bin/configureStrelkaSomaticWorkflow.py --exome \
--normalBam ./$TESTDIR/aln.bam  \
--tumorBam ./$TESTDIR/mut.bam \
--referenceFasta ./$TESTDIR/genome.fa  \
--indelCandidates ./$TESTDIR/manta/results/variants/candidateSmallIndels.vcf.gz \
--runDir ./$TESTDIR/strelka

python2 ./$TESTDIR/strelka/runWorkflow.py -m local

gzip -d ./$TESTDIR/strelka/results/variants/somatic.indels.vcf.gz 
mv ./$TESTDIR/strelka/results/variants/somatic.indels.vcf $TESTCONFIG.vcf
rm -r $TESTDIR 
