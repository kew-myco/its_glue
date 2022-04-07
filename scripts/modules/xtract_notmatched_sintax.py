#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  9 15:03:12 2022

@author: blex
"""

from argparse import ArgumentParser
import re
import pandas as pd
from Bio import SeqIO

parser = ArgumentParser()
parser.add_argument("sintax_class", help="path to input sintax classifications")
parser.add_argument("input_fasta", help="path to fasta used to generate sintax classifications")
parser.add_argument("op", help="output path")

args = parser.parse_args()

with open(args.sintax_class) as sc, open(args.input_fasta) as sf:
    clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))
    sq = [x for x in SeqIO.parse(sf, 'fasta-2line')]
    
clsif_l = clsif.values.tolist()

clif_s = [[str(x) for x in row] for row in clsif_l]

no_sh = [row[0] for row in clif_s if not re.search('SH[0-9]', row[3])] # samples which don't match to SH

no_sh_sq = [s for s in sq if s.id in no_sh]

# write output

with open(args.op, 'w') as o :
    SeqIO.write(no_sh_sq, o, 'fasta-2line')
    

    
    
# test code

# with open('/home/blex/Documents/Kew/fungi_research/george/classifier_output/6_512.1/its_sintax_class.tsv') as sc:
#     clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))

# with open('/home/blex/Documents/Kew/fungi_research/george/trace_processing/6_512.1/its/cat_its.fa') as sf:
#     sq = [x for x in SeqIO.parse(sf, 'fasta-2line')]

# SeqIO.write(no_sh_sq, '/home/blex/Documents/Kew/fungi_research/george/classifier_output/6_512.1/no_match.fasta', 'fasta-2line')