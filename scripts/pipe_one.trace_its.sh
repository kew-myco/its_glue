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

while getopts t:f:r:o:x flag
do
    case "${flag}" in
        t) trace_dir=${OPTARG};;
        f) f_tag=${OPTARG};;
        r) r_tag=${OPTARG};;
        o) out_dir=${OPTARG};;
        x) overwrite="y";; 
    esac
done

if [[ "$trace_dir" == "" || "$f_tag" == "" || "$r_tag" == "" ]] ; then
    echo "ERROR: flags -t, -f, and -r require arguments." >&2
    exit 1
fi

if [[ "$out_dir" == "" ]] ; then
    out_dir='.'
fi

if [[ "${overwrite}" == "y" ]] ; then
    mkdir -p ${out_dir}/assembly ${out_dir}/its ${out_dir}/logs
else
    mkdir ${out_dir}/assembly ${out_dir}/its ${out_dir}/logs || echo "ERROR: output directory exists! Did you want to overwrite with -x?" ; exit 1
fi

echo "" # blank line to space output

# FIRST TIME? RUN CREATE_ENV.sh:
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
if conda activate ./seq_conda ; then
    echo "activated conda env"
else 
    echo 'conda environment not set up! Have you run CREATE_ENV.sh?'
    exit 1
fi

### basecalling/assembly
# Using Tracy since 
# i) it's recent
# ii) it's expressly designed for (modern) Sanger data
# iii) I've had active discussions/collaboration from the devs

# assemble forward and reverse direct from traces
echo "running Tracy..."
trac_count=0
for file in ${trace_dir}/*${r_tag}* ; do
    xbase=${file##*/}
    code=$(awk -F"${r_tag}" '{print $1}' <<< "$xbase") #code excluding primer id
    ffile=(${trace_dir}/${code}*${f_tag}*)
    tag='_cons'
    
    if
    ./tracy/tracy consensus \
    -o ${out_dir}/assembly/$code$tag \
    -q 0 -u 0 -r 0 -s 0 -i \
    -b $code \
    $ffile \
    $file \
    &>> ${out_dir}/logs/cons_log.txt ;
    
    then
    let trac_count++ 
    
    else 
    echo "assembly failure for ${code}!"
    
    fi
    
done
echo "assembled ${trac_count} samples"

# STDOUT and STDERR logged
# no trimming performed with -qurs
# only intersect taken with -i

# add counter!

### Collate seqs

cat ${out_dir}/assembly/*cons.fa > ${out_dir}/assembly/con_list.fasta

###  xtract ITS with ITSx
echo "running ITSx..."
ITSx -i ${out_dir}/assembly/con_list.fasta -o ${out_dir}/its/its \
-t 'fungi' \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4 \
&>> ${out_dir}/logs/its_cons_log.txt


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
nd_count=0
while read p; do

  pt=(${out_dir}/assembly/${p}*_cons.txt)
  
  c=`cat $pt`
  c=${c%%[[:space:]]Align*}
  c=${c//(*)/}
  
  nd_ar+=($c)
  
  let nd_count++
  
done < ${out_dir}/its/its_no_detections.txt

if [[ $nd_count -ne 0 ]] ; then
echo "no ITS detected in consensus for $nd_count samples, trying single direction strands..."
fi

printf "%s\n" "${nd_ar[@]}" > ${out_dir}/its/noconits.fa


# try ITSx on those
ITSx -i ${out_dir}/its/noconits.fa -o ${out_dir}/its/sing \
-t 'fungi' \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4 \
&>> ${out_dir}/logs/its_sing_log.txt

echo "sorting results..."

# cat results - drop those we can't find ITS for, this is our major quality filter
cat ${out_dir}/its/*ITS1* > ${out_dir}/its/its1.merge.fa
cat ${out_dir}/its/*5_8S* > ${out_dir}/its/5_8S.merge.fa
cat ${out_dir}/its/*ITS2* > ${out_dir}/its/its2.merge.fa


#join ITS1 5.8S ITS2 per sample
python3 ./scripts/modules/itsx_its_cat.py \
"${out_dir}/its/its1.merge.fa" \
"${out_dir}/its/5_8S.merge.fa" \
"${out_dir}/its/its2.merge.fa" \
-op "${out_dir}"

echo "done!"
