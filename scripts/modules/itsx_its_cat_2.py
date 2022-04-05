#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 17 22:15:53 2022

@author: blex
"""

from Bio import SeqIO
from Bio import Seq
from argparse import ArgumentParser
import re
    
def coll_seqs(seq_lists) :
    names = [x[0::2] for x in seq_lists]
    seqs = [x[1::2] for x in seq_lists]

    #flatten
    flat_names = [n for sl in names for n in sl]
    flat_seqs = [n for sl in seqs for n in sl]

    # extract sample ids
    ids = [re.search('>(.+?)\|', n).group(1) for n in flat_names]

    # merge ids and seqs
    recs = list(zip(ids, flat_seqs))
    
    return recs, set(ids)

def seq_dict(recs, ids, join = False) :
    # init empty dict
    s_dict={}
    # add seqs to dict values matching by id
    for key in ids :
        parts = [rec[1].replace('\n', '') for rec in recs if key in rec]
        
        if join == True : 
            full = ''.join(parts)
            s_dict[key] = full
        else :
            s_dict[key] = parts
    
    # filter out empty ids
    if join == True : 
        s_dict = {k: v for k, v in s_dict.items() if v}
    else :
        s_dict = {k: v for k, v in s_dict.items() if len(v) == 2}
    return s_dict

# convert to iterable of seqrecords
def dict_2_sr(s_dict) : 
    sr_gen = (SeqIO.SeqRecord(seq=Seq.Seq(value), id=key, description='') for key, value in s_dict.items())
    return sr_gen



# do

parser = ArgumentParser()
parser.add_argument("its1", help="path to input ITS1 fasta")
parser.add_argument("fives", help="path to input 5.8S fasta")
parser.add_argument("its2", help="path to input ITS2 fasta")
parser.add_argument("-op", help="output path")

args = parser.parse_args()

with open(args.its1, 'r') as f1, open(args.fives, 'r') as fs, open(args.its2, 'r') as f2 :
    its1 = f1.readlines()
    fives = fs.readlines()
    its2 = f2.readlines()


recs_its, ids_its = coll_seqs([its1, its2])
recs_full, ids_full = coll_seqs([its1, fives, its2])


its_dict = seq_dict(recs_its, ids_its)
its1_dict = {k: v[0] for k, v in its_dict.items() if v}
its2_dict = {k: v[1] for k, v in its_dict.items() if v}

full_dict = seq_dict(recs_full, ids_full, join=True)


its1_it = dict_2_sr(its1_dict)
its2_it = dict_2_sr(its2_dict)
full_it = dict_2_sr(full_dict)

# done




# out

if args.op :
    with open(args.op + 'paired_its1.fa', 'w') as out1 :
        SeqIO.write(its1_it, out1, 'fasta-2line')
    with open(args.op + 'paired_its2.fa', 'w') as out2 :
        SeqIO.write(its2_it, out2, 'fasta-2line')
    with open(args.op + 'all_its.fa', 'w') as out3 :
        SeqIO.write(full_it, out3, 'fasta-2line')
        
else :
    with open('./paired_its1.fa', 'w') as out1 :
        SeqIO.write(its1_it, out1, 'fasta-2line')
    with open('./paired_its2.fa', 'w') as out2 :
        SeqIO.write(its2_it, out2, 'fasta-2line')
    with open('./all_its.fa', 'w') as out3 :
        SeqIO.write(full_it, out3, 'fasta-2line')
        
        
# testing        
# with open('./data/its_out/its.ITS1.fasta') as f:
#     t1 = f.readlines()
# with open('./data/its_out/its.5_8S.fasta') as f:
#     t5 = f.readlines()
# with open('./data/its_out/its.ITS2.fasta') as f:
#     t2 = f.readlines()

# names = [x[0::2] for x in [t1, t5, t2]]
# seqs = [x[1::2] for x in [t1, t5, t2]]
