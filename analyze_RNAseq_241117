#!/usr/bin/env bash

################################################
# PROGRAM:
# analyze_RNAseq_241117.sh
#
# DESCRIPTION:
# This is a very basic RNA-seq pipeline that I use for analyzing paired-end fastq reads. 
# This is a simple wrapper that performs quality control, genome alignment, basic format
# conversions, and htseq-count tabulation for paired-end RNA-seq samples using a specified
# genome. An optional Step2 is a clean up program that removes unnecessary files and compresses 
# files to save space.
#
# AUTHOR:
# Erin Osborne Nishimura
#
# START DATE:
# November 17,2024
#
# DEPENDENCIES:
# 	Requires the installation of the follwing software: 
#		fastp
#		hisat2
#		featureCounts (subread)
#		samtools
#		bedtools
#		deep-tools
#
#
# REQUIRES:
#    INPUT: .fastq files.    For each sample, paired forward and reverse sequencing files
#								are required. These should be placed in an input
#								directory.
#
#    INPUT: _metadata.txt file: A metadata file with two columns. The first two columns
#								are fastq file names (paired-end). The third column is a "nickname"
#								of each sample. Later columns can be included with other
#								metadata information. Metadata file should be placed
#								within the inputdir directory.
#
#
#    HISAT2 INDEXES: .ht2 files for the genome. These are produced using hisat2-build. For
#								instructions see
#	           https://ccb.jhu.edu/software/hisat2/manual.shtml#the-hisat2-build-indexer
#
#    GENOME SEQUENCE: .fa  or .tar.gz file for the genome. This is the sequence of the 
#                                genome.
#
#    GENOME ANNOTATION: .gtf file for the genome. This is a genome annotation file of gene
#								features. Version and coordinates must match the genome
#								sequence (.fa above).
#
# USAGE:
# $ bash analyze_RNAseq_241117.sh <number of threads> <line of metadata.txt> 
#
# OUTPUT:
#
# KNOWN BUGS:
#
# THINGS TO IMPROVE:
#
################################################


####### MODIFY THIS SECTION #############

#The input samples live in directory:
inputdir="../01_input"

#This is where the ht2 files live:
hisat2path="/pl/active/onishimura_lab/ERIN/COURSES/2024_testing/PROJ02_ce11IndexBuild/ce11"

#This is where the genome sequence lives:
genomefa="/pl/active/onishimura_lab/ERIN/COURSES/2024_testing/PROJ02_ce11IndexBuild/ce11_wholegenome.fa"

#This is where the gtf file lives:
gtffile="../01_input/ce11_annotation_ensembl_to_ucsc.gtf"

##This is the output_directory:
DATE=`date +%Y-%m-%d`
##OR
##DATE='2024-12-03'

outputdir="../03_output/"$DATE"_output/"

##The input samples live in directory:
#inputdir="<yourinputdir>"

##This is where the ht2 files live:
#hisat2path="<hisatpath/previx>"

##This is where the genome sequence lives:
#genomefa="<genome.fa>"

##This is where the gtf file lives:
#gtffile="<annotation.gtf>"

##This is the output_directory:
#DATE=`date +%Y-%m-%d`
##OR
##DATE='2024-12-03'

#outputdir="../03_output/"$DATE"_output/"

########## DONE MODIFYING ###############


####### OBTAIN ARGUMENTS & META DATA #############

#Number of threads to use:
#p-thread & Metadata info. This pulls the number of ntasks and the metadata from the command line
# Note - this imports the number of threads (ntasks) given in the command line
pthread=$1

#This is the name of the first read:
samples1=$2

#This is the name of the second read
samples2=$3

#These is the nickname:
names=$4


########## BEGIN CODE ###############

echo -e ">>> INITIATING analyzer with command:\n\t$0 $@"

# Make output directories
echo -e ">>> MAKING output directory"
echo -e "\tmkdir $outputdir"
mkdir -p $outputdir



############################
####### PIPELINE ###########
############################

# Report back to the user which files will be processed and which names they'll be given:
#echo -e ">>> INPUT: This script will process files from the metafile:\n\t$metadata"

echo -e ">>> PLAN: This script will process the sample files into the following names: "
echo -e "\tSAMPLE1\tSAMPLE2\tNAMES"
echo -e "\t${samples1}\t${samples2}\t${names}"


############################
# FASTP to remove unwanted sequences

echo -e "\n>>> FASTP: Trimming excess and low-quality sequences from .fastq file; generating quality report"

# Make output directories
mkdir -p $outputdir"01_fastp"
    mkdir -p $outputdir"01_fastp/"${names}

# Execute fastp
cmd1="fastp -i $inputdir/${samples1} \
-I $inputdir/${samples2} \
-o ${outputdir}01_fastp/${names}/${names}_trim_1.fastq \
-O ${outputdir}01_fastp/${names}/${names}_trim_2.fastq \
-h ${outputdir}01_fastp/${names}/${names}_report.html \
-j ${outputdir}01_fastp/${names}/${names}_report.json \
--detect_adapter_for_pe \
--thread $pthread \
-x -g "
  
echo -e "\t$ ${cmd1}"
time eval $cmd1


############################
# HISAT2 to align to the genome
echo -e "\n>>> HISAT2: aligning each sample to the genome"

# Make output directory
outhisat2=$outputdir"02_hisat2/"
mkdir -p $outhisat2

## execute hisat2
cmd3="hisat2 -x $hisat2path \
-1 ${outputdir}01_fastp/${names}/${names}_trim_1.fastq \
-2 ${outputdir}01_fastp/${names}/${names}_trim_2.fastq \
-S ${outhisat2}${names}.sam --summary-file ${outhisat2}${names}_summary.txt --no-unal -p $pthread"

echo -e "\t$ $cmd3"
time eval $cmd3


############################
# FEATURECOUNTS to tabulate reads per gene:
echo -e "\n>>> FEATURECOUNTS: Run featureCounts on all files to tabulate read counts per gene"

# Make output directory
outfeature=$outputdir"03_feature/"
mkdir -p $outfeature

# Execute featureCounts
samfilePath=${outhisat2}${names}.sam
cmd4="featureCounts -p -T $pthread -a $gtffile -o ${outfeature}${names}_counts.txt ${samfilePath}"
echo -e "\t$ $cmd4"
time eval $cmd4


############################
# SAMTOOLS and BAMCOVERAGE: to convert .sam output to uploadable .bam and .wg files
echo -e "\n>>> SAMTOOLS/BAMCOVERAGE: to convert files to uploadable _sort.bam and _sort.bam.bai files:"

# Make output directory
samout=$outputdir"04_samtools/"
mkdir -p $samout

# Samtools: compress .sam -> .bam
echo -e "\tSamtools and BamCoverage convert: ${names}"
cmd5="samtools view --threads $pthread -bS ${outhisat2}${names}.sam > ${samout}${names}.bam"
echo -e "\t$ ${cmd5}"
time eval $cmd5

# Samtools: sort .bam -> _sort.bam
cmd6="samtools sort --threads $pthread -o ${samout}${names}_sort.bam --reference $genomefa ${samout}${names}.bam"
echo -e "\t$ ${cmd6}"
time eval $cmd6

# Samtools: index _sort.bam -> _sort.bam.bai
cmd7="samtools index ${samout}${names}_sort.bam"
echo -e "\t$ ${cmd7}"
time eval $cmd7

# bamCoverage: Create a .bw file that is normalized. This can be uploaded to IGV or UCSC
cmd8="bamCoverage -b ${samout}${names}_sort.bam -o ${samout}${names}_sort.bw --outFileFormat bigwig -p $pthread --normalizeUsing CPM --binSize 1"
echo -e "\t$ ${cmd8}"
time eval $cmd8
    


######## VERSIONS #############
echo -e "\n>>> VERSIONS:"
echo -e "\n>>> FASTP VERSION:"
fastp --version
echo -e "\n>>> HISAT2 VERSION:"
hisat2 --version
echo -e "\n>>> SAMTOOLS VERSION:"
samtools --version
echo -e "\n>>> FEATURECOUNTS VERSION:"
featureCounts -v
echo -e "\n>>> BAMCOVERAGE VERSION:"
bamCoverage --version
echo -e ">>> END: Analayzer complete."
