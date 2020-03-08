#!/bin/bash
#run from script folder

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

# Load and set envs from env.txt
set -a
. ${file}
set +a

cd ../dev/
sprint "Running terrafom destroy in /dev"
terraform destroy -auto-approve

cd ./vpc
sprint "Running terrafom destroy in /dev/vpc"
terraform destroy -auto-approve