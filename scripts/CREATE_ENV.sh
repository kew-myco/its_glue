#!/usr/bin/env bash

mkdir ./data/
mkdir ./data/traces
mkdir ./data/tracy_assemble
mkdir ./data/fasta
mkdir ./data/its_out
mkdir ./tracy
mkdir ./ext_dbs
mkdir ./logs
mkdir ./results

wget -O ./tracy/tracy https://github.com/gear-genomics/tracy/releases/download/v0.7.1/tracy_v0.7.1_linux_x86_64bit
chmod +x ./tracy/tracy

conda create -p ./seq_conda -c conda-forge -c bioconda biopython itsx vsearch


