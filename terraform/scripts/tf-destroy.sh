#!/bin/bash
# Run from any folder in or below the main terraform folder of the repository.
# The script takes one argument: the path to the file containing environment variables to be injected before running the Terraform configuration.
# The name of the env file defaults to terraform.tfvars inside the scripts folder of this repository.

# The script passes the envfile as a var-file
# and runs terraform destroy for all folders listed in dirlist.

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

dirlist="/dev/argo-1
/dev/nginx
/dev/sql
/dev/cluster"
#  /dev/vpc"

# ---------------------------------------------------------------------------------------------------------------------
# FUNCTION DEFINITIONS
# ---------------------------------------------------------------------------------------------------------------------

sprint () {
  echo "$1"
  echo "================================="
  echo
}

tf-destroy () {
  if terraform destroy -auto-approve -var-file "${envfile}" ;
  then
    echo "$tfdir destroyed"
  else
    echo "Could not destroy $tfdir, exiting"
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
  if terraform destroy -auto-approve -var-file "${envfile}" ;
  then
    echo "$tfdir destroyed"
  else
    echo "Could not destroy $tfdir, exiting"
    exit 1
  fi
done
