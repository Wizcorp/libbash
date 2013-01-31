#!/bin/bash

#
# Setting destination for each repo to create
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/colorize.sh
. $DIR/spinner.sh
. $DIR/query.sh

export BASHR_LEVEL=1;

echoH1(){

    export BASHR_LEVEL=1;

    len=$(($(echo "$@" | wc -c) + 10))
    sep="❖"

    echo "";
    (seq -s $sep $len | sed 's/[0-9]//g') | blue
    echo " ◉ $@" | blue | bold
    (seq -s $sep $len | sed 's/[0-9]//g') | blue
}

echoH2(){
    export BASHR_LEVEL=2;
    echo "";
    echo "‣ $@" | blue | bold
}

echoH3(){
    export BASHR_LEVEL=3;
    echo "";
    echo "⁃⁃ $@" | blue | bold
}

echoH4(){
    export BASHR_LEVEL=4;
    echo "";
    echo "◦◦◦ $@" | blue | bold
}

echoH5(){
    export BASHR_LEVEL=5;
    echo "";
    echo "◘◘◘◘ $@" | blue | bold
}

echoSpacing(){
    for i in $(seq $BASHR_LEVEL); do echo -n ' '; done
}

echoInfo(){
    echoSpacing;
    echo "⚀ $@" | grey
}

echoWarning(){
    echoSpacing;
    echo "⧫ $@" | yellow | bold
}

echoError(){
    echoSpacing;
    echo "✘ $@" | red | bold 1>&2
}

echoOk(){
    echoSpacing;
    echo "✔ $@" | green | bold
}

echoQuestion(){
    echoSpacing;
    query $(echo "？ $@" | magenta | bold)
}

echoQuestionHide(){
    echoSpacing;
    queryStared $(echo "？ $@" | magenta | bold)
}

echoPadded() {
    padding=$(( $1 - ${#2} ));
    echo -n $2;
    for i in $(seq 1 $padding); do echo -n " "; done
}

setup(){

    label="$1"
    cmd=("${@:2:$(($#-2))}");
    errorMsg="${@:2:$(($#-2))}";
    cmdStr="";
    cmdIncr=0;
    cmdId="$(cat /dev/urandom | tr -cd '[:alnum:]' | head -c 5)-$(date +%s)";

    #
    # Escaping of values which contain spaces
    #
    while [ "${cmd[$cmdIncr]}" != "" ]; do
        case "${cmd[$cmdIncr]}" in
             *\ * )
                   cmd[$cmdIncr]="\"${cmd[$cmdIncr]}\"";
                   ;;
               *)
                   ;;
        esac

        cmdStr="$cmdStr ${cmd[$cmdIncr]}"
        cmdIncr=$(($cmdIncr+1));
    done

    #
    # Capture pipes
    #
    errorPipe=/tmp/$cmdId-errors
    errorCodePipe=/tmp/$cmdId-code

    touch $errorPipe;
    touch $errorCodePipe;

    echoSpacing
    echo -ne "✪  $label : " | blue | bold

    #
    # Execution and information gathering (pid, error code, logs)
    #
    (eval "$cmdStr" > /dev/null 2> $errorPipe; echo $? > $errorCodePipe) &
    spinner $!
    spinRet=$?
    cmdRet=0;
    cmdRet=$(cat $errorCodePipe)

    if [ $spinRet -ne 0 ]; then
        echo -e "Aborted" | yellow | bold;
        echo "";
        exit 1;
    elif [ $cmdRet -ne 0 ]; then
        echo -e "✘" | red | bold;
        echo "-- $(cat $errorPipe) (error code: $cmdRet)" | red | bold 1>&2;
        exit $cmdRet;
    else
        echo "✔" | green | bold;
    fi

    #
    # Destroying pipes
    #
    rm -f $errorPipe;
    rm -f $errorCodePipe;
}

run(){

    #
    # Command variables
    #
    label="$1"
    cmd=("${@:2:$(($#-1))}");
    cmdStr="";
    cmdIncr=0;
    cmdId="$(cat /dev/urandom | tr -cd '[:alnum:]' | head -c 5)-$(date +%s)";

    #
    # Escaping of values which contain spaces
    #
    while [ "${cmd[$cmdIncr]}" != "" ]; do
        case "${cmd[$cmdIncr]}" in
             *\ * )
                   cmd[$cmdIncr]="'${cmd[$cmdIncr]}'";
                   ;;
               *)
                   ;;
        esac

        cmdStr="$cmdStr ${cmd[$cmdIncr]}"
        cmdIncr=$(($cmdIncr+1));
    done

    #
    # Capture pipes
    #
    errorPipe=/tmp/$cmdId-errors
    errorCodePipe=/tmp/$cmdId-code

    touch $errorPipe;
    touch $errorCodePipe;

    #
    # Label echo
    #

    echoSpacing
    echo -ne "♻  $label : \t" | grey

    #
    # Execution and information gathering (pid, error code, logs)
    #
    (eval "$cmdStr" > /dev/null 2> $errorPipe; echo $? > $errorCodePipe) &
    spinner $!
    spinRet=$?
    cmdRet=0;
    cmdRet=$(cat $errorCodePipe)

    #
    # Error code handling
    #
    if [ $spinRet -ne 0 ]; then
        echo -e "Aborted" | yellow | bold;
        echo "";
        exit;
    elif [ $cmdRet -ne 0 ]; then
        echo -e "Failed" | red | bold;
        echo "";
        cat $errorPipe 1>&2;
        retVal=1;
    else
        echo -e "Done" | green | bold;
        retVal=0;
    fi

    #
    # Destroying pipes
    #
    rm -f $errorPipe;
    rm -f $errorCodePipe;

    return $retVal;
}
