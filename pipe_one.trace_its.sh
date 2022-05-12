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

while getopts t:f:r:o:x flag
do
    case "${flag}" in
        t) trace_dir=${OPTARG};;
        f) f_tag=${OPTARG};;
        r) r_tag=${OPTARG};;
        o) out_dir=${OPTARG};;
        x) overwrite="y";; 
        
        *) echo "ERROR: invalid flag! Have you read the README?" >&2
           exit 1
           ;;
    esac
done

if [[ "$trace_dir" == "" || "$f_tag" == "" || "$r_tag" == "" ]] ; then
    echo "ERROR: flags -t, -f, and -r require arguments." >&2
    exit 1
fi

if [[ "$out_dir" == "" ]] ; then
    out_dir='.'
fi

if [[ "$overwrite" == "y" ]] ; then
    mkdir -p "$out_dir"/assembly "$out_dir"/its
else
    mkdir "${out_dir}"/assembly "${out_dir}"/its
fi

echo "" # blank line to space output

# FIRST TIME? RUN CREATE_ENV.sh:
CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"
if conda activate ./seq_conda ; then
    echo "activated conda env"
else 
    echo 'ERROR: conda environment not set up! Have you run CREATE_ENV.sh?' >&2
    exit 1
fi

### basecalling/assembly
# Using Tracy since 
# i) it's recent
# ii) it's expressly designed for (modern) Sanger data
# iii) I've had active discussions/collaboration from the devs

# check all filenames are unique

# assemble forward and reverse direct from traces
echo "running Tracy..."
ftot=$(ls "$trace_dir"/*"$r_tag".* | wc -l)
if [ $ftot -eq 0 ] ; then echo "ERROR: 0 trace files detected using given -r tag" >&2 ; exit 1 ; fi
trac_count=0
fail_count=0
if [ -f "$out_dir"/assembly/basecall_log.txt ] ; then > "$out_dir"/assembly/basecall_log.txt ; fi
for file in "$trace_dir"/*"$r_tag".* ; do

    # take full path of file and delete all except filename
    xbase="${file##*/}"
    
    # get filename excluding primer/direction id
    code=${xbase%%"$r_tag"*}
    
    # check only a pair of files for given $code
    uchk=$(ls "$trace_dir"/"$code"* | wc -l)
    if [ "$uchk" -gt 2 ] ; then
        echo "multiple matching filenames detected for "${code}", skipping" >> "$out_dir"/assembly/basecall_log.txt
        fail_count=$((fail_count + 1))
        continue
    fi
    if [ "$uchk" -lt 2 ] ; then
        echo "single file (no pair) detected for "${code}", skipping" >> "$out_dir"/assembly/basecall_log.txt
        fail_count=$((fail_count + 1))
        continue
    fi
    
    # grab matching file
    ffile=("$trace_dir"/"$code"*"$f_tag".*)
    
    # assemble - -t 2 best trimming so far in terms of result. -qurs tbc -q 100 -u 500 -r 100 -s 500. -qurs equal is appealing... getting the right -p might be valuable
    if
    ./tracy/tracy consensus \
    -o "$out_dir"/assembly/"$code"_cons \
    -p 0.3 \
    -t 2  \
    -b "$code" \
    "$ffile" \
    "$file" \
    2>> "$out_dir"/assembly/basecall_log.txt 1> /dev/null
    
    then
    trac_count=$((trac_count + 1))

    else
    fail_count=$((fail_count + 1))
    
    fi
    
    echo -ne ""${trac_count}"/"${ftot}" assembled, "${fail_count}" failures\r"

done


if [ "$trac_count" -eq 0 ] ; then
    echo "ERROR: assembled 0 samples! Check log files for details"
    exit 1
fi

echo ""${trac_count}"/"${ftot}" assembled, "${fail_count}" failures - check logs for failure details"

# STDOUT and STDERR logged
# no trimming performed with -qurs
# only intersect taken with -i

# add counter!

### Collate seqs

cat "$out_dir"/assembly/*cons.fa > "$out_dir"/assembly/consensus_seqs.fasta

###  xtract ITS with ITSx
echo "running ITSx..."
ITSx -i "$out_dir"/assembly/consensus_seqs.fasta -o "$out_dir"/its/consensus \
-t 'fungi' \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4 \
--temp "$out_dir"

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
while read -r p; do

  pt=("$out_dir"/assembly/"$p"*_cons.txt)
  
  c=$(cat "$pt")
  c=${c%%[[:space:]]Align*}
  c=${c//(*)/}
  
  nd_ar+=("$c")
  
  nd_count=$((nd_count + 1))
  
done < "$out_dir"/its/consensus_no_detections.txt

if [[ $nd_count -ne 0 ]] ; then
echo "no ITS detected in consensus for $nd_count samples, trying single direction strands..."
fi

printf "%s\n" "${nd_ar[@]}" > "$out_dir"/its/consensus_no_detections.fasta


# try ITSx on those
ITSx -i "$out_dir"/its/consensus_no_detections.fasta -o "$out_dir"/its/single_direction \
-t 'fungi' \
--graphical F \
--save_regions 'ITS1,5.8S,ITS2' \
--cpu 4 \
--temp "$out_dir"

echo "sorting results..."

cat "$out_dir"/its/*ITS1* > "$out_dir"/its/its1.merge.fasta
cat "$out_dir"/its/*5_8S* > "$out_dir"/its/5_8S.merge.fasta
cat "$out_dir"/its/*ITS2* > "$out_dir"/its/its2.merge.fasta

echo "sorting consensus..."

# cat results - drop those we can't find ITS for, this is our major quality filter
#join ITS1 5.8S ITS2 per sample
# for consensus only
python3 ./scripts/modules/itsx_its_cat.py \
"$out_dir/its/consensus.ITS1.fasta" \
"$out_dir/its/consensus.5_8S.fasta" \
"$out_dir/its/consensus.ITS2.fasta" \
-n "consensus.merged_ITS_seqs.fasta" \
-od "$out_dir/its/"

echo "sorting all..."

python3 ./scripts/modules/itsx_its_cat.py \
"$out_dir/its/its1.merge.fasta" \
"$out_dir/its/5_8S.merge.fasta" \
"$out_dir/its/its2.merge.fasta" \
-n "all.merged_ITS_seqs.fasta" \
-od "$out_dir/its/"

echo "done!"
