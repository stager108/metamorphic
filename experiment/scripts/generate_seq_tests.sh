#!/bin/sh

TESTDIR=$1
TESTPREFIX=$2
N=$3
MODE=$4
GENOME=$5

mkdir ${TESTDIR}
./scripts/run_iss_bwa.sh ${TESTDIR} ${GENOME} aligned 50 ${GENOME}

./scripts/generate_mut.exe ${GENOME} ${TESTDIR}/general_config.txt -${MODE}
./scripts/generate_pack.exe ${TESTDIR}/general_config.txt.inner ${TESTDIR}/${TESTPREFIX} $N -t

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  ./scripts/apply_mut.exe ${GENOME} ${TESTDIR}/genome_mut_${MODE}${i}.fa $TESTDIR/${TESTPREFIX}0${i}.txt -a
  ./scripts/run_iss_bwa.sh ${TESTDIR} ${TESTDIR}/genome_mut_${MODE}${i}.fa mutated_${MODE}${i} 50 ${GENOME}

  sequenza-utils gc_wiggle -f ${TESTDIR}/genome_mut_${MODE}${i}.fa -o ${TESTDIR}/genome_mut_${MODE}${i}.wig -w 50
  sequenza-utils bam2seqz -n ${TESTDIR}/aligned.bam -t ${TESTDIR}/mutated_${MODE}${i}.bam -gc ${TESTDIR}/genome_mut_${MODE}${i}.wig -F ${GENOME} -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt
  sequenza-utils seqz_binning --seqz ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt -w 50 -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.seqz

  ./scripts/run_strelka.sh ${TESTDIR} aligned mutated_${MODE}${i} ${TESTPREFIX}0${i} ${GENOME}

done

cp -r ${TESTDIR} results/
