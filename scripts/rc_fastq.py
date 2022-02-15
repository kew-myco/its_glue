#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb  4 12:54:20 2022

@author: blex
"""
    
from argparse import ArgumentParser
from Bio import SeqIO

parser = ArgumentParser()
parser.add_argument("fqin", help="input fastqs", nargs = "+")
parser.add_argument("-od", help="output directory")

args = parser.parse_args()

fqs = [SeqIO.read(x, "fastq") for x in args.fqin]
for fq in fqs :
    rc = fq.reverse_complement()
    rc.description = ''
    rc.id = fq.id + '_rc'
    
    if args.od :
        rc.name = args.od + fq.name.split('.')[0] + '_rc.fastq' 
    else :
        rc.name = fq.name.split('.')[0] + '_rc.fastq' 
        
    SeqIO.write(rc, rc.name, 'fastq')
