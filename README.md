# its_glue
###### Pipeline to take trace files of fungal ITS sequences to identified & denovo OTUs

## Raison D'etre

`its_glue` is a pipeline to batch process pairs of forward and reverse chromatagrams produced via Sanger sequencing. It wraps powerful tools for working into a simple workflow, and outputs collated, organised results. The pipeline covers basecalling, assembly of forward and reverse reads, ITS extraction, and OTU picking.

## Requirements

-  **A Unix environment** (e.g. Windows Subsytem for Linux if you're on Windows)  
-  **Conda** - I recommend miniconda
 
Since this project is very much in development I also recommend cloning the repository with **git** and regularly using `git pull` so you can keep up with updates.

## Setup

Clone (or download) the repository, and in the top level of the created directory run `./scripts/CREATE_ENV.sh` to set up the Conda environment. You'll probably need to chmod +x the scripts first - `chmod +x ./scripts/CREATE_ENV.sh`

`CREATE_ENV.sh` will have Conda install all the necessary dependencies for you in a self contained environment. This does mean that you have to run all the scripts from within the ecto_pipe directory, but for now it seems the easiest way to ensure everyone is able to run things without having to worry about dependencies.  

## Usage
   

**Trace to ITS**:   `pipe_one.trace_its.sh`

The first section of the pipeline consists of basecalling the input trace files using **Tracy**, extracting consensus sequences where possible, chimera detection and finally extraction of ITS regions using **ITSx**. Consensus sequences are preferred but where necessary **ITSx** will extract from single direction strands.

This functionality is all wrapped into a single script:

```
./scripts/pipe_one.trace_its.sh -t [path/to/traces/directory] \
-f [fw_tag] \
-r [rev_tag] \
-o [path/to/output] \
-x
```
The script expects pairs of forward and reverse traces as .ab1 or .scf, all in one folder (i.e. not in subfolders). It will attempt the process on every trace file it finds in the input directory.

-f and -r specify the tags used to identify forward and reverse reads in the filenames. They should be last before the extension and the filenames for fw and reverse reads should otherwise be identical. The -x flag indicates that you want to overwrite any previous runs of the pipeline to the specified output path.

Play with the script if you need to change parameters, but you shouldn't need to (unless you're trying to ID something other than fungi)

**ITS to OTUs/Identifcations**:   `pipe_two.cluster_classify.sh`

`pipe_two.cluster_classify.sh` contains a workflow of commands for first classifying sequences against a reference database using **sintax** via **vsearch**, and then, if desired, clustering unmatched sequences into denovo OTUs. This process is both tricky and contentious, so for now the functionality is not wrapped up into a single command and is instead left open for the end user to implement how they see fit. More development to come.

## Issues, Comments and Suggestions

If you have issues with the pipeline please post them to the **Issues** tab of this GitHub repository. Please note that this is only for issues installing the pipeline itself or running it, not installing the dependencies. I'd love to have time to help people install dependencies etc. but I unfortunately don't.

If you have queries, comments, suggestions or questions about the pipeline please submit them to the **Discussions** tab. Hopefully this way we can build up something of a community FAQ.

## Citing / Crediting

I haven't really figured this bit out yet, but if you use this pipeline, or data produced from this pipeline, please credit me in some way - I suppose either through authorship (if appropriate) or citing (for now) this page.

