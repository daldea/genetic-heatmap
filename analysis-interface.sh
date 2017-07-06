#!/bin/bash

#===============================================================================
# TITLE    : analysis-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to BETA and 'analysis-engine.sh'
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-06
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ghmtools analysis [OPTIONS] RNA_DATA CHIP_DATA GENOME CSV_FILE
#
# OPTIONS:
#
#     -f                : do not prompt before overwriting files
#     -i                : prompt before overwriting files (default)
#     -n                : do not overwrite files
#     -d <NUMBER>       : maximum distance (in kilobases) between a bound gene
#                         and the nearest binding site (default: 10)
#     --window <NUMBER> : number of genes to be summed to calculate a binding
#                         score (default: 10)
#
# ARGUMENTS:
#
#     RNA_DATA  : filepath of the file containing RNA-seq data
#     CHIP_DATA : filepath of the BED file containing ChIP-seq data
#     GENOME    : reference genome used by BETA (options: hg19, mm9)
#     CSV_FILE  : filepath where the gene activity CSV file will be saved
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'gmtools help analysis' for usage notes."

# create a temporary directory to hold temporary files
temp_dir=$(mktemp -d --tmpdir "$(basename "$0").XXXXXXXXXX")

# create a temporary file to store option parser output
opt_file=$temp_dir/options.conf
touch $opt_file

# pass all arguments and option metadata to option parser
~/.genetic-heatmaps/option-parser.py -f -i -n -d VALUE --window VALUE -- $@ -- \
    $opt_file

# load option parser output
source $opt_file

# determine overwrite option
if $n; then
    ow_opt="n"
elif $i; then
    ow_opt="i"
elif $f; then
    ow_opt="f"
else
    ow_opt="i"
fi

# convert kilobases to bases
binding_dist=$((d * 1000))

# remove the option flags from the list of positional arguments
# $1 refers to the CSV filepath and not the first option flag
shift $((ARG_INDEX - 1))

# check that the RNA-seq file is a valid file
if ! [[ -f $1 ]]; then
    if ! [[ -e $1 ]]; then
        echo "ERROR: RNA-seq file does not exist ($1)" >&2
    else
        echo "ERROR: Invalid RNA-seq file ($1)" >&2
    fi
    echo "$HELP_PROMPT"
    exit 1
else
    rna_path="$1"
fi

# check that the ChIP-seq file is a valid file
if ! [[ -f $2 ]]; then
    if ! [[ -e $2 ]]; then
        echo "ERROR: ChIP-seq file does not exist ($2)" >&2
    else
        echo "ERROR: Invalid ChIP-seq file ($2)" >&2
    fi
    echo "$HELP_PROMPT"
    exit 1
else
    chip_path="$2"
fi

# check that the genome is valid
case $3 in
    hh19)
        genome="hh19"
        ;;
    mm9)
        genome="mm9"
        ;;
    \?)
        # exit program with error on invalid genome
        echo "ERROR: Invalid genome ($3)" >&2
        echo "$HELP_PROMPT"
        exit 1
        ;;
esac

# create a temporary sub-directory to store parsed data files
mkdir $temp_dir/parsed_data

# remove comments from RNA-seq data file so that it can be read by R
temp_rna_data=$temp_dir/parsed_data/rna_data
sed '/^#/ d' < $rna_path > $temp_rna_data

# run the BETA minus genomic analysis program to generate ChIP-seq gene list
# supress BETA terminal output
BETA minus -p $chip_path -g $genome -d $binding_dist -o $temp_dir/BETA_output \
   --bl >/dev/null

# remove comments from ChIP-seq gene list so that it can read by R
temp_beta_genes=$temp_dir/parsed_data/beta_genes
sed '/^#/ d' < $tmp_dir/BETA_output/NA_targets.txt > $temp_beta_genes

# TODO: connect to analysis-engine.r
