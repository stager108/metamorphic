#!/bin/sh 

# InSilicoSeq
iss generate --genomes ./carsonella/genome.fa --model miseq --output ./carsonella/reads -n 30k

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

mv testregion_mut.addindel.test_indel.vcf  ./carsonella/testregion_mut.vcf 

java -jar ./picard/build/libs/picard.jar BuildBamIndex \
      -I ./carsonella/testregion_mut.bam -O ./carsonella/testregion_mut.bam.bai

# delete garbage
rm -r addindel*
mkdir carsonella/manta
mkdir carsonella/strelka

python2 /manta/bin/configManta.py \
--normalBam ./carsonella/aln.bam \
--tumorBam ./carsonella/testregion_mut.bam \
--referenceFasta ./carsonella/genome.fa \
--runDir ./carsonella/manta

python2 ./carsonella/runWorkflow.py

python2 /strelka/bin/configureStrelkaSomaticWorkflow.py \
--normalBam ./carsonella/aln.bam  \
--tumorBam ./carsonella/testregion_mut.bam \
--referenceFasta ./carsonella/genome.fa  \
--indelCandidates ./carsonella/manta/results/variants/candidateSmallIndels.vcf.gz \
--runDir ./carsonella/strelka





