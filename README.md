# 2024_RNAseq_PE_array
DSCI512: 2024: Course pipeline with quality control, alignment, tabulation, and format conversion for paired-end, short read RNA-seq projects. New this year - run in ARRAY format

-----


*DSCI512 - RNA sequencing data analysis - course scripts*

*A simple set of wrappers and tools for RNA-seq analysis. These tools were designed for the DSCI512 RNA-seq analysis class at Colorado State University*

Below is a tutorial on the use of these scripts:

----


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

Notice that instead of having a single script, you now have a few scripts. These will work in a **Two step** method for executing jobs on ALPINE. The `execute` script calls the `analyze` script. This Readme file and a license file were also downloaded.

Let's copy the two scripts up one directory. This will create duplicate copies for you to edit on and will move the scripts directly into ''02_scripts'', not its sub-directory.

```bash
$ cd 2024_RNAseq_PE_array
$ cp analyze_RNAseq_241117.sh ..
$ cp execute_RNAseq_pipeline.sbatch ..
$ cd ..
```

----
## Let's explore the RNAseqAnalyzer Script 


The **analyze_RNAseq_231126.sh** script contains our pipeline. 

Let's briefly peek into it and see that it contains. 
  * Open **analyze_RNAseq_241117.sh** in an editor window. You'll notice the following sections.

**The pipeline**
  * A shebang
  * A long comment section with documentation on its use
  * MODIFY THIS SECTION - *you will tailor this section to each job*
  * BEGIN CODE - *the code starts and reports how it is running*
  * METADATA - *this part pulls information out of the metadata file to create bash arrays*
  * PIPELINE - *right now this contains a loop that will execute fastp (preprocessing), a loop to execute hisat2 (alignment), a single line of code for featureCounts, and a number of file format conversion steps.*
  * VERSIONS - *this prints out the versions of software used for your future methods section*

The way this script works, we (as the user) modify the MODIFY THIS SECTION part, then when we run the script, we give it a metadata file as its first argument. We can execute the analyzer script like so...

```bash
$ bash RNAseq_analyzer_231117.sh ../01_input/metadatafile.txt
```

This will take a metadata file as input and loop over the content within that metadata file. It will pull the names of the .fastq file names to process from the first and second column of the metadata file and start processing them one at a time. It will name them by the 'short nickname' in the third column.

Now, we COULD execute the RNA_seq analyzer pipeline that way, but there is a problem with that. It would fail to use slurm, so we would overload the system. Instead, we need to execute this script using sbatch. We'll do that using a short mini-script called the execute program.

----
## Let's explore the Execute script 

The **execute_RNAseq_pipeline.sbatch** script will be used to submit the analyze script to the **job batch manager** called **SLURM**. This will put your analyze script in the queue and specify how it should be run on the supercomputer system.

For more background on SLURM:
  * [JOB SUBMISSIONS ON ALPINE](https://curc.readthedocs.io/en/latest/running-jobs/batch-jobs.html)
  * [SLURM ON ALPINE - FAQ](https://curc.readthedocs.io/en/latest/faq.html)
  * [SLURM DOCUMENTATION](https://slurm.schedmd.com/sbatch.html)

To execute the bash script, we will do the following...

```bash
$ sbatch execute_RNAseq_pipeline.sbatch
```

By doing this, the **execute** script will submit the **analyzer** script to **SLURM**. This will ensure the **analyzer** script is run at the proper time and with the requested resources on compute nodes on the ALPINE system. What is SLURM? Slurm is a job scheduling system for large and small Linux clusters. It puts your job into a 'queue'. When the resources you have requested are available, your job will begin. SLURM is organized so that different users have different levels of priority in the queue. On ALPINE, users who use fewer resources have higher priority. Power users have less priority and are encouraged to purchase greater access to the system if it is a problem.

Let's open **execute_RNAseq_pipeline.sbatch** in an editor window and explore how it works. 

```bash
#!/usr/bin/env bash

#SBATCH --job-name=RNAseq_pipeline 
#SBATCH --nodes=1                          # this script is designed to run on one node
#SBATCH --ntasks=2                       # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --time=00:10:00                    # modify this number to reflect how much time to request
#SBATCH --partition=amilan                 # modify this to reflect which queue you want to use.
#SBATCH --mail-type=END                    # Keep these two lines of code if you want an e-mail sent to you when it is complete.
#SBATCH --mail-user=<youremail>             # add your e-mail here
#SBATCH --output=log-RNAseqpipe-%j.out     # this will capture all output in a logfile with %j as the job #

######### Instructions ###########

# Modify your SLURM entries above to fit your choices
# Below, modify the SECOND argument to point to YOUR metadata.file
# Below, you don't need to change $SLURM_NTASKS. It will automatically populate whatever you put in --ntasks=# above.
# Execute this script using $ sbatch --array=0-17 execute_RNAseq_pipeline.sbatch 
#   where n = number of paired-end samples to process. 

# Get the ARRAY#
num=$(( ${SLURM_ARRAY_TASK_ID} + 1 ))

# Get the metadata line of information associated with this ARRAY#
line=$( sed -ne "${num}p" ../01_intput/metadata_gomezOrte.txt )

echo $line

## Execute the RNA-seq_pipeline to run the pipeline
bash analyze_RNAseq_241117.sh $SLURM_NTASKS $line 

```

  * This script is going to request 2 ntasks (threads) on 1 node. NOTE - never split a node. 
  * Notice that this script only has 1 line of code that will execute. The second bash line is commented out for now. 
  * The way you will use this script is by modifying the SLURM prepended commands to fit how you want the job to run.
  * Next, you will add in your <metadatafile> information. Mine will be ../01_input/tester_metadatafile.txt
  * Then, you will execute the script like so...
  
```bash

$ sbatch --array=0-17 execute_RNAseq_pipeline.sbatch
```

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
6. Run the scripts
7. Clean up the project
 
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
  - Most importantly, replace <metadatafile> with a path to your tester metadata file. 
  - Mine looks like:

```bash
 bash analyze_RNAseq_231126.sh ../01_input/metadata_gomezOrte.txt  $SLURM_NTASKS
```
 
### 5. Modify the **analyzer** script

  - Awesome!
  - Next, we'll modify the script **analyze_RNAseq_241117.sh**
  - Open the **analyze_RNAseq_241117.sh** in a text editor window.
  - Within the MODIFY THIS SECTION part of the code, replace <yourinputdir> with a path to your input directory. 
  - Within the MODIFY THIS SECTION part of the code, replace <hisatpath/prefix> with the path to your hisat2 indexes and the prefix for your hisat2 indexes.
  - Mine ended up looking like:

```bash
 
####### MODIFY THIS SECTION #############

#The input samples live in directory:
inputdir="../01_input"

#This is where the ht2 files live:
hisat2path="/pl/active/onishimura_lab/ERIN/COURSES/2024_testing/PROJ02_ce11IndexBuild/ce11"

#This is where the genome sequence lives:
genomefa="/pl/active/onishimura_lab/ERIN/COURSES/2024_testing/PROJ02_ce11IndexBuild/ce11_wholegenome.fa"

#This is where the gtf file lives:
gtffile="../01_input/ce11_annotation_ensembl_to_ucsc.gtf"

```

 ### 6. Run the scripts
 
   - Simply run the scripts by executing:

```bash
$ sbatch execute_RNAseq_pipeline.sbatch
```
 
   - Check on your script using:

```bash
$ scheck
$ more <logfile>
$ tail <logfile>
```

Did it work?

  - If it worked, you should have a directory in your output file labeled with today's date.
  - Within that output directory, you should have folders for different steps of the pipeline `01_fastp`, `02_hisat2`, etc. 
  - Within the first two sub-directories, you should have files corresponding to samples EG01 and EG02. 
  - The code will likely have only progressed as far as the hisat2 step.

### 7. Clean up the project

I included a script that automates the process of compressing files and deleting temp files. This is located in the same directory you cloned from github. To use this script:

 - Copy the cleanup script RNAseq_cleanup_231126.sh into the 02_scripts directory (move it one directory up).
 - Modify the “Modify this Section” part of the clean script.
 - Modify the execute_RNAseq_pipeline.sbatch script to 1) comment out ~Line22, the one that runs the RNAseq_analyzer script, 2) remove the commenting from ~Line26 that runs the cleanup script, and 3) add the metadata path to ~Line26
 - It should look like this:
   
```
## Execute the RNA-seq_pipeline to run the pipeline
#bash RNAseq_analyzer_231126.sh ../01_input/test_metadata.txt  $SLURM_NTASKS

## Execute the cleanup script to zip .fastq files and delete extra files
bash RNAseq_cleanup_221126.sh ../01_input/test_metadata.txt
```

Again, run with:

```
$ sbatch execute_RNAseq_pipeline.sbatch
```


Thanks!
 
 [To Alignment](https://rna.colostate.edu/2023/doku.php?id=wiki:introalignment)

