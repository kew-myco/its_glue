# ecto_pipe
###### Pipeline to take fungal ITS sequences from trace files to identified OTUs

## setup

First run CREATE_ENV.sh to set up the environment. You'll probably need to chmod +x the scripts

then run 
```
./scripts/pipe_one.trace_its.sh -t [path/to/traces/directory] -f [fw_tag] -r [rev_tag] -o [path/to/output]
```
-f and -r specify the tags used to identify forward and reverse reads in the filenames. They should be last before the extension and the filenames for fw and reverse reads should otherwise be identical.

Play with the script if you need to change parameters.

pipe_two.cluster_classify.sh contains various commands for classifying and clustering, but it's not yet wrapped up into a command line utility and still needs work.

