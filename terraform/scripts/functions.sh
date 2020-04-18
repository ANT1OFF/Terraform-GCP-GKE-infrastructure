#!/bin/bash

# This is a bash library which is used by the other scripts.

# exit_abnormal calls the help function of the respective script and exits with a code of 1
exit_abnormal() {
  help
  exit 1
}

sprint () {
  echo "$1"
  echo "================================="
  echo
}

# find_basedir finds the main terraform folder of the repo, moves to it and sets its path as the basedir variable
find_basedir() {
  # Moving to the directory containing the scripts
  cd "${scripts_dir}" || { echo "Could not change directory to scripts: $scripts_dir, exiting"; exit 1; }
  
  # Trying to find the main terraform folder of the repo
  dir=$(basename "$(pwd)")
  while [ "$dir" != "terraform" ] && [ "$dir" != "/" ]
  do
    cd .. || { echo "Could change directory to parentdirectory from $dir, exiting"; exit 1; }
    dir=$(basename "$(pwd)")
  done
  
  if [ "$dir" != "terraform" ]
  then
    echo "Could not find terraform dir in parrent folders, exiting"
    exit 1
  fi
  
  # basedir contains the path to the main terraform folder of the repo
  basedir=$(pwd)
}

# validate_var_file checks if a var-file has been provided, otherwise uses the default and checks if the file is readable.
validate_var_file() {
  # Checking if var_file is provided
  if [ -z "$var_file" ]
  then
    # Defaults to the terraform.tfvars file inside the scripts folder.
    var_file="${basedir}/scripts/terraform.tfvars"
  fi
  
  if [ ! -r "$var_file" ]
  then
    echo "Could not read var-file, exiting"
    exit 1
  fi
}

# err() {
#   echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
# }