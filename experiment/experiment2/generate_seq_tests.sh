#!/bin/sh

TESTDIR=$1
TESTPREFIX=$2
N=$3
MODE=$4
GENOME=$5

mkdir ${TESTDIR}

sequenza-utils gc_wiggle -f ${GENOME} -o ${TESTDIR}/genome_mut.wig -w 50

./experiment2/run_iss_bwa.sh ${TESTDIR} ${GENOME} aligned 150 ${GENOME}
./experiment2/run_iss_bwa.sh ${TESTDIR} ${GENOME} mutated 150 ${GENOME}
./experiment2/run_iss_bwa.sh ${TESTDIR} ${GENOME} donor 150 ${GENOME}

./experiment2/generate_mut.exe ${GENOME} ${TESTDIR}/general_config -${MODE}
./experiment2/generate_pack.exe ${TESTDIR}/general_config.ind ${TESTDIR}/${TESTPREFIX}_ind $N -t
./experiment2/generate_pack.exe ${TESTDIR}/general_config.sv ${TESTDIR}/${TESTPREFIX}_sv $N -t

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  ./experiment2/run_surg_ind.sh ${TESTDIR} mutated ${TESTPREFIX}0${i}c ${TESTDIR}/${TESTPREFIX}_ind0${i}.txt ${TESTPREFIX} ${GENOME}
  ./experiment2/run_surg_copy.sh ${TESTDIR} ${TESTPREFIX}0${i}c ${TESTPREFIX}0${i} ${TESTDIR}/${TESTPREFIX}_sv0${i}.txt ${TESTPREFIX} ${GENOME} ${TESTDIR}/donor.bam

  sequenza-utils bam2seqz -n ${TESTDIR}/aligned.bam -t ${TESTDIR}/${TESTPREFIX}0${i}.bam -gc ${TESTDIR}/genome_mut.wig -F ${GENOME} -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt
  sequenza-utils seqz_binning --seqz ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt -w 50 -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.seqz

  ./experiment2/run_strelka.sh ${TESTDIR} aligned ${TESTPREFIX}0${i} ${TESTPREFIX} ${GENOME}

done

mv ${TESTDIR} results/


