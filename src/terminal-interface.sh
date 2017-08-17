#!/bin/bash

#===============================================================================
# TITLE    : terminal-interface.sh
# ABSTRACT : A BASH script that matches the operation argument to an interface
#            and passes the following arguments to that interface
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-13
#
# LICENSE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# SYNOPSIS:
#
#     ghmtools <operation> [<option>...] [--] <argument>... : execute an
#                                                             operation
#     ghmtools help                                         : display a list of
#                                                             operations
#     ghmtools help <operation>                             : display the help
#                                                             message for an
#                                                             operation
#
# OPERATIONS:
#
#     analysis : create gene actitity TSV files from RNA-seq and ChIP-seq data
#                files
#     heatmap  : create gene transcription and gene binding heatmaps from gene
#                activity TSV files
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'ghmtools help' for usage notes"

# if no arguments were given, assume 'help' operation
if [ -z "$1" ]; then
    operation="help"
else
    # remove operation name from command line arguments
    operation=$1; shift
fi

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
