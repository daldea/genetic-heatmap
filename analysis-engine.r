#!/usr/bin/env Rscript

#===============================================================================
# TITLE    : analysis-engine.r
# ABSTRACT : An R script that combines RNA-seq data files and BETA gene lists to
#            generate combined gene activity TSV files
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-10
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ./analysis-engine.r RNA_PATH BETA_PATH WINDOW_SIZE OUTPUT_PATH
#
# ARGUMENTS:
#
#     RNA_PATH      : filepath of the file containing RNA-seq data
#     BETA_PATH     : filepath of the file containing BETA data
#     WINDOW_SIZE   : number of genes to be summed to calculate a binding score
#     OUTPUT_PATH   : filepath where the gene activity TSV file will be saved
#===============================================================================

# store command line arguments into a list with given names and convert numeric
# strings to doubles
store_arguments <- function(name_vector) {
    # store command line arguments in a list
    argument_list <- as.list(commandArgs(trailingOnly = TRUE))
    for (index in c(1:length(argument_list))) {
        # if argument is a numeric string, convert it to double
        if (suppressWarnings(!is.na(as.double(argument_list[index])))) {
            argument_list[index] <- as.double(argument_list[index])
        }
    }
    names(argument_list) <- name_vector
    return(argument_list)
}

# read arguments from command line
argument_names <- c("rna_path", "beta_path", "window_size", "output_path")
args <- store_arguments(argument_names)

# read RNA-seq data from TSV file
rna_frame <- read.delim(args[["rna_path"]], header = FALSE)
colnames(rna_frame) <- c("gene_name", "transcription_score")

# read BETA data from TSV file
beta_frame <- read.delim(args[["beta_path"]], header = FALSE)
beta_vector <- beta_frame[[ncol(beta_frame)]]

# calculate binding flags from case-insensitive match vector
match_vector <- toupper(rna_frame[["gene_name"]]) %in% toupper(beta_vector)
match_vector <- as.numeric(match_vector)
rna_frame[["binding_flag"]] <- match_vector

# TODO: calculate binding scores from binding flags and window size
#       (write function)

# TODO: extract output frame from input frame
#       (copy function from heatmap-engine.r)

# TODO: write output frame to output TSV
