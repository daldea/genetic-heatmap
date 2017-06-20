#!/usr/bin/env Rscript

#===============================================================================
# TITLE    : heatmap-generator.r
# ABSTRACT : An R script that creates gene transcription and gene binding
#            heatmaps from CSV files.
# 
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-06-19
#
# LICENCE  : MIT <https://opensource.org/licenses/MIT>
#===============================================================================

# save the default warning option
default_warn <- getOption("warn")

# suppress warnings when loading packages
options(warn = -1)
library(ggplot2)
library(svglite)
options(warn = default_warn)

# height and width of images in centimeters
image_dimensions <- c(5, 15)

# remove axis labels, lines, tick marks, padding and whitespace
minimal_theme <- theme(plot.margin = unit(c(0, 0, -0.5, -0.5), "line"),
                       axis.text   = element_blank(),
                       axis.ticks  = element_blank(),
                       axis.title  = element_blank())

# color scale for transcription heatmap
blue_white_red_scale <- scale_fill_gradient2(low      = "blue",
                                             mid      = "white",
                                             high     = "red",
                                             midpoint = 0,
                                             guide    = "colourbar")

# color scale for binding heatmap
black_yellow_scale <- scale_fill_gradient(low   = "black",
                                          high  = "yellow",
                                          guide = "colourbar")

# save a plot with a given scale, theme and dimensions (cm) to a given file
draw_heatmap <- function(ggplot, legend_label, fill_scale, theme,
                         dimension_vector, filepath) {
    map <- ggplot + geom_raster() +
                    scale_x_continuous(expand = c(0,0)) +
                    scale_y_continuous(expand = c(0,0)) +
                    fill_scale +
                    labs(fill = legend_label) +
                    theme
    ggsave(filepath,
           plot   = map,
           width  = dimension_vector[2],
           height = dimension_vector[1])
}

# append a column of meaningless y values to a data frame
# reference: <https://stackoverflow.com/a/21911221>
expand_grid_df <- function(...) {
    Reduce(function(...) merge(..., by = NULL), list(...))
}

# generate a copy of a data frame in which all values in a given column greater
# than a given max are set to max and all values less than a given min are set
# to min
flatten_outliers <- function(data, test_column, min, max, selected_columns) {
    # copy data into a local variable so that original data is not modified
    modified_data <- data
    # iterate through every row in data frame
    for (row_index in c(1:nrow(modified_data))) {
        # flatten data in test column (set outliers to min or max)
        if (modified_data[row_index, test_column] < min) {
            modified_data[row_index, test_column] <- min
        } else if (modified_data[row_index, test_column] > max) {
            modified_data[row_index, test_column] <- max
        }
    }
    # create a subset using selected columns
    modified_data <- subset(modified_data, select = selected_columns)
    # sort in ascending order by test column
    modified_data <- modified_data[order(test_column)]
    # reorder row names
    row.names(modified_data) <- NULL
    return(modified_data)
}

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
argument_names <- c("csv_path", "lower_bound", "upper_bound",
                    "transcription_path", "binding_path")
args <- store_arguments(argument_names)

# read data from CSV
# first column -> transcription data, second column -> binding data
gene_data <- read.csv(args[["csv_path"]], header = TRUE)

# store given column names in order to label legends
legend_labels <- colnames(gene_data)
names(legend_labels) <- c("transcription", "binding")

# standardize column names
# first column -> "transcription", second column -> "binding"
colnames(gene_data) <- c("transcription", "binding")

# filter transcription data from gene data
transcription_data <- flatten_outliers(gene_data, "transcription",
                                       args[["lower_bound"]],
                                       args[["upper_bound"]],
                                       c("transcription"))
transcription_data$x_data <- attr(transcription_data, "row.names") - 1
# append meaningless y values (-1, 0 and 1) to every x value
transcription_data <- expand_grid_df(transcription_data,
                                     data.frame(y_data = -1:1))

# filter binding data from gene data
binding_data <- flatten_outliers(gene_data, "transcription",
                                 args[["lower_bound"]], args[["upper_bound"]],
                                 c("binding"))
binding_data$x_data <- attr(binding_data, "row.names") - 1
# append meaningless y values (-1, 0 and 1) to every x value
binding_data <- expand_grid_df(binding_data, data.frame(y_data = -1:1))

# map transcription data
transcription_map <- ggplot(transcription_data,
                            aes(x = x_data, y = y_data, fill = transcription))
draw_heatmap(transcription_map, legend_labels["transcription"],
             blue_white_red_scale, minimal_theme, image_dimensions,
             filepath = args[["transcription_path"]])

# map binding data
binding_map <- ggplot(binding_data, aes(x = x_data, y = y_data, fill = binding))
draw_heatmap(binding_map, legend_labels["binding"], black_yellow_scale,
             minimal_theme, image_dimensions, filepath = args[["binding_path"]])
