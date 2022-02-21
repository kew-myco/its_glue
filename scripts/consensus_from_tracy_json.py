#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 15 13:18:18 2022
Script with input args
Read consensus sequence from Tracy JSON
Write consensus sequence as fasta
@author: blex
"""

from argparse import ArgumentParser
import json
from Bio import SeqIO
from Bio import Seq

parser = ArgumentParser()
parser.add_argument("JSONin", help="path to input tracy assemble JSON")
parser.add_argument("-od", help="output directory")

args = parser.parse_args()

with open(args.JSONin, 'r') as f:
    tj = json.load(f)
    
name = tj['msa'][0]['traceFileName']
name = '_'.join(name.split('_')[0:4]) + '_con'

rec = SeqIO.SeqRecord(Seq.Seq(tj['gapFreeConsensus']), id = name, description='')

pout = args.od + '/' + name + '.fasta'

with open(pout, 'x') as po :
    SeqIO.write(rec, po, 'fasta-2line')