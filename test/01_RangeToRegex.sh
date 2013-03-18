#!/bin/bash

##
# title           : regex.sh
# description     : This script provides helper functions for
#                   unit testing regex helper functions.
# author          : Almir Kadric
# created on      : 2012-11-22
# version         : 0.1
##

# Source regex helper file
source ../regex.sh

##
# Function to test range to regex results for a certain range of numbers. Will
# test all numbers within single range for positive results and all numbers
# outside of range for negative results.
#
# Usage: TestRangeToRegex <range> <test from> <test to>
#
# Arguments:
#       range: Single numeric range i.e. "10-20"
#   test from: start testing from this number.
#     test to: stop testing when reaching this number.
##
function TestRangeToRegex() {
    # Get arguments
    range=$1;
    testFrom=$2;
    testTo=$3;

    # separate from and to in case piece is a range
    from=$(echo ${range} | cut -d '-' -f 1);
    to=$(echo ${range} | cut -d '-' -f 2);

    # Sort from and to and get largest character length
    if [ $from -gt $to ]
    then
        tmp="$from";
        from="$to";
        to="$tmp";
    fi

    # Ensure arguments
    if [ "$range" = "" ] || [ "$testFrom" = "" ] || [ "$testTo" = "" ]
    then
        echo "Usage: TestFalsePositives <range> <test from> <test to>";
        return 1;
    fi

    # Get regex
    regex=$(RangeToRegex $1);

    # Begin testing
    for i in $(seq $from $to)
    do
        if [ $i -lt $from ] || [ $i -gt $to ]
        then
            ret="$(echo "${i}" | egrep "^${regex}$")";
            if [ "$ret" != "" ]
            then
                echo "- FAILURE: false possitive found ($i : $ret)";
            fi
        else
            ret="$(echo "${i}" | egrep "^${regex}$")";
            if [ "$ret" = "" ]
            then
                echo "- FAILURE on true match ($i)";
            fi
        fi

        if [ $(($i % 100)) -eq 0  ]
        then
            echo "$i completed";
            echo "";
        fi
    done
}


##
# Unit test function for RangeToRegex. Uses TestRangeToRegex to test multiple
# known edge cases. Should be added to overtime as edge cases arrise or are
# thought of.
#
# Usage: RangeToRegexUnitTest [<ranges>]
#
# Arguments:
#     ranges: Optional comma separated list of ranges. i.e. "1,5,9,10-20,400-1000"
##
function RangeToRegexUnitTest() {
    # Get ranges from arguments
    if [ "$1" = "" ]
    then
        echo "No regex supplied. Will use default."
        ranges="2-8,2-15,9-15,2-75,8-85,8-95,8-135,24-155,6-2345,45-3455,158-2766"
    else
        ranges=$1
    fi


    # Output ranges passed to function
    echo "Testing range(s):";
    echo "$ranges";
    echo ""


    # Run parsing loop
    for piece in $(echo ${ranges} | sed 's/,/ /g')
    do
        # separate from and to in case piece is a range
        from=$(echo ${piece} | cut -d '-' -f 1);
        to=$(echo ${piece} | cut -d '-' -f 2);

        if [ "$(echo ${piece} | grep '^[0-9][0-9]*$')" != "" ]
        then
            # piece is a number
            echo "Single value test (${piece}):";

            # Test regex
            TestRangeToRegex ${piece} 0 10000
        elif [ "$(echo ${piece} | grep '^[0-9][0-9]*-[0-9][0-9]*$')" != "" ] && [ "${from}" = "${to}" ]
        then
            # piece is a range of the same value
            echo "Single value test (${from}):";

            # Test regex
            TestRangeToRegex ${from} 0 10000
        elif [ "$(echo ${piece} | grep '^[0-9][0-9]*-[0-9][0-9]*$')" != "" ] && [ "${from}" != "${to}" ]
        then
            # piece is a proper range
            echo "Range test (${piece}):";

            # Test regex
            TestRangeToRegex ${piece} 0 10000
        else
            # piece is unkown, fail
            echo "Unkown value (${piece}) in range:";
            echo "${1}";
            exit 1;
        fi

        echo "";
    done
}