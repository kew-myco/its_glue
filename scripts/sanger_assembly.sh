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

### basecalling
# Using Tracy since 
# i) it's recent
# ii) it's expressly designed for (modern) Sanger data

# basecall the forward seq for use as reference
for file in ./data/traces/*ITS1F* ; do
    extn=".fa"
    xbase=${file##*/} #get filename
    xpref=${xbase%.*} #drop extension
    xout=$xpref$extn
    tracy basecall -f fasta -o data/fasta/$xout $file \
    &>> logs/basecall_log.txt # log to catch errors
done

# basecall with tsv for qual scores
# for file in ./data/traces/*ITS1F* ; do
#    extn=".tsv"
#    xbase=${file##*/} #get filename
#    xpref=${xbase%.*} #drop extension
#    xout=$xpref$extn
#    tracy basecall -f tsv -o data/tsv/$xout $file \
#    &>> logs/basecall_log.txt # log to catch errors
# done

# assemble reverse using forward seq as reference
# -t specifies trimming stringency (default), 
# -d set to 1 for hard consensus, i.e. 100% match. 
# -d 0.5 seems to get decent consensus without Ns
# tracy doc/output sparse, discussing with author on github (feb 2022)
for file in ./data/traces/*ITS4* ; do
    xbase=${file##*/}
    xpref=${xbase%.*}
    wellcode=$(awk -F'_ITS' '{print $1}' <<< "$xbase") #code excluding primer id
    reffile=(./data/fasta/$wellcode*)
    
    tracy assemble -t 2 -d 0.5 \
    -r $reffile \
    -o data/tracy_assemble/$wellcode \
    --inccons \
    $file \
    &>> logs/assem_log.txt # log STDOUT and STDERR to catch assembly failures
done

### Extract gap free consensus 

for file in ./data/tracy_assemble/*.json ; do
    python3 ./scripts/consensus_from_tracy_json.py $file -od ./data/fasta
    echo 'extracted consensus' $file
done

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
