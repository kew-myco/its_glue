### basecalling

# basecall the forward seq for use as reference
tracy basecall -f fasta -o data/fasta/6_512/6_512_1_ref.fa data/traces/6_512/abi/6_512_1_ITS1F_A01.ab1

# assemble reverse using forward seq as reference
# -t specifies trimming stringency (default), -d set to 1 for hard consensus, i.e. 100% match
tracy assemble -t 1 -d 0.5 -r data/fasta/6_512/6_512_1_ref.fa -o data/fasta/6_512/6_512_1_A01 data/traces/6_512/abi/6_512_1_ITS4_A01.ab1


### itsexpress

# basecall with phred to fastq

## call bases with Phred

./scripts/phred_calls_no_trim.sh ./data/traces/6_512/abi ./data/phd/6_512

## convert phd to fastq

for file in ./data/phd/6_512/*.phd.1 ; do
    python3 ./scripts/phd2fastq.py $file -od ./data/fastq/6_512/
    echo 'converted' $file
done

## get RC of ITS4 for assembly

for file in ./data/fastq/6_512/*ITS4* ; do
    python3 ./scripts/rc_fastq.py $file -od ./data/fastq/6_512/
    echo 'transformed' $file
    #rm $file
done

#attempt vsearch merge

vsearch --fastq_mergepairs data/fastq/6_512/6_512_1_ITS1F_A01.fastq --reverse data/fastq/6_512/6_512_1_ITS4_A01.fastq --fastqout vsearch_mergetest.fastq \
--fastq_qmax 93 --fastq_allowmergestagger --fastq_truncqual 10


# attempt itsxpress
# only works with illumina encoded fastqs!
# doesn't work without qual data

itsxpress --fastq data/fastq/6_512/6_512_1_ITS1F_A01.fastq --single_end \
--region ALL --taxa Fungi --threads 2 \
--tempdir temp/ --keeptemp \
--log logfile.txt --outfile trimmed_reads.fastq

itsxpress --fastq data/fasta/6_512/6_512_1_A01_con.fq --single_end \
--region ALL --taxa Fungi --threads 2 \
--tempdir temp/ --keeptemp \
--log logfile.txt --outfile trimmed_reads.fastq

# attempt ITSx

ITSx -i data/fasta/6_512/6_512_1_A01_con.fasta -o A01
# ITSx works! Sort of. Can detect ITS1 and ITS2 but not surrounding SSU/LSU. Presumably because forming the consensus seq trims off these regions.
# So I guess it detects 5.8S and just takes either side of it to be ITS.

#test on non consensus

ITSx -i data/fasta/6_512/6_512_1_ITS1F_A01.fasta -o A01_single
#hypothesis confirmed - using forward strand nets us LSU
#Using tracy assemble with -d 0.5 to get consensus sequence, rather than -d 1, gives a con seq that lets us catch SSU for 6_512_1_A01. but I imagine the end of the seq is garbage?
