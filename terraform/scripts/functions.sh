#!/bin/bash

# This is a bash library which is used by the other scripts.

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
# Prints help message for the script.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Prints help message for the script.
##########################################################
help() {
  echo "Usage: $0 [ -m ] [ -v VAR_FILE ]"
  echo
  echo "Options:"
  echo "   -m                   Manual mode, disabling '-auto-approve' option for terraform apply"
  echo "   -v VAR_FILE          Specifying var-file for terraform init, including path"
  echo
}

##########################################################
# Handles arguments using getopts.
# Globals:
#   var_file
#   manual
# Arguments:
#   "$@"
# Outputs:
#   Sets var_file if "-v" option is provided.
#   Sets manual to an empty string if "-m" option is provided.
##########################################################
handle_arguments() {
  while getopts ":v:m" options; do
    case "${options}" in
      v)
        var_file=${OPTARG}
        echo "Setting var-file to ${OPTARG}"
      ;;
      m)
        # It's a global variable used in the calling scripts.
        # shellcheck disable=SC2034
        manual=""
        echo "Operating in manual mode, disabling -auto-approve flag when running terraform apply"
      ;;
      :)
        err "-${OPTARG} requires an argument."
        help
        return 1
      ;;
      *)
        err "-${OPTARG} is not a valid argument."
        help
        return 1
      ;;
    esac
  done
}

##########################################################
# Finds the main terraform folder of the repo, changes directory to it and sets its path as the base_dir variable
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
  if ! cd "${SCRIPTS_DIR}"; then
    err "Could not change directory to scripts: ${SCRIPTS_DIR}"
    return 1
  fi 
  
  # Trying to find the main terraform folder of the repo
  local dir
  dir=$(basename "$(pwd)")
  while [[ "${dir}" != "terraform" ]] && [[ "${dir}" != "/" ]]
  do
    if ! cd .. ; then
      err "Could change directory to parentdirectory from ${dir}"
      return 1
    fi

    dir=$(basename "$(pwd)")
  done
  if [[ "${dir}" != "terraform" ]]
  then
    err "Could not find terraform dir in parrent folders"
    return 1
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
  if [[ -z "${var_file}" ]]
  then
    # Defaults to the terraform.tfvars file inside the scripts folder.
    var_file="${base_dir}/scripts/terraform.tfvars"
  fi
  
  if [[ ! -r "${var_file}" ]]
  then
    err "Couldn't read var-file"
    return 1
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