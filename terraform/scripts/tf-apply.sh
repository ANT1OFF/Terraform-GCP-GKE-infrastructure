#!/bin/bash
# Run from any folder in or bellow the main terraform folder of the repo.
# The script takes one argument: the path to the file containing environment variables to be injected before running the Terraform configuration.
# The name of the env file defaults to "env.txt" inside the scripts folder of this repository.

# The script loads all vars in env.txt,
# plans and applies all terraform configs in dirlist.

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

dirlist="/dev/vpc 
         /dev 
         /dev/sql 
         /dev/argo"

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tf-apply () {
    sprint "Running terrafom plan"

    #TODO: add ability to disable planning
    if terraform plan -var-file "${envfile}" ;
    then
        echo "$tfdir plan success"
    else
        echo "$tfdir plan failure, exiting"
        exit 1
    fi

    sprint "Running terrafom apply"

    #TODO: add ability to diable -auto-approve
    if terraform apply -auto-approve -var-file "${envfile}" ; 
    then
        echo "$tfdir apply success"
    else
        echo "$tfdir apply failure, exiting"
        if [ "$tfdir" != "/dev/argo-2" ]
        then
            exit 1
        fi
    fi
}

check-tf-argo-state () {
    state="$(terraform state list | grep kubernetes_config_map.argocd-config)"
    if [ -z "$state" ] 
    then
        bash -c 'terraform import kubernetes_config_map.argocd-config argocd/argocd-cm' 
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
    if [ "$tfdir" = "/dev/argo-2" ]
    then
        set +e  # turn off error-trapping
        (
            sleep 30
            echo "running in subshell"
            check-tf-argo-state
        ) &
        wait
        tf-apply
        set -e  # turn on error-trapping
        
    else
        tf-apply
    fi    
done

for tfdir in $dirlist
do
    echo "Moving to $tfdir"
    cd "$basedir$tfdir" || { echo "Could not cd, exiting"; exit 1; }
    if [ "$tfdir" = "/dev/argo-2" ]
    then
        set +e  # turn off error-trapping
        (
            sleep 30
            echo "running in subshell"
            check-tf-argo-state
        ) &
        wait
        set -e  # turn on error-trapping
    fi
    tf-apply
done