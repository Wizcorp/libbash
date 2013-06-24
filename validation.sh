#!/bin/bash

##
# title           : validation.sh
# description     : This script provides helper functions for data, input and
#                   setup validation.
# author          : Almir Kadric
# created on      : 2012-12-12
# version         : 0.1
##

# Get script root path, symlink resistant
scriptRoot=$(cd "$(dirname ${BASH_SOURCE})" && pwd);
if [ -h ${BASH_SOURCE} ] 
then
    scriptRoot=$(cd "$(dirname $(readlink ${BASH_SOURCE}))" && pwd);
fi

# Include required libraries
. ${scriptRoot}/bashr.sh


##
# Takes in a space separated list of command which should be expected. If anyone
# one of the listed commands are found to not exist, an error will thrown for
# that command. And once all commands are processed, if any were found missing
# function will exit with status code of 1 and return those missing command names
# in a predefined array called notFoundCommands.
# 
# Commands can be scripts, system binaries etc. found in $PATH or functions
#
# Usage: EnsureCommandsAvailable command1 [command2] [...]
#
# Arguments:
#     commands: space separated list of commands which to test for
#
# Environment Variables:
#   notFoundCommands: Array list of commands which could not be found.
#
#       SILENT_ERROR: (BOOLEAN) Whether or not an error should be written to
#                     STDERR when a command is not found. This is useful if you
#                     want to display a custom error message, or handle it in a
#                     different fashion.
##
function EnsureCommandsAvailable() {
    # Define returned environment variables
    eval notFoundCommands=();

    # Define required variables
    commands="$@";
    errors=false;

    # Iterate through commands
    for command in ${commands}
    do
        # Check command type
        type $command 2>/dev/null 1>/dev/null;
        status=$?;

        # Check if type casting of command was successful
        if [ $status -ne 0 ]
        then
            # If not silent, output error if command was not found
            if [ "${SILENT_ERROR:-}" = "" ] || ! $SILENT_ERROR
            then
                echoError "Could not find command ${command}";
            fi

            eval notFoundCommands+=(${command});
            errors=true;
        fi
    done

    # Exit if any commands were not found
    if $errors
    then
        return 1;
    fi
}


##
# Function which takes in a list of arguments and allowed arguments and then
# determines if there are any foreign arguments. If none are found it will then
# store the argument value pairs into variables with argument label and values.
#
# Usage: ParseArguments <allowed> <arguments>
#
# Arguments:
#     allowed: space or comma separated list of allowed arguments. Anything not
#              in this list will be considered foreign and will cause the function
#              to exit with error code 1.
#
#   arguments: list of arguments passed to your application (usually will be $@)
#              which will be tested against allowed values passed. Also these
#              will then be pulled a part and stored into actual variables.
#
# Environment Variables:
#   invalidArguments: Array list of arguments which were invalid.
#
#       SILENT_ERROR: (BOOLEAN) Whether or not an error should be written to
#                     STDERR when a command is not found. This is useful if you
#                     want to display a custom error message, or handle it in a
#                     different fashion.
##
function ParseArguments() {
    # Define returned environment variables
    eval invalidArguments=();

    # Define required variables
    allow="${1:-}";
    errors=false;

    # Remove the first element from arguments
    shift 1

    # Iterate through remaining arguments
    for argument in $@
    do
        label="$(echo $argument | awk -F '=' '{print $1}' | sed 's/^--//')";
        value="$(echo $argument | awk -F '=' '{print $2}')";

        if [ "$(echo ${allow} | egrep "(^|[,\ ])${label}([,\ ]|$)")" = "" ]
        then
            if [ "$SILENT_ERROR" = "" ] || ! $SILENT_ERROR
            then
                echoError "Unrecognized argument --${label}";
            fi

            eval invalidArguments+=(${label});
            errors=true;
        else
            eval "export ${label}='${value}'";
        fi
    done

    # Exit if any commands were not found
    if $errors
    then
        return 1;
    fi
}
