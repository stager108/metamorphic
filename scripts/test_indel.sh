#!/bin/sh

# requires samtools/bcftools

if [ $# -ne 1 ]
then
    echo "usage: $0 <path to picard.jar>"
    exit 65
fi

REF=../bamsurgeon/test_data/Homo_sapiens_chr22_assembly19.fasta

command -v addindel.py >/dev/null 2>&1 || { echo "addindel.py isn't installed" >&2; exit 65; }

if [ ! -e $1 ]
then
    echo "cannot find picard.jar"
    exit 65
fi


addindel.py -v ../bamsurgeon/test_data/test_indels.txt -f  ../bamsurgeon/test_data/testregion_realign.bam -r $REF -o ../bamsurgeon/test_data/testregion_mut.bam  --picardjar $1 --aligner mem --s$

if [ $? -ne 0 ]
then
 echo "addindel.py failed."
 exit 1 
else
    samtools sort -T ../bamsurgeon/test_data/testregion_mut.sorted.bam -o ../bamsurgeon/test_data/testregion_mut.sorted.bam ../bamsurgeon/test_data/testregion_mut.bam
    mv ../bamsurgeon/test_data/testregion_mut.sorted.bam ../bamsurgeon/test_data/testregion_mut.bam
    samtools index ../bamsurgeon/test_data/testregion_mut.bam
    samtools mpileup -ugf $REF ../bamsurgeon/test_data/testregion_mut.bam | bcftools call -vm
fi
 

