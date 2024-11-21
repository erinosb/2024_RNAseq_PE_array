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

# Replace <metadata> to your metadata file including its relative or absolute path. Mine looks like this...
# metadata=../01_input/metadata_gomezOrte.txt

metadata=<yourmetadatafile.txt>


##############################
#      SET ARRAYS TO RUN     #
##############################

# Get the ARRAY#
num=$(( ${SLURM_ARRAY_TASK_ID} + 1 ))

# Get the metadata line of information associated with this ARRAY#
line=$( sed -ne "${num}p" $metadata )
echo $line


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
