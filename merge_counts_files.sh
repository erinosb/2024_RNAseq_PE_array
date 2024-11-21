#!/usr/bin/env bash

################################################
# PROGRAM:
# merge_counts_files.sh
#
# DESCRIPTION:
# Run this at the end to merge all your counts files together
#
# AUTHOR:
# Erin Osborne Nishimura
#
# START DATE:
# November 19,2024
#
#
# Usage statement: 
# bash merge_counts_files.sh

########################
# MODIFY THIS SECTION
########################

#Select the proper date for the output file you'd like to merge:
#day=`date +%Y-%m-%d`
#OR
day='2024-11-20'


# Select the metadata file
metadata=../01_input/metadata_gomezOrte.txt

########################
# MERGE FILES
########################

#Directory is:
outdir="../03_output/"$day"_output/03_feature/"

# Merged file to create is:
mergedfile=${outdir}${day}_merged_counts.txt

# Name array is:
names=( $(cut -f 3 --output-delimiter=' ' $metadata) )

# Trim header off of first file and add its contents to the mergefile
grep -v "#" ${outdir}${names[0]}_counts.txt > $mergedfile

# Loop over remaining files, trim off headers, and paste their last columns onto a growing merged file
# Set counter
x=1
# While loop starting with second element:
while [ $x -lt ${#names[@]} ]
do
    # get countsfile name
    nthcountsfile=${outdir}${names[$x]}_counts.txt
    # trim off header, paste last column onto mergefile
    grep -v "#" ${outdir}${names[$x]}_counts.txt | cut -f 7 | paste $mergedfile - > ${outdir}temp_file${x}.txt
    
    # Copy tempfile to new merged file
    mv ${outdir}temp_file${x}.txt $mergedfile
    
    # Incrementalization of the counter
    ((x++))
 
done
 
echo "The code is complete"
