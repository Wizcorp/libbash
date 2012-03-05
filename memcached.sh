#!/bin/sh

if [ "$MB_SERVER" == "" ]; then
    export MB_SERVER="localhost"
fi

if [ "$MB_PORT" == "" ]; then
    export MB_PORT="11211"
fi

mbGet(){
    keys=$(mbGetKey $@)
    mbQuery "get $keys"
}

mbDel(){
    key=$(mbGetKey $1)
    mbQuery "delete $key"
}

mbTouch(){
    key=$(mbGetKey $1)
    OPTIND=2;
    mbGetOpts $@;
    mbQuery "touch $key $TTL"
}

mbIncr(){
    key=$(mbGetKey $1)
    value=$2

    mbQuery "incr $key $value"
}

mbDecr(){
    key=$(mbGetKey $1)
    value=$2

    mbQuery "decr $key $value"
}

mbSet(){
    mbDataCommand "set" $@
}

mbAdd(){
    mbDataCommand "add" $@
}

mbReplace(){
    mbDataCommand "replace" $@
}

mbAppend(){
    mbDataCommand "append" $@
}

mbPrepend(){
    mbDataCommand "prepend" $@
}

mbDataCommand(){

    # Options

    command=$1;
    key=$(mbGetKey $2 | sed "s/ $//")
    value="$3"
    dataFile="/tmp/mbCommand_$(uuidgen)";

    if [ "$3" == "" -o "$(echo $3 | grep "^-")" != "" ]; then
        OPTIND=3;
        cat - > $dataFile;
    else
        OPTIND=4;
        echo -n $3 > $dataFile;
    fi

    mbGetOpts $@;

    if [ "$3" == "$(cat $dataFile)" ]; then
        len=$(($(cat $dataFile | wc -c)))
    elif [ "$(grep  $dataFile)" == "" ]; then
        len=$(($(cat $dataFile | wc -c)-1))
    else
        len=$(($(cat $dataFile | wc -c)))
    fi

    # Run
    mbQuery "set $key $FLAGS $TTL $len"

    # Cleanup
    rm -rf $dataFile
    unset dataFile;
    unset value;
    unset key;

    mbCleanOpts
}

mbGetOpts(){

  TTL=0;
  FLAGS=0;

  while getopts "t:f:" OPTION; do
    case $OPTION in
         t)
             TTL="$OPTARG"
             ;;
         f)
             FLAGS="$OPTARG"
             ;;
     esac
  done
}

mbCleanOpts(){
  unset TTL;
  unset FLAGS;
}

mbGetKey(){
  if [ "$MB_PREFIX" == "" ]; then
    for key in $@; do
        echo -n "$key "
    done
  else
    for key in $@; do
        echo -n "$MB_PREFIX/$key "
    done
  fi
}

mbQuery(){
  for query in "$@"; do
    mbBuildQuery "$query" | nc $MB_SERVER $MB_PORT
  done
}

mbBuildQuery(){

  echo -en "$1\r\n";

  if [ "$dataFile" != "" ]; then
      if [ -f $dataFile ]; then
          cat $dataFile | sed "\$s/\$//" | sed "\$s/$/\\r\\nquit\\r\\n/";
      else
        echo "Could not find dataFile!" >&2;
      fi
  else
      echo -en "quit\r\n";
  fi

}

mbExtract(){
  cat - | sed "1 d;$ d;\$s/\r\n\$//";
}

mbExtractTest(){

  dataFile="/tmp/mbCommand_$(uuidgen)";

  cat - | tee $dataFile | sed "1 d;$ d;\$s/\r\n\$//";
  meta=$(head -n1 < $dataFile && rm $dataFile);

  mb_key=$(echo $meta | cut -d" " -f2);
  mb_flag=$(echo $meta | cut -d" " -f3);
  mb_size=$(echo $meta | cut -d" " -f4);
}
