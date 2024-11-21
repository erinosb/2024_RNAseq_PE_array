#!/usr/bin/env bash

#SBATCH --job-name=RNAseq_pipeline 
#SBATCH --nodes=1                          # this script is designed to run on one node
#SBATCH --ntasks=1                         # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --time=00:15:00                    # modify this number to reflect how much time to request
#SBATCH --partition=amilan                 # modify this to reflect which queue you want to use.
#SBATCH --mail-type=END                    # Keep these two lines of code if you want an e-mail sent to you when it is complete.
#SBATCH --mail-user=erinnish@colostate.edu            # add your e-mail here
#SBATCH --output=log-RNAseqpipe-%j.out     # this will capture all output in a logfile with %j as the job #

######### Instructions ###########

# Modify your SLURM entries above to fit your choices
# Below, modify the SECOND argument to point to YOUR metadata.file
# Below, you don't need to change $SLURM_NTASKS. It will automatically populate whatever you put in --ntasks=# above.
# Execute this script using $ sbatch --array=0-17 execute_RNAseq_pipeline.sbatch 
#   where n = number of paired-end samples to process. 


##############################
#      MODIFY THIS SECTION   #
##############################
metadata=../01_input/metadata_gomezOrte.txt


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

#bash analyze_RNAseq_241117.sh $SLURM_NTASKS $line 


#############################
# Optional Clean Up Script  #
#############################

## Execute the cleanup script to zip .fastq files and delete extra files
bash cleanup_RNAseq_241117.sh $line 
