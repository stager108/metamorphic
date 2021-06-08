#!/bin/sh
#!/bin/sh

TESTDIR=$1
TESTPREFIX=$2
N=$3
MODE=$4
GENOME=$5

mkdir ${TESTDIR}

./experiment4/run_iss_bwa.sh ${TESTDIR} ${GENOME} aligned 50 ${GENOME}
./experiment4/run_iss_bwa.sh ${TESTDIR} ${GENOME} mutated 50 ${GENOME}

./experiment4/generate_mut.exe ${GENOME} ${TESTDIR}/general_config.txt -${MODE}
python3 experiment4/generate_pack.py ${TESTDIR}/general_config.txt ${TESTDIR}/${TESTPREFIX} $N

for i in `seq 0 $((N-1))`
do
  TESTDIR=$1
  ./experiment4/run_surg_ind.sh ${TESTDIR} mutated ${TESTPREFIX}0${i}_n $TESTDIR/${TESTPREFIX}0${i}_norm.txt ${TESTPREFIX} ${GENOME}

  ./experiment4/run_surg_ind.sh ${TESTDIR} ${TESTPREFIX}0${i}_n ${TESTPREFIX}0${i}_t $TESTDIR/${TESTPREFIX}0${i}_tum.txt ${TESTPREFIX} ${GENOME}

  ./experiment4/run_strelka_germ.sh ${TESTDIR} ${TESTPREFIX}0${i}_n ${TESTPREFIX}_n_0${i} ${GENOME}
  ./experiment4/run_strelka_germ.sh ${TESTDIR} ${TESTPREFIX}0${i}_t ${TESTPREFIX}_t_0${i} ${GENOME}
  ./experiment4/run_strelka_som.sh ${TESTDIR} ${TESTPREFIX}0${i}_n ${TESTPREFIX}0${i}_t ${TESTPREFIX}0${i} ${GENOME}
done
