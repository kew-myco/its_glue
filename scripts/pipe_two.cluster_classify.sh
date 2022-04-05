#!/usr/bin/env bash

#   .__  __           __________.__              .__  .__                 #
#   |__|/  |_  ______ \______   \__|_____   ____ |  | |__| ____   ____    #
#   |  \   __\/  ___/  |     ___/  \____ \_/ __ \|  | |  |/    \_/ __ \   #
#   |  ||  |  \___ \   |    |   |  |  |_> >  ___/|  |_|  |   |  \  ___/   #
#   |__||__| /____  >  |____|   |__|   __/ \___  >____/__|___|  /\___  >  #
#                 \/               |__|        \/             \/     \/   #
#                                                                         #
##                                                                       ##
###                                                                     ###  
####         Author : Alex Byrne                                       ####    
####         Contact : ablex7@gmail.com                                ####
####                                                                   ####
####         Run from top level of seq_pipeline project folder         ####
####         By default, expects .ab1 files in the format:             ####
####         samplecode_DIRECTION_*.ab1 - e.g '_R_' = reverse          ####
####         reads. The * just means anything can come after.          ####
####         The sample filenames MUST match before the direction      ####
####         is given.                                                 ####
####                                                                   ####
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# CLOSED REFERENCE OTU ASSIGN
# vsearch sintax, bootstrap support 0.8 per Edgar (https://www.drive5.com/usearch/manual/cmd_sintax.html)

vsearch --sintax './results/OTU_centroids.fa' \
--db ./ext_dbs/utax_unite8.3.gz \
--sintax_cutoff 0.8 \
--tabbedout './results/sintax_class.tsv'

# Sort unmatched reads, possibly into taxonomic groups?
python3 ./scripts/modules/xtract_notmatched_sintax.py '[SOURCE]' '[DESTINATION]'

# OPEN REFERENCE OTU ASSIGN
# vsearch cluster to OTUs
# --id 0.97 : 97% pairwise to match to an OTU. This isn't ideal but it's certainly standard
# --sizeorder: abundance trumps distance for ties
# --maxaccepts: number of decent hits to look for before making a decision (default 1!)

vsearch --cluster_size 'PLACEHOLDER' \
--centroids './results/OTU_centroids.fa' \
--otutabout './results/OTU_cluster_memb.tsv' \
--uc './results/OTU_cluster_data.uc' \
--id 0.97 \
--sizeorder --clusterout_sort --maxaccepts 5

# Do something with those clusters...

