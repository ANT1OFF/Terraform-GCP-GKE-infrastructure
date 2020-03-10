#!/bin/bash
#run from script folder

# TODO: make run on all dirs as input

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tf-apply () {

    sprint "Running terrafom plan"


    terraform plan; 
    if (($? > 0)) 
    then
        echo " Plan failed exiting"
        exit 1 
    fi

    sprint "Running terrafom apply"
    terraform apply -auto-approve
}

file="$1"

# if env not provided use env.txt
if [ -z "$file" ]
then
      file="env.txt"
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

tf-apply;
if (($? > 0)) 
then
    echo "Apply failed exiting"
    exit 1
fi

sprint "Moving to /dev"
cd ".." || { echo "Could not cd, exiting"; exit 1; }
tf-apply
if (($? > 0)) 
then
    echo "Apply failed exiting"
    exit 1
fi

sprint "Moving to /sql"
cd "./sql" || { echo "Could not cd, exiting"; exit 1; }
tf-apply
if (($? > 0)) 
then
    echo "Apply failed exiting"
    exit 1
fi

