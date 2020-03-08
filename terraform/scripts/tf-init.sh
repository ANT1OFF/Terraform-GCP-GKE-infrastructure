#!/bin/bash
#run from script folder

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tfin () {

    sprint "Running terrafom init"

    terraform init
    if (($? > 0))
    then
        echo " Init failed exiting"
        exit 1
    fi
}

tfval () {

    sprint "Running terrafom validate"

    terraform validate
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
      file="env.txt"
fi

# Load and set envs from env.txt
set -a
. ${file}
set +a

sprint "Moving to /dev/vpc"
cd ../dev/vpc
tfin
tfval
if (($? > 0))
then
    echo "Init failed exiting"
    exit 1
fi

sprint "Moving to /dev"
cd ..
tfin
tfval

