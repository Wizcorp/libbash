#!/bin/bash

. ../colorize.sh
. ../bashr.sh

# Working example
grep "date" ../date.sh > /dev/null;

if [ $? -eq 0 ]; then
    echo "Found date in date.sh" | green
else
    echo "Could not find date in date.sh" | red
fi

#Failing exampl
grep "idontknowthatstring" ../date.sh > /dev/null;

if [ $? -eq 0 ]; then
    echo "Found idontknowthatstring in date.sh" | green
elif [ $? -eq 1 ]; then
    echo "Could not find idontknowthatstring in date.sh" | yellow
elif [ $? -eq 2 ]; then
    echo "Could not find date.sh in exepected directory ../" | red;
    exit;
else
    echo "Unknown error..." | red
fi

