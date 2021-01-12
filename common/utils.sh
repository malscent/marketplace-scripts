#!/usr/bin/env bash

#  Generates a 13 character random string
function __generate_random_string() {
    NEW_UUID=$(LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo '')
    echo "${NEW_UUID}"
}

error_exit() {
    line=$1
    shift 1
    __log_error "non zero return code from line: $line - $*"
    exit 1
}

# Checks to see if a value is contained by an array
function __elementIn() {
    local e match
    match=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    shift
    for e; do [[ "${e}" = "${match}" ]] && echo 0 && return; done
    echo 1
}

# Upper cases text
function __toUpper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'    
}

function __compareVersions() {
    if [[ $1 == "$2" ]]
    then
        echo 0
        return
    fi
    local IFS=.

    local i ver1 ver2
    read -r -a ver1 <<< "$1"
    read -r -a ver2 <<< "$2"
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo 1
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo 2
            return
        fi
    done
    echo 0
    return
}

function __findClosestVersion() {
    local e requestedVersion=$1
    shift
    compatibleVersions=( "$@" )
    if [[ ! "${requestedVersion}" =~  ^[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}$ ]]; then
        __log_error "${requestedVersion} is not in the correct version format."
        return 1
    fi
    local contained
    contained=$(__elementIn "${requestedVersion}" "$@")
    if [[ "$contained" == "0" ]]; then 
        echo "${requestedVersion}"
        return
    fi

    selectedVersion="${compatibleVersions[0]}"
    for i in "${compatibleVersions[@]}"; do
        comparison=$(__compareVersions "$requestedVersion" "$i")
        selectedComparison=$(__compareVersions "$selectedVersion" "$i")
        if [[ "$comparison" == "1" && "$selectedComparison" == "2" ]]; then
            # our selected version is greater than the requested so we go with it
            selectedVersion=$i

        fi
    done
    
    echo "$selectedVersion"
    return
}