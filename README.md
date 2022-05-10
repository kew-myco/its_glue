# its_glue
###### Pipeline to take trace files of fungal ITS sequences to identified & denovo OTUs

## Summary

`its_glue` is a pipeline to batch process pairs of forward and reverse chromatagrams produced via Sanger sequencing. It wraps powerful tools into a simple workflow, and outputs collated, organised results. The pipeline covers basecalling, assembly of forward and reverse reads, ITS extraction, quality control, and OTU picking.

## Requirements

-  **A Unix environment** (via Windows Subsytem for Linux if you're on Windows) - I recommend Ubuntu
-  **Bash** - The main language the pipeline is written in. Almost all Unix enivironments come with bash so you probably don't need to worry about this, unless you already know that you do. Compatible with Bash 3 and greater.
-  **Conda** - A package manganement/development environment system. It allows setting up and installing other dependencies isolated from the rest of your computer with minimal hassle. I recommend miniconda.
-  **Git** (Optional) - if you want to keep up with updates and bugfixes (depending how actively I am developing), you can use git to create a copy of the pipeline on your local machine which is linked to this repository.
 
Check the [project wiki](https://github.com/kew-myco/its_glue/wiki) for install guides for Mac and Windows, including installation of these requirements.

## Setup

Since this project is very much in development (as of April 2022), I recommend cloning the repository with **git** and regularly using `git pull` so you can keep up with updates.

Once you have all the reqiurements set up, clone the repository into your Unix enivronment using git - `git clone https://github.com/kew-myco/its_glue.git`. You can also download the repository if you don't want to use git. 

In the top level of the created directory run `./scripts/CREATE_ENV.sh` to set up the Conda environment. You'll probably need to chmod +x the scripts first - e.g. `chmod +x ./scripts/CREATE_ENV.sh`, or you'll get `permission denied` errors.

`CREATE_ENV.sh` will have Conda install all the necessary dependencies for you in a self contained Conda environment. It seems the easiest way to ensure everyone is able to run things without having to worry about installing the specific tools the pipeline relies on. This does mean that you have to run all the scripts from within the top-level pipeline directory.

## Usage
   
All scripts must be run from inside the [top-level directory](https://github.com/kew-myco/its_glue/wiki/Glossary-of-Terms) of the pipeline.

**Trace to ITS**:

The first section of the pipeline handles basecalling the input trace files using [**Tracy**](https://github.com/gear-genomics/tracy), extracting consensus sequences where possible, chimera detection and finally extraction of ITS regions using [**ITSx**](https://microbiology.se/software/itsx/). Consensus sequences are preferred but where necessary **ITSx** will extract from single direction strands.

This functionality is all wrapped into a single script:

```
./pipe_one.trace_its.sh -t path/to/traces/directory \
-f fw_tag \
-r rev_tag \
-o path/to/output
```
The script expects pairs of forward and reverse traces as .ab1 or .scf, all in one folder (i.e. not in subfolders). It will attempt the process on every trace file it finds in the input directory. The path to this directory is specified by the `-t` flag.

`-f` and `-r` specify the tags used to identify forward and reverse reads in the filenames. They should be last before the extension and the filenames for fw and reverse reads should otherwise be identical. They cannot be `-f` or `-r` - those are reserved for the flags!

Specify an output directory with the optional `-o` flag - if not specified it will default to the current location, which you probably don't want

If you want to overwrite previous output (i.e. you are sending output to the same path as a previous run), use the optional `-x` flag.

Play with the script if you need to change parameters, but you shouldn't need to (unless you're trying to ID something other than fungi)  

**ITS to OTUs/Identifications**:

The second section of the pipeline handles OTU picking. It first clusters sequences into OTUs at 97% similarity, using the single linkage clustering algorithm provided by [**vsearch**](https://github.com/torognes/vsearch). It then uses [**sintax**](https://drive5.com/sintax/), again implemented in **vsearch**, to assign taxonomy (as best it can) to each OTU using a [reference database](https://github.com/kew-myco/its_glue/wiki/Glossary-of-Terms). I am personally dubious of *all* presently available methods of taxonomic assignment (e.g. see [here](https://peerj.com/articles/3889/) and [here](https://peerj.com/articles/4652/)), for a discussion of this implemenation see the wiki (**TODO**).

The functionality is wrapped into a single script:

```
./pipe_two.cluster_classify.sh -d path/to/reference/database \
-f path/to/input/fasta \
-o path/to/output
```
The script expects, as arguments, a reference database, specified by the `-d` flag, an input fasta, specified by the `-f` flag, and an output directory, specified by the `-o` flag. If you are using the first stage of the pipeline, the input fasta will be in the `its` directory of the output, and named `ALL_ITS.fa`.

## Outputs

Please see the [project wiki](https://github.com/kew-myco/its_glue/wiki) for a [guide to output](https://github.com/kew-myco/its_glue/wiki/Guide-to-Output) for each pipeline stage (**part-complete**)

## Issues, Comments and Suggestions

If you have issues with the pipeline please post them to the **Issues** tab of this GitHub repository. Please note that this is only for issues installing the pipeline itself or running it, not installing the dependencies. I'd love to have time to help people install dependencies etc. but I unfortunately don't - and they have their own GitHub repositories where you may ask questions.

If you have queries, comments, suggestions or questions about the pipeline please submit them to the **Discussions** tab. Hopefully this way we can build up something of a community FAQ.

## Citing / Crediting

I haven't really figured this bit out yet, but if you use this pipeline, or data produced from this pipeline, please credit me in some way - I suppose either through authorship (if appropriate) or citing (for now) this page. You should also be citing the appropriate publications for **Tracy**, **ITSx**, **vsearch** and **sintax**.

