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

parser = ArgumentParser()
parser.add_argument("its1", help="path to input ITS1 fasta")
parser.add_argument("fives", help="path to input 5.8S fasta")
parser.add_argument("its2", help="path to input ITS2 fasta")
parser.add_argument('--name', help="output file name")
parser.add_argument("-op", help="output path")

args = parser.parse_args()

with open(args.its1, 'r') as f1, open(args.fives, 'r') as fs, open(args.its2, 'r') as f2 :
    its1 = f1.readlines()
    fives = fs.readlines()
    its2 = f2.readlines()
    
names = [x[0::2] for x in [its1, fives, its2]]
seqs = [x[1::2] for x in [its1, fives, its2]]

#flatten
flat_names = [n for sl in names for n in sl]
flat_seqs = [n for sl in seqs for n in sl]

# extract sample ids
ids = [re.search('>(.+?)\|', n).group(1) for n in flat_names]

# merge ids and seqs
recs = list(zip(ids, flat_seqs))

# init empty dict
seq_dict={}
# add seqs to dict values matching by id
for key in set(ids) :
    its_parts = [rec[1] for rec in recs if key in rec]
    its_full = ''.join(its_parts)
    its_full = its_full.replace('\n', '')
    seq_dict[key] = its_full
    
# filter out empty ids
seq_dict = {k: v for k, v in seq_dict.items() if v}
    
# convert to iterable of seqrecords
sr_gen = (SeqIO.SeqRecord(seq=Seq.Seq(value), id=key, description='') for key, value in seq_dict.items())

if args.op :
    with open(args.op, 'w') as sout :
        SeqIO.write(sr_gen, sout, 'fasta-2line')
else :
    with open('./cat_its.fasta', 'w') as sout :
        SeqIO.write(sr_gen, sout, 'fasta-2line')
        
        
# testing        
# with open('./data/its_out/its.ITS1.fasta') as f:
#     t1 = f.readlines()
# with open('./data/its_out/its.5_8S.fasta') as f:
#     t5 = f.readlines()
# with open('./data/its_out/its.ITS2.fasta') as f:
#     t2 = f.readlines()

# names = [x[0::2] for x in [t1, t5, t2]]
# seqs = [x[1::2] for x in [t1, t5, t2]]
