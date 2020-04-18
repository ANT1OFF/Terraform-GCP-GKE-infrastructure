#!/bin/bash
# See the help function for usage informating (-h option).

# The script passes the var-file to terraform init,
# inits and validates all terraform configs in dirlist.

# ---------------------------------------------------------------------------------------------------------------------
# VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

scripts_dir=$(dirname $0)

dirlist="
/dev/vpc
/dev/cluster
/dev/sql
/dev/argo-1
/dev/nginx"

manual="-input=false"

# ---------------------------------------------------------------------------------------------------------------------
# IMPORTING FUNCTIONS LIBRARY
# ---------------------------------------------------------------------------------------------------------------------

source "${scripts_dir}/functions.sh" ":"

# ---------------------------------------------------------------------------------------------------------------------
# FUNCTION DEFINITIONS
# ---------------------------------------------------------------------------------------------------------------------

help() {
  echo "Usage: $0 [ -m ] [ -v VAR_FILE ] [ -b BACKEND_CONFIG ]"
  echo
  echo "Options:"
  echo "   -m                   Manual mode, disabling '-input=false' option for terraform init"
  echo "   -v VAR_FILE          Specifying var-file for terraform init, including path"
  echo "   -b BACKEND_CONFIG    Specifying the backend-config for terraform init. When passing a file, include the path"
  echo
}

tf-init () {
  sprint "Running terrafom init in $tfdir"
  
  if terraform init $manual -var-file "${var_file}" -backend-config "${backend}" ;
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

validate_backend () {
  # Checking if backend is provided
  if [ -z "$backend" ]
  then
    # Defaults to the backend.tf file inside the scripts folder.
    backend="${basedir}/scripts/backend.tf"
  fi
  
  # Bachend-config may be either a path to a file or a 'key=value' format. Therefore allowing all strings containing '='.
  # If the string doesn't contain '=', checking if the file can be read.
  if [[ ! "$backend" == *"="* ]] && [ ! -r "$backend" ]
  then
    echo "Could not read backend file, exiting"
    exit 1
  fi
}

# ---------------------------------------------------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------------------------------------------------

# Handling arguments
while getopts ":v:b:m" options; do
  case "${options}" in
    v)
      var_file=${OPTARG}
      echo "Setting var-file to ${OPTARG}"
    ;;
    b)
      backend=${OPTARG}
      echo "Setting backend to ${OPTARG}"
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

# Finding the main terraform folder of the repo, moving to it and setting its path as the 'basedir' variable
find_basedir

# Validating the var-file
validate_var_file

# Validating the backend
validate_backend


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
