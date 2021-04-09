#!/bin/sh

TESTDIR=$1
TESTPREFIX=$2
MODE=$4
RUNDIR=tmp_run_dir
N=$3

mkdir ${RUNDIR}
mkdir ${TESTDIR}
./scripts/run_iss.sh ${TESTDIR} genome.fa aligned 10

./scripts/generate_mut.exe carsonella/genome.fa ${TESTDIR}/general_config.txt -${MODE}
./scripts/generate_pack.exe ${TESTDIR}/general_config.txt.inner ${TESTDIR}/${TESTPREFIX} $N -t

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  RUNDIR=tmp_run_dir
  ./scripts/apply_mut.exe carsonella/genome.fa $TESTDIR/genome_mut_${MODE}${i}.fa $TESTDIR/${TESTPREFIX}0${i}.txt -a
  ./scripts/run_iss.sh ${TESTDIR} genome_mut_${MODE}${i}.fa mutated_${MODE}${i} 10
done
