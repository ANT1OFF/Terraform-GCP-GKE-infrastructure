#!/bin/bash
# See the help function for usage informating (-h option).

# The script passes the var-file to terraform plan and apply,
# plans and applies all terraform configs in dirlist.

readonly SCRIPTS_DIR=$(dirname "$0")

readonly DIR_LIST=(
  /dev
)

# The import path needs to be relative to allow calling the script from outside the scripts folder.
# shellcheck disable=SC1090
source "${SCRIPTS_DIR}/functions.sh" ":"

##########################################################
# Runs terraform apply in the current directory.
# Globals:
#   tf_dir
#   manual
# Arguments:
#   None
# Outputs:
#   Info message and either sucess or error message.
# Returns:
#   0 on successfull terraform apply, 1 on error
##########################################################
tf_apply () {
  sprint "Running terrafom apply"
  
  # Double quoting manual would cause manual mode to fail.
  # shellcheck disable=SC2086
  if terraform apply ${manual} -var-file "${var_file}" ;
  then
    echo "${tf_dir} apply success"
  else
    err "${tf_dir} apply failure"
    return 1
  fi
}

main() {
  manual="-auto-approve"
  
  if ! handle_options "$@"; then
    err "Unexpected options, exiting"
    exit 1
  fi
  
  if ! find_base_dir; then
    err "Couldn't find main Terraform folder, exiting"
    exit 1
  fi

  if ! validate_var_file; then
    err "Invalid var-file, exiting"
    exit 1
  fi

  
  for tf_dir in "${DIR_LIST[@]}"; do
    echo "Moving to ${tf_dir}"
    if ! cd "${base_dir}${tf_dir}"; then
      err "Couldn't cd to ${base_dir}${tf_dir}, exiting"
      exit 1
    fi

    if ! tf_apply; then
      err "tf_apply failed, exiting"
      exit 1
    fi
  done
}


main "$@"