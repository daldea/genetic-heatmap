#!/usr/bin/env Rscript

#===============================================================================
# TITLE    : analysis-engine.r
# ABSTRACT : An R script that combines RNA-seq files and ChIP-seq gene lists to
#            generate combined gene activity CSV files
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-06
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ./analysis-engine.r RNA_PATH CHIP_PATH WINDOW_SIZE OUTPUT_PATH
#
# ARGUMENTS:
#
#     RNA_PATH      : filepath of the file containing RNA-seq data
#     CHIP_PATH     : filepath of the file containing ChIP-seq data (i.e. the
#                     list of bound genes)
#     WINDOW_SIZE   : number of genes to be summed to calculate a binding score
#     OUTPUT_PATH   : filepath where the gene activity CSV file will be saved
#===============================================================================

# store command line arguments into a list with given names and convert numeric
# strings to doubles
store_arguments <- function(name_vector) {
    # store command line arguments in a list
    argument_list <- as.list(commandArgs(trailingOnly = TRUE))
    # iterate through every argument in argument list
    for (index in c(1:length(argument_list))) {
        # if argument is a numeric string, convert it to double
        if (suppressWarnings(!is.na(as.double(argument_list[index])))) {
            argument_list[index] <- as.double(argument_list[index])
        }
    }
    # name arguments using given name vector
    names(argument_list) <- name_vector
    return(argument_list)
}

# read arguments from command line
argument_names <- c("rna_path", "chip_path", "window_size", "output_path")
args <- store_arguments(argument_names)

# read RNA-seq data from file
rna_data <- read.delim(args[["rna_path"]], header = FALSE)

# read ChIP-seq data from file
chip_data <- read.delim(args[["chip_path"]], header = FALSE)
