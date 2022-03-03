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

while getopts tc:od:fr:rr:pf: flag
do
    case "${flag}" in
        tc) trace_dir=${OPTARG};;
        od) out_dir=${OPTARG};;
        fr) f_read=${OPTARG};;
        rr) r_read=${OPRTARG};;
        pf) out_pref=${OPTARG};;
    esac
done

# FIRST TIME? RUN CREATE_ENV.sh:
conda activate ./seq_conda || echo 'conda environment not set up! Have you run CREATE_ENV.sh?'

### basecalling/assembly
# Using Tracy since 
# i) it's recent
# ii) it's expressly designed for (modern) Sanger data
# iii) I've had active discussions/collaboration from the devs

# assemble forward and reverse direct from traces
for file in $tc/*$rr* ; do
    xbase=${file##*/}
    code=$(awk -F'_R_' '{print $1}' <<< "$xbase") #code excluding primer id
    ffile=($tc/$code$fr*)
    tag='_cons'
    
    ./tracy/tracy consensus \
    -o data/tracy_assemble/$code$tag \
    -q 0 -u 0 -r 0 -s 0 -i \
    -b $code \
    $ffile \
    $file \
    &>> logs/cons_log.txt 
done
# STDOUT and STDERR logged
# no trimming performed with -qurs
# only intersect taken with -i

# Sietse's data DOESN'T WORK DUE TO OUTDATED FILE TYPE

# add counter!

### Collate seqs

cat ./data/tracy_assemble/*cons.fa > ./data/tracy_assemble/con_list.fasta

###  xtract ITS with ITSx

ITSx -i ./data/tracy_assemble/con_list.fasta -o ./data/its_out/its \
-t 'fungi' \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4

# extract forward and reverse strands from sequences where no ITS could be recognised in the consensus seq
# init empty array
# for line in its_no_detections, which corresponds to a sample code
# find the appropriate txt file in tracy assemble data
# read it into memory
# extract everything before ' Align'
# remove bracketed things
# append to array
# finally print all that out seperating with newlines

nd_ar=()
while read p; do
  echo $p
  pt=(./data/tracy_assemble/$p*_cons.txt)
  c=`cat $pt`
  c=${c%%[[:space:]]Align*}
  c=${c//(*)/}
  nd_ar+=($c)
done < data/its_out/its_no_detections.txt

printf "%s\n" "${nd_ar[@]}" > ./data/its_out/noconits.fa

# try ITSx on those

ITSx -i ./data/its_out/noconits.fa -o ./data/its_out/sing \
-t 'fungi' \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4

# cat these results - drop those we can't find ITS for, this is our major quality filter
cat ./data/its_out/*ITS1* > ./data/fasta/its1.fasta
cat ./data/its_out/*5_8S* > ./data/fasta/5_8S.fasta
cat ./data/its_out/*ITS2* > ./data/fasta/its2.fasta


#join ITS1 5.8S ITS2 per sample
python3 ./scripts/itsx_its_cat.py \
'./data/fasta/its1.fasta' \
'./data/fasta/5_8S.fasta' \
'./data/fasta/its2.fasta' \
-op './results/cat_its.fa'
