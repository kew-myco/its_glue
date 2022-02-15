#!/usr/bin/env bash

### call bases from ABI 3730 traces
# arg 1 is input directory, arg 2 is output

PHRED_PARAMETER_FILE=/usr/local/etc/PhredPar/phredpar.dat
export PHRED_PARAMETER_FILE

phred -id $1 -pd $2
# this alternate formation trims ends but perhaps better to ITS extract then trim
