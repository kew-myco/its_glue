#!/usr/bin/env bash
#                                                                         #
#               .__  __                   .__                             #
#               |__|/  |_  ______    ____ |  |  __ __   ____              #
#               |  \   __\/  ___/   / ___\|  | |  |  \_/ __ \             #
#               |  ||  |  \___ \   / /_/  >  |_|  |  /\  ___/             #
#               |__||__| /____  >  \___  /|____/____/  \___  >            #
##                            \/  /_____/                  \/            ##
###                                                                     ###  
####         Author : Alex Byrne                                       ####    
####         Contact : ablex7@gmail.com                                ####
####                                                                   ####
####         See its_glue github for usage details.                    ####
####                                                                   ####
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

set -e

while getopts d:f:o:x flag
do
    case "${flag}" in
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

# vsearch cluster to OTUs
# --id 0.97 : 97% pairwise to match to an OTU. This isn't ideal but it's certainly standard
# --sizeorder: abundance trumps distance for ties
# --maxaccepts: number of decent hits to look for before making a decision (default 1!)
vsearch --cluster_size "${fasta}" \
--otutabout "${out_dir}"/cluster_membership.tsv \
--id 0.97 \
--sizeorder --clusterout_sort

vsearch --sintax "${fasta}" \
--db "${db}" \
--sintax_cutoff 0.6 \
--tabbedout "${out_dir}"/sintax_classifications.tsv


#(TODO: merge output)
