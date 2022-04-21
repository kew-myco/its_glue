#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  9 15:03:12 2022

@author: blex
"""

import re
import csv
import pandas as pd
from Bio import SeqIO
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("sintax_class", help="path to input sintax classifications")
parser.add_argument("input_fasta", help="path to fasta used to generate sintax classifications")
parser.add_argument("od", help="output directory")

args = parser.parse_args()

with open(args.sintax_class) as sc, open(args.input_fasta) as sf:
    clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))
    sq = [x for x in SeqIO.parse(sf, 'fasta-2line')]
    
clsif_l = clsif.values.tolist()

clif_s = [[str(x) for x in row] for row in clsif_l]

sh = [row for row in clif_s if re.search('SH[0-9]', row[3])] # samples which match to SH
no_sh = [row[0] for row in clif_s if not re.search('SH[0-9]', row[3])] # samples which don't match to SH

no_sh_sq = [s for s in sq if s.id in no_sh]

# write output

with open(args.od + '/nomatch.fa', 'w') as o :
    SeqIO.write(no_sh_sq, o, 'fasta-2line')

with open(args.od + '/sh_sintax_classifications.tsv', 'w') as o2 :
    writer = csv.writer(o2, delimiter='\t')
    for match in sh:
        writer.writerow(match)
    
# test code

# with open('/home/blex/Documents/Kew/fungi_research/george/classifier_output/6_512.1/its_sintax_class.tsv') as sc:
#     clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))

# with open('/home/blex/Documents/Kew/fungi_research/george/trace_processing/6_512.1/its/cat_its.fa') as sf:
#     sq = [x for x in SeqIO.parse(sf, 'fasta-2line')]

# SeqIO.write(no_sh_sq, '/home/blex/Documents/Kew/fungi_research/george/classifier_output/6_512.1/no_match.fasta', 'fasta-2line')
