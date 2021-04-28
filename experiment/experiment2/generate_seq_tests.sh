#!/bin/sh

TESTDIR=$1
TESTPREFIX=$2
N=$3
MODE=$4
GENOME=$5

mkdir ${TESTDIR}

./scripts/run_iss_bwa.sh ${TESTDIR} ${GENOME} aligned 50 ${GENOME}
./scripts/run_iss_bwa.sh ${TESTDIR} ${GENOME} mutated 50 ${GENOME}

./scripts/generate_mut.exe ${GENOME} ${TESTDIR}/general_config.txt -${MODE}
./scripts/generate_pack.exe ${TESTDIR}/general_config.txt.ind ${TESTDIR}/${TESTPREFIX}_ind $N -t
./scripts/generate_pack.exe ${TESTDIR}/general_config.txt.sv ${TESTDIR}/${TESTPREFIX}_sv $N -t

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1

  ./scripts/run_surg_copy.sh ${TESTDIR} mutated ${TESTPREFIX}0${i}c ${TESTDIR}/${TESTPREFIX}_sv0${i}.txt ${TESTPREFIX} ${GENOME}
  ./scripts/run_surg_ind.sh ${TESTDIR} ${TESTPREFIX}0${i}c ${TESTPREFIX}0${i} ${TESTDIR}/${TESTPREFIX}_ind0${i}.txt ${TESTPREFIX} ${GENOME}

  sequenza-utils gc_wiggle -f ${TESTDIR}/genome_mut_${MODE}${i}.fa -o ${TESTDIR}/genome_mut_${MODE}${i}.wig -w 50
  sequenza-utils bam2seqz -n ${TESTDIR}/aligned.bam -t ${TESTDIR}/mutated_${MODE}${i}.bam -gc ${TESTDIR}/genome_mut_${MODE}${i}.wig -F ${GENOME} -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt.gz
  sequenza-utils seqz_binning --seqz ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt.gz -w 50 -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.seqz.gz

  ./scripts/run_strelka.sh ${TESTDIR} aligned mutated_${MODE}${i} ${TESTPREFIX}0${i} ${GENOME}

done

mv -r ${TESTDIR} results/


