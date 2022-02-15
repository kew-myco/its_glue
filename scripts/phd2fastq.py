#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 27 11:00:15 2022

@author: blex

This is a script to convert phd.1 files output from phred to fastqs with both sequence and quality data.
It also names seqs appropriately
"""

from argparse import ArgumentParser
from Bio import SeqIO

parser = ArgumentParser()
parser.add_argument("phdin", help="input phd.1", nargs = "+")
parser.add_argument("-od", help="output directory")

args = parser.parse_args()

phds = [SeqIO.read(x, "phd") for x in args.phdin]
for pd in phds:
    pd.description = ''
    pd.id = pd.id.split('.')[0]

    if args.od :
        pd.name = args.od + pd.name.split('.')[0] + '.fastq' 
    else :
        pd.name = pd.name.split('.')[0] + '.fastq' 
    
    SeqIO.write(pd, pd.name, 'fastq') # 'fastq-illumina' for illumina quality encoding
