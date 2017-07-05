#!/bin/bash

#===============================================================================
# TITLE    : analysis-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to BETA and 'analysis-engine.sh'
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-05
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ghmtools analysis [OPTIONS] RNA_DATA CHIP_DATA BINDING_DISTANCE GENE_LIST
#         CSV_FILE
#
# OPTIONS:
#
#     -f                : do not prompt before overwriting files
#     -i                : prompt before overwriting files (default)
#     -n                : do not overwrite files
#     -d <NUMBER>       : maximum distance (in kilobases) between a bound gene
#                         and the nearest binding site
#                             default: 10
#     --window <NUMBER> : number of genes to be summed to calculate a binding
#                         score
#                             default: 10
#
# ARGUMENTS:
#
#     RNA_DATA         : filepath of the file containing RNA-seq data
#     CHIP_DATA        : filepath of the BED file containing ChIP-seq data
#     BINDING_DISTANCE : maximum distance (in kilobases) that a gene can be from
#                        a binding site to be listed as a bound gene
#     GENE_LIST        : filepath where the list of bound genes will be saved
#     CSV_FILE         : filepath where the gene activity CSV file will be saved
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'gmtools help analysis' for usage notes."

# create a temporary file to store option parser output
opt_file=$(mktemp /tmp/XXXXXXXX.config)

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
    input_path="$1"
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
    input_path="$1"
fi
