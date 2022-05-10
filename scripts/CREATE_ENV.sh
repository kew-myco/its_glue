#!/usr/bin/env bash
#                                                                         #
#               .__  __                   .__                             #
#               |__|/  |_  ______    ____ |  |  __ __   ____              #
#               |  \   __\/  ___/   / ___\|  | |  |  \_/ __ \             #
#               |  ||  |  \___ \   / /_/  >  |_|  |  /\  ___/             #
#               |__||__| /____  >  \___  /|____/____/  \___  >            #
##                            \/  /_____/                  \/            ##
###                                                                     ###  
####         Author : Alex Byrne                                       ####    
####         Contact : ablex7@gmail.com                                ####
####                                                                   ####
####         See its_glue github for usage details.                    ####
####                                                                   ####
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## set up tracy (tracy doc https://www.gear-genomics.com/docs/tracy/installation/#installation-for-mac-osx, with modifications)

brew install \
     cmake \
     zlib \
     readline \
     xz \
     bzip2 \
     gsl \
     libtool \
     pkg-config \
     htslib \
     autoconf@2.69
     
brew install boost # this might fail but as I recall the error message was informative

brew link autoconf@2.69

git clone --recursive https://github.com/gear-genomics/tracy.git
cd tracy
make all

conda create -p ./seq_conda -c conda-forge -c bioconda biopython itsx vsearch pandas


