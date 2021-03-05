# metamorphic

This is a prototype of pipeline uses metamorphic testing for bioinformatics tool named Strelka2.
The purpose of that was to check if this method is usable for testing pipelines.
Some of test scripts uses wrong problem formulation, so they're out of use.

Please build and run Docker image and use the following commands to run tests.

docker build -t bd .

docker run -it bd /bin/bash

. ./scripts/test_surg_casc_mut.sh [test_directory] [prefix_for_tests] [N] [mode: i inserts, d deletions, p point mutations, r replacements]

. ./scripts/test_coverage.sh [test_directory] [N] [mode: i inserts, d deletions, p point mutations, r replacements] 

Please check test results in folder /root/results
