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
# import logging

parser = ArgumentParser()
parser.add_argument("its1", help="path to input ITS1 fasta")
parser.add_argument("fives", help="path to input 5.8S fasta")
parser.add_argument("its2", help="path to input ITS2 fasta")
parser.add_argument('-n', help="output file name")
parser.add_argument("-od", help="output directory")
args = parser.parse_args()

# logging.basicConfig(filename= args.od + args.n + '.log', encoding='utf-8', level=logging.DEBUG)
# logging.debug('This message should go to the log file')
# logging.info('So should this')
# logging.warning('And this, too')
# logging.error('And non-ASCII stuff, too, like Øresund and Malmö')

with open(args.its1, 'r') as f1, open(args.fives, 'r') as fs, open(args.its2, 'r') as f2 :
    its1 = f1.readlines()
    fives = fs.readlines()
    its2 = f2.readlines()

onefivetwo = []
chk_patterns=['ITS1', '5.8S', 'ITS2']
for ind, reg in enumerate([its1, fives, its2]):
    names = reg[0::2]
    if not all([re.search(chk_patterns[ind], n) for n in names]):
        raise RuntimeError("unexpected ITS region detected (e.g. 'ITS2' where 'ITS1' was expected)")
    seqs = reg[1::2]
    ids = [re.search('>(.+?)\|', n).group(1) for n in names]
    recs = list(zip(ids, seqs))
    onefivetwo.append(recs)

    
all_names=[x[0::2] for x in [its1, fives, its2]]
flat_names=[n for sl in all_names for n in sl]
all_ids=[re.search('>(.+?)\|', n).group(1) for n in flat_names]
set_ids=set(all_ids)

# init empty dict
seq_dict={}
# add seqs to dict values matching by id
for key in all_ids :
    
    # prevent chimera formation
    if any(key in st for st in onefivetwo[0]) and any(key in st for st in onefivetwo[2]):
        if not any(key in st for st in onefivetwo[1]):
            next
    
    partone = [rec[1] for rec in onefivetwo[0] if key in rec]
    partfive = [rec[1] for rec in onefivetwo[1] if key in rec]
    parttwo = [rec[1] for rec in onefivetwo[2] if key in rec]
    if any([True for x in [partone, partfive, parttwo] if len(x) > 1]):
        raise RuntimeError('multiple ITS seqs detected for a single sample code!')
    
    its_parts = partone + partfive + parttwo
    its_full = ''.join(its_parts)
    its_full = its_full.replace('\n', '')
    seq_dict[key] = its_full
    
# filter out empty ids
seq_dict = {k: v for k, v in seq_dict.items() if v}
    
# convert to iterable of seqrecords
sr_gen = (SeqIO.SeqRecord(seq=Seq.Seq(value), id=key, description='') for key, value in seq_dict.items())

if args.od :
    with open(args.od + args.n, 'w') as sout :
        SeqIO.write(sr_gen, sout, 'fasta-2line')
else :
    with open('./' + args.n, 'w') as sout :
        SeqIO.write(sr_gen, sout, 'fasta-2line')
        
        
# testing        
# with open('/home/blex/Documents/Kew/fungi_research/sietse_era_seqs/pipeline_testing/pine/its/consensus.ITS1.fasta') as f:
#     its1 = f.readlines()
# with open('/home/blex/Documents/Kew/fungi_research/sietse_era_seqs/pipeline_testing/pine/its/consensus.5_8S.fasta') as f:
#     fives = f.readlines()
# with open('/home/blex/Documents/Kew/fungi_research/sietse_era_seqs/pipeline_testing/pine/its/consensus.ITS2.fasta') as f:
#     its2 = f.readlines()
