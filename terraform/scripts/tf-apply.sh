#!/bin/bash
# See the help function for usage informating (-h option).

# The script passes the var-file to terraform plan and apply,
# plans and applies all terraform configs in dirlist.

readonly SCRIPTS_DIR=$(dirname "$0")

readonly DIR_LIST=(
  /dev/vpc
  /dev/cluster
  /dev/sql
  /dev/argo-1
  /dev/nginx
)

# The import path needs to be relative to allow calling the script from outside the scripts folder.
# shellcheck disable=SC1090
source "${SCRIPTS_DIR}/functions.sh" ":"

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
# Runs terraform apply in the current directory.
# Globals:
#   tf_dir
#   manual
# Arguments:
#   None
# Outputs:
#   Info message and either sucess or error message.
##########################################################
tf-apply () {
  sprint "Running terrafom apply"
  
  # Double quoting manual would cause manual mode to fail.
  # shellcheck disable=SC2086
  if terraform apply ${manual} -var-file "${var_file}" ;
  then
    echo "${tf_dir} apply success"
  else
    err "${tf_dir} apply failure"
    exit 1
  fi
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
        manual=""
        echo "Operating in manual mode, disabling -auto-approve flag when running terraform apply"
      ;;
      :)
        err "Error: -${OPTARG} requires an argument."
        exit_abnormal
      ;;
      *)
        exit_abnormal
      ;;
    esac
  done
}

main() {
  manual="-auto-approve"
  
  handle_arguments "$@"
  find_base_dir
  validate_var_file
  
  for tf_dir in "${DIR_LIST[@]}"; do
    echo "Moving to ${tf_dir}"
    cd "${base_dir}${tf_dir}" || { err "Could not cd to ${base_dir}${tf_dir}, exiting"; exit 1; }
    tf-apply
  done
}


main "$@"