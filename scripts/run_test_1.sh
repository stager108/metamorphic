#!/bin/sh 

TESTDIR=$1
TESTCONFIG=$2
RUNDIR=tmp_run_dir
N=$3
. ./scripts/run_iss.sh $TESTDIR aligned
. ./scripts/run_iss.sh $TESTDIR mutated

for i in `seq 1 $N`
do
  mkdir $RUNDIR
  cp $TESTDIR/* $RUNDIR
  cp ./carsonella/genome.fa $RUNDIR
  cp ./carsonella/genome.fa.fai $RUNDIR
  . ./scripts/run_surg.sh $RUNDIR mutated $TESTCONFIG\_$i.txt
  . ./scripts/run_strelka.sh $RUNDIR aligned mutated_mut

  gzip -d ./$RUNDIR/strelka/results/variants/somatic.indels.vcf.gz 
  mv ./$RUNDIR/strelka/results/variants/somatic.indels.vcf $TESTCONFIG\_$i.vcf
  rm -r $RUNDIR
done