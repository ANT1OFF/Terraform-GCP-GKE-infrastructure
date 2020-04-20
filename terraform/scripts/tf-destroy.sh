#!/bin/bash
# See the help function for usage informating (-h option).

# The script passes the var_file as a var-file
# and runs terraform destroy for all folders listed in dirlist.

readonly SCRIPTS_DIR=$(dirname "$0")

readonly DIR_LIST=(
  /dev/nginx
  /dev/argo-1
  /dev/sql
  /dev/cluster
  /dev/vpc
)

# The import path needs to be relative to allow calling the script from outside the scripts folder.
# shellcheck disable=SC1090
source "${SCRIPTS_DIR}/functions.sh" ":"

##########################################################
# Runs terraform destroy in the current directory.
# Globals:
#   tf_dir
#   manual
# Arguments:
#   None
# Outputs:
#   Info message and either sucess or error message.
##########################################################
tf_destroy () {
  # Double quoting manual would cause manual mode to fail.
  # shellcheck disable=SC2086
  if terraform destroy ${manual} -var-file "${var_file}" ;
  then
    echo "${tf_dir} destroyed"
  else
    err "Could not destroy ${tf_dir}, exiting"
    exit 1
  fi
}

main() {
  manual="-auto-approve"
  
  handle_arguments "$@"
  find_base_dir
  validate_var_file
  
  for tf_dir in "${DIR_LIST[@]}"; do
    echo "Moving to ${tf_dir}"
    cd "${base_dir}${tf_dir}" || { err "Could not cd to ${base_dir}${tf_dir}, exiting"; exit 1; }
    tf_destroy
  done
}


main "$@"