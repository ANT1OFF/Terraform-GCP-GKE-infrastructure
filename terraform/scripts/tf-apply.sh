#!/bin/bash
# Run from any folder in or bellow the main terraform folder of the repo.
# The script takes one argument: the path to the file containing environment varialbes to be injected before running the Terraform configuration.
# The name of the env file defaults to "env.txt" inside the scripts folder of this repository.

# The script loads all vars in env.txt,
# plans and applies all terraform configs in dirlist.

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

tf-apply () {
    sprint "Running terrafom plan"

    if terraform plan ; 
    then
        echo "$tfdir plan success"
    else
        echo "$tfdir plan failure, exiting"
        exit 1
    fi

    sprint "Running terrafom apply"

    #TODO: add ability to diable -auto-approve
    if terraform apply -auto-approve ; 
    then
        echo "$tfdir apply success"
    else
        echo "$tfdir apply failure, exiting"
        exit 1
    fi
}

# ---------------------------------------------------------------------------------------------------------------------
# SCRIPT
# ---------------------------------------------------------------------------------------------------------------------

# trying to find the main terraform folder
# TODO: merely checking that the folder is named "terraform" isn't very robust. Look into fixing
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

# basedir is the path to the main terraform folder of this repository
basedir=$(pwd)

envfile="$1"

# checking if envfile has been provided
if [ -z "$envfile" ]
then
    # defaults to a "env.txt" inside the scripts folder.
    envfile="${basedir}/scripts/env.txt"
fi

# checking if the envfile is readable
if [ ! -r "$envfile" ]
then
    echo "Could not read env file, exiting"
    exit 1
fi

# Load and set envs from env.txt
set -a
. ${envfile}
set +a


for tfdir in $dirlist
do
    echo "Moving to $tfdir"
    cd "$basedir$tfdir" || { echo "Could not cd, exiting"; exit 1; }
    if [ "$tfdir" = "/dev/argo-2" ]
    then
        terraform import kubernetes_config_map.argocd-config argocd/argocd-cm
    fi

    tf-apply
done
