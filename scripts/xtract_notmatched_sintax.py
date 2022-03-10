#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  9 15:03:12 2022

@author: blex
"""

from argparse import ArgumentParser
import re
import pandas as pd
import csv
from Bio import SeqIO
from Bio import Seq

parser = ArgumentParser()
parser.add_argument("sintax_class", help="path to input sintax classifications")
parser.add_argument("input_fasta" help="path to fasta used to generate sintax classifications")
parser.add_argument("op", help="output path")

args = parser.parse_args()

with open(args.sintax_class) as sc, open(args.input_fasta) as f:
    clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))
    sq = f.readlines()
    
clsif_l = clsif.values.tolist()

clif_s = [[str(x) for x in row] for row in clsif_l]

nosh = [row[0] for row in clif_s if not re.search('SH[0-9]', row[3])] # samples which don't match to SH



with open(args.op, 'w') as o :
    [o.write(x + '\n') for x in nosh]
