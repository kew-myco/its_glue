#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 22 12:52:08 2022

@author: blex
"""

import pandas as pd
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("sintax_class", help="path to input sintax classifications")
parser.add_argument("cluster_membership", help="path to cluster membership table")
parser.add_argument("op", help="output path")

args = parser.parse_args()

with open(args.sintax_class) as sc, open(args.cluster_membership) as cm:
    clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))
    cmem = pd.read_csv(cm, sep = '\t', index_col=0)

clsif = clsif.values.tolist()
clsif = [[str(x) for x in row] for row in clsif]

best_ids = []
for row_index in range(cmem.shape[0]):
    members = cmem.iloc[row_index,:].loc[lambda x: x == 1].index.values.tolist()
    ids_list  = []
    ids_len = []
    for member in members:
        mem_id = [cl[3] for cl in clsif if member in cl]
        ids_list.append(mem_id[0])
        ids_len.append(len(mem_id[0].split(',')))
        
    best_ids.append(ids_list[ids_len.index(max(ids_len))])
    
rename_clust = []
for ind, tax in enumerate(best_ids):
    if tax != 'nan':
        rename_clust.append('{}|{}'.format(cmem.index.values.tolist()[ind], tax))
    else:
        rename_clust.append('{}|d:Fungi(ITSx)'.format(cmem.index.values.tolist()[ind]))
        
cmem.set_index(pd.Series(rename_clust), inplace = True)

with open(args.op, 'w') as o:
    cmem.to_csv(o)

# merge duplicated SHs into single clusters!
# filter dataframe of cluster membership by SH, and sum for duplicated SHs (i.e. more than one row)
        



# testing data

# with open('/home/blex/Documents/Kew/fungi_research/genetics/seq_pipeline/bugfix/out_21.04.22/otu/sintax_classifications.tsv') as sc:
#     clsif = pd.read_csv(sc, sep = '\t', header=None, names=list('abcde'))
    
# with open('/home/blex/Documents/Kew/fungi_research/genetics/seq_pipeline/bugfix/out_21.04.22/otu/cluster_membership.tsv') as cm:
#    cmem = pd.read_csv(cm, sep = '\t', index_col=0)
