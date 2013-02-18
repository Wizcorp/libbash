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
#     allowed: space separated list of allowed arguments. Anything not in this
#              list will be considered foreign and will cause the function to
#              exit with error code 1.
#
#   arguments: list of arguments passed to your application (usually will be $@)
#              which will be tested against allowed values passed. Also these
#              will then be pulled a part and stored into actual variables.
##
function ParseArguments() {
    # Define required variables
    allow="$1";
    arguments="$2";

    # Iterate through arguments
    for argument in ${arguments}
    do
        label="$(echo $argument | awk -F '=' '{print $1}' | sed 's/^--//')";
        value="$(echo $argument | awk -F '=' '{print $2}')";

        if [ "$(echo ${allow} | grep ${label})" = "" ]
        then
            echoError "Unrecognized argument --${label}";
            echoError "Check --help for further usage information";
            return 1;
        else
            eval "export ${label}='${value}'";
        fi
    done
}
