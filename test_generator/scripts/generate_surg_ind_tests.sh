#!/bin/sh 

TESTDIR=$1
TESTPREFIX=$2
MODE=$4
N=$3

mkdir ${TESTDIR}

./scripts/run_iss.sh ${TESTDIR} genome.fa aligned 50
./scripts/run_iss.sh ${TESTDIR} genome.fa mutated 50

./scripts/generate_mut.exe carsonella/genome.fa ${TESTDIR}/general_config.txt -${MODE}
./scripts/generate_pack.exe ${TESTDIR}/general_config.txt ${TESTDIR}/${TESTPREFIX} ${N} -t

TESTDIR=$1

cp carsonella/genome.fa ${TESTDIR}
cp carsonella/genome.fa.fai ${TESTDIR}

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  TESTPREFIX=$2
  cp carsonella/genome.fa.fai ${TESTDIR}
  ./scripts/run_surg_ind.sh ${TESTDIR} mutated ${TESTPREFIX}0${i} ${TESTDIR}/${TESTPREFIX}0${i}.txt ${TESTPREFIX}
done

cp -r ${TESTDIR} results/

