#!/bin/bash

#===============================================================================
# TITLE    : analysis-interface.sh
# ABSTRACT : A BASH script that validates command line arguments before passing
#            them to BETA and 'analysis-engine.sh'
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-06-30
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
#     --window [NUMBER] : number of genes to be summed to calculate a binding
#                         score (defaults to 10 if not specified)
#
#     If conflicting options are given, the last option given takes effect.
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
