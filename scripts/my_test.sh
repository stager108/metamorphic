#!/bin/sh 

# InSilicoSeq
iss generate --genomes ./carsonella/genome.fa --model miseq --output ./carsonella/reads -n 1k

# BWA
bwa index ./carsonella/genome.fa &&\
     bwa mem ./carsonella/genome.fa ./carsonella/reads_R1.fastq \
     ./carsonella/reads_R2.fastq > ./carsonella/aln.sam

# samtools
samtools view -S -b ./carsonella/aln.sam > ./carsonella/aln_n.bam
samtools sort -o ./carsonella/aln.bam ./carsonella/aln_n.bam

java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./carsonella/aln.bam -O ./carsonella/aln.bam.bai

# generate
python3 ./scripts/generate_indels_positions.py 


# bamSurgeon
addindel.py -v ./carsonella/test_indel.txt -f ./carsonella/aln.bam -r ./carsonella/genome.fa \
-o ./carsonella/testregion_mut.bam  --picardjar ./picard/build/libs/picard.jar --aligner mem --seed 1234




