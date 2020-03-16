#!/bin/bash
# run from some folder bellow or in the terraform folder of the repo
# loads all vars in env.txt
# plans and applies all terraform configs in dirlist

dirlist="/dev/vpc 
         /dev 
         /dev/sql 
         /dev/argo-1
         /dev/argo-2"

sprint () {
    echo "$1"
    echo "================================="
    echo
}

tf-apply () {
    sprint "Running terrafom plan"

    if terraform plan ; 
    then
        echo "$tfdir plan success"
    else
        echo "$tfdir plan failure, exiting"
        exit 1
    fi

    sprint "Running terrafom apply"

    #TODO: add ability to diable -auto-approve
    if terraform apply -auto-approve ; 
    then
        echo "$tfdir apply success"
    else
        echo "$tfdir apply failure, exiting"
        exit 1
    fi
}

dir=$(basename "$(pwd)")
while [ "$dir" != "terraform" ] && [ "$dir" != "/" ]
do
    cd ..
    dir=$(basename "$(pwd)")
done

if [ "$dir" != "terraform" ] 
then
    echo "Could not find terraform dir in parrent folders, exiting"
    exit 1
fi

basedir=$(pwd)

file="$1"

# if env not provided (file is an empty string)
if [ -z "$file" ]
then
    cd "${basedir}/scripts" || { echo "Could not cd, exiting"; exit 1; }
    file="env.txt"
fi

if [ ! -r "$file" ]
then
    echo "Could not read env file, exiting"
    exit 1
fi

# Load and set envs from env.txt
set -a
. ${file}
set +a


for tfdir in $dirlist
do
    echo "Moving to $tfdir"
    cd "$basedir$tfdir" || { echo "Could not cd, exiting"; exit 1; }
    if [ "$tfdir" = "/dev/argo-2" ]
    then
        terraform import kubernetes_config_map.argocd-config argocd/argocd-cm
    fi
    tf-apply
done
