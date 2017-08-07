#!/bin/bash

#===============================================================================
# TITLE    : help-interface.sh
# ABSTRACT : A BASH script that displays help messages
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-06-29
#
# LICENSE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ghmtools help           : display a list of operations
#     ghmtools help OPERATION : display the help message for a given operation
#===============================================================================

# exit program with error if any command returns an error
set -e

HELP_PROMPT="Type 'ghmtools help' for usage notes."

# check that only 0 or 1 arguments were passed
if ! [[ $# -le 1 ]]; then
    echo "ERROR: Invalid number of arguments" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

if [[ $1 ]]; then
    filename=$1
else
    # if no particular help message was requested, display a list of operations
    filename="operations"
fi

# search for help message in HELP directory
filepath=~/.genetic-heatmaps/HELP/$filename

# check that help message exists
if ! [[ -f $filepath ]]; then
    echo "ERROR: Invalid operation ($filename)" >&2
    echo "$HELP_PROMPT"
    exit 1
fi

# display help message
cat $filepath
