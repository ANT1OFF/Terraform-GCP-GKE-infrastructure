#!/bin/bash
#run from script folder
# TODO: make run on all dirs as input

sprint () {
    echo "$1"
    echo "================================="
    echo
}

file="$1"

# if env not provided
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

cd "../dev/sql" || { echo "Could not cd, exiting"; exit 1; }
sprint "Running terrafom destroy in /dev/sql"
terraform destroy -auto-approve

cd ".." || { echo "Could not cd, exiting"; exit 1; }
sprint "Running terrafom destroy in /dev"

terraform destroy -auto-approve

cd "./vpc" || { echo "Could not cd, exiting"; exit 1; }
sprint "Running terrafom destroy in /dev/vpc"
terraform destroy -auto-approve