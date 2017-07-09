#!/bin/bash

#===============================================================================
# TITLE    : heatmap-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to 'heatmap-engine.r'
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-09
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ghmtools heatmap [OPTIONS] GENE_DATA TRANSCRIPTION_MIN TRANSCRIPTION_MAX
#         [BINDING_MAX] TRANSCRIPTION_FILE BINDING_FILE
#
# OPTIONS:
#
#     -f        : do not prompt before overwriting files
#     -i        : prompt before overwriting files (default)
#     -n        : do not overwrite files
#     --nozeros : do not map genes with zero transcription values
#
# ARGUMENTS:
#
#     GENE_DATA          : filepath of the file containing gene transcription
#                          and gene binding data
#     TRANSCRIPTION_MIN  : minimum value on the gene transcription scale
#     TRANSCRIPTION_MAX  : maximum value on the gene transcription scale
#     BINDING_MAX        : maximum value on the gene binding scale (optional)
#                              if BINDING_MAX is not given or is set to NONE,
#                              the maximum value on the gene binding scale is
#                              set to the maximum gene binding value in the data
#     TRANSCRIPTION_FILE : filepath where the gene transcription heatmap will be
#                          saved
#     BINDING_FILE       : filepath where the gene binding heatmap will be saved
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'gmtools help heatmap' for usage notes."

# create a temporary directory to hold temporary files
temp_dir=$(mktemp -d --tmpdir "$(basename "$0").XXXXXXXXXX")

# create a temporary file to hold option parser output
opt_file=$temp_dir/options.conf

# pass all arguments and option metadata to option parser
~/.genetic-heatmaps/option-parser.py -f -i -n --nozeros -- $@ -- $opt_file

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

# determine include_zeros option to be passed to heatmap-engine.r
if $nozeros; then
    include_zeros="FALSE"
else
    include_zeros="TRUE"
fi

# remove the option flags from the list of positional arguments
# $1 refers to the gene data filepath and not the first option flag
shift $((ARG_INDEX - 1))

# check that the number of arguments is valid
if ! [[ $# -eq 5 || $# -eq 6 ]]; then
    echo "ERROR: Invalid number of arguments" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# check that the gene data file is a valid file
if ! [[ -f $1 ]]; then
    if ! [[ -e $1 ]]; then
        echo "ERROR: Gene data file does not exist ($1)" >&2
    else
        echo "ERROR: Invalid gene data file ($1)" >&2
    fi
    echo "$HELP_PROMPT"
    exit 1
else
    gene_path="$1"
fi

# regular expression to detect positive and negative integers and doubles
signed_double_re='^[+-]?[0-9]*([.][0-9]+)?$'

# check that transcription_min is a number
if ! [[ $2 =~ $signed_double_re ]]; then
    echo "ERROR: Transcription min is not a number ($2)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# check that the upper bound is a number
if ! [[ $3 =~ $signed_double_re ]]; then
    echo "ERROR: Transcription max is not a number ($3)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# check that the lower bound is less than the upper bound
if ! [[ $(echo "$2 < $3" | bc) -eq 1 ]]; then
    echo "ERROR: Transcription max ($2) is not greater than min ($3)" >&2
    echo "$HELP_PROMPT"
    exit 1
else
    transcription_min="$2"
    transcription_max="$3"
fi

# determine whether the binding_max was given by checking if  is a number
if [[ $4 =~ $signed_double_re ]]; then
    if ! [[ $(echo "$4 > 0" | bc) -eq 1 ]]; then
        echo "ERROR: Binding max ($4) is not greater than 0" >&2
        echo "$HELP_PROMPT"
        exit 1
    fi
    binding_max="$4"
    # $5 -> $1 = transcription_file
    shift 4
else
    binding_max="NONE"
    # $4 -> $1 = transcription_file
    shift 3
fi

# check that the transcription heatmap file does not exist
if [[ -e $1 ]]; then
    # if it does exist, check option to determine whether to prompt user
    case $ow_opt in
        f)
            # do not prompt user, overwrite file
            transcription_path="$1"
            ;;
        i)
            # prompt user
            echo "A file already exists at $1"
            read -p "Type y to overwrite that file, type n to exit: " yn
            if ! [[ $yn == "y" || $yn == "Y" ]]; then
                # do not overwrite file, exit program
                exit
            else
                # overwrite file
                transcription_path="$1"
            fi
            ;;
        n)
            # do not prompt user, do not overwrite, exit program with error
            echo "ERROR: A file already exists at $1" >&2
            echo "$HELP_PROMPT"
            exit 1
            ;;
    esac
else
    transcription_path="$1"
fi

# check that the binding heatmap file does not exist
if [[ -e $2 ]]; then
    # if it does exist, check option to determine whether to prompt user
    case $ow_opt in
        f)
            # do not prompt user, overwrite file
            binding_path="$2"
            ;;
        i)
            # prompt user
            echo "A file already exists at $2"
            read -p "Type y to overwrite that file, type n to exit: " yn
            if ! [[ $yn == "y" || $yn == "Y" ]]; then
                # do not overwrite file, exit program
                exit
            else
                # overwrite file
                binding_path="$2"
            fi
            ;;
        n)
            # do not prompt user, do not overwrite, exit program with error
            echo "ERROR: A file already exists at $2" >&2
            echo "$HELP_PROMPT"
            exit 1
            ;;
    esac
else
    binding_path="$2"
fi

# pass validated arguments to heatmap-engine.r
~/.genetic-heatmaps/heatmap-engine.r "$gene_path" "$include_zeros" \
    "$transcription_min" "$transcription_max" "$binding_max" \
    "$transcription_path" "$binding_path"
