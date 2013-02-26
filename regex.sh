#!/bin/bash

##
# title           : regex.sh
# description     : This script provides helper functions for
#                   creating or manipulating regular expressions.
# author          : Almir Kadric
# created on      : 2012-11-22
# version         : 0.1
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