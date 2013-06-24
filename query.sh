#!/bin/bash

query(){

    local resultvar=${1:-};
    local ret;
    shift;

    if [ "${1:-}" == "" ]; then
        while read data; do
            echo -n $data
        done
    else
        while test $# -gt 0; do
            if [ "${1:-}" != "" ]; then
                echo -n " ${1:-}";
                shift
            fi
        done
    fi

    echo -n ": "

    read ret;

    eval $resultvar="'$ret'"
}

queryStared(){

    local resultvar=${1:-};
    local ret;
    shift;

    if [ "${1:-}" == "" ]; then
        while read data; do
            echo -n $data
        done
    else
        while test $# -gt 0; do
            echo -n " ${1:-}";
            shift
        done
    fi
    echo -n ": "

    prompt="";
    while IFS= read -p "$prompt" -r -s -n 1 char
    do
        if [[ $char == $'\0' ]]; then
            break
        elif [ "$(echo -ne $char | cat -A -)" == "^?" ]; then

            prompt="";

            if [ "$(echo $ret | wc -c)" != "1" ]; then
                echo -ne "\b\c";
                echo -ne " ";
                echo -ne "\b\c";
                ret=$(echo $ret | sed "s/.$//")
            fi

            continue;
        fi

        prompt='*'
        ret+="$char"
    done

    echo "";
    eval $resultvar="'$ret'"
}
