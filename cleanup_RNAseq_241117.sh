#!/usr/bin/env bash

################################################
# Program:
# RNAseq_cleanup_241117.sh
#
# Author:
# Erin Osborne Nishimura
#
# Date initiated:
# November 17, 2024
#
# Description:
#
# This is a very basic pipeline to clean up the files generated from RNAseq_analyzer_241117.sh
#
# Requires: A metadata file with two columns. The first two columns are fastq file names. 
#           The third column is a "nickname" of each sample
#           Later columns can be included with other metadata information
#           Metadata file should be placed within the inputdir directory.
# 
# Executed with:
# bash RNAseq_cleanup_241117.sh <line from metadata.txt>
################################################

echo -e ">>> INITIATING cleanup with command:\n\t$0 $@"


####### MODIFY THIS SECTION #############

# The input samples (metadata file and _fastq.gz files) live in directory:
# Replace <intputDir> with your input directory
# Mine looked like: inputdir="../01_input"
inputdir="<inputDir>"

# This is the output_directory. Look at the date of the output file you'd like cleanup
# modify this section to reflect that date
DATE=`date +%Y-%m-%d`
#OR
#DATE=2022-12-03
outputdir="../03_output/"$DATE"_output/"


########## DONE MODIFYING ###############


####### META DATA #############

# Read the metadata file and extract information out of it.

#These are the sample names, R1:
samples1=$1

#These are the sample names, R2:
samples2=$2

#These are the nicknames I want to give the files:
names=$3




####### RE-ZIPPING #############

### Optional: REZIP ALL THE INPUT FILES: 

echo -e ">>>Zipping files"
for fastqfile in ${samples1[@]}
do
   echo -e "gzipping ${inputdir}/${fastqfile}"
   #gzip ${inputdir}/${fastqfile}
done
for fastqfile in ${samples2[@]}
do
   echo -e "gzipping ${inputdir}/${fastqfile}"
   #gzip ${inputdir}${fastqfile}
done




####### DELETING FILES #############

# Gather output directories
outfastp=$outputdir"01_fastp/"
outhisat2=$outputdir"02_hisat2/"
samout=$outputdir"04_samtools/"

echo -e "fastp output directory is $outfastp"
echo -e "HISAT2 outpur directory is $outhisat2"
echo -e "samtools output directory is $samout"

# Delete _trim.fastq files.  .fastq files are huge and are easily regenerated. 
echo -e "\n>>> DELETING _trim.fastq files. Ensuring that _sort.bam files exists first:"

for seqname in ${names[@]}
do
    # test whether the _sort.bam file exists
    sortbamfile=${samout}${seqname}_sort.bam
    echo -e "Sorted bamfile is $sortbamfile"
    if [ -s  $sortbamfile ] 
    then
        # remove the _trim.fastq file2
        echo -e "\t$ rm ${outfastp}/${seqname}/${seqname}_trim_1.fastq"
        rm ${outfastp}/${seqname}/${seqname}_trim_1.fastq
        echo -e "\t$ rm ${outfastp}/${seqname}/${seqname}_trim_2.fastq"
        rm ${outfastp}/${seqname}/${seqname}_trim_2.fastq
    fi
done


# Delete .sam files.  X.sam files are huge and redundant with _sort.bam files. 
echo -e "\n>>> DELETING .sam files. Ensuring that _sort.bam files exists first:"

for seqname in ${names[@]}
do
    # test whether the _sort.bam file exists
    sortbamfile=${samout}${seqname}_sort.bam

    if [ -s  $sortbamfile ] 
    then
        # remove the .sam file
        echo -e "\t$ rm ${outhisat2}${seqname}.sam"
        rm ${outhisat2}${seqname}.sam
    fi
done


# Delete .bam files.  X.bam files are not necessary when we have smaller _sort.bam files. 
echo -e "\n>>> DELETING .bam files. Ensuring that _sort.bam files exists and keeping it:"


for seqname in ${names[@]}
do
    # test whether the _sort.bam file exists
    sortbamfile=${samout}${seqname}_sort.bam
    if [ -s  $sortbamfile ] 
    then
        # Delete the .bam file
        echo -e "\t$ rm ${samout}${seqname}.bam"
        rm ${samout}${seqname}.bam
    fi
done


echo -e "\n>>> END PROGRAM: Clean up is complete."
