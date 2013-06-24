#!/bin/bash

declare -a bold=("\033[1m"  "\033[22m");
declare -a italic=("\033[3m"  "\033[23m");
declare -a underline=("\033[4m"  "\033[24m");
declare -a inverse=("\033[7m"  "\033[27m");
declare -a white=("\033[37m" "\033[39m");
declare -a grey=("\033[90m" "\033[39m");
declare -a black=("\033[30m" "\033[39m");
declare -a blue=("\033[34m" "\033[39m");
declare -a cyan=("\033[36m" "\033[39m");
declare -a green=("\033[32m" "\033[39m");
declare -a magenta=("\033[35m" "\033[39m");
declare -a red=("\033[31m" "\033[39m");
declare -a yellow=("\033[33m" "\033[39m");

cWrap(){
    echo -en "$(eval "echo \${${1:-}[0]}")"
    cat -;
    echo -en "$(eval "echo \${${1:-}[1]}")"
}

black(){
    cat - | cWrap black;
}

red(){
    cat - | cWrap red;
}

green(){
    cat - | cWrap green;
}

yellow(){
    cat - | cWrap yellow;
}

blue(){
    cat - | cWrap blue;
}

magenta(){
    cat - | cWrap magenta;
}

cyan(){
    cat - | cWrap cyan;
}

white(){
    cat - | cWrap white;
}

grey(){
    cat - | cWrap grey;
}

bold(){
    cat - | cWrap bold;
}

italic(){
    cat - | cWrap italic;
}

underline(){
    cat - | cWrap underline;
}

inverse(){
    cat - | cWrap inverse;
}
