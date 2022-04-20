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

set -e

while getopts c:d:f:o:x flag
do
    case "${flag}" in
        c) closed_ref="y";;
        d) db=${OPTARG};;
        f) fasta=${OPTARG};;
        o) out_dir=${OPTARG};;
        x) overwrite="y";;

        *) echo "ERROR: invalid flag! Have you read the README?" 
           exit 1
           ;;
    esac
done

#(TODO: make flags c and x do more things)
if [[ "$db" == "" || "$fasta" == "" ]] ; then
    echo "ERROR: flags -d and -f require arguments." >&2
    exit 1
fi

if [[ "$out_dir" == "" ]] ; then
    out_dir='.'
fi


#activate conda
CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"
if conda activate ./seq_conda ; then
    echo "activated conda env"
else 
    echo 'conda environment not set up! Have you run CREATE_ENV.sh?'
    exit 1
fi

# CLOSED REFERENCE OTU ASSIGN
# vsearch sintax, bootstrap support 0.6 per Edgar (https://www.drive5.com/usearch/manual/cmd_sintax.html)

vsearch --sintax "${fasta}" \
--db "${db}" \
--sintax_cutoff 0.6 \
--tabbedout "${out_dir}"/sintax_classifications.tsv

# Sort unmatched reads (TODO: possibly into taxonomic groups?)
python3 ./scripts/modules/xtract_notmatched_sintax.py "${out_dir}"/sintax_classifications.tsv "${fasta}" "${out_dir}"/nomatch.fa

# OPEN REFERENCE OTU ASSIGN
# vsearch cluster to OTUs
# --id 0.97 : 97% pairwise to match to an OTU. This isn't ideal but it's certainly standard
# --sizeorder: abundance trumps distance for ties
# --maxaccepts: number of decent hits to look for before making a decision (default 1!)

vsearch --cluster_size "${out_dir}"/nomatch.fa \
--centroids "${out_dir}"/OTU_centroids.fa \
--otutabout "${out_dir}"/OTU_cluster_membership.tsv \
--uc "${out_dir}"/OTU_cluster_data.uc \
--id 0.97 \
--sizeorder --clusterout_sort --maxaccepts 5

# Tentatively identify those clusters
vsearch --sintax "${out_dir}"/OTU_centroids.fa \
--db "${db}" \
--sintax_cutoff 0.6 \
--tabbedout "${out_dir}"/sintax_denovo_classifications.tsv

#(TODO: merge output)

