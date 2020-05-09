#!/bin/bash
# See the help function for usage informating (-h option).

# The script passes the var_file as a var-file
# and runs terraform destroy for all folders listed in dirlist.

readonly SCRIPTS_DIR=$(dirname "$0")

readonly DIR_LIST=(
  /dev
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
# Returns:
#   0 on successfull terraform destroy, 1 on error
##########################################################
tf_destroy () {

  #!! temporary fix for some res timing out during destroy
  echo "Hacky fix"
  terraform state rm 'module.argo.kubernetes_namespace.argocd'
  sleep 1
  terraform state rm 'module.cluster.kubernetes_namespace.app-prod'
  sleep 1
  terraform state rm 'module.nginx.null_resource.cert-manager-crd[0]'
  sleep 1
  terraform state rm 'module.argo.null_resource.demo-application-argocd[0]'
  sleep 1
  terraform state rm 'module.argo.null_resource.argocd-ingress[0]'
  sleep 1

  # Double quoting manual would cause manual mode to fail.
  # shellcheck disable=SC2086
  if terraform destroy ${manual} -var-file "${var_file}" ; then
    echo "${tf_dir} destroyed"
  else
    err "Could not destroy ${tf_dir}, exiting"
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

    if ! tf_destroy; then
      err "tf_init failed, exiting"
      exit 1
    fi
  done
}

main "$@"