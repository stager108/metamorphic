#!/bin/sh 

# InSilicoSeq
iss generate --genomes ./carsonella/genome.fa --model miseq --output ./carsonella/reads -n 30k

# BWA
bwa index ./carsonella/genome.fa &&\
     bwa mem ./carsonella/genome.fa ./carsonella/reads_R1.fastq \
     ./carsonella/reads_R2.fastq > ./carsonella/aln.sam

# samtools sort
samtools view -S -b ./carsonella/aln.sam > ./carsonella/aln_n.bam
samtools sort -o ./carsonella/aln.bam ./carsonella/aln_n.bam

java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./carsonella/aln.bam -O ./carsonella/aln.bam.bai

# generate
python3 ./scripts/generate_indels_positions.py 

# bamSurgeon
addindel.py -v ./carsonella/test_indel.txt -f ./carsonella/aln.bam -r ./carsonella/genome.fa \
-o ./carsonella/testregion_mut.bam  --picardjar ./picard/build/libs/picard.jar --aligner mem --seed 1234

# sort
samtools sort -o ./carsonella/mut.bam ./carsonella/testregion_mut.bam

mv testregion_mut.addindel.test_indel.vcf  ./carsonella/mut.vcf 

# indexing
java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./carsonella/mut.bam -O ./carsonella/mut.bam.bai

# delete garbage
rm -r addindel*

mkdir carsonella/manta
mkdir carsonella/strelka

python2 /soft/manta-1.5.0.centos6_x86_64/bin/configManta.py --exome \
--normalBam ./carsonella/aln.bam \
--tumorBam ./carsonella/mut.bam \
--referenceFasta ./carsonella/genome.fa \
--runDir ./carsonella/manta

python2 ./carsonella/manta/runWorkflow.py -m local

python2 /soft/strelka-2.8.2.centos5_x86_64/bin/configureStrelkaSomaticWorkflow.py --exome \
--normalBam ./carsonella/aln.bam  \
--tumorBam ./carsonella/mut.bam \
--referenceFasta ./carsonella/genome.fa  \
--indelCandidates ./carsonella/manta/results/variants/candidateSmallIndels.vcf.gz \
--runDir ./carsonella/strelka

python2 ./carsonella/strelka/runWorkflow.py -m local






