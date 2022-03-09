#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar  7 17:25:38 2022

@author: blex
"""

import pandas as pd
import csv

sintax_path = '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/sintax_class.csv'

with open(sintax_path) as f :
    clsif = pd.read_csv(f, sep = '\t', header=None)
    
clsif_l = clsif.values.tolist()    
    
otus = set([x[3] for x in clsif_l])

otu_dict = {}
for otu in otus :
    otu_dict[otu] = [x[0] for x in clsif_l if otu in x]
    


ot = list(zip(otu_dict.keys(), [len(x) for x in otu_dict.values()], otu_dict.values()))
ot_headr = ['tax', 'n_samples', 'sample_codes']
ot.insert(0, ot_headr)
    
ot_path = '/home/blex/Documents/Kew/fungi_research/manuel/seqs.07_03_22/pipe_out/OTU/otu_table-ish_clust.csv'

with open(ot_path, 'w') as f :
    csv_write = csv.writer(f)
    csv_write.writerows(ot)
    