#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 22 12:52:08 2022

@author: blex
"""

from __future__ import annotations
import sys
import pandas as pd
from functools import partial
from argparse import ArgumentParser

# handle input
def handle_read(input_path, namestring: str, read_func) -> pd.DataFrame:
    try:
        with open(input_path) as i:
            f = read_func(i)
    except Exception as e:
        print(e)
        sys.exit("Could not read {} from file!".format(namestring))
    if any(f.shape) == 0:
        sys.exit("{} empty!".format(namestring))
    return(f)


# get deepest classification of cluster
def best_id(cluster_members: list[str], classifications: list[str]) -> list[str]:
    ids_list = []
    for member in cluster_members:
        try:
            mem_id = [cl[3] for cl in classifications if member in cl][0]
        except IndexError:
            print("cannot find cluster member {} in classifications, skipping".format(member))
            mem_id = 'nan'
        ids_list.append(mem_id)
    return(max(ids_list, key=lambda x: len(x.split(','))))


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("sintax_class", help="path to input sintax classifications")
    parser.add_argument("cluster_membership", help="path to cluster membership table")
    parser.add_argument("op", help="output path")
    args = parser.parse_args()

    # handle input
    clsif_read = partial(pd.read_csv, sep='\t', header=None, names=list('abcde'))
    clsif = handle_read(args.sintax_class, namestring='classifications', read_func=clsif_read)
    cluster_read = partial(pd.read_csv, sep='\t', index_col=0)
    clusters = handle_read(args.cluster_membership, namestring='classifications', read_func=cluster_read)

    # format classifications
    try:
        clsif: list = clsif.values.tolist()  # I clearly don't like pandas
        clsif: list[str] = [[str(x) for x in row] for row in clsif]  # convert to string
    except (TypeError, ValueError) as e:
        print(e)
        sys.exit("Error formatting input classification file")

    # get best ids for each cluster
    best_ids: list = []
    for row_index in range(clusters.shape[0]):
        single_cluster: list = clusters.iloc[row_index, :].loc[lambda x: x == 1].index.values.tolist()  # Sample IDs for one cluster (row)
        best_ids.append(best_id(cluster_members=single_cluster, classifications=clsif))

    # make annotated cluster names
    annotated_names: list = []
    for ind, tax in enumerate(best_ids):
        if tax == 'nan':
            annotated_names.append('{}|d:Fungi(ITSx)'.format(clusters.index.values.tolist()[ind]))
        else:
            annotated_names.append('{}|{}'.format(clusters.index.values.tolist()[ind], tax))

     # annotate clusters
    clusters.set_index(pd.Series(annotated_names), inplace=True)

    # write out
    try:
        with open(args.op, 'w') as o:
            clusters.to_csv(o)
    except Exception as e:
        print(e)
        sys.exit("Error writing annotated clusters to file")


# testing data
# clsif_read = partial(pd.read_csv, sep='\t', header=None, names=list('abcde'))
# clsif = handle_read('sintax_classifications.tsv', namestring='classifications', read_func=clsif_read)
# cluster_read = partial(pd.read_csv, sep='\t', index_col=0)
# clusters = pd.read_csv('cluster_membership.tsv', sep='\t', index_col=0)
