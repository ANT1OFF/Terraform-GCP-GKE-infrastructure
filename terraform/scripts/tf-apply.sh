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
        if [ "$tfdir" != "/dev/argo-2" ]
        then
            echo "$tfdir apply failure, exiting"
            exit 1
        fi
    fi
}

check-tf-argo-state () {
    terraform state list  ## !!! might by needed ????
    state="$(terraform state list | grep kubernetes_config_map.argocd-config)"
    if [ -z "$state" ] 
    then
        terraform import kubernetes_config_map.argocd-config argocd/argocd-cm
    else
        echo "argocd-config already managed by terraform"
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
    if [ "$tfdir" = "/dev/argo-2" ]
    then
        set +e  # turn off error-trapping
        echo "running checks"
        check-tf-argo-state
        tf-apply    
        echo "sleep 30"
        sleep 30
        echo "importing argocd-config map"
        check-tf-argo-state    
        set -e  # turn on error-trapping
    fi
    echo "running tf-apply"
    tf-apply   
done
