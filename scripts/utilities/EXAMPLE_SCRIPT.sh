./scripts/pipe_one.trace_its.sh -t ./data/traces -f '_ITS1F' -r '_ITS4' -o ../bash3_test -x

./scripts/pipe_two.cluster_classify.sh -d ./ext_dbs/db_formatted.fasta \
-f ../bash3_test/its/ALL_ITS.fa \
-o ../bash3_test

