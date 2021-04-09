#!/bin/sh 

TESTDIR=$1
TESTPREFIX=$2
MODE=$4
RUNDIR=tmp_run_dir
N=$3
./scripts/run_iss.sh $TESTDIR genome.fa aligned 50
./scripts/run_iss.sh $TESTDIR genome.fa mutated 50

./scripts/generate_mut.exe carsonella/genome.fa $TESTDIR/general_config.txt -$MODE
./scripts/generate_pack.exe $TESTDIR/general_config.txt $TESTDIR/$TESTPREFIX $N -t

TESTDIR=$1
mkdir ./results/$TESTDIR

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  TESTPREFIX=$2
  RUNDIR=$1
  mkdir $RUNDIR
  cp carsonella/genome.fa.fai $RUNDIR
  ./scripts/run_surg_copy.sh $RUNDIR mutated $TESTDIR/${TESTPREFIX}0${i}.txt $i
  RUNDIR=$1
  cp -r $RUNDIR results/

done

