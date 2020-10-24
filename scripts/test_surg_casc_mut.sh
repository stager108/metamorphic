#!/bin/sh 

TESTDIR=$1
TESTPREFIX=$2
MODE=$4
RUNDIR=tmp_run_dir
N=$3
. ./scripts/run_iss.sh $TESTDIR genome.fa aligned 50
. ./scripts/run_iss.sh $TESTDIR genome.fa mutated 50

./scripts/generate_config.exe carsonella/genome.fa $TESTDIR/general_config.txt -$MODE
./scripts/generate_pack.exe $TESTDIR/general_config.txt $TESTDIR/$TESTPREFIX $N -t

TESTDIR=$1
mkdir ./results/$TESTDIR

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  TESTPREFIX=$2
  RUNDIR=tmp_run_dir
  mkdir $RUNDIR
  cp $TESTDIR/* $RUNDIR
  cp ./carsonella/genome.fa $RUNDIR
  cp ./carsonella/genome.fa.fai $RUNDIR
  . ./scripts/run_surg.sh $RUNDIR mutated $TESTDIR/${TESTPREFIX}0${i}.txt
  . ./scripts/run_strelka.sh $RUNDIR aligned mutated_mut

  gzip -d ./$RUNDIR/strelka/results/variants/somatic.indels.vcf.gz 
  TESTDIR=$1
  mv ./$RUNDIR/strelka/results/variants/somatic.indels.vcf ./results/$TESTDIR/${TESTPREFIX}_${i}.vcf
  rm -r $RUNDIR
done

