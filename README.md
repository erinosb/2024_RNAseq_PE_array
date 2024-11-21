# 2024_RNAseq_PE_array
DSCI512: 2024: Course pipeline with quality control, alignment, tabulation, and format conversion for paired-end, short read RNA-seq projects. New this year - run in ARRAY format

-----


*DSCI512 - RNA sequencing data analysis - course scripts*

*A simple set of wrappers and tools for RNA-seq analysis. These tools were designed for the DSCI512 RNA-seq analysis class at Colorado State University*

Below is a tutorial on the use of these scripts:

----

## TUESDAY - NOV 19 - just read, don't do anything! We will do this on Thursday!

## Let's download the script templates I've written on github.

We will build on these scripts each class session.
You will be able to tailor these templates to your own purposes for future use and for the final project.


**Exercise**

  * Locate the green **code** button on the top right of this page. Click it.
  * Click on the clipboard icon. This will save a github URL address to your clipboard.
  * Switch over to JupyterHub linked to ALPINE.
  * Navigate into your directory for `PROJ01_GomezOrte/02_scripts` and use `git clone` as shown below to pull the information from github to your location on ALPINE.
  
```bash
$ cd /scratch/alpine/<eID>@colostate.edu    #Replace <eID> with your EID
$ cd PROJ01_GomezOrte
$ cd 02_scripts
$ git clone <paste path to github repository here>
```

**Explore what you obtained.**

Notice that instead of having a single script, you now have a few scripts. 

You have an **execute** script. This script will act in a **two step** method. The `execute` script executes either the `analyze` shell script or the `cleanup` shell script. 

There is a fourth script called **merge_counts_files.sh** that can be run as a standalone script later. 

Let's copy all four scripts into the parent directory. This will create duplicate copies for you to customize and use while retaining a backup copy in this subdirectory.

```bash
$ cd 2024_RNAseq_PE_array
$ cp execute_RNAseq_pipeline.sbatch ..
$ cp *.sh ..
$ cd ..
```

----
## Let's explore the RNAseqAnalyzer Script 


The **analyze_RNAseq_241117.sh** script contains our pipeline. 

Let's briefly peek into it and see what it contains. 
  * Open **analyze_RNAseq_241117.sh** in an editor window. You'll notice the following sections.

**The pipeline**
  * A shebang
  * A long comment section with documentation on its use
  * MODIFY THIS SECTION - *you will tailor this section to each job*
  * BEGIN CODE - *the code starts and reports how it is running*
  * METADATA - *this part pulls information out of the metadata file to create bash arrays*
  * PIPELINE - *right now this contains a loop that will execute fastp (preprocessing), a loop to execute hisat2 (alignment), a single line of code for featureCounts, and a number of file format conversion steps.*
  * VERSIONS - *this prints out the versions of software used for your future methods section*

The way each script in this directory works, you as the user will modify the MODIFY THIS SECTION part of the script to customize the code. Then, you will run the code either using the execute script or just by calling it on the command line. 

```bash
# Usage for the analyzer script
$ bash analyze_RNAseq_241117.sh <ntasks> <file_1.fastq> <file_2.fastq> <nickname>
```

Now, we could just run this on the command line, but that would be an issue for a few different reasons. #1 - it wouldn't request resources using SLURM. #2 - it would only run one sample. and #3 - it would require we type out every sample long-hand, something we  would like to use our metadata file to automate.

Instead, we can run this script over all our samples, we will use an **execute** script. This is a mini sbatch script that will cycle over the metadata file and run each sample using SLURM!!! Yay!

----
## Let's explore the Execute script 

The **execute_RNAseq_pipeline.sbatch** script will be used to cycle over the metadata file and submit row as input for the **analyze** script. It will also take advantage of the **job batch manager** called **SLURM**. This will put your analyze script runs in the queue and specify how it should be run on the supercomputer system.

For more background on SLURM:
  * [JOB SUBMISSIONS ON ALPINE](https://curc.readthedocs.io/en/latest/running-jobs/batch-jobs.html)
  * [SLURM ON ALPINE - FAQ](https://curc.readthedocs.io/en/latest/faq.html)
  * [SLURM DOCUMENTATION](https://slurm.schedmd.com/sbatch.html)

To execute the bash script in array form, we will use the following command in which you'll substitute 'n' with n being one less the number of samples you have.
```bash
$ sbatch --array=0-n execute_RNAseq_pipeline.sbatch
```

By doing this, the **execute** script will submit the whole job to **SLURM**. What is SLURM? SLURM is a job scheduling system for large and small Linux clusters. It puts your job into a 'queue'. When the requested resources are available, your job will begin. SLURM is organized so that different users have different levels of priority in the queue. On ALPINE, users who use fewer resources have higher priority. Power users have less priority and are encouraged to purchase greater access to the system if it is a problem.

Let's open **execute_RNAseq_pipeline.sbatch** in an editor window and explore how it works. 

```bash
#!/usr/bin/env bash

#SBATCH --job-name=RNAseq_pipeline 
#SBATCH --nodes=1                          # this script is designed to run on one node
#SBATCH --ntasks=2                         # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --time=00:15:00                    # modify this number to reflect how much time to request
#SBATCH --partition=amilan                 # modify this to reflect which queue you want to use.
#SBATCH --mail-type=END                    # Keep these two lines of code if you want an e-mail sent to you when it is complete.
#SBATCH --mail-user=<youremailhere@colostate.edu>            # add your e-mail here
#SBATCH --output=log-RNAseqpipe-%j.out     # this will capture all output in a logfile with %j as the job #

######### INSTRUCTIONS ###########

# Modify your SLURM entries above to fit your choices

# Modify the MODIFY THIS SECTION part to point to YOUR metadata.file
#   Note: metadata files must be in the form: 
#         1st column -- first paired-end fastq file for your sample
#         2nd column -- second paired-end fastq file for your sample
#         3rd column -- a nice short, sortable nickname for your sample

# Pick whether you want to run the script analyze_RNAseq_241117.sh to analyze your RNA-seq data or
#   whether you want to run cleanup_RNAseq_241117.sh to cleanup your project afterwards.
#   Suggestion is to run the analyze script first and the cleanup script second

# Execute this script using $ sbatch --array=0-17 execute_RNAseq_pipeline.sbatch 
#   where n = one minus the number of paired-end samples to process. 


##############################
#      MODIFY THIS SECTION   #
##############################
metadata=../01_input/metadata_gomezOrte.txt

... and so on and so forth

```

  * The way you will use this script is by modifying the SLURM prepended commands to fit how you want the job to run.  You will add in your <metadatafile> information. Mine will be ../01_input/metadata_GomezOrte.txt
  * Then, you pick which bash line of code you want to run (analyze or cleanup)
  * Then, you will execute the script


----
## Instructions - How to Modify & Run this Pipeline
 
Let's try this out. Follow along to test the scripts. Here's the plan...
 
1. Ensure you have some fastq files in your 01_input folder
2. Create a metadata file
3. Gather the genome files you'll need
   - Download your genome (.fasta files)
   - Build an index out of your genome (.ht2 files)
   - Download (or obtain) an annotation file (.gtf or .gff)
4. Modify the **execute** script
5. Modify the **analyzer** script. Point it to the genome, index, .gtf, input folder, and .fastq files
6. Run the script
7. Merge the counts files
8. Clean up the project
 
----
 

### 1. Ensure you have some fastq files in your 01_input folder

Let's make sure you have .fastq files. These are files we made last time by subsetting the larger files. For more instructions on this process --> [Data Acquisition](https://rna.colostate.edu/2024/doku.php?id=wiki:dataacquisition)
 
```bash
# Navigate to the input directory (using cd ../01_input)
$ pwd
~/01_input

$ ls
```
 
 
### 2. Create a metadata file
 
Within your 01_input directory, make sure you have a metadata file. For more instructions on this process --> [Automation I](https://rna.colostate.edu/2024/doku.php?id=wiki:automation)
 
### 3. Gather the genome files you'll need

   - Download your genome (.fasta files)
   - Build an index out of your genome (.ht2 files)
   - Download (or obtain) an annotation file (.gtf or .gff)

We'll work through these steps in the next section --> [Building Indexes](https://rna.colostate.edu/2024/doku.php?id=wiki:hisat2build)

### 4. Modify the **execute** script

  - Great! 
  - Next, we'll navigate over to our scripts directory.
  - Navigate to the scripts directory in the terminal.
  - Navigate to the scripts directory in your file structure navigation panel.
  - Open the **execute_RNAseq_pipeline.sbatch** script in a text editor window.
  - Add your e-mail if you'd like to receive e-mail updates when your job completes
  - Most importantly, replace <metadatafile> with a path to your metadata file. 
  - Mine looks like:

```bash
metadata=../01_input/metadata_gomezOrte.txt
```

  - Ensure you have the analyzer script set to run and the cleanup script off. You should see a pound sign in front of the cleanup script line. 
 
### 5. Modify the **analyzer** script

  - Awesome!
  - Next, we'll modify the script **analyze_RNAseq_241117.sh**
  - Open the **analyze_RNAseq_241117.sh** in a text editor window.
  - NOTE! Most of the paths you need, we have already prepared. they are in a file called **paths.txt** in your **PROJ02_ce11IndexBuild** folder. Open that and copy and paste them in.
  - Within the MODIFY THIS SECTION part of the code, replace <yourinputdir> with a path to your input directory. 
  - Within the MODIFY THIS SECTION part of the code, replace <hisatpath/prefix> with the path to your hisat2 indexes and the prefix for your hisat2 indexes.
  - Mine ended up looking like:

```bash
 
####### MODIFY THIS SECTION #############

#The input samples live in directory:
inputdir="../01_input"

#This is where the ht2 files live:
hisat2path="/scratch/alpine/erinnish@colostate.edu/DSCI512/PROJ02_ce11IndexBuild/ce11"

#This is where the genome sequence lives:
genomefa="/scratch/alpine/erinnish@colostate.edu/DSCI512/PROJ02_ce11IndexBuild/ce11_wholegenome.fa"

#This is where the gtf file lives:
gtffile="/scratch/alpine/erinnish@colostate.edu/DSCI512/PROJ02_ce11IndexBuild/ce11_annotation_ensembl_to_ucsc.gtf"

```

 ### 6. Run the scripts
 
   - Simply run the scripts by executing:

```bash
$ sbatch --array=0-17 execute_RNAseq_pipeline.sbatch
```
 
   - Check on your script using:

```bash
$ squeue -u $USER
$ more <logfile>
$ tail <logfile>
```

Did it work?

  - If it worked, you should have a directory in your output file labeled with today's date.
  - Within that output directory, you should have folders for different steps of the pipeline `01_fastp`, `02_hisat2`, etc. 
  - Within the first two sub-directories, you should have files corresponding to samples EG01 and EG02. 

### 7. Clean up the project

In the next step of our project, we will need the counts.txt files that are located in **03_feature** sub-directory. These are each separate. To merge them into a single file for download, we need to run a quick little merge script.

  - Open the file **merge_counts_files.sh
  - Modify the MODIFY THIS SECTION part to match A) the date of your your output folder and B) your metadata file.
  - Run the script like so...

```bash
$ sh merge_counts_files.sh

### 8. Clean up the project

I included a script that automates the process of compressing files and deleting temp files. This is located in the same directory you cloned from github. To use this script:

 - Copy the cleanup script RNAseq_cleanup_241117.sh into the 02_scripts directory (move it one directory up).
 - Modify the “Modify this Section” part of the clean script.
 - Modify the execute_RNAseq_pipeline.sbatch script to 1) comment out ~Line57, the one that runs the RNAseq_analyzer script, 2) remove the commenting from ~Line65 that runs the cleanup script, and 3) add the metadata path to ~Line26
 - It should now look like this:
   
```bash
######################################################
## Execute the RNA-seq_pipeline to run the pipeline ##
######################################################

# Execute this script to analyze samples in your metadata file
bash analyze_RNAseq_241117.sh $SLURM_NTASKS $line 


#############################
# Optional Clean Up Script  #
#############################

## Execute the cleanup script to zip .fastq files and delete extra files
#bash cleanup_RNAseq_241117.sh $line 
```

Again, run with:

```
$ sbatch --array=0-17 execute_RNAseq_pipeline.sbatch
```


Thanks!
 
 [To Alignment](https://rna.colostate.edu/2024/doku.php?id=wiki:introalignment)

