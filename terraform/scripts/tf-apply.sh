#!/bin/bash
#run from script folder

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tf-apply () {

    sprint "Running terrafom plan"

    terraform plan
    if (($? > 0)) 
    then
        echo " Plan failed exiting"
        exit 1
    fi

    sprint "Running terrafom apply"
    terraform apply -auto-approve
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
tf-apply
if (($? > 0)) 
then
    echo "Apply failed exiting"
    exit 1
fi

sprint "Moving to /dev"
cd ..
tf-apply

