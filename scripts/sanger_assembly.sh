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
####         Country_Site_Plate_Well_ITS*.ext                          ####
####                                                                   ####
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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
    wellcode=$(awk -F'_ITS' '{print $1}' <<< "$xbase") #code excluding primer id
    F='_ITS1F'
    ffile=(./data/traces/$wellcode$F*)
    
    ./tracy/tracy assemble --inccons \
    -o data/tracy_assemble/$wellcode \
    $file \
    $ffile \
    &>> logs/assem_log.txt # log STDOUT and STDERR to catch assembly failures
done

# for 6_512, successful xtraction from 180 of X? number of seqs
# add counter!

#### MUST UPDATE BELOW
### Collate seqs?

cat ./data/fasta/*_con.fasta > ./data/fasta/con_list.fasta

###  xtract ITS with ITSx

# ITSx with tracy -d 1 can detect ITS1 and ITS2 but not surrounding SSU/LSU. 
# Presumably because forming the consensus seq trims off these regions.
# So I guess it detects 5.8S and just takes either side of it to be ITS.
# hypothesis confirmed - using forward strand nets us LSU

# Using tracy assemble with -d 0.5 to get consensus sequence, 
# rather than -d 1, gives a con seq that lets us catch SSU for 6_512_1_A01.
# But I imagine the end of the seq is garbage?
# Catching SSU is most important, seqs then start at same location!

ITSx -i ./data/fasta/con_list.fasta -o ./data/its_out/its \
-t 'fungi' \
--complement F \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4
