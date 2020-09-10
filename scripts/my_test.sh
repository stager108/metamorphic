#!/bin/sh 

# InSilicoSeq
iss generate --genomes /~/carsonella/genome.fa --model miseq --output /~/carsonella/reads -n 1k

# BWA
bwa index /~/carsonella/genome.fa &&\
     bwa mem /~/carsonella/genome.fa /~/carsonella/reads_R1.fastq /~/carsonella/reads_R2.fastq > /~/carsonella/aln.sam

# bamSurgeon
/~/bamsurgeon/test/test_indel.sh
