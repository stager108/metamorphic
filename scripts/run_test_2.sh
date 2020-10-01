#!/bin/sh

TESTDIR=$1
TESTCONFIG=point_mut
RUNDIR=tmp_run_dir
N=$2
mkdir $TESTDIR
cp ./carsonella/genome.fa $TESTDIR/genome_rand_0.fa
. ./scripts/run_iss.sh $TESTDIR genome_rand_0.fa aligned

for i in `seq 1 $N`
do
  TESTDIR=$1
  RUNDIR=tmp_run_dir
  mkdir $RUNDIR

  ./scripts/generate_mut.exe $TESTDIR/genome_rand_0.fa $TESTDIR/genome_rand_${i}.fa -r
  . ./scripts/run_iss.sh $TESTDIR genome_rand_${i}.fa mutated
  cp $TESTDIR/* $RUNDIR
  cp ./carsonella/genome.fa $RUNDIR
  cp ./carsonella/genome.fa.fai $RUNDIR

  . ./scripts/run_strelka.sh $RUNDIR aligned mutated

  gzip -d ./$RUNDIR/strelka/results/variants/somatic.indels.vcf.gz
  mv ./$RUNDIR/strelka/results/variants/somatic.indels.vcf ./results/genome_rand_${i}.vcf
  rm -r $RUNDIR
done
