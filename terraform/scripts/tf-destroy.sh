#!/bin/bash
# Run from any folder in or bellow the main terraform folder of the repo.
# The script takes one argument: the path to the file containing environment varialbes to be injected before running the Terraform configuration.
# The name of the env file defaults to "env.txt" inside the scripts folder of this repository.

# The script loads all vars in env.txt and runs terraform destroy for all folders listed in dirlist.

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

dirlist="/dev/argo-2
         /dev/argo-1
         /dev/sql
         /dev 
         /dev/vpc"

# ---------------------------------------------------------------------------------------------------------------------
# FUNCTION DEFINITIONS
# ---------------------------------------------------------------------------------------------------------------------

sprint () {
    echo "$1"
    echo "================================="
    echo
}

# ---------------------------------------------------------------------------------------------------------------------
# SCRIPT
# ---------------------------------------------------------------------------------------------------------------------

# trying to find the main terraform folder
# TODO: merely checking that the folder is named "terraform" isn't very robust. mby fix?
dir=$(basename "$(pwd)")
while [ "$dir" != "terraform" ] && [ "$dir" != "/" ]
do
    cd .. || { echo "Could not cd, exiting"; exit 1; }
    dir=$(basename "$(pwd)")
done

if [ "$dir" != "terraform" ] 
then
    echo "Could not find terraform dir in parrent folders, exiting"
    exit 1
fi

basedir=$(pwd)

envfile="$1"

# if env not provided
if [ -z "$envfile" ]
then
    # defaults to a "env.txt" inside the scripts folder.
    envfile="${basedir}/scripts/terraform.tfvars"
fi

if [ ! -r "$envfile" ]
then
    echo "Could not read env file, exiting"
    exit 1
fi

# ---------------------------------------------------------------------------------------------------------------------
# Run commands
# ---------------------------------------------------------------------------------------------------------------------

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
