#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  9 15:03:12 2022

@author: blex
"""

import csv
import pandas as pd
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("sintax_class", help="path to input sintax classifications")
parser.add_argument("od", help="output directory")

args = parser.parse_args()

with open(args.sintax_class) as sc:
    clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))
    
clsif_l = clsif.values.tolist()

clif_s = [[str(x) for x in row] for row in clsif_l]

idd = [row for row in clif_s if row[3]] # samples with some id

with open(args.od + '/noblanks_sintax_classifications.tsv', 'w') as o2 :
    writer = csv.writer(o2, delimiter='\t')
    for match in idd:
        writer.writerow(match)
    
# test code

# with open('/home/blex/Documents/Kew/fungi_research/george/classifier_output/6_512.1/its_sintax_class.tsv') as sc:
#     clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))

# with open('/home/blex/Documents/Kew/fungi_research/george/trace_processing/6_512.1/its/cat_its.fa') as sf:
#     sq = [x for x in SeqIO.parse(sf, 'fasta-2line')]

# SeqIO.write(no_sh_sq, '/home/blex/Documents/Kew/fungi_research/george/classifier_output/6_512.1/no_match.fasta', 'fasta-2line')
