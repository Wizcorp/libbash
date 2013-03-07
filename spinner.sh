#!/bin/bash
spinner()
{
    local ESC=$'\e'
    local CSI="$ESC["

    local pid=$1
    local delay=$2
    local spinstr='|/-\'

    if [ "$delay" == "" ]; then
        delay=0.02
    fi

    trap spinner_sorry INT

    printf "${CSI}?25l"

    (while ps ax | awk '{print $1}' | grep -qs "^${pid}$"; do

        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr";
        local spinstr=$temp${spinstr%"$temp"}

        sleep $delay
        printf "\b\b\b\b\b\b"
    done) || (exit 1);

    ret=$?;

    printf "    \b\b\b\b"
    printf "${CSI}?12l${CSI}?25h";
    trap - INT

    return $ret
}

spinner_sorry(){

    local ESC=$'\e'
    local CSI="$ESC["

    printf "    \b\b\b\b"
    printf "${CSI}?12l${CSI}?25h";

    trap - INT
}
