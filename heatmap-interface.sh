#!/bin/bash

#===============================================================================
# TITLE    : heatmap-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to the heatmap engine
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-12
#
# LICENSE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# SYNOPSIS:
#
#     ghmtools heatmap [-f | -i | -n ] [--no-zeros] <gene-data>
#         <transcription-file> <transcription-max> [<binding-max>]
#         <transcription-file> <binding-file>
#
# DESCRIPTION:
#
#     -f                   : do not prompt before overwriting files
#     -i                   : prompt before overwriting files (default)
#     -n                   : do not overwrite files
#     --no-zeros           : do not map genes with zero transcription values
#     <gene-data>          : filepath of the file containing gene transcription
#                            and gene binding data
#     <transcription-min>  : minimum value on the gene transcription scale
#     <transcription-max>  : maximum value on the gene transcription scale
#     <binding-max>        : maximum value on the gene binding scale (optional)
#     <transcription-file> : filepath where the gene transcription heatmap will
#                            be saved
#     <binding-file>       : filepath where the gene binding heatmap will be
#                            saved
#
# NOTES:
#
#     If <binding-max> is not given, the maximum value on the gene binding scale
#     is set to the maximum gene binding value in the data.
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'ghmtools help heatmap' for usage notes."

# create a temporary directory to hold temporary files
temp_dir=$(mktemp -d --tmpdir "$(basename "$0").XXXXXXXXXX")

# pass all arguments and option metadata to option parser
opt_file=$temp_dir/options.conf
~/.genetic-heatmaps/option-parser.py -f -i -n --nozeros -- $@ -- "$opt_file"
source "$opt_file"

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

# determine include zeros option
if $nozeros; then
    include_zeros="FALSE"
else
    include_zeros="TRUE"
fi

# remove option flags from the list of positional arguments
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
    gene_path=$1
fi

# regular expression to match numbers
number_regex='^[+-]?[0-9]*([.][0-9]+)?$'

# check that the lower bound is a number
if ! [[ $2 =~ $number_regex ]]; then
    echo "ERROR: Transcription min is not a number ($2)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# check that the upper bound is a number
if ! [[ $3 =~ $number_regex ]]; then
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
    transcription_min=$2
    transcription_max=$3
fi

# determine whether the binding max was given by checking if it is a number
if [[ $4 =~ $number_regex ]]; then
    if ! [[ $(echo "$4 > 0" | bc) -eq 1 ]]; then
        echo "ERROR: Binding max ($4) is not greater than 0" >&2
        echo "$HELP_PROMPT"
        exit 1
    fi
    binding_max=$4
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
            transcription_path=$1
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
                transcription_path=$1
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
    transcription_path=$1
fi

# check that the binding heatmap file does not exist
if [[ -e $2 ]]; then
    # if it does exist, check option to determine whether to prompt user
    case $ow_opt in
        f)
            # do not prompt user, overwrite file
            binding_path=$2
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
                binding_path=$2
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
    binding_path=$2
fi

# create a temporary sub-directory to store parsed data files
mkdir $temp_dir/parsed_data

# remove comments from gene data file
temp_gene=$temp_dir/parsed_data/gene_data
sed '/^#/ d' < "$gene_path" > "$temp_gene"

# pass validated arguments to the heatmap engine
~/.genetic-heatmaps/heatmap-engine.r "$temp_gene" $include_zeros \
    $transcription_min $transcription_max $binding_max "$transcription_path" \
    "$binding_path"
