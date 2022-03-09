#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 18 17:09:34 2022

extract SHs and counts from vsearch

@author: blex
"""

import csv
import re
import numpy as np

with open('./results/vsearchres') as f :
    res = [line for line in csv.reader(f, delimiter='\t')]
    
otus = [sl[3] for sl in res]

otus = list(filter(None, otus))

otusclean = [re.sub('\(....\)', '', e) for e in otus]

len(set(otusclean))

values, counts = np.unique(otusclean, return_counts=True)
otu_props = list(zip(values, counts))

with open('./results/aliceholt_0.95_otus.csv', 'w') as o :
    wo = csv.writer(o)
    wo.writerows(otu_props)
