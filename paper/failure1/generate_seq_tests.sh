#!/bin/sh

TESTDIR=$1
TESTPREFIX=$2
N=$3
MODE=$4
GENOME=$5

mkdir ${TESTDIR}

./failure1/generate_mut.exe ${GENOME} ${TESTDIR}/general_config.txt -${MODE}
python3 failure1/generate_pack.py ${TESTDIR}/general_config.txt.inner ${TESTDIR}/${TESTPREFIX} $N
sequenza-utils gc_wiggle -f ${GENOME} -o ${TESTDIR}/genome.wig -w 50

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  ./failure1/apply_mut.exe ${GENOME} ${TESTDIR}/genome_mut_${MODE}${i}_n.fa $TESTDIR/${TESTPREFIX}0${i}_norm.txt -a
  ./failure1/apply_mut.exe ${GENOME} ${TESTDIR}/genome_mut_${MODE}${i}_t.fa $TESTDIR/${TESTPREFIX}0${i}_tum.txt -a

  ./failure1/run_iss_bwa.sh ${TESTDIR} ${TESTDIR}/genome_mut_${MODE}${i}_t.fa mutated_${MODE}${i}_t 50 ${GENOME}
  ./failure1/run_iss_bwa.sh ${TESTDIR} ${TESTDIR}/genome_mut_${MODE}${i}_n.fa mutated_${MODE}${i}_n 50 ${GENOME}


  sequenza-utils bam2seqz -n ${TESTDIR}/mutated_${MODE}${i}_n.bam -t ${TESTDIR}/mutated_${MODE}${i}_t.bam -gc ${TESTDIR}/genome.wig -F ${GENOME} -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt
  sequenza-utils seqz_binning --seqz ${TESTDIR}/genome_mut_${MODE}${i}_seq.txt -w 50 -o ${TESTDIR}/genome_mut_${MODE}${i}_seq.seqz

  ./failure1/run_strelka_germ.sh ${TESTDIR} mutated_${MODE}${i}_n ${TESTPREFIX}_n_0${i} ${GENOME}
  ./failure1/run_strelka_germ.sh ${TESTDIR} mutated_${MODE}${i}_t ${TESTPREFIX}_t_0${i} ${GENOME}
  ./failure1/run_strelka_som.sh ${TESTDIR} mutated_${MODE}${i}_n mutated_${MODE}${i}_t ${TESTPREFIX}0${i} ${GENOME}

done

mv -r ${TESTDIR} results/
