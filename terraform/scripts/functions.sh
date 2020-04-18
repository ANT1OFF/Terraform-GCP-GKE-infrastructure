#!/bin/bash

# This is a bash library which is used by the other scripts.


##########################################################
# Calls the help function of the respective script and exits with a code of 1.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Print from help function.
##########################################################
exit_abnormal() {
  help
  exit 1
}

##########################################################
# Prints the given message with divider and space underneath.
# Globals:
#   None
# Arguments:
#   Message to print.
# Outputs:
#   Prints message, a divider and empty line.
##########################################################
sprint() {
  echo "${1}"
  echo "================================="
  echo
}

##########################################################
# Finds the main terraform folder of the repo, moves to it and sets its path as the base_dir variable
# Globals:
#   SCRIPTS_DIR
#   base_dir
# Arguments:
#   None
# Outputs:
#   Sets base_dir to the main terraform folder of the repo.
##########################################################
find_base_dir() {
  # Moving to the directory containing the scripts
  cd "${SCRIPTS_DIR}" || { err "Could not change directory to scripts: ${SCRIPTS_DIR}, exiting"; exit 1; }
  
  # Trying to find the main terraform folder of the repo
  local dir
  dir=$(basename "$(pwd)")
  while [ "${dir}" != "terraform" ] && [ "${dir}" != "/" ]
  do
    cd .. || { err "Could change directory to parentdirectory from ${dir}, exiting"; exit 1; }
    dir=$(basename "$(pwd)")
  done
  if [ "${dir}" != "terraform" ]
  then
    err "Could not find terraform dir in parrent folders, exiting"
    exit 1
  fi
  
  # base_dir contains the path to the main terraform folder of the repo
  readonly base_dir=$(pwd)
}


##########################################################
# Validates the var-file by checking if it's been provided and checks if it's readable.
# Globals:
#   var_file
# Arguments:
#   None
# Outputs:
#   Sets var_file to default if it is empty.
##########################################################
validate_var_file() {
  # Checking if var_file is provided
  if [ -z "${var_file}" ]
  then
    # Defaults to the terraform.tfvars file inside the scripts folder.
    var_file="${base_dir}/scripts/terraform.tfvars"
  fi
  
  if [ ! -r "${var_file}" ]
  then
    err "Could not read var-file, exiting"
    exit 1
  fi
}

##########################################################
# Logs message with time and date to stderr.
# Globals:
#   None
# Arguments:
#   Error message
# Outputs:
#   Prints message with time and date to stderr.
##########################################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}