#!/bin/bash
# See the help function for usage informating (-h option).

# The script passes the var-file to terraform init,
# inits and validates all terraform configs in DIR_LIST.

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
init_help() {
  echo "Usage: $0 [ -m ] [ -v VAR_FILE ] [ -b BACKEND_CONFIG ]"
  echo
  echo "Options:"
  echo "   -m                   Manual mode, disabling '-input=false' option for terraform init"
  echo "   -v VAR_FILE          Specifying var-file for terraform init, including path"
  echo "   -b BACKEND_CONFIG    Specifying the backend-config for terraform init. When passing a file, include the path"
  echo
}

##########################################################
# Calls the init_help function and exits with a code of 1.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Print from help function.
##########################################################
init_exit_abnormal() {
  init_help
  exit 1
}

##########################################################
# Runs terraform init in the current directory.
# Globals:
#   tf_dir
#   manual
#   var_file
#   backend
# Arguments:
#   None
# Outputs:
#   Info message and either sucess or error message.
#   Generates or modifies .terraform folder in the directory if needed.
##########################################################
tf-init() {
  sprint "Running terrafom init in ${tf_dir}"
  
  # Double quoting manual would cause manual mode to fail.
  # shellcheck disable=SC2086
  if terraform init ${manual} -var-file "${var_file}" -backend-config "${backend}" ;
  then
    echo "${tf_dir} init success"
  else
    err "${tf_dir} init failure, exiting"
    exit 1
  fi
}

##########################################################
# Runs terraform validate in the current directory.
# Globals:
#   tf_dir
# Arguments:
#   None
# Outputs:
#   Info message and either sucess or error message.
##########################################################
tf-validate() {
  sprint "Running terrafom validate in ${tf_dir}"
  
  if terraform validate ;
  then
    echo "${tf_dir} validate success"
  else
    err "${tf_dir} validate failure, exiting"
    exit 1
  fi
}

##########################################################
# Validates the backend by checking if it's been provided and checks if it's readable.
# Globals:
#   backend
# Arguments:
#   None
# Outputs:
#   Sets backend to default if it is empty.
##########################################################
validate_backend() {
  # Checking if backend is provided
  if [ -z "${backend}" ]
  then
    # Defaults to the backend.tf file inside the scripts folder.
    backend="${base_dir}/scripts/backend.tf"
  fi
  
  # Bachend-config may be either a path to a file or a 'key=value' format. Therefore allowing all strings containing '='.
  # If the string doesn't contain '=', checking if the file can be read.
  if [[ ! "${backend}" == *"="* ]] && [ ! -r "${backend}" ]
  then
    err "Could not read backend file, exiting"
    exit 1
  fi
}

##########################################################
# Handles arguments using getopts.
# Globals:
#   var_file
#   backend
#   manual
# Arguments:
#   "$@"
# Outputs:
#   Sets var_file if "-v" option is provided.
#   Sets backend if "-b" option is provided.
#   Sets manual to an empty string if "-m" option is provided.
##########################################################
handle_init_arguments() {
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
        err "Error: -${OPTARG} requires an argument."
        init_exit_abnormal
      ;;
      *)
        init_exit_abnormal
      ;;
    esac
  done
}

main() {
  manual="-input=false"
  
  handle_init_arguments "$@"
  find_base_dir
  validate_var_file
  validate_backend
  
  for tf_dir in "${DIR_LIST[@]}"; do
    echo "Moving to ${tf_dir}"
    cd "${base_dir}${tf_dir}" || { err "Could not cd to ${base_dir}${tf_dir}, exiting"; exit 1; }
    tf-init
    tf-validate
  done
}


main "$@"