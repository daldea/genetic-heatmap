#!/bin/bash

#===============================================================================
# TITLE    : terminal-interface.sh
# ABSTRACT : A BASH script that matches the operation argument to an interface
#            and passes the following arguments to that interface
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-06-29
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ghmtools OPERATION [OPTIONS] ARGUMENTS :
#         execute a given operation with given options and arguments
#
#     ghmtools help :
#         display a list of operations
#
#     ghmtools help OPERATION :
#         display the help message for a particular operation
#
# OPERATIONS:
#
#     analysis : create gene actitity TSV files from RNA-seq and ChIP-seq data
#                files
#     heatmaps : create gene transcription and gene binding heatmaps from gene
#                activity TSV files
#-------------------------------------------------------------------------------
# ALIAS PROGRESSION:
#     1. ~/.genetic-heatmaps/terminal-interface.sh OPERATION [OPTIONS] ARGUMENTS
#     2. ~/.genetic-heatmaps/OPERATION-interface.sh [OPTIONS] ARGUMENTS
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'gmtools help' for usage notes."

# remove operation name from command line arguments
operation=$1; shift

# replace '--help' operation with 'help' operation
if [[ $operation == "--help" ]]; then
    operation="help"
fi

# parse operation interface
interface=~/.genetic-heatmaps/${operation}-interface.sh

# ensure operation interface exists
# prevent recursive references
if ! [[ -f $interface && $operation != "terminal" ]]
then
    echo "ERROR: Invalid operation ($operation)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# pass all arguments (except operation name) to operation interface
eval "$interface $@"
