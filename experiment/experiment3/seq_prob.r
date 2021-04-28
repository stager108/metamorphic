#!/usr/bin/env Rscript
library(sequenza)
data.file <-  system.file("extdata", "example.seqz.txt.gz", package = "sequenza$
test <- sequenza.extract(data.file, verbose = FALSE)
CP <- sequenza.fit(test)
sequenza.results(sequenza.extract = test,
    cp.table = CP, sample.id = "Test",
    out.dir="TEST")

