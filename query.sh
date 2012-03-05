#!/bin/bash

query(){
    local ret

    if [ "$1" == "" ]; then
        while read data; do
            echo -n $data
        done
    else
        for data in "$@"; do
            echo -n $data;
        done
    fi

    echo -n " : "

    read ret;
    echo $ret;
}

queryStared(){
    local ret

    if [ "$1" == "" ]; then
        while read data; do
            echo -n $data
        done
    else
        for data in "$@"; do
            echo -n $data;
        done
    fi

    echo -n " : "

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

    echo $ret;
}
