#!/bin/bash
# Run from any folder in or bellow the main terraform folder of the repo.
# The script takes one argument: the path to the file containing environment variables to be injected before running the Terraform configuration.
# The name of the env file defaults to "env.txt" inside the scripts folder of this repository.

dirlist="/dev/argo
         /dev/sql 
         /dev 
         /dev/vpc"

sprint () {
    echo "$1"
    echo "================================="
    echo
}

dir=$(basename "$(pwd)")
while [ "$dir" != "terraform" ] && [ "$dir" != "/" ]
do
    cd ..
    dir=$(basename "$(pwd)")
done

if [ "$dir" != "terraform" ] 
then
    echo "Could not find terraform dir in parrent folders, exiting"
    exit 1
fi

basedir=$(pwd)

file="$1"

# if env not provided
if [ -z "$file" ]
then
    # defaults to a "env.txt" inside the scripts folder.
    envfile="${basedir}/scripts/terraform.tfvars"
fi

if [ ! -r "$file" ]
then
    echo "Could not read env file, exiting"
    exit 1
fi

for tfdir in $dirlist
do
    echo "Moving to $tfdir"
    cd "$basedir$tfdir" || { echo "Could not cd, exiting"; exit 1; }
    if terraform destroy -auto-approve -var-file "${envfile}" ;
    then
        echo "$tfdir destroyed"
    else
        echo "Could not destroy $tfdir, exiting"
        exit 1
    fi
done
