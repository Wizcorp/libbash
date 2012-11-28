#!/bin/bash

##
# title           :regex.sh
# description     :This script provides helper functions for
#                  creating or manipulating regular expressions.
# author          :Almir Kadric
# created on      :2012-11-22
# version         :0.1
##


##
# Takes in a comma separated list of numeric reanges which can be
# either a single number or a range <from>-<to>. It will then
# generate a regular expression which will match those ranges.
#
# Usage: RangeToRegex "<ranges>"
#
# Arguments:
#     ranges: comma separated list of numeric ranges. i.e. "1,2,5,10-20,100-200"
##
function RangeToRegex() {
    # Initial regex to start multi selections
    regex="";

    # Function to add 'OR' if required
    function addOr() {
        if [ "${regex}" != "" ]
        then
            regex+="|";
        fi
    }

    # Run parsing loop
    for piece in $(echo ${1} | sed 's/,/ /g')
    do
        # separate from and to in case piece is a range
        from=$(echo ${piece} | cut -d '-' -f 1);
        to=$(echo ${piece} | cut -d '-' -f 2);

        #echo "${piece}:";

        # Attempt to parse single number, range or fail
        if [ "$(echo ${piece} | grep '^[0-9][0-9]*$')" != "" ]
        then
            # piece is a number
            addOr;
            regex+="${piece}";
        elif [ "$(echo ${piece} | grep '^[0-9][0-9]*-[0-9][0-9]*$')" != "" ] && [ "${from}" = "${to}" ]
        then
            # piece is a range of the same value
            addOr;
            regex+="${from}";
        elif [ "$(echo ${piece} | grep '^[0-9][0-9]*-[0-9][0-9]*$')" != "" ] && [ "${from}" != "${to}" ]
        then
            # Sort from and to and get largest character length
            if [ $from -gt $to ]
            then
                tmp="$from";
                from="$to";
                to="$tmp";
            fi

            length=${#to};


            # Create from digit arrays and add leading zeros
            fromArr=();
            for digit in $(echo ${from} | sed 's/\([0-9]\)/\ \1/g')
            do
                fromArr+=("${digit}");
            done

            # Create to digit arrays and add leading zeros
            toArr=();
            for digit in $(echo ${to} | sed 's/\([0-9]\)/\ \1/g')
            do
                toArr+=("${digit}");
            done


            # Generate largest 10(power) regex
            for i in $(seq $(( ${#to} )))
            do
                p=$(( ${#to} - $i ));

                #
                if [ ${#from} -eq ${#to} ] && [ "${from:0:$p}" = "${to:0:$p}" ]
                then
                    continue;

                # if (last digit) and (not equal to 0)
                elif [ $i -eq 1 ] && [ ${toArr[$p]} -ne 0 ]
                then
                    addOr;
                    regex+="${to:0:$p}";
                    regex+="[0-${toArr[$p]}]";

                # if (last digit) and (is equal to 0)
                elif [ $i -eq 1 ] && [ ${toArr[$p]} -eq 0 ]
                then
                    addOr;
                    regex+="${to:0:$p}";
                    regex+="0";

                # if (not last digit) and (not first digit) and (is greater than 1)
                elif [ $i -gt 1 ] && [ $p -ne 0 ] && [ ${toArr[$p]} -gt 1 ]
                then
                    addOr;
                    regex+="${to:0:$p}";
                    regex+="[0-$(( ${toArr[$p]} - 1 ))]";

                    for j in $(seq $(( $i - 1 )) )
                    do
                        regex+="[0-9]";
                    done

                # if (not last digit) and (not first digit) and (equal to 1)
                elif [ $i -gt 1 ] && [ $p -ne 0 ] && [ ${toArr[$p]} -eq 1 ]
                then
                    addOr;
                    regex+="${to:0:$p}";
                    regex+="0";

                    for j in $(seq $(( $i - 1 )) )
                    do
                        regex+="[0-9]";
                    done

                # if (not last digit) and (not first digit) and (equal to 0)
                elif [ $i -gt 1 ] && [ $p -ne 0 ] && [ ${toArr[$p]} -eq 0 ]
                then
                    # Redundant 10(power)
                    continue;

                # if (not last digit) and (first digit) and (greater than 2)
                elif [ $i -gt 1 ] && [ $p -eq 0 ] && [ ${toArr[$p]} -gt 2 ]
                then
                    addOr;
                    regex+="[1-$(( ${toArr[$p]} - 1 ))]";

                    for j in $(seq $(( $i - 1 )) )
                    do
                        regex+="[0-9]";
                    done

                # if (not last digit) and (first digit) and (equal to 2)
                elif [ $i -gt 1 ] && [ $p -eq 0 ] && [ ${toArr[$p]} -eq 2 ]
                then
                    addOr;
                    regex+="1";

                    for j in $(seq $(( $i - 1 )) )
                    do
                        regex+="[0-9]";
                    done

                # if (not last digit) and (first digit) and (equal to 1)
                elif [ $i -gt 1 ] && [ $p -eq 0 ] && [ ${toArr[$p]} -eq 1 ]
                then
                    # Redundant
                    continue;

                # otherwise un-handled case
                else
                    echo "Unhandled exception: Unexpected case in largest power parsing." 1>&2;
                    return 1;
                fi
            done


            # Generate 10(powers) between lowest and highest
            if [ ${#from} -ne ${#to} ]
            then
                # Generate missing 10(powers)
                for i in $(seq $(( ${#from} + 1 )) $(( ${#to} - 1 )))
                do
                    # Generate full range regext for power
                    addOr;
                    regex+="[1-9]";
                    for j in $(seq $(( $i - 1 )))
                    do
                        regex+="[0-9]";
                    done
                done
            else
                # Fill in 10 powers between from and to
                for i in $(seq ${#from})
                do
                    p=$(( ${#from} - $i + 1 ));

                    # if (substring of to and from is equal) and (difference between following character is greater than 2)
                    if [ "${from:0:$p}" = "${to:0:$p}" ] && [ $(( ${toArr[$p]} - ${fromArr[$p]} )) -gt 2 ]
                    then
                        addOr;
                        regex+="${from:0:$p}";
                        regex+="[$(( ${fromArr[$p]} + 1 ))-$(( ${toArr[$p]} - 1 ))]";

                        for i in $(seq $(( ${#from} - $p - 1)))
                        do
                            regex+="[0-9]";
                        done

                    # if (substring of to and from is equal) and (difference between following character is equal to 2)
                    elif [ "${from:0:$p}" = "${to:0:$p}" ] && [ $(( ${toArr[$p]} - ${fromArr[$p]} )) -eq 2 ]
                    then
                        addOr;
                        regex+="${from:0:$p}";
                        regex+="$(( ${fromArr[$p]} + 1 ))";

                        for i in $(seq $(( ${#from} - $p - 1)))
                        do
                            regex+="[0-9]";
                        done
                    fi
                done
            fi


            # Generate lowest 10(power) regex
            lastDigit=$(( ${#from} - 1 ));

            # if to and from in same 10 power range
            if [ $(( ${fromArr[$lastDigit]} - 9 )) -ne 0 ] && [ "${from:0:$(( ${#from} - 1 ))}" = "${to:0:$(( ${#to} - 1 ))}" ]
            then
                addOr;
                regex+="${from:0:$(( ${#from} - 1 ))}";
                regex+="[${fromArr[$lastDigit]}-${toArr[$lastDigit]}]";

            # if (last digit not equal 9) and (from is 100 and above)
            elif [ $(( ${fromArr[$lastDigit]} - 9 )) -ne 0 ] && [ ${#from} -gt 2 ]
            then
                addOr;
                regex+="${from:0:$(( ${#from} - 1 ))}";
                regex+="[${fromArr[$lastDigit]}-9]";


            # if (last digit not equal 9) and (from is the 10s power)
            elif [ $(( ${fromArr[$lastDigit]} - 9 )) -ne 0 ] && [ ${#from} -eq 2 ]
            then
                addOr;
                regex+="${from:0:1}";
                regex+="[${fromArr[$lastDigit]}-9]";

            # if (last digit not equal 9) and (from is less than 10)
            elif [ $(( ${fromArr[$lastDigit]} - 9 )) -ne 0 ] && [ ${#from} -eq 1 ]
            then
                addOr;
                regex+="[${fromArr[$lastDigit]}-9]";

            # if (last digit equal to 9)
            elif [ $(( ${fromArr[$lastDigit]} - 9 )) -eq 0 ]
            then
                addOr;
                regex+="${from}";

            # otherwise un-handled case
            else
                echo "Unhandled exception: Unexpected case in lowest power parsing." 1>&2;
                return 1;
            fi

            # Complete lowest power
            for i in $(seq $(( ${#from} - 1 )))
            do
                p=$(( ${#from} - $i - 1 ));

                # if (from and 2 in same power) and (from and to leading substring is equal)
                if [ ${#from} -eq ${#to} ] && [ "${from:0:$p}" = "${to:0:$p}" ]
                then
                    continue;

                # if (digit is less than 8)
                elif [ ${fromArr[$p]} -lt 8 ]
                then
                    addOr;
                    regex+="${from:0:$p}";
                    regex+="[$(( ${fromArr[$p]} + 1 ))-9]";

                    for j in $(seq $(( $i )) )
                    do
                        regex+="[0-9]";
                    done

                # if (digit is equal to 8)
                elif [ ${fromArr[$p]} -eq 8 ]
                then
                    addOr;
                    regex+="${from:0:$p}";
                    regex+="9";

                    for j in $(seq $i)
                    do
                        regex+="[0-9]";
                    done

                # if (digit is equal to 9)
                elif [ ${fromArr[$p]} -eq 9 ]
                then
                    continue;

                # otherwise un-handled case
                else
                    echo "Unhandled exception: Unexpected case in lowest power parsing." 1>&2;
                    return 1;
                fi
            done
        else
            # piece is unkNown, fail
            echo "Unkown value (${piece}) in range:" 1>&2;
            echo "${1}" 1>&2;
            return 1;
        fi
    done

    # Echo regex
    echo "$(echo ${regex})";
}


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