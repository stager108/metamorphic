#!/bin/sh

TESTDIR=$1
TESTCONFIG=point_mut
RUNDIR=tmp_run_dir
N=$2
TYPE=$3
GENOME=genome.fa

mkdir $TESTDIR
cp ./carsonella/* ./$TESTDIR

# normal
iss generate --genomes ./$TESTDIR/$GENOME --model miseq \
    --output ./$TESTDIR/reads -n $(((N+3 - i)*10))k
    
bwa index ./$TESTDIR/$GENOME &&\
     bwa mem ./$TESTDIR/$GENOME ./$TESTDIR/reads_R1.fastq \
     ./$TESTDIR/reads_R2.fastq > ./$TESTDIR/aligned.sam
     
samtools view -S -b ./$TESTDIR/aligned.sam > ./$TESTDIR/aligned_n.bam
samtools sort -o ./$TESTDIR/aligned.bam ./$TESTDIR/aligned_n.bam

java -jar ./picard/build/libs/picard.jar BuildBamIndex \
        -I ./$TESTDIR/aligned.bam -O ./$TESTDIR/aligned.bam.bai

# tumor
./scripts/generate_mut.exe $TESTDIR/$GENOME $TESTDIR/genome_mut_${TYPE}.fa \
     $TESTDIR/config_${TYPE}.txt -${TYPE}

iss generate --genomes ./$TESTDIR/genome_mut_${TYPE}.fa --model miseq \
    --output ./$TESTDIR/reads -n $(((N+3 - i)*10))k

bwa index ./$TESTDIR/$GENOME &&\
     bwa mem ./$TESTDIR/$GENOME ./$TESTDIR/reads_R1.fastq \
     ./$TESTDIR/reads_R2.fastq > ./$TESTDIR/mutated.sam

# test pack
./scripts/generate_pack.exe $TESTDIR/mutated.sam $TESTDIR/mutated_ $N -s
TESTDIR=$1
mkdir ./results/$TESTDIR

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  RUNDIR=tmp_run_dir
  samtools view -S -b ./$TESTDIR/mutated_0${i}.sam > ./$TESTDIR/mutated_0${i}_n.bam
  samtools sort -o ./$TESTDIR/mutated_0${i}.bam ./$TESTDIR/mutated_0${i}_n.bam

  java -jar ./picard/build/libs/picard.jar BuildBamIndex \
        -I ./$TESTDIR/mutated_0${i}.bam -O ./$TESTDIR/mutated_0${i}.bam.bai
      
  rm ./$TESTDIR/aligned_n* 

  TESTDIR=$1
  RUNDIR=tmp_run_dir
  mkdir $RUNDIR
  
  cp $TESTDIR/* $RUNDIR
  cp ./carsonella/genome.fa $RUNDIR
  cp ./carsonella/genome.fa.fai $RUNDIR

  . ./scripts/run_strelka.sh $RUNDIR aligned mutated_0${i}
  
  TESTDIR=$1
  RUNDIR=tmp_run_dir
  gzip -d ./$RUNDIR/strelka/results/variants/somatic.indels.vcf.gz
  mv ./$RUNDIR/strelka/results/variants/somatic.indels.vcf ./results/$TESTDIR/genome_mut_${TYPE}_0${i}.vcf
  rm -r $RUNDIR
done
