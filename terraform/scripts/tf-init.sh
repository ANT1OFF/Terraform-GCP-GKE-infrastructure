#!/bin/bash
# Run from any folder in or below the main terraform folder of the repository.
# The script takes one argument: the path to the file containing environment variables to be injected before running the Terraform configuration.
# The name of the env file defaults to terraform.tfvars inside the scripts folder of this repository.

# The script passes the envfile as a var-file,
# inits and validates all terraform configs in dirlist.

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

dirlist="/dev/vpc 
         /dev/cluster 
         /dev/sql
         /dev/argo-1
         /dev/nginx"

manual="-input=false"

# ---------------------------------------------------------------------------------------------------------------------
# FUNCTION DEFINITIONS
# ---------------------------------------------------------------------------------------------------------------------

help() {
  echo "Usage: $0 [ -m ] [ -e ENVFILE ]" 1>&2
  echo
  echo "Options:"
  echo "   -m              Manual mode, disabling '-input=false' option for terraform init"
  echo "   -e ENVFILE      Specifying envfile, including path"
  echo
}

exit_abnormal() {
  help
  exit 1
}

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tf-init () {
    sprint "Running terrafom init in $tfdir"

    # TODO: maybe take backend config as parameter aswell
    if terraform init $manual -var-file "${envfile}" -backend-config="${basedir}/scripts/backend.tf" ; 
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

# handling arguments
while getopts ":e:m" options; do
    case "${options}" in
        e)
            envfile=${OPTARG}
            echo "Setting envfile to ${OPTARG}"
            ;;
        m)
            manual=""
            echo "Operating in manual mode, terraform will ask for input if required instead of erroring"
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument."
            exit_abnormal
            ;;
        *)
            exit_abnormal
            ;;
    esac
done

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
    tf-init
    tf-validate
done
