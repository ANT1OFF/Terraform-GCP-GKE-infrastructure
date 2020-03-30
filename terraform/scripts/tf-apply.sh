#!/bin/bash
# Run from any folder in or bellow the main terraform folder of the repo.
# The script takes one argument: the path to the file containing environment varialbes to be injected before running the Terraform configuration.
# The name of the env file defaults to the terraform.tfvars file inside the scripts folder of this repository.

# The script passes the envfile as a var-file,
# plans and applies all terraform configs in dirlist.

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

dirlist="/dev/vpc 
         /dev/cluster 
         /dev/sql
         /dev/argo-1"
         #/dev/argo-2"

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

    if terraform plan -var-file "${envfile}" ; 
    then
        echo "$tfdir plan success"
    else
        echo "$tfdir plan failure"
        return 1
    fi

    sprint "Running terrafom apply"

    #TODO: add ability to diable -auto-approve
    if terraform apply -auto-approve -var-file "${envfile}" ; 
    then
        echo "$tfdir apply success"
    else
        echo "$tfdir apply failure"
        return 1
    fi
}

import-argo-state () {
    state="$(terraform state list -var-file "${envfile}" | grep kubernetes_config_map.argocd-config)"
    if [ -z "$state" ] 
    then
        terraform import -var-file="${envfile}" kubernetes_config_map.argocd-config argocd/argocd-cm 
    else
        echo "argocd-config already managed by terraform"
    fi
}


# ---------------------------------------------------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------------------------------------------------

# TODO: merely checking that the folder is named "terraform" isn't very robust. mby fix?
# Trying to find the main terraform folder of the repo
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


# basedir contains the path to the main terraform folder of the repo
basedir=$(pwd)
# envfile should be a terraform tfvars file containing variables
envfile="$1"


# Checking if envfile is provided
if [ -z "$envfile" ]
then
    # Defaults to the terraform.tfvars file inside the scripts folder.
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

    # kind of a hack to get state import working
    if [ "$tfdir" = "/dev/argo-2" ]
    then
        set +e  # Turn off error-trapping
        tf-apply || { echo "tf-apply failed, running state import"; import-argo-state;  }
        set -e  # Turn on error-trapping
    fi

    echo "running tf-apply"
    tf-apply || { echo "tf-apply failed, exiting"; exit 1; }
done