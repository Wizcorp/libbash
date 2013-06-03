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
        HEADERS_STR="${HEADERS[*]}\r\n"
        HEADERS=${SAVE_HEADERS};
    fi

    echo -en "${ACTION} ${URL} HTTP/1.0\r\nHost: ${HOST}\r\n${HEADERS_STR}" | net tcp ${HOST} ${PORT};
}

tcp(){
    cat - | net tcp ${@};
}

udp(){
    cat - | net udp ${@};
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

    if [ "${4}" == "" ] || echo ${4} | grep "^-"; then
        cat - <&6 &
        catPid=$!;

        trap "kill ${catPid} 2> /dev/null" SIGINT SIGTERM;

        while read line; do
            echo -e "${line}" >&6;
        done;
    else
        shift 3
        echo -e "$@" >&6;
        cat - <&6;
    fi

    if [ "${catPid}" != "" ]; then
        while kill -0 ${catPid} 2> /dev/null; do
            sleep 1;
        done
    fi

    exec 6>&-;
    exec 6<&-;

    return ${RES};
}
