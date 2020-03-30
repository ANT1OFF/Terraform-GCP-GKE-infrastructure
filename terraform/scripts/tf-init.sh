#!/bin/bash
# Run from any folder in or below the main terraform folder of the repository.
# The script takes one argument: the path to the file containing environment variables to be injected before running the Terraform configuration.
# The name of the env file defaults to "env.txt" inside the scripts folder of this repository.

# The script loads all vars in env.txt,
# inits and validates all terraform configs in dirlist.

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

dirlist="/dev/vpc 
         /dev 
         /dev/sql 
         /dev/argo-1
         /dev/argo-2"

# ---------------------------------------------------------------------------------------------------------------------
# FUNCTION DEFINITIONS
# ---------------------------------------------------------------------------------------------------------------------

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tf-init () {
    sprint "Running terrafom init in $tfdir"

    if terraform init -input=false -var-file "${envfile}" ; 
    then
        echo "$tfdir init success"
    else
        echo "$tfdir init failure, exiting"
        exit 1
    fi
}

tf-validate () {
    sprint "Running terrafom validate in $tfdir"

    if terraform validate ; 
    then
        echo "$tfdir validate success"
    else
        echo "$tfdir validate failure, exiting"
        exit 1
    fi
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
    tf-init
    tf-validate
done
