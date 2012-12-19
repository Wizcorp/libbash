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
if [ -h ${BASH_SOURCE} 
then
    scriptRoot=$(cd "$(dirname $(readlink ${BASH_SOURCE}))" && pwd);
fi

# Include required libraries
. ${scriptRoot}/bashr.sh

##
# Takes in a space separated list of command which should be expected. If anyone
# one of the listed commands are found to not exist, an error will thrown for
# that command. And once all commands are processed, if any were found missing
# function will exit with status code of 1.
# 
# Commands can be scripts, system binaries etc. found in $PATH or functions
#
# Usage: EnsureCommandsAvailable <commands>
#
# Arguments:
#     commands: space separated list of commands which to test for
##
function EnsureCommandsAvailable() {
    # Define required variables
    commands="$@";
    errors=false;

    # Iterate through commands
    for command in ${commands}
    do
        # Check command type
        result=$(type $command);
        status=$?;

        # Check if type casting of command was successful
        if [ $status -ne 0 ]
        then
            # Output error if command was not found
            echoError "Could not find command ${command}";
            errors=true;
        fi
    done

    # Exit if any commands were not found
    if $errors
    then
        exit 1;
    fi
}