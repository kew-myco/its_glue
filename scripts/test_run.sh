./scripts/pipe_one.trace_its.sh -t ./data/traces -f ITS1F -r ITS4 -o ./wrap_test

./scripts/pipe_one.trace_its.sh -t /home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/traces -f _fw -r _rev -o /home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out -x

vsearch --cluster_size '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/its/merged_its.fasta' \
--centroids '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/OTU_centroids.fa' \
--otutabout '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/OTU_cluster_memb.tsv' \
--uc '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/OTU_cluster_data.uc' \
--id 0.97 \
--sizeorder --clusterout_sort --maxaccepts 5


vsearch --sintax '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/its/its.ITS1.fasta' \
--db '/home/blex/Documents/Kew/fungi_research/genetics/seq_pipeline/ext_dbs/db_formatted.fasta' \
--sintax_cutoff 0.8 \
--tabbedout '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/its1_sintax_class.tsv'

./scripts/xtract_notmatched_sintax /home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/sintax_class.tsv /home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/no_match.csv


