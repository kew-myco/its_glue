# ecto_pipe
###### Pipeline to take fungal ITS sequences from trace files to identified OTUs

##Requirements

-  **A Unix environment** (e.g. Windows Subsytem for Linux if you're on Windows)  
-  **Conda** - I personally recommend miniconda
 
Since this project is very much in development I also recommend cloning the repository with **git** and regularly using `git pull` so you can keep up with updates.

## Setup

Clone (or download) the repository, and in the top level of the created directory run `./CREATE_ENV.sh` to set up the Conda environment. You'll probably need to chmod +x the scripts first - `chmod +x ./CREATE_ENV.sh`

CREATE_ENV.sh will have Conda install all the necessary dependencies for you in a self contained environment. This does mean that you have to run all the scripts from within the ecto_pipe directory, but for now it seems the easiest way to ensure everyone is able to run things without having to worry about dependencies.  

## Usage
   

**Trace to ITS**:  

The first section of the pipeline consists of basecalling the input trace files using **Tracy**, extracting consensus sequences where possible, chimera detection and finally extraction of ITS regions using **ITSx**. Consensus sequences are preferred but where necessary **ITSx** will extract from single direction strands.

This functionality is all wrapped into a single script:

```
./scripts/pipe_one.trace_its.sh -t [path/to/traces/directory] -f [fw_tag] -r [rev_tag] -o [path/to/output]
```
-f and -r specify the tags used to identify forward and reverse reads in the filenames. They should be last before the extension and the filenames for fw and reverse reads should otherwise be identical.

Play with the script if you need to change parameters.

pipe_two.cluster_classify.sh contains various commands for classifying and clustering, but it's not yet wrapped up into a command line utility and still needs work.

