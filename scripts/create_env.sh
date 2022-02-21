#!/usr/bin/env bash

mkdir ./data/
mkdir ./data/traces
mkdir ./data/tracy_assemble
mkdir ./data/fasta
mkdir ./data/itsx_out
mkdir ./tracy
mkdir ./ext_dbs

wget https://github.com/gear-genomics/tracy/releases/download/v0.6.1/tracy_v0.6.1_linux_x86_64bit
mv tracy_v0.6.1_linux_x86_64bit ./tracy/tracy
chmod +x ./tracy/tracy

conda create -p ./seq_conda
conda activate ./seq_conda
conda install -c bioconda itsx
conda install -c bioconda vsearch


