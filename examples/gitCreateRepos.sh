#!/bin/bash
# Simple example of a sequential script using bashr.sh
#
# There are two kind of commands:
#  * Templating
#     - echoH1-5
#     - echoInfo
#     - echoWarning
#     - echoError
#     - echoOk
#     - echoQuestion
#  * Templated command execution
#     - setup: if fails, the script exits
#     - run: failure is yours to handled
#

#
# Setting destination for each repo to create
#

. /usr/lib/bash/bashr.sh

dst=${1:-};

if [ "$dst" == "" ]; then
    dst="localGit"
fi

echoH1 "Setting up destination for remote repository ($dst)"
echo "";

setup "Validation of the destination for repos to be created" \
         ls $(dirname $dst) \
         "Could not validate given path" \
;

setup "Deleting previous git local creation subdir" \
    rm -rf $dst \
    "Could complete deletion, exiting!" \
;

setup "(re)creating local git creation subdir" \
    mkdir $dst 2> /dev/null \
    "Could not create destination directory, exiting!" \
;

#
# Create a repo for each directory found in this path
#

echoH1 "Creating git repos"

for d in $(ls .); do

    if [ ! -d $d ] || [ "$(stat -c "%d:%i" $d)" == "$(stat -c "%d:%i" $dst)" ]; then
        continue;
    fi;

    touch $dst/$d.error.log

    echoH2 "Creating test repo for plugin $d";
    echo "";

    run "Syncing data locally"  \
        rsync -av $d/ $dst/$d/ 2> $dst/$d.error.log \
    ;

    if [ $? -ne 0 ]; then
        continue;
    fi;

    pushd $dst/$d/ > /dev/null;

    run "Creating git repo" \
        git init 2> $dst/$d.error.log \
    ;

    if [ $? -ne 0 ]; then
        continue;
    fi

    run "Add all files to repo" \
        git add * 2> $dst/$d.error.log \
    ;

    if [ $? -ne 0 ]; then
        continue;
    fi

    run "Inital commit" \
        git commit -m "Initial import for plugin $d" 2> ../$d.error.log \
    ;

    if [ $? -ne 0 ]; then
        continue;
    fi

    echoOk "Creation completed with success!" | green | bold;

    if [  -e ../$d.error.log ] && [ "$(cat ../$d.error.log)" == "" ]; then
        rm -rf ../$d.error.log;
    fi

    popd > /dev/null;
done;

echoInfo "========================"
echoOk "Import completed!"
echoInfo "========================"
