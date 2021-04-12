# metamorphic

This is a prototype of pipeline uses metamorphic testing for bioinformatics pipelines.

Please build and run Docker image and use the following commands to run tests.

docker build -t bd .

docker run -it bd /bin/bash

. ./scripts/generate_surg_copy_tests.sh [test_directory] [prefix_for_tests] [N] [mode: c big duplicates] [reference genome .fa]

. ./scripts/generate_surg_ind_tests.sh [test_directory] [prefix_for_tests] [N] [mode: i inserts, d deletions, p point mutations] [reference genome .fa]

. ./scripts/generate_iss_tests.sh [test_directory] [prefix_for_tests] [N] [mode: i inserts, d deletions, p point mutations, c big duplicates] [reference genome .fa]

Please check test results in folder /root/results
 
