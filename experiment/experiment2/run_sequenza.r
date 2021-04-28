#!/usr/bin/env Rscript
library(sequenza)
sqz     <- "/root/test1/genome_mut_i0_seq.seqz"
dir.out <- "out"
sqz.id  <- "id1"

test <- sequenza.extract(file=sqz, verbose = FALSE,
gamma = 60, min.reads = 20,
                                  kmin = 200, weighted.mean = FALSE,
                                  min.fw.freq = 0, min.reads.baf = 15)
warnings()
CP <- sequenza.fit(test)
sequenza.results(sequenza.extract = test,
    cp.table = CP, sample.id = "id1",
    out.dir="TEST")


