#!/bin/bash

#===============================================================================
# TITLE    : terminal-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to "heatmap-generator.r"
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-06-26
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#     heatmaps [OPTIONS] CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE
#         BINDING_FILE
#
# OPTIONS:
#     --help      : display this help message
#     --omitzeros : do not map genes with zero transcription values
#     
#     -f : do not prompt before overwriting files
#     -i : prompt before overwriting files (default)
#     -n : do not overwrite files
#
#     If multiple conflicting options are given, only the final option takes effect.
#
# ARGUMENTS:
#     CSV_FILE           : filepath of the csv file containing gene
#                          transcription and gene binding data
#     LOWER_BOUND        : minimum value on the gene transcription scale
#     UPPER_BOUND        : maximum value on the gene transcription scale
#     TRANSCRIPTION_FILE : filepath where the gene transcription heatmap will be
#                          saved
#     BINDING_FILE       : filepath where the gene binding heatmap will be saved
#===============================================================================

HELP_MESSAGE=$(cat <<'__END_HEREDOC'
USAGE:
    heatmaps [OPTIONS] CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE
        BINDING_FILE

OPTIONS:
    -f : do not prompt before overwriting files
    -i : prompt before overwriting files (default)
    -n : do not overwrite files

    If multiple options are given, only the final option takes effect.

ARGUMENTS:
    CSV_FILE           : filepath of the csv file containing gene
                         transcription and gene binding data
    LOWER_BOUND        : minimum value on the gene transcription scale
    UPPER_BOUND        : maximum value on the gene transcription scale
    TRANSCRIPTION_FILE : filepath where the gene transcription heatmap will be
                         saved
    BINDING_FILE       : filepath where the gene binding heatmap will be saved
__END_HEREDOC
)

HELP_PROMPT="Type \"heatmap --help\" for usage notes."

# output a single option flag and the total number of option flags within a
# given list of arguments
parse_options() {
    # ABSTRACT  : Outputs a single option flag and the total number of option
    #             flags within a given list of arguments. The list of valid
    #             option flags and the logic for determining precedence between
    #             multiple option flags is hard-coded.
    #
    # USAGE     : parse_options FLAG_VAR NUM_VAR PARSE_ARGS...
    #
    # ARGUMENTS :
    #     FLAG_VAR      : variable name that will be given to the selected
    #                     option flag
    #     NUM_VAR       : variable name that will be given to the total number
    #                     of option flags
    #     PARSE_ARGS... : list of arguments to be parsed

    # set local references to given variable names
    local __flag_var="$1"
    local __num_var="$2"

    # shift function arguments so that $1 refers to the first argument to be
    # parsed
    shift 2

    # determine whether user typed "--help"
    if [[ $1 == "--help" ]]; then
        local flag='help'
        # store flag value in FLAG_VAR
        eval $__flag_var="'$flag'"

        local num=1
        # store num value in NUM_VAR
        eval $__num_var="'$num'"

        # do not parse options, exit function
        return
    fi

    # default option: prompt before overwriting an existing file
    local flag="i"

    # interpret options for whether to overwrite an existing file
    # if conflicting options are given, the final option takes precedence
    while getopts ":fin" flags; do
        case $flags in
            f)
                local flag="f"
                ;;
            i)
                local flag="i"
                ;;
            n)
                local flag="n"
                ;;
            \?)
                # exit program with error on invalid option
                echo "ERROR: Invalid option (-$OPTARG)" >&2
                echo "$HELP_PROMPT"
                exit 1
                ;;
        esac
    done

    # store flag value in FLAG_VAR
    eval $__flag_var="'$flag'"

    local num=$((OPTIND-1))
    # store num value in NUM_VAR
    eval $__num_var="'$num'"
}

# store selected option flag in $option and number of options in $num_opts
parse_options option NUM_OPTS "$@"

# output help message and exit program if user typed "--help"
if [[ $option == "help" ]]; then
    echo "$HELP_MESSAGE"
    exit
fi

# remove the option flags from the list of positional arguments
# $1 refers to the input filepath and not the first option flag
shift $NUM_OPTS

# check that the number of arguments is valid
if ! [[ $# -eq 5 ]]; then
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

# regular expression to detect positive and negative integers and doubles
signed_double_re='^[+-]?[0-9]*([.][0-9]+)?$'

# check that the lower bound is a number
if ! [[ $2 =~ $signed_double_re ]]; then
    echo "ERROR: Lower bound is not a number ($2)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# check that the upper bound is a number
if ! [[ $3 =~ $signed_double_re ]]; then
    echo "ERROR: Upper bound is not a number ($3)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# check that the lower bound is less than the upper bound
if ! [[ $(echo "$2 < $3" | bc) -eq 1 ]]; then
    echo "ERROR: Lower bound is not less than upper bound." >&2
    echo "$HELP_PROMPT"
    exit 1
else
    lower_bound="$2"
    upper_bound="$3"
fi

# check that the transcription output file does not exist
if [[ -e $4 ]]; then
    # if it does exist, check option to determine whether to prompt user
    case $option in
        f)
            # do not prompt user, overwrite file
            transcription_path="$4"
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
                transcription_path="$4"
            fi
            ;;
        n)
            # do not prompt user, do not overwrite, exit program with error
            echo "ERROR: A file already exists at $4" >&2
            echo "$HELP_PROMPT"
            exit 1
            ;;
        \?)
            # exit program with error on invalid option
            echo "ERROR: Invalid option (-$option)" >&2
            echo "$HELP_PROMPT"
            exit 1
            ;;
    esac
else
    transcription_path="$4"
fi

# check that the binding output file does not exist
if [[ -e $5 ]]; then
    # if it does exist, check option to determine whether to prompt user
    case $option in
        f)
            # do not prompt user, overwrite file
            binding_path="$5"
            ;;
        i)
            # prompt user
            echo "A file already exists at $5"
            read -p "Type y to overwrite that file, type n to exit: " yn
            if ! [[ $yn == "y" || $yn == "Y" ]]; then
                # do not overwrite file, exit program
                exit
            else
                # overwrite file
                binding_path="$5"
            fi
            ;;
        n)
            # do not prompt user, do not overwrite, exit program with error
            echo "ERROR: A file already exists at $5" >&2
            echo "$HELP_PROMPT"
            exit 1
            ;;
        \?)
            # exit program with error on invalid option
            echo "ERROR: Invalid option (-$option)" >&2
            echo "$HELP_PROMPT"
            exit 1
            ;;
    esac
else
    binding_path="$5"
fi

# pass validated arguments to heatmap-generator.r
~/.genetic-heatmaps/heatmap-generator.r "$input_path" "$lower_bound" \
    "$upper_bound" "$transcription_path" "$binding_path"
