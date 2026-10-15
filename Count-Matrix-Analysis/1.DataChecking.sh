#!/bin/bash
#SBATCH -A Research_Project-T112069 # research project to submit under.
#SBATCH --export=ALL # export all environment variables to the batch job.
#SBATCH -D . # set working directory to .
#SBATCH -p mrcq # submit to the parallel test queue
#SBATCH --time=01:00:00 # Maximum wall time for the job
#SBATCH --nodes=1 # specify number of nodes.
#SBATCH --ntasks-per-node=16 # specify number of processors.
#SBATCH --mail-type=END # send email at job completion
#SBATCH --mail-user=j.d.harvey@exeter.ac.uk # email address
#SBATCH --output=%x.%j.out
#########################################################################
##################     1. Data Checking     #############################
#########################################################################
# This script runs an initial check of RNA counts from the RNA calls. It requires a formatted pheno file,
# processed raw count matrix and parameters for data filtering. It outputs a set of plots showing library
# size distribution, PCA defined outliers and h-clustered sample level data. It also provides sample level
# summaries of those outputs. 
# Note, if you want to run this script with salmon-tpm normalisation, in addition to the raw-count matrix you
# will also need to provide a tpm-normalised tsv output file from the salmon quantifier exports.


# Processed counts file, formatted with gene ID rownames, sample ID colnames:
counts_file="/lustre/projects/Research_Project-T112069/FAD/3_RNA/3_1_RNA/3_1_2_2_Salmon/FAD_ARUK_salmonCounts_tx2gene.tsv" 

# Processed pheno file, first row must contain rownames compatible with colnames
pheno_file="/lustre/projects/Research_Project-T112069/FAD/1_metadata/3_1_RNA_phenomerge.csv" 

# Main group of interest
trait_var="BroadGroup" 

# Factorial & Binarized variables (pheno file collumn names)
factor_vars="Sex,Plate"

# Numeric/Continuous variables (pheno file collumn names)
numeric_vars="Age,PMI,RINe,NeuNNeg_SOX10Pos,NeuNNeg_Sox10Neg_IRF8Neg,NeuNNeg_Sox10Neg_IRF8Pos,NeuNPos_SOX6Neg,NeuNPos_SOX6Pos,Astro,EndoMural,Micro,Oligo,OPC,Excit,Inhib"

# Normalisation method (options: cpm, vst or tpm_salmon). If using tpm_salmon, please also supply the salmon_tpm variable
normalize_method="tpm_salmon"

# Library size threshold for the cohort filtering. Recommended inputs are: 
# mRNA-Seq / Whole Transcriptome: 25 million minimum
# miRNA-Seq / Small RNA Analysis: 1 million minimum
# https://knowledge.illumina.com/library-preparation/rna-library-prep/library-preparation-rna-library-prep-reference_material-list/000001243
lib_size_threshold="20e+6"

# Minimum gene count threshold, to be supplied to the min.count argument in edgeR::filterByExpr()
gFilter_min_count=5

# Minimum proportion threshold, to be supplied to the min.prop argument in edgeR::filterByExpr()
gFilter_min_prop=0.75

# If using salmontpm normalisation 
salmon_tpm="/lustre/projects/Research_Project-T112069/FAD/3_RNA/3_1_RNA/3_1_2_2_Salmon/FAD_ARUK_salmonCounts_tx2gene.tpm.tsv"

# Output prefix of how results should be saved (note, the end will indicate the naming convention for this run)
OutPrefix="/lustre/projects/Research_Project-T112069/FAD/3_RNA/3_1_RNA/Plots/3_1_3_MKpipeline"

# Directory with script location
ScriptDir="/lustre/projects/Research_Project-T112069/FAD/Scripts/RNA-Seq-Analysis/Count-Matrix-Analysis"

#Argument to filter samples out with low library size, prior to PCA analysis (TRUE = filter, FALSE = run all samples in PCA)
filter_low="TRUE"


##########################################################################

conda activate rna_env

Rscript $ScriptDir/DataChecking.R $ScriptDir $counts_file $pheno_file $trait_var $factor_vars $numeric_vars $normalize_method $lib_size_threshold $gFilter_min_count $gFilter_min_prop $OutPrefix $salmon_tpm $filter_low

echo "All done!"