#!/usr/bin/env bash

mkdir ./tracy
wget -O ./tracy/tracy https://github.com/gear-genomics/tracy/releases/download/v0.7.1/tracy_v0.7.1_linux_x86_64bit
chmod +x ./tracy/tracy

conda create -p ./seq_conda -c conda-forge -c bioconda biopython itsx vsearch


