#!/bin/bash
# run from some folder bellow or in the terraform folder of the repo
# loads all vars in env.txt
# destroys all terraform configs in dirlist

dirlist="/dev/argo-2
         /dev/argo-1
         /dev/sql 
         /dev 
         /dev/vpc"

sprint () {
    echo "$1"
    echo "================================="
    echo
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

# if env not provided
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
    if terraform destroy -auto-approve ;
    then
        echo "$tfdir destroyed"
    else
        echo "Could not destroy $tfdir, exiting"
        exit 1
    fi
done
