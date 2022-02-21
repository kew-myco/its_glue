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
####         samplecode_ITS*.ext                                       ####
####                                                                   ####
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

conda activate ./seq_conda

### basecalling/assembly
# Using Tracy since 
# i) it's recent
# ii) it's expressly designed for (modern) Sanger data

# Tracy can output basecalls directly
# .tsv output gives a sort of qual scores

# assemble forward and reverse direct from traces
# -t specifies trimming stringency (default), 
# -f set to 1 for hard consensus, i.e. 100% match. 
# -f 0.5 seems to get decent consensus without Ns
# tracy doc/output sparse, discussing with author on github (feb 2022)

# assemble without ref
for file in ./data/traces/*ITS4* ; do
    xbase=${file##*/}
    code=$(awk -F'_ITS' '{print $1}' <<< "$xbase") #code excluding primer id
    F='_ITS1F'
    ffile=(./data/traces/$code$F*)
    
    ./tracy/tracy assemble --inccons \
    -o data/tracy_assemble/$code \
    $file \
    $ffile \
    &>> logs/assem_log.txt # log STDOUT and STDERR to catch assembly failures
done

# Sietse's data DOESN'T WORK DUE TO OUTDATED FILE TYPE
# for file in ./data0/traces/*ITS4* ; do
#     xbase=${file##*/}
#     wellcode=$(awk -F'_ITS' '{print $1}' <<< "$xbase") #code excluding primer id
#     F='_ITS1F'
#     ffile=(./data0/traces/$wellcode$F*)
#    
#    ./tracy/tracy assemble --inccons \
#    -o data0/tracy_assemble/$wellcode \
#     $file \
#     $ffile \
#     &>> logs/assem0_log.txt # log STDOUT and STDERR to catch assembly failures
# done

# for 6_512, successful xtraction from 180 of X? number of seqs
# add counter!

### Collate seqs?

cat ./data/tracy_assemble/*cons.fasta > ./data/fasta/con_list.fasta

###  xtract ITS with ITSx

# ITSx with tracy -d 1 can detect ITS1 and ITS2 but often not surrounding SSU/LSU. 
# Presumably because forming the consensus seq trims off these regions.
# So I guess it detects 5.8S and just takes either side of it to be ITS.
# hypothesis confirmed - using forward strand nets us LSU

# Using tracy assemble with -d 0.5 to get consensus sequence, 
# rather than -d 1, gives a con seq that lets us catch SSU for 6_512_1_A01.
# But I imagine the end of the seq is garbage?
# Catching SSU is most important, seqs then start at same location!

ITSx -i ./data/fasta/con_list.fasta -o ./data/itsx_out/its \
-t 'fungi' \
--complement F \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4

#join ITS1 5.8S ITS2

python3 ./scripts/itsx_its_cat.py \
'./data/itsx_out/its.ITS1.fasta' \
'./data/itsx_out/its.5_8S.fasta' \
'./data/itsx_out/its.ITS2.fasta' \
-op './results/cat_its.fa'

#vsearch with fixed seed

vsearch --sintax ./results/cat_its.fa \
--db ./ext_dbs/utax_unite8.3.gz \
--sintax_cutoff 0.95 \
--tabbedout ./results/vsearchres




