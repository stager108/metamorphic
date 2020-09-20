#!/bin/sh 

TESTDIR=$1
TESTCONFIG=$2
N=$3

for ((i=1; i<=$N; i++)) do
    . ./scripts/run_iss.sh $TESTDIR aligned
    . ./scripts/run_surg.sh $TESTDIR aligned mut $TESTCONFIG_$i.txt
    . ./scripts/run_strelka.sh $TESTDIR aligned mut

    gzip -d ./$TESTDIR/strelka/results/variants/somatic.indels.vcf.gz 
    mv ./$TESTDIR/strelka/results/variants/somatic.indels.vcf $TESTCONFIG_$i.vcf
    rm -r $TESTDIR 
done
