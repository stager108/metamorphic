#!/bin/sh 

TESTDIR=$1
TESTPREFIX=$2
N=$3
MODE=$4
GENOME=$5

mkdir ${TESTDIR}

./scripts/run_iss.sh ${TESTDIR} ${GENOME} aligned 50
./scripts/run_iss.sh ${TESTDIR} ${GENOME} mutated 50

./scripts/generate_mut.exe ${GENOME} ${TESTDIR}/general_config.txt -${MODE}
./scripts/generate_pack.exe ${TESTDIR}/general_config.txt ${TESTDIR}/${TESTPREFIX} ${N} -t

TESTDIR=$1

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  TESTPREFIX=$2
  ./scripts/run_surg_copy.sh ${TESTDIR} mutated ${TESTPREFIX}0${i} ${TESTDIR}/${TESTPREFIX}0${i}.txt ${TESTPREFIX} ${GENOME}
done


cp -r ${TESTDIR} results/
