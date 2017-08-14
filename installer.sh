#!/bin/bash

#===============================================================================
# TITLE    : installer.sh
# ABSTRACT : A BASH script that installs Genetic Heatmap Tools for a single user
#
# AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
# DATE     : 2017-08-14
#
# LICENSE  : MIT <https://opensource.org/licenses/MIT>
#==============================================================================+

# Download the repository
wget https://github.com/dennisaldea/genetic-heatmaps/archive/master.tar.gz

# Extract the TAR archive
tar -xzvf master.tar.gz
rm master.tar.gz

# Move the extracted files to the '~/.genetic-heatmaps' directory.
mkdir ~/.genetic-heatmaps
mv -T genetic-heatmaps-master ~/.genetic-heatmaps

# Mark the code files as executable.
cd ~/.genetic-heatmaps
chmod 755 *
chmod 644 README.md LICENSE HELP/*

# Make a symbolic link to the terminal interface in the `~/bin` directory.
ln -s ~/.genetic-heatmaps/terminal-interface.sh ~/bin/ghmtools
