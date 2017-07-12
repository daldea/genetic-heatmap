#!/bin/bash

#===============================================================================
# TITLE    : analysis-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to BETA and the analysis engine
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-12
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ghmtools analysis [OPTIONS] TRANSCRIPTION_DATA BINDING_DATA GENOME
#         GENE_FILE
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
#     TRANSCRIPTION_DATA : filepath of the file containing gene transcription
#                          data
#     BINDING_DATA       : filepath of the file containing ChIP-seq data or a
#                          list of bound genes
#     GENOME             : reference genome used by BETA (options: hg19, mm9)
#     GENE_FILE          : filepath where the gene activity file will be saved
#
# NOTES:
#
#     It is not necessary to specify whether BINDING_DATA is a ChIP-seq data
#     file or a list of bound genes, since the analysis interface can determine
#     this automatically.
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'ghmtools help analysis' for usage notes."

# create a temporary directory to hold temporary files
temp_dir=$(mktemp -d --tmpdir "$(basename "$0").XXXXXXXXXX")

# pass all arguments and option metadata to option parser
opt_file=$temp_dir/options.conf
~/.genetic-heatmaps/option-parser.py -f -i -n -d VALUE --window VALUE -- $@ -- \
    $opt_file
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

# regular expression to match positive numbers
positive_number_regex='^[+]?[0-9]*([.][0-9]+)?$'
# regular expression to match non-negative integers
nonnegative_integer_regex='^[+]?[0-9]+$'

if [[ $d == "None" ]]; then
    d=10
fi
# check that the binding distance is a positive number
if ! [[ $d =~ $positive_number_regex ]]; then
    echo "ERROR: Binding distance is not a positive number ($d)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi
# convert the binding distance from kbp to bp, round to the nearest integer
binding_dist=$(python3 -c "print(round(1000 * $d))")

if [[ $window == "None" ]]; then
    window=10
fi
# check that the window size is a positive integer
if ! [[ $window =~ $nonnegative_integer_regex ]]; then
    echo "ERROR: Window size is not a non-negative integer ($window)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# remove option flags from the list of positional arguments
# $1 refers to the transcription data filepath and not the first option flag
shift $((ARG_INDEX - 1))

# check that the transcription data file is a valid file
if ! [[ -f $1 ]]; then
    if ! [[ -e $1 ]]; then
        echo "ERROR: Transcription data file does not exist ($1)" >&2
    else
        echo "ERROR: Invalid transcription data file ($1)" >&2
    fi
    echo "$HELP_PROMPT"
    exit 1
else
    transcription_path="$1"
fi

# check that the binding data file is a valid file
if ! [[ -f $2 ]]; then
    if ! [[ -e $2 ]]; then
        echo "ERROR: Binding data file does not exist ($2)" >&2
    else
        echo "ERROR: Invalid binding data file ($2)" >&2
    fi
    echo "$HELP_PROMPT"
    exit 1
else
    binding_path="$2"
fi

# check that the genome is a supported genome
case $3 in
    "hh19")
        genome="hh19"
        ;;
    "mm9")
        genome="mm9"
        ;;
    *)
        # exit program with error on invalid genome
        echo "ERROR: Invalid genome ($3)" >&2
        echo "$HELP_PROMPT"
        exit 1
        ;;
esac

# check that the gene data file does not exist
if [[ -e $4 ]]; then
    # if it does exist, check option to determine whether to prompt user
    case $ow_opt in
        f)
            # do not prompt user, overwrite file
            gene_path=$4
            ;;
        i)
            # prompt user
            echo "A file already exists at $4"
            read -p "Type y to overwrite that file, type n to exit: " yn
            if ! [[ $yn == "y" || $yn == "Y" ]]; then
                # do not overwrite file, exit program
                exit
            else
                # overwrite file
                gene_path=$4
            fi
            ;;
        n)
            # do not prompt user, do not overwrite, exit program with error
            echo "ERROR: A file already exists at $4" >&2
            echo "$HELP_PROMPT"
            exit 1
            ;;
    esac
else
    gene_path=$4
fi

# create a temporary sub-directory to store parsed data files
mkdir $temp_dir/parsed_data

# remove comments from transcription data file
temp_transcription=$temp_dir/parsed_data/transcription_data
sed '/^#/d' < "$transcription_path" > "$temp_transcription"
# replace spaces with tabs in transcription data file
sed -i "s/ /\t/g" "$temp_transcription"

# remove comments from binding data file
temp_binding=$temp_dir/parsed_data/binding_data
sed '/^#/d' < "$binding_path" > "$temp_binding"
# replace spaces with tabs in binding data file
sed -i "s/ /\t/g" "$temp_binding"

# determine if binding data is a ChIP-seq data file or a bound gene list file
if grep -Pq "\t" "$temp_binding"; then
    # run the BETA genomic analysis program to generate bound gene list file
    BETA minus -p "$temp_binding" -g $genome -d $binding_dist \
        -o "$temp_dir/BETA_output" --bl >/dev/null
    # remove comments from BETA output file
    sed '/^#/d' < "$temp_dir/BETA_output/NA_targets.txt" > "$temp_binding"
fi

# pass validated arguments to the analysis engine
~/.genetic-heatmaps/analysis-engine.r "$temp_transcription" "$temp_binding" \
    $window "$gene_path"
