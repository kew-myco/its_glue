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

parser = ArgumentParser()
parser.add_argument("sintax_class", help="path to input sintax classifications")
parser.add_argument("op", help="output path")

args = parser.parse_args()

with open(args.sintax_class) as f :
    clsif = pd.read_csv(f, sep = '\t', header=None, names=list('abcde'))
    
clsif_l = clsif.values.tolist()

clif_s = [[str(x) for x in row] for row in clsif_l]

nosh = [row[0] for row in clif_s if not re.search('SH[0-9]', row[3])] # samples which don't match to SH

with open(args.op, 'w') as o :
    [o.write(x + '\n') for x in nosh]
