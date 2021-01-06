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
    for e; do [[ "${e}" = "${match}" ]] && echo 0; done
    echo 1
}

# Upper cases text
function __toUpper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'    
}