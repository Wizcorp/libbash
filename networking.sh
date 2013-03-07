#!/usr/bin/env bash

getRandomOpenPort(){
    NOT_FOUND=true;

    while ${NOT_FOUND}; do
        # RANDOM MAX Value is 32767, how convenient. We double to create
        # a range where port would fit in.
        PORT=$(($RANDOM + ($RANDOM)));
        isLocalPortOpen ${PORT} || NOT_FOUND=false
    done

    echo ${PORT};
}

isLocalPortOpen() {
    PORT=${1};
    isPortOpen 127.0.0.1 ${PORT};
    return $?;
}

isPortOpen(){
    HOST=${1};
    PORT=${2};

    if [ "${HOST}" == "" ] || [ "${PORT}" == "" ]; then
        return 1;
    fi

    (echo "" >/dev/tcp/${HOST}/${PORT}) 2>/dev/null;
    RES=$?;

    return $(test ${RES} -eq 0);
}

http(){

    URI=$(echo ${1} | sed "s#^http://##");

    HOST=$(echo ${URI} | cut -d"/" -f1);
    URL=$(echo ${URI} | cut -d"/" -f2-);
    PORT=${2};

    if [ "${HOST}" == "" ]; then
        return 1;
    fi

    if [ "${URL}" == "" ] || [ "${URL}" == "${HOST}" ]; then
        URL="/";
    else
        URL="/${URL}";
    fi

    if [ "${PORT}" == "" ]; then
        PORT=80;
    fi

    if [ "${ACTION}" == "" ]; then
        ACTION="GET";
    fi

    if [ -z "${HEADERS}" ]; then
        SAVE_HEADERS=${HEADERS};
        HEADERS="\r\n";
        HEADERS_STR="${HEADERS[*]}"
        HEADERS=${SAVE_HEADERS};
    fi

    echo -en "${ACTION} ${URL} HTTP/1.0\r\n${HEADERS_STR}\r\n" | net tcp ${HOST} ${PORT};
}

tcp(){
    net tcp ${@} <&1;
}

udp(){
    net udp ${@} <&1;
}

net(){
    PROTO=${1};
    HOST=${2};
    PORT=${3};

    if [ "${HOST}" == "" ] || [ "${PORT}" == "" ]; then
        return 1;
    fi

    exec 6<>/dev/${PROTO}/${HOST}/${PORT};

    RES=$?;

    if [ "${4}" == "" -o "$(echo ${4} | grep "^-")" != "" ]; then
        # Send this pipe to backgound. Not sure if this works...
        cat - >&6 &
    else
        shift 3
        echo -e "$@" >&6;
    fi

    cat <&6;

    exec 6>&-;
    exec 6<&-;

    return ${RES};
}
