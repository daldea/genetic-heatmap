#!/usr/bin/env python3

"""
TITLE    : option-parser.py
ABSTRACT : A Python script that parses options and determines the index of the
           first non-option argument in a list of arguments. The option data is
           saved as a JSON file. The list of valid option flags and the logic
           for reading option values is passed to the script along with the
           arguments to be parsed.

AUTHOR   : Dennis Aldea <dennis.aldea@gmail.com>
DATE     : 2017-07-03
LICENCE  : MIT <https://opensource.org/licenses/MIT>
--------------------------------------------------------------------------------
USAGE: ./option-parser.py (FLAG [RULE])... -- PARSE_ARGS... -- JSON_FILE

    FLAG       : a option flag to search for in PARSE_ARGS
    RULE       : a rule by which to assign values to option flags (optional)
                     flag (default) : assign true if FLAG is in PARSE_ARGS
                                      assign false is FLAG is not in PARSE_ARGS
                     value          : assign the argument following FLAG if FLAG
                                        is in PARSE_ARGS
                                      assign null if FLAG is not in PARSE_ARGS
    PARSE_ARGS : list of arguments to be parsed
    JSON_FILE  : filepath where the option data will be saved
"""

import sys
import json

# argument that separates option metadata from parsing data from JSON filepath
SEPARATOR = "--"
# list of valid metadata tags
TAGS = ["flag", "value"]

"""
Prints to stderr
"""
def print_error(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

"""
Separates a list into a given number of groups by splitting at a given separator
"""
def separate_arguments(arguments, separator, num_groups=2):
    argument_groups = []
    argument_group = []
    for argument in arguments:
        if len(argument_groups) >= num_groups:
            # stop once the number of groups reaches num_groups
            break
        if argument == separator:
            # store current argument group
            argument_groups.append(argument_group)
            # continue with a new argument group
            argument_group = []
        else:
            # add non-separator argument to current argument group
            argument_group.append(argument)
    # store final argument group
    argument_groups.append(argument_group)
    if len(argument_groups) != num_groups:
        # exit program with error on invalid number of argument groups
        print_error("ERROR: Invalid option parsing separation")
        sys.exit(1)
    return argument_groups

"""
Creates a dictionary of option flag metadata (valid option flags and associated
rules) by parsing command line arguments
"""
def read_metadata(flag_group, valid_tags):
    flag_metadata = {}
    for index in range(len(flag_group)):
        # do not seach for a tag on a tag
        if flag_group[index][0] != "-":
            continue
        flag = flag_group[index]
        if flag[0:2] != "--" and len(flag) != 2:
            # exit program with error on invalid flag
            print_error("ERROR: Invalid option parsing flag ({})".format(flag))
            sys.exit(1)
        # search for a tag on a flag
        if index == len(flag_group) - 1:
            # assume "flag" tag if final tag is not given
            tag = "flag"
        else:
            # read next argument
            if flag_group[index + 1][0] != "-":
                # set tag to next argument if next argument is not a flag
                tag = flag_group[index + 1]
            else:
                # assume "flag" tag if next argument is a flag
                tag = "flag"
        tag = tag.lower()
        if not tag in valid_tags:
            # exit program with error on invalid tag
            print_error("ERROR: Invalid option parsing tag ({})".format(tag))
            sys.exit(1)
        # append flag (key) and tag (value) to flags
        flag_metadata[flag] = tag
    return flag_metadata

"""
Expands short-form combined option phrases into a list of short-form flags
within a given list of arguments
"""
def expand_short_flags(command_group):
    for index in range(len(command_group)):
        if (command_group[index][0] == "-" and
            command_group[index][0:2] != "--" and
            not command_group[index][1].isdigit()):
                # short-form flag expansion
                phrase = command_group[index]
                flags = ["-" + character for character in phrase[1:]]
                # merge list of short-form flags into command_group
                command_group = (command_group[:index] + flags +
                                 command_group[index + 1:])
    return command_group

"""
Creates a dicitionary of option values by parsing a list of arguments and a
dictionary of option flag metadata
"""
def parse_options(command_group, flag_metadata):
    option_data = {flag: None for flag in flag_metadata}
    command_group = expand_short_flags(command_group)
    for index in range(len(command_group)):
        if not command_group[index] in option_data:
            # do not parse arguments
            continue
        flag = command_group[index]
        # determine option type
        if flag_metadata[flag] == "flag":
            value = True
        elif flag_metadata[flag] == "value":
            if (command_group[index + 1][0] == "-" and
                not command_group[index + 1][1].isdigit()):
                    # exit program with error on missing option value
                    print_error("ERROR: No option value ({})".format(flag))
                    sys.exit(1)
            value = command_group[index + 1]
        # store option value
        option_data[flag] = value
    # replace "None" with "False" for "flag" options
    for flag in option_data:
        if option_data[flag] == None and flag_metadata[flag] == "flag":
            option_data[flag] = False
    return option_data

"""
Determines the zero-based index of the first non-option argument in a given list
of arguments
"""
def locate_first_argument(command_group, flag_metadata):
    for index in range(len(command_group)):
        if command_group[index][0] != "-":
            if command_group[index - 1] in flag_metadata:
                if flag_metadata[command_group[index - 1]] != "value":
                    return index
            else:
                return index
    return None

"""
Converts an option flag to a BASH variable name by removing leading dashes and
replacing inner dashes with underscores.
"""
def format_bash_variable_name(name):
    dash_count = 0
    # count the number of leading dashes
    for index in range(len(name)):
        if name[index] == "-":
            dash_count += 1
        else:
            break
    # create a substring that excludes the leading dashes
    name = name[dash_count:]
    # replace inner dashes with underscores
    for index in range(len(name)):
        if name[index] == "-":
            name[index] = "_"
    return name

"""
Converts a Python value to a BASH value by translating reserved words.
"""
def format_bash_variable_value(value):
    # determine if the value is a boolean value
    if str(value).lower() == "true" or str(value).lower() == "false":
        value = str(value).lower()
    return value

"""
Writes a dictionary in a BASH-readable format to a given filepath
"""
def write_bash_config(option_data, filepath):
    with open(filepath, "w") as config_file:
        for flag in option_data:
            variable_name = format_bash_variable_name(flag)
            variable_value = format_bash_variable_value(option_data[flag])
            command = "{}={}\n".format(variable_name, variable_value)
            config_file.write(command)

def main():
    # do not include program name in the list of arguments
    arguments = sys.argv[1:]
    argument_groups = separate_arguments(arguments, SEPARATOR, num_groups=3)
    flag_metadata = read_metadata(argument_groups[0], TAGS)
    option_data = parse_options(argument_groups[1][:], flag_metadata)
    option_data["ARG_INDEX"] = locate_first_argument(argument_groups[1],
                                                     flag_metadata) + 1
    config_filepath = argument_groups[2][0]
    write_bash_config(option_data, config_filepath)

if __name__ == "__main__":
    main()
