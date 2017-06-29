#!/bin/bash

#===============================================================================
# TITLE    : heatmap-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to "heatmap-generator.r"
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-06-28
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#     ghmtools heatmap [OPTIONS] CSV_FILE TRANSCRIPTION_MIN
#         TRANSCRIPTION_MAX [BINDING_MAX] TRANSCRIPTION_FILE BINDING_FILE
#
# OPTIONS:
#     --help    : display this help message
#     --nozeros : do not map genes with zero transcription values
#
#     -f : do not prompt before overwriting files
#     -i : prompt before overwriting files (default)
#     -n : do not overwrite files
#
#     If conflicting options are given, the last option given takes effect.
#
# ARGUMENTS:
#     CSV_FILE           : filepath of the CSV file containing gene
#                          transcription and gene binding data
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

# get the help message from another file
HELP_MESSAGE=$(cat ~/.genetic-heatmaps/resources/HELP_MESSAGE)

HELP_PROMPT="See 'heatmap --help' for usage notes."

# output a single option flag and the total number of option flags within a
# given list of arguments
parse_options() {
    # ABSTRACT : Outputs a single option flag and the total number of option
    #            flags within a given list of arguments. The list of valid
    #            option flags and the logic for determining precedence between
    #            multiple option flags is hard-coded.
    #
    # USAGE    : parse_options HELP_VAR OMIT_VAR OW_VAR COUNT_VAR PARSE_ARGS...
    #
    # ARGUMENTS:
    #     HELP_VAR      : variable name that will be given to the help boolean
    #     OMIT_VAR      : variable name that will be given to the nozeros
    #                     boolean
    #     OW_VAR        : variable name that will be given to the overwrite flag
    #     COUNT_VAR     : variable name that will be given to the total number
    #                     of option arguments
    #     PARSE_ARGS... : list of arguments to be parsed

    # set default option values
    local help_val=false
    local omit_val=false
    local ow_val="i"

    local count=0

    # set local references to given variable names
    local __help_var="$1"
    local __omit_var="$2"
    local __ow_var="$3"
    local __count_var="$4"
    # shift function arguments so that $1 refers to the first argument to be
    # parsed
    shift 4

    # iterate through PARSE_ARGS to determine long-form options
    local opt_phrase
    for arg in "$@"; do
        if [[ "${arg:0:1}" == "-" ]]; then
            if [[ "${arg:0:2}" == "--" ]]; then
                # long-form option parsing
                # strip leading dashes
                opt_phrase="${arg:2:${#arg}-2}"
                # determine long-form option
                case $opt_phrase in
                    help)
                        # set help values and exit function
                        help_val=true
                        count=$((count+1))
                        eval $__help_var="'$help_val'"
                        eval $__omit_var="'$omit_val'"
                        eval $__ow_var="'$ow_val'"
                        eval $__num_var="'$num'"
                        return
                        ;;
                    nozeros)
                        omit_val=true
                        ;;
                    \?)
                        # exit program with error on invalid option
                        echo "ERROR: Invalid option (--$opt_phrase)" >&2
                        echo "$HELP_PROMPT"
                        exit 1
                        ;;
                esac
            else
                # short-form option parsing
                # strip leading dash
                opt_phrase="${arg:1:${#arg}-1}"
                # iterate through every character in the short-form phrase
                local opt_char
                for ((char_ind=0; char_ind < ${#opt_phrase}; char_ind++)); do
                    opt_char="${opt_phrase:$char_ind:1}"
                    case $opt_char in
                        f)
                            ow_val="f"
                            ;;
                        i)
                            ow_val="i"
                            ;;
                        n)
                            ow_val="n"
                            ;;
                        \?)
                            # exit program with error on invalid option
                            echo "ERROR: Invalid option (-$OPTARG)" >&2
                            echo "$HELP_PROMPT"
                            exit 1
                            ;;
                    esac
                done
            fi
        else
            # break on first non-option argument
            break
        fi
        count=$((count+1))
    done

    # set output variables
    eval $__help_var="'$help_val'"
    eval $__omit_var="'$omit_val'"
    eval $__ow_var="'$ow_val'"
    eval $__count_var="'$count'"
}

# NUM_OPTS = (index of first non-option argument) - 1
parse_options help_opt omit_opt ow_opt OPT_COUNT "$@"

# output help message and exit program if user typed "--help"
if $help_opt; then
    echo "$HELP_MESSAGE"
    exit
fi

# remove the option flags from the list of positional arguments
# $1 refers to the input filepath and not the first option flag
shift $OPT_COUNT

# check that the number of arguments is valid
if ! [[ $# -eq 5 || $# -eq 6 ]]; then
    echo "ERROR: Invalid number of arguments" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# check that the input file is a valid file
if ! [[ -f $1 ]]; then
    if ! [[ -e $1 ]]; then
        echo "ERROR: Input file does not exist ($1)" >&2
    else
        echo "ERROR: Invalid input file ($1)" >&2
    fi
    echo "$HELP_PROMPT"
    exit 1
else
    input_path="$1"
fi

# determine whether to map genes with zero transcription values
if $omit_opt; then
    include_zeros="FALSE"
else
    include_zeros="TRUE"
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
        echo "ERROR: Binding max () is not greater than 0" >&2
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

# check that the transcription output file does not exist
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

# check that the binding output file does not exist
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

# pass validated arguments to heatmap-generator.r
~/.genetic-heatmaps/heatmap-generator.r "$input_path" "$include_zeros" \
    "$transcription_min" "$transcription_max" "$binding_max" \
    "$transcription_path" "$binding_path"
