#!/bin/bash
# run from some folder bellow or in the terraform folder of the repo
# loads all vars in env.txt
# inits and validates all terraform configs in dirlist

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

tfin () {
    sprint "Running terrafom init in $tfdir"

    if terraform init -input=false ; 
    then
        echo "$tfdir init success"
    else
        echo "$tfdir init failure, exiting"
        exit 1
    fi
}

tfval () {
    sprint "Running terrafom validate in $tfdir"

    if terraform validate ; 
    then
        echo "$tfdir validate success"
    else
        echo "$tfdir validate failure, exiting"
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
    tfin
    tfval
done


