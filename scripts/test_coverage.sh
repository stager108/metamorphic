#!/bin/sh

TESTDIR=$1
TESTCONFIG=point_mut
RUNDIR=tmp_run_dir
N=$2
TYPE=$3
mkdir $TESTDIR
cp ./carsonella/genome.fa $TESTDIR/genome_cov_${TYPE}0.fa
. ./scripts/run_iss.sh $TESTDIR genome_cov_${TYPE}0.fa aligned 50
./scripts/generate_mut.exe $TESTDIR/genome_cov_${TYPE}0.fa $TESTDIR/genome_cov_${TYPE}1.fa -${TYPE}


for i in `seq 1 $N`
do
  TESTDIR=$1
  RUNDIR=tmp_run_dir
  mkdir $RUNDIR
  
  . ./scripts/run_iss.sh $TESTDIR genome_mut_${TYPE}1.fa mutated $(((N+3 - i)*10))
  
  cp $TESTDIR/* $RUNDIR
  cp ./carsonella/genome.fa $RUNDIR
  cp ./carsonella/genome.fa.fai $RUNDIR

  . ./scripts/run_strelka.sh $RUNDIR aligned mutated

  gzip -d ./$RUNDIR/strelka/results/variants/somatic.indels.vcf.gz
  mv ./$RUNDIR/strelka/results/variants/somatic.indels.vcf ./results/genome_mut_${TYPE}$(((N+3 - i)*10)).vcf
  rm -r $RUNDIR
done
