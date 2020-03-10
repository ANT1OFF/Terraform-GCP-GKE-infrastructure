#!/bin/bash
#run from script folder
# TODO: make run on all dirs as input

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tfin () {

    sprint "Running terrafom init"

    terraform init -input=false 
    if (($? > 0))
    then
        echo " Init failed exiting"
        exit 1
    fi
}

tfval () {

    sprint "Running terrafom validate"

    terraform validate;
    if (($? > 0))
    then
        echo " Validate failed exiting"
        exit 1
    fi
}


file="$1"

# if env not provided
if [ -z "$file" ]
then
      file="./env.txt"
fi

if [ ! -r "$file" ]
then
    echo "Could not read env file, exiting"
    exit 1
fi

# Load and set envs from env.txt
set -a
. ${file}
set +a

sprint "Moving to /dev/vpc"
cd "../dev/vpc" || { echo "Could not cd, exiting"; exit 1; }
tfin
tfval
if (($? > 0))
then
    echo "Init failed exiting"
    exit 1
fi

sprint "Moving to /dev"
cd .. || { echo "Could not cd, exiting"; exit 1; }
tfin
tfval


sprint "Moving to /sql"
cd ./sql || { echo "Could not cd, exiting"; exit 1; }
tfin
tfval


