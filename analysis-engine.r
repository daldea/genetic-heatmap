#!/usr/bin/env Rscript

#===============================================================================
# TITLE    : analysis-engine.r
# ABSTRACT : An R script that combines RNA-seq data files and BETA gene lists to
#            generate combined gene activity TSV files
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-07-12
#
# LICENSE  : MIT <https://opensource.org/licenses/MIT>
#-------------------------------------------------------------------------------
# USAGE:
#
#     ./analysis-engine.r <rna-path> <beta-path> <window-size> <output-path>
#
# DESCRIPTION:
#
#     <rna-path>      : filepath of the file containing RNA-seq data
#     <beta-path>     : filepath of the file containing BETA data
#     <window-size>   : number of genes used to calculate a binding score
#     <output-path>   : filepath where the gene activity TSV file will be saved
#===============================================================================

# store command line arguments into a list with given names and convert numeric
# strings to doubles
store_arguments <- function(name_vector) {
    # store command line arguments in a list
    argument_list <- as.list(commandArgs(trailingOnly = TRUE))
    for (index in 1:length(argument_list)) {
        # if argument is a numeric string, convert it to double
        if (suppressWarnings(!is.na(as.double(argument_list[index])))) {
            argument_list[index] <- as.double(argument_list[index])
        }
    }
    names(argument_list) <- name_vector
    return(argument_list)
}

# generate a vector of window sums of a given size in a given numeric vector
sum_windows <- function(addend_vector, window_size) {
    upper_index <- length(addend_vector)
    # pre-allocate the sum vector (same length as addend column) to reduce
    # calculation time
    sum_vector <- numeric(upper_index)
    # append first window sum to sum vector
    sum_vector[1] <- sum(addend_vector[1:window_size])
    # calculate complete window sums using rolling algorithm
    for (index in 2:upper_index) {
        window_sum <- sum_vector[index - 1] - addend_vector[index - 1]
        if ((index - 1) + window_size <= upper_index) {
            window_sum <- window_sum + addend_vector[(index - 1) + window_size]
        }
        sum_vector[index] <- window_sum
    }
    return(sum_vector)
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

# calculate binding scores from binding flags and window size
score_vector = sum_windows(rna_frame[["binding_flag"]], args[["window_size"]])
rna_frame[["binding_score"]] <- score_vector

# extract output frame from input frame
output_columns <- c("gene_name", "transcription_score", "binding_score")
output_frame <- rna_frame[output_columns]

# write output frame to output TSV
write.table(output_frame, file = args[["output_path"]], quote = FALSE,
            sep = "\t", row.names = FALSE, col.names = FALSE)
