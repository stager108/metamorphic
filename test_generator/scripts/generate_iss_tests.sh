#!/bin/sh

TESTDIR=$1
TESTPREFIX=$2
N=$3
MODE=$4
GENOME=$5

mkdir ${TESTDIR}
./scripts/run_iss.sh ${TESTDIR} ${GENOME} aligned 50

./scripts/generate_mut.exe ${GENOME} ${TESTDIR}/general_config.txt -${MODE}
./scripts/generate_pack.exe ${TESTDIR}/general_config.txt.inner ${TESTDIR}/${TESTPREFIX} $N -t

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  ./scripts/apply_mut.exe ${GENOME} ${TESTDIR}/genome_mut_${MODE}${i}.fa $TESTDIR/${TESTPREFIX}0${i}.txt -a
  ./scripts/run_iss.sh ${TESTDIR} ${TESTDIR}/genome_mut_${MODE}${i}.fa mutated_${MODE}${i} 50
done

cp -r ${TESTDIR} results/
